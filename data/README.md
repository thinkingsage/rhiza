# Rhiza Data Directory

This directory contains database initialization and seed data files.

## Cypher Files

### `cypher/complete_enriched_seed.cypher`
**Current production seed data** - Contains fully enriched Greek roots and English words with:
- Semantic categories (emotion, political, nature, etc.)
- Usage frequency (very_high, high, medium, low)
- Etymology periods and parts of speech
- Word definitions, first use years, and complexity levels
- Enhanced relationships with strength and position properties

**Usage:**
```bash
# Load into Neo4j
cat data/cypher/complete_enriched_seed.cypher | docker exec -i neo4j-container cypher-shell -u neo4j -p password
```

### `cypher/seed_data.cypher`
**Legacy seed data** - Original basic seed data without enriched properties. Kept for reference and testing purposes.

## Data Model

The enriched data model includes:

**Node Types:**
- `EnglishWord` - English words with etymology
- `GreekRoot` - Ancient Greek root words
- `WordFamily` - Groups of related words
- `SemanticField` - Academic/professional domains

**Relationships:**
- `DERIVES_FROM` - Word derives from root (with strength/position)
- `BELONGS_TO` - Word belongs to family
- `IN_FIELD` - Word in semantic field
- `COMMONLY_WITH` - Roots commonly used together

**Properties:**
- **Roots**: category, frequency, etymology_period, part_of_speech
- **Words**: definition, first_use_year, complexity_level, field, modern_usage
