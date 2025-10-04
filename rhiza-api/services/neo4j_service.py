import os
from neo4j import GraphDatabase
from typing import List, Dict, Optional
import structlog

logger = structlog.get_logger(__name__)

class EtymologyGraphService:
    def __init__(self):
        uri = os.environ.get("NEO4J_URI", "bolt://localhost:7687")
        user = os.environ.get("NEO4J_USER", "neo4j")
        password = os.environ.get("NEO4J_PASSWORD", "password")
        
        # Configure connection pool settings
        self.driver = GraphDatabase.driver(
            uri, 
            auth=(user, password),
            max_connection_lifetime=3600,  # 1 hour
            max_connection_pool_size=50,   # Max connections
            connection_acquisition_timeout=60  # 60 seconds
        )
        
        logger.info("Neo4j driver initialized with connection pooling", 
                   uri=uri, max_pool_size=50)
    
    def close(self):
        self.driver.close()
    
    def find_word_roots(self, word: str) -> Optional[Dict]:
        """Query graph for existing word etymology"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (w:EnglishWord {name: $word})-[:DERIVES_FROM]->(r:GreekRoot)
                RETURN w.name as word, 
                       collect({
                           name: r.name,
                           transliteration: r.transliteration,
                           meaning: r.meaning
                       }) as roots
            """, word=word.lower())
            
            record = result.single()
            if record:
                return {
                    "name": record["word"],
                    "roots": record["roots"]
                }
            return None
    
    def store_etymology(self, word: str, roots: List[Dict]) -> bool:
        """Store AI-generated etymology in graph"""
        with self.driver.session() as session:
            try:
                session.run("""
                    MERGE (w:EnglishWord {name: $word})
                    WITH w
                    UNWIND $roots as root
                    MERGE (r:GreekRoot {
                        name: root.name,
                        transliteration: root.transliteration,
                        meaning: root.meaning
                    })
                    MERGE (w)-[:DERIVES_FROM]->(r)
                """, word=word.lower(), roots=roots)
                return True
            except Exception as e:
                print(f"Error storing etymology: {e}")
                return False
    
    def get_related_words(self, root_name: str) -> List[str]:
        """Find all words that derive from a specific Greek root"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (r:GreekRoot {name: $root_name})<-[:DERIVES_FROM]-(w:EnglishWord)
                RETURN w.name as word
            """, root_name=root_name)
            
            return [record["word"] for record in result]
