// Rhiza Etymology Database - Initial Seed Data
// Run this in Neo4j Browser or via cypher-shell

// Clear existing data (optional)
// MATCH (n) DETACH DELETE n;

// Create Greek roots
MERGE (:GreekRoot {name: "φίλος", transliteration: "philos", meaning: "loving"})
MERGE (:GreekRoot {name: "σοφία", transliteration: "sophia", meaning: "wisdom"})
MERGE (:GreekRoot {name: "δῆμος", transliteration: "demos", meaning: "people"})
MERGE (:GreekRoot {name: "κρατία", transliteration: "kratia", meaning: "rule, power"})
MERGE (:GreekRoot {name: "λόγος", transliteration: "logos", meaning: "word, study"})
MERGE (:GreekRoot {name: "βίος", transliteration: "bios", meaning: "life"})
MERGE (:GreekRoot {name: "γραφή", transliteration: "graphe", meaning: "writing"})
MERGE (:GreekRoot {name: "ψυχή", transliteration: "psyche", meaning: "soul, mind"})
MERGE (:GreekRoot {name: "θεός", transliteration: "theos", meaning: "god"})
MERGE (:GreekRoot {name: "ἄνθρωπος", transliteration: "anthropos", meaning: "human"})
MERGE (:GreekRoot {name: "γῆ", transliteration: "geo", meaning: "earth"})
MERGE (:GreekRoot {name: "τέχνη", transliteration: "techne", meaning: "art, skill"})
MERGE (:GreekRoot {name: "φόβος", transliteration: "phobos", meaning: "fear"})
MERGE (:GreekRoot {name: "μικρός", transliteration: "mikros", meaning: "small"})
MERGE (:GreekRoot {name: "τῆλε", transliteration: "tele", meaning: "far, distant"})
MERGE (:GreekRoot {name: "φωνή", transliteration: "phone", meaning: "sound, voice"})
MERGE (:GreekRoot {name: "σκοπεῖν", transliteration: "skopein", meaning: "to look, examine"});

// Create English words and relationships
MERGE (w1:EnglishWord {name: "philosophy"})
MERGE (r1:GreekRoot {name: "φίλος"})
MERGE (r2:GreekRoot {name: "σοφία"})
MERGE (w1)-[:DERIVES_FROM]->(r1)
MERGE (w1)-[:DERIVES_FROM]->(r2);

MERGE (w2:EnglishWord {name: "democracy"})
MERGE (r3:GreekRoot {name: "δῆμος"})
MERGE (r4:GreekRoot {name: "κρατία"})
MERGE (w2)-[:DERIVES_FROM]->(r3)
MERGE (w2)-[:DERIVES_FROM]->(r4);

MERGE (w3:EnglishWord {name: "biology"})
MERGE (r5:GreekRoot {name: "βίος"})
MERGE (r6:GreekRoot {name: "λόγος"})
MERGE (w3)-[:DERIVES_FROM]->(r5)
MERGE (w3)-[:DERIVES_FROM]->(r6);

MERGE (w4:EnglishWord {name: "psychology"})
MERGE (r7:GreekRoot {name: "ψυχή"})
MERGE (w4)-[:DERIVES_FROM]->(r7)
MERGE (w4)-[:DERIVES_FROM]->(r6);

MERGE (w5:EnglishWord {name: "theology"})
MERGE (r8:GreekRoot {name: "θεός"})
MERGE (w5)-[:DERIVES_FROM]->(r8)
MERGE (w5)-[:DERIVES_FROM]->(r6);

MERGE (w6:EnglishWord {name: "anthropology"})
MERGE (r9:GreekRoot {name: "ἄνθρωπος"})
MERGE (w6)-[:DERIVES_FROM]->(r9)
MERGE (w6)-[:DERIVES_FROM]->(r6);

MERGE (w7:EnglishWord {name: "geography"})
MERGE (r10:GreekRoot {name: "γῆ"})
MERGE (r11:GreekRoot {name: "γραφή"})
MERGE (w7)-[:DERIVES_FROM]->(r10)
MERGE (w7)-[:DERIVES_FROM]->(r11);

MERGE (w8:EnglishWord {name: "technology"})
MERGE (r12:GreekRoot {name: "τέχνη"})
MERGE (w8)-[:DERIVES_FROM]->(r12)
MERGE (w8)-[:DERIVES_FROM]->(r6);

MERGE (w9:EnglishWord {name: "phobia"})
MERGE (r13:GreekRoot {name: "φόβος"})
MERGE (w9)-[:DERIVES_FROM]->(r13);

MERGE (w10:EnglishWord {name: "microscope"})
MERGE (r14:GreekRoot {name: "μικρός"})
MERGE (r15:GreekRoot {name: "σκοπεῖν"})
MERGE (w10)-[:DERIVES_FROM]->(r14)
MERGE (w10)-[:DERIVES_FROM]->(r15);

MERGE (w11:EnglishWord {name: "telephone"})
MERGE (r16:GreekRoot {name: "τῆλε"})
MERGE (r17:GreekRoot {name: "φωνή"})
MERGE (w11)-[:DERIVES_FROM]->(r16)
MERGE (w11)-[:DERIVES_FROM]->(r17);

MERGE (w12:EnglishWord {name: "biography"})
MERGE (w12)-[:DERIVES_FROM]->(r5)
MERGE (w12)-[:DERIVES_FROM]->(r11);

MERGE (w13:EnglishWord {name: "philosopher"})
MERGE (w13)-[:DERIVES_FROM]->(r1)
MERGE (w13)-[:DERIVES_FROM]->(r2);

// Create indexes for performance
CREATE INDEX english_word_name IF NOT EXISTS FOR (w:EnglishWord) ON (w.name);
CREATE INDEX greek_root_name IF NOT EXISTS FOR (r:GreekRoot) ON (r.name);
CREATE INDEX greek_root_transliteration IF NOT EXISTS FOR (r:GreekRoot) ON (r.transliteration);
