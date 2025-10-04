// Database constraints and indexes for data integrity

// Unique constraints to prevent duplicates
CREATE CONSTRAINT english_word_name IF NOT EXISTS FOR (w:EnglishWord) REQUIRE w.name IS UNIQUE;
CREATE CONSTRAINT greek_root_transliteration IF NOT EXISTS FOR (r:GreekRoot) REQUIRE r.transliteration IS UNIQUE;

// Indexes for performance
CREATE INDEX english_word_name_index IF NOT EXISTS FOR (w:EnglishWord) ON (w.name);
CREATE INDEX greek_root_transliteration_index IF NOT EXISTS FOR (r:GreekRoot) ON (r.transliteration);
CREATE INDEX greek_root_category_index IF NOT EXISTS FOR (r:GreekRoot) ON (r.category);
CREATE INDEX greek_root_frequency_index IF NOT EXISTS FOR (r:GreekRoot) ON (r.frequency);

// Node existence constraints
CREATE CONSTRAINT english_word_name_exists IF NOT EXISTS FOR (w:EnglishWord) REQUIRE w.name IS NOT NULL;
CREATE CONSTRAINT greek_root_name_exists IF NOT EXISTS FOR (r:GreekRoot) REQUIRE r.name IS NOT NULL;
CREATE CONSTRAINT greek_root_transliteration_exists IF NOT EXISTS FOR (r:GreekRoot) REQUIRE r.transliteration IS NOT NULL;
CREATE CONSTRAINT greek_root_meaning_exists IF NOT EXISTS FOR (r:GreekRoot) REQUIRE r.meaning IS NOT NULL;
