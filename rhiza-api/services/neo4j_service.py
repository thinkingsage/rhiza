import os
from neo4j import AsyncGraphDatabase
from typing import List, Dict, Optional
import structlog

logger = structlog.get_logger(__name__)

class EtymologyGraphService:
    def __init__(self):
        uri = os.environ.get("NEO4J_URI", "bolt://localhost:7687")
        user = os.environ.get("NEO4J_USER", "neo4j")
        password = os.environ.get("NEO4J_PASSWORD", "password")
        
        # Configure async connection pool settings
        self.driver = AsyncGraphDatabase.driver(
            uri, 
            auth=(user, password),
            max_connection_lifetime=3600,  # 1 hour
            max_connection_pool_size=50,   # Max connections
            connection_acquisition_timeout=60  # 60 seconds
        )
        
        logger.info("Neo4j async driver initialized with connection pooling", 
                   uri=uri, max_pool_size=50)
    
    async def create_indexes(self):
        """Create database indexes for optimal query performance"""
        async with self.driver.session() as session:
            try:
                # Index on EnglishWord.name for fast word lookups
                await session.run("CREATE INDEX english_word_name_idx IF NOT EXISTS FOR (w:EnglishWord) ON (w.name)")
                
                # Index on GreekRoot.name for fast root lookups  
                await session.run("CREATE INDEX greek_root_name_idx IF NOT EXISTS FOR (r:GreekRoot) ON (r.name)")
                
                # Index on GreekRoot.transliteration for fast transliteration lookups
                await session.run("CREATE INDEX greek_root_transliteration_idx IF NOT EXISTS FOR (r:GreekRoot) ON (r.transliteration)")
                
                logger.info("Database indexes created successfully")
            except Exception as e:
                # Try legacy syntax for older Neo4j versions
                try:
                    await session.run("CREATE INDEX ON :EnglishWord(name)")
                    await session.run("CREATE INDEX ON :GreekRoot(name)")  
                    await session.run("CREATE INDEX ON :GreekRoot(transliteration)")
                    logger.info("Database indexes created using legacy syntax")
                except Exception as legacy_error:
                    logger.warning(f"Failed to create indexes: {e}, legacy attempt: {legacy_error}")
                    # Continue without indexes - not critical for functionality
    
    async def close(self):
        await self.driver.close()
    
    async def find_word_roots(self, word: str) -> Optional[Dict]:
        """Query graph for existing word etymology with enriched properties"""
        async with self.driver.session() as session:
            result = await session.run("""
                MATCH (w:EnglishWord {name: $word})-[:DERIVES_FROM]->(r:GreekRoot)
                RETURN w.name as word, 
                       collect({
                           name: r.name,
                           transliteration: r.transliteration,
                           meaning: r.meaning,
                           category: r.category,
                           frequency: r.frequency,
                           part_of_speech: r.part_of_speech
                       }) as roots
            """, word=word.lower())
            
            record = await result.single()
            if record and record["roots"]:
                return {
                    "name": record["word"],
                    "roots": record["roots"]
                }
            return None
    
    async def store_etymology(self, word: str, roots: List[Dict]):
        """Store etymology data in graph, preserving enriched properties"""
        if not roots:
            # Store word with no roots, preserve existing properties
            async with self.driver.session() as session:
                await session.run("""
                    MERGE (w:EnglishWord {name: $word})
                """, word=word.lower())
            return
        
        async with self.driver.session() as session:
            await session.run("""
                MERGE (w:EnglishWord {name: $word})
                WITH w
                UNWIND $roots as root
                MERGE (r:GreekRoot {name: root.name})
                ON CREATE SET 
                    r.transliteration = root.transliteration,
                    r.meaning = root.meaning,
                    r.category = root.category,
                    r.frequency = root.frequency,
                    r.part_of_speech = root.part_of_speech
                ON MATCH SET 
                    r.transliteration = COALESCE(r.transliteration, root.transliteration),
                    r.meaning = COALESCE(r.meaning, root.meaning),
                    r.category = COALESCE(r.category, root.category),
                    r.frequency = COALESCE(r.frequency, root.frequency),
                    r.part_of_speech = COALESCE(r.part_of_speech, root.part_of_speech)
                MERGE (w)-[:DERIVES_FROM]->(r)
            """, word=word.lower(), roots=roots)
    
    async def get_related_words(self, root_name: str) -> List[str]:
        """Get all words that derive from a specific Greek root"""
        async with self.driver.session() as session:
            result = await session.run("""
                MATCH (r:GreekRoot)-[:DERIVES_FROM]-(w:EnglishWord)
                WHERE r.name = $root_name OR r.transliteration = $root_name
                RETURN collect(DISTINCT w.name) as words
            """, root_name=root_name)
            
            record = await result.single()
            return record["words"] if record else []
