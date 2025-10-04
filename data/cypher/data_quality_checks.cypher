// Data quality monitoring queries

// Check for orphaned nodes
MATCH (w:EnglishWord)
WHERE NOT (w)-[:DERIVES_FROM]->()
RETURN 'Orphaned English words' as issue, count(w) as count, collect(w.name)[..5] as examples;

MATCH (r:GreekRoot)
WHERE NOT ()<-[:DERIVES_FROM]-(r)
RETURN 'Unused Greek roots' as issue, count(r) as count, collect(r.transliteration)[..5] as examples;

// Check for missing required properties
MATCH (w:EnglishWord)
WHERE w.name IS NULL OR w.name = ''
RETURN 'English words missing name' as issue, count(w) as count;

MATCH (r:GreekRoot)
WHERE r.transliteration IS NULL OR r.transliteration = '' OR
      r.meaning IS NULL OR r.meaning = '' OR
      r.category IS NULL OR r.category = ''
RETURN 'Greek roots missing required properties' as issue, count(r) as count;

// Check for duplicate relationships
MATCH (w:EnglishWord)-[r:DERIVES_FROM]->(root:GreekRoot)
WITH w, root, count(r) as rel_count
WHERE rel_count > 1
RETURN 'Duplicate relationships' as issue, count(*) as count, 
       collect(w.name + ' -> ' + root.transliteration)[..5] as examples;

// Validate category values
MATCH (r:GreekRoot)
WHERE NOT r.category IN ['emotion', 'abstract_concept', 'political', 'nature', 'academic', 
                        'psychology', 'religion', 'human', 'communication', 'spatial', 
                        'science', 'qualities', 'social']
RETURN 'Invalid categories' as issue, count(r) as count, collect(DISTINCT r.category) as invalid_categories;

// Validate frequency values
MATCH (r:GreekRoot)
WHERE NOT r.frequency IN ['very_high', 'high', 'medium', 'low']
RETURN 'Invalid frequencies' as issue, count(r) as count, collect(DISTINCT r.frequency) as invalid_frequencies;
