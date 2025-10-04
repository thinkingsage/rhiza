// Complete enriched seed data - clear and reload everything

// Clear all existing data
MATCH (n) DETACH DELETE n;

// Create enriched Greek roots
MERGE (r1:GreekRoot {
  name: "φίλος", transliteration: "philos", meaning: "loving, friend",
  category: "emotion", frequency: "high", etymology_period: "classical", part_of_speech: "adjective"
});

MERGE (r2:GreekRoot {
  name: "σοφία", transliteration: "sophia", meaning: "wisdom",
  category: "abstract_concept", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r3:GreekRoot {
  name: "δῆμος", transliteration: "demos", meaning: "people",
  category: "political", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r4:GreekRoot {
  name: "κρατία", transliteration: "kratia", meaning: "rule, power",
  category: "political", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r5:GreekRoot {
  name: "λόγος", transliteration: "logos", meaning: "word, study, reason",
  category: "academic", frequency: "very_high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r6:GreekRoot {
  name: "βίος", transliteration: "bios", meaning: "life",
  category: "nature", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r7:GreekRoot {
  name: "γραφή", transliteration: "graphe", meaning: "writing",
  category: "communication", frequency: "very_high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r8:GreekRoot {
  name: "ψυχή", transliteration: "psyche", meaning: "soul, mind",
  category: "psychology", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r9:GreekRoot {
  name: "θεός", transliteration: "theos", meaning: "god",
  category: "religion", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r10:GreekRoot {
  name: "ἄνθρωπος", transliteration: "anthropos", meaning: "human",
  category: "human", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r11:GreekRoot {
  name: "γῆ", transliteration: "geo", meaning: "earth",
  category: "nature", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r12:GreekRoot {
  name: "τέχνη", transliteration: "techne", meaning: "art, skill",
  category: "skill", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r13:GreekRoot {
  name: "φόβος", transliteration: "phobos", meaning: "fear",
  category: "emotion", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r14:GreekRoot {
  name: "μικρός", transliteration: "mikros", meaning: "small",
  category: "size", frequency: "high", etymology_period: "classical", part_of_speech: "adjective"
});

MERGE (r15:GreekRoot {
  name: "τῆλε", transliteration: "tele", meaning: "far, distant",
  category: "distance", frequency: "medium", etymology_period: "classical", part_of_speech: "adverb"
});

MERGE (r16:GreekRoot {
  name: "φωνή", transliteration: "phone", meaning: "sound, voice",
  category: "communication", frequency: "high", etymology_period: "classical", part_of_speech: "noun"
});

MERGE (r17:GreekRoot {
  name: "σκοπεῖν", transliteration: "skopein", meaning: "to look, examine",
  category: "perception", frequency: "high", etymology_period: "classical", part_of_speech: "verb"
});

// Create enriched English words
MERGE (w1:EnglishWord {
  name: "philosophy", definition: "the study of fundamental questions about existence, knowledge, values",
  first_use_year: 1300, complexity_level: "advanced", field: "humanities", syllable_count: 4, modern_usage: "academic"
});

MERGE (w2:EnglishWord {
  name: "democracy", definition: "a system of government by the whole population",
  first_use_year: 1576, complexity_level: "intermediate", field: "politics", syllable_count: 4, modern_usage: "common"
});

MERGE (w3:EnglishWord {
  name: "biology", definition: "the scientific study of living organisms",
  first_use_year: 1819, complexity_level: "intermediate", field: "science", syllable_count: 4, modern_usage: "common"
});

MERGE (w4:EnglishWord {
  name: "psychology", definition: "the scientific study of mind and behavior",
  first_use_year: 1693, complexity_level: "intermediate", field: "science", syllable_count: 4, modern_usage: "common"
});

MERGE (w5:EnglishWord {
  name: "theology", definition: "the study of the nature of God and religious belief",
  first_use_year: 1362, complexity_level: "advanced", field: "religion", syllable_count: 4, modern_usage: "academic"
});

MERGE (w6:EnglishWord {
  name: "anthropology", definition: "the study of humankind",
  first_use_year: 1593, complexity_level: "advanced", field: "science", syllable_count: 5, modern_usage: "academic"
});

MERGE (w7:EnglishWord {
  name: "geography", definition: "the study of the physical features of the earth",
  first_use_year: 1540, complexity_level: "intermediate", field: "science", syllable_count: 4, modern_usage: "common"
});

MERGE (w8:EnglishWord {
  name: "technology", definition: "the application of scientific knowledge for practical purposes",
  first_use_year: 1615, complexity_level: "intermediate", field: "science", syllable_count: 4, modern_usage: "very_common"
});

MERGE (w9:EnglishWord {
  name: "phobia", definition: "an extreme or irrational fear of something",
  first_use_year: 1786, complexity_level: "intermediate", field: "psychology", syllable_count: 3, modern_usage: "common"
});

MERGE (w10:EnglishWord {
  name: "microscope", definition: "an instrument for viewing very small objects",
  first_use_year: 1656, complexity_level: "intermediate", field: "science", syllable_count: 3, modern_usage: "common"
});

MERGE (w11:EnglishWord {
  name: "telephone", definition: "a device for transmitting sound over distances",
  first_use_year: 1835, complexity_level: "basic", field: "technology", syllable_count: 3, modern_usage: "very_common"
});

MERGE (w12:EnglishWord {
  name: "biography", definition: "an account of someone's life written by someone else",
  first_use_year: 1683, complexity_level: "intermediate", field: "literature", syllable_count: 4, modern_usage: "common"
});

MERGE (w13:EnglishWord {
  name: "philosopher", definition: "a person engaged in or learned in philosophy",
  first_use_year: 1297, complexity_level: "advanced", field: "humanities", syllable_count: 4, modern_usage: "academic"
});

// Create relationships
MERGE (w1)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r1);
MERGE (w1)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r2);

MERGE (w2)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r3);
MERGE (w2)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r4);

MERGE (w3)-[:DERIVES_FROM {strength: 0.95, position: "prefix"}]->(r6);
MERGE (w3)-[:DERIVES_FROM {strength: 0.95, position: "suffix"}]->(r5);

MERGE (w4)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r8);
MERGE (w4)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r5);

MERGE (w5)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r9);
MERGE (w5)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r5);

MERGE (w6)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r10);
MERGE (w6)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r5);

MERGE (w7)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r11);
MERGE (w7)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r7);

MERGE (w8)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r12);
MERGE (w8)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r5);

MERGE (w9)-[:DERIVES_FROM {strength: 0.95, position: "root"}]->(r13);

MERGE (w10)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r14);
MERGE (w10)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r17);

MERGE (w11)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r15);
MERGE (w11)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r16);

MERGE (w12)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r6);
MERGE (w12)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r7);

MERGE (w13)-[:DERIVES_FROM {strength: 0.9, position: "prefix"}]->(r1);
MERGE (w13)-[:DERIVES_FROM {strength: 0.9, position: "suffix"}]->(r2);
