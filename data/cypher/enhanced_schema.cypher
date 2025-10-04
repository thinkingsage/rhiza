// Enhanced schema with metadata and validation

// Add metadata properties to existing nodes
MATCH (w:EnglishWord)
SET w.created_at = datetime(),
    w.updated_at = datetime(),
    w.source = 'seed_data',
    w.verified = true;

MATCH (r:GreekRoot)
SET r.created_at = datetime(),
    r.updated_at = datetime(),
    r.source = 'seed_data',
    r.verified = true;

// Add relationship metadata
MATCH (w:EnglishWord)-[rel:DERIVES_FROM]->(r:GreekRoot)
SET rel.confidence = 1.0,
    rel.created_at = datetime(),
    rel.source = 'etymological_analysis';

// Create etymology source tracking
CREATE (source:EtymologySource {
  name: 'manual_curation',
  description: 'Manually curated etymological relationships',
  reliability: 'high',
  created_at: datetime()
});

// Create category definitions for consistency
CREATE (cat1:Category {name: 'emotion', description: 'Feelings and emotional states'});
CREATE (cat2:Category {name: 'abstract_concept', description: 'Abstract ideas and concepts'});
CREATE (cat3:Category {name: 'political', description: 'Government and political systems'});
CREATE (cat4:Category {name: 'nature', description: 'Natural world and phenomena'});
CREATE (cat5:Category {name: 'academic', description: 'Academic and scholarly terms'});
CREATE (cat6:Category {name: 'psychology', description: 'Mind and psychological concepts'});
CREATE (cat7:Category {name: 'religion', description: 'Religious and spiritual concepts'});
CREATE (cat8:Category {name: 'human', description: 'Human-related concepts'});
CREATE (cat9:Category {name: 'communication', description: 'Language and communication'});
CREATE (cat10:Category {name: 'spatial', description: 'Space and location concepts'});
CREATE (cat11:Category {name: 'science', description: 'Scientific and technical terms'});
CREATE (cat12:Category {name: 'qualities', description: 'Descriptive qualities and attributes'});
CREATE (cat13:Category {name: 'social', description: 'Social relationships and structures'});
