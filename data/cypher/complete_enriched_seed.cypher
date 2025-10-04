// Clear existing data
MATCH (n) DETACH DELETE n;

// Create Greek roots with enriched properties
CREATE (philos:GreekRoot {
  name: 'φίλος',
  transliteration: 'philos',
  meaning: 'loving, friend',
  category: 'emotion',
  frequency: 'high',
  part_of_speech: 'adjective'
});

CREATE (sophia:GreekRoot {
  name: 'σοφία',
  transliteration: 'sophia',
  meaning: 'wisdom',
  category: 'abstract_concept',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (demos:GreekRoot {
  name: 'δῆμος',
  transliteration: 'demos',
  meaning: 'people',
  category: 'political',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (kratia:GreekRoot {
  name: 'κρατία',
  transliteration: 'kratia',
  meaning: 'power, rule',
  category: 'political',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (bios:GreekRoot {
  name: 'βίος',
  transliteration: 'bios',
  meaning: 'life',
  category: 'nature',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (logos:GreekRoot {
  name: 'λόγος',
  transliteration: 'logos',
  meaning: 'word, study, reason',
  category: 'academic',
  frequency: 'very_high',
  part_of_speech: 'noun'
});

CREATE (psyche:GreekRoot {
  name: 'ψυχή',
  transliteration: 'psyche',
  meaning: 'soul, mind, spirit',
  category: 'psychology',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (theos:GreekRoot {
  name: 'θεός',
  transliteration: 'theos',
  meaning: 'god',
  category: 'religion',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (anthropos:GreekRoot {
  name: 'ἄνθρωπος',
  transliteration: 'anthropos',
  meaning: 'human, person',
  category: 'human',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (geo:GreekRoot {
  name: 'γῆ',
  transliteration: 'geo',
  meaning: 'earth, land',
  category: 'nature',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (graphe:GreekRoot {
  name: 'γραφή',
  transliteration: 'graphe',
  meaning: 'writing, drawing',
  category: 'communication',
  frequency: 'high',
  part_of_speech: 'noun'
});

CREATE (an:GreekRoot {
  name: 'ἀν-',
  transliteration: 'an-',
  meaning: 'without, not',
  category: 'abstract_concept',
  frequency: 'high',
  part_of_speech: 'prefix'
});

CREATE (arche:GreekRoot {
  name: 'ἀρχή',
  transliteration: 'arche',
  meaning: 'rule, government, authority',
  category: 'political',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (hieros:GreekRoot {
  name: 'ἱερός',
  transliteration: 'hieros',
  meaning: 'sacred, holy',
  category: 'religion',
  frequency: 'medium',
  part_of_speech: 'adjective'
});

CREATE (para:GreekRoot {
  name: 'παρά',
  transliteration: 'para',
  meaning: 'beside, beyond, abnormal',
  category: 'spatial',
  frequency: 'high',
  part_of_speech: 'preposition'
});

CREATE (nous:GreekRoot {
  name: 'νοῦς',
  transliteration: 'nous',
  meaning: 'mind, intellect',
  category: 'psychology',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (pharmakon:GreekRoot {
  name: 'φάρμακον',
  transliteration: 'pharmakon',
  meaning: 'drug, medicine, poison',
  category: 'science',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (polys:GreekRoot {
  name: 'πολύς',
  transliteration: 'polys',
  meaning: 'many, much',
  category: 'qualities',
  frequency: 'high',
  part_of_speech: 'adjective'
});

CREATE (gamos:GreekRoot {
  name: 'γάμος',
  transliteration: 'gamos',
  meaning: 'marriage',
  category: 'social',
  frequency: 'medium',
  part_of_speech: 'noun'
});

CREATE (dia:GreekRoot {
  name: 'διά',
  transliteration: 'dia',
  meaning: 'through, across, apart',
  category: 'spatial',
  frequency: 'high',
  part_of_speech: 'preposition'
});

CREATE (spora:GreekRoot {
  name: 'σπορά',
  transliteration: 'spora',
  meaning: 'sowing, scattering of seed',
  category: 'nature',
  frequency: 'low',
  part_of_speech: 'noun'
});

CREATE (anti:GreekRoot {
  name: 'ἀντί',
  transliteration: 'anti',
  meaning: 'against, opposite',
  category: 'abstract_concept',
  frequency: 'high',
  part_of_speech: 'preposition'
});

// Create English words
CREATE (philosophy:EnglishWord {name: 'philosophy'});
CREATE (democracy:EnglishWord {name: 'democracy'});
CREATE (biology:EnglishWord {name: 'biology'});
CREATE (psychology:EnglishWord {name: 'psychology'});
CREATE (theology:EnglishWord {name: 'theology'});
CREATE (anthropology:EnglishWord {name: 'anthropology'});
CREATE (geography:EnglishWord {name: 'geography'});
CREATE (technology:EnglishWord {name: 'technology'});
CREATE (phobia:EnglishWord {name: 'phobia'});
CREATE (microscope:EnglishWord {name: 'microscope'});
CREATE (anarchy:EnglishWord {name: 'anarchy'});
CREATE (hierarchy:EnglishWord {name: 'hierarchy'});
CREATE (paranoia:EnglishWord {name: 'paranoia'});
CREATE (pharmacy:EnglishWord {name: 'pharmacy'});
CREATE (polygamy:EnglishWord {name: 'polygamy'});
CREATE (diaspora:EnglishWord {name: 'diaspora'});
CREATE (antimatter:EnglishWord {name: 'antimatter'});
CREATE (geology:EnglishWord {name: 'geology'});
CREATE (biography:EnglishWord {name: 'biography'});
CREATE (philanthropist:EnglishWord {name: 'philanthropist'});
CREATE (bibliophile:EnglishWord {name: 'bibliophile'});
CREATE (sophisticated:EnglishWord {name: 'sophisticated'});
CREATE (demographic:EnglishWord {name: 'demographic'});
CREATE (epidemic:EnglishWord {name: 'epidemic'});
CREATE (antibiotic:EnglishWord {name: 'antibiotic'});

// Create relationships
MATCH (philosophy:EnglishWord {name: 'philosophy'}), (philos:GreekRoot {transliteration: 'philos'}), (sophia:GreekRoot {transliteration: 'sophia'})
CREATE (philosophy)-[:DERIVES_FROM]->(philos), (philosophy)-[:DERIVES_FROM]->(sophia);

MATCH (democracy:EnglishWord {name: 'democracy'}), (demos:GreekRoot {transliteration: 'demos'}), (kratia:GreekRoot {transliteration: 'kratia'})
CREATE (democracy)-[:DERIVES_FROM]->(demos), (democracy)-[:DERIVES_FROM]->(kratia);

MATCH (biology:EnglishWord {name: 'biology'}), (bios:GreekRoot {transliteration: 'bios'}), (logos:GreekRoot {transliteration: 'logos'})
CREATE (biology)-[:DERIVES_FROM]->(bios), (biology)-[:DERIVES_FROM]->(logos);

MATCH (psychology:EnglishWord {name: 'psychology'}), (psyche:GreekRoot {transliteration: 'psyche'}), (logos:GreekRoot {transliteration: 'logos'})
CREATE (psychology)-[:DERIVES_FROM]->(psyche), (psychology)-[:DERIVES_FROM]->(logos);

MATCH (theology:EnglishWord {name: 'theology'}), (theos:GreekRoot {transliteration: 'theos'}), (logos:GreekRoot {transliteration: 'logos'})
CREATE (theology)-[:DERIVES_FROM]->(theos), (theology)-[:DERIVES_FROM]->(logos);

MATCH (anthropology:EnglishWord {name: 'anthropology'}), (anthropos:GreekRoot {transliteration: 'anthropos'}), (logos:GreekRoot {transliteration: 'logos'})
CREATE (anthropology)-[:DERIVES_FROM]->(anthropos), (anthropology)-[:DERIVES_FROM]->(logos);

MATCH (geology:EnglishWord {name: 'geology'}), (geo:GreekRoot {transliteration: 'geo'}), (logos:GreekRoot {transliteration: 'logos'})
CREATE (geology)-[:DERIVES_FROM]->(geo), (geology)-[:DERIVES_FROM]->(logos);

MATCH (biography:EnglishWord {name: 'biography'}), (bios:GreekRoot {transliteration: 'bios'}), (graphe:GreekRoot {transliteration: 'graphe'})
CREATE (biography)-[:DERIVES_FROM]->(bios), (biography)-[:DERIVES_FROM]->(graphe);

MATCH (anarchy:EnglishWord {name: 'anarchy'}), (an:GreekRoot {transliteration: 'an-'}), (arche:GreekRoot {transliteration: 'arche'})
CREATE (anarchy)-[:DERIVES_FROM]->(an), (anarchy)-[:DERIVES_FROM]->(arche);

MATCH (hierarchy:EnglishWord {name: 'hierarchy'}), (hieros:GreekRoot {transliteration: 'hieros'}), (arche:GreekRoot {transliteration: 'arche'})
CREATE (hierarchy)-[:DERIVES_FROM]->(hieros), (hierarchy)-[:DERIVES_FROM]->(arche);

MATCH (paranoia:EnglishWord {name: 'paranoia'}), (para:GreekRoot {transliteration: 'para'}), (nous:GreekRoot {transliteration: 'nous'})
CREATE (paranoia)-[:DERIVES_FROM]->(para), (paranoia)-[:DERIVES_FROM]->(nous);

MATCH (pharmacy:EnglishWord {name: 'pharmacy'}), (pharmakon:GreekRoot {transliteration: 'pharmakon'})
CREATE (pharmacy)-[:DERIVES_FROM]->(pharmakon);

MATCH (polygamy:EnglishWord {name: 'polygamy'}), (polys:GreekRoot {transliteration: 'polys'}), (gamos:GreekRoot {transliteration: 'gamos'})
CREATE (polygamy)-[:DERIVES_FROM]->(polys), (polygamy)-[:DERIVES_FROM]->(gamos);

MATCH (diaspora:EnglishWord {name: 'diaspora'}), (dia:GreekRoot {transliteration: 'dia'}), (spora:GreekRoot {transliteration: 'spora'})
CREATE (diaspora)-[:DERIVES_FROM]->(dia), (diaspora)-[:DERIVES_FROM]->(spora);

MATCH (antimatter:EnglishWord {name: 'antimatter'}), (anti:GreekRoot {transliteration: 'anti'})
CREATE (antimatter)-[:DERIVES_FROM]->(anti);

MATCH (philanthropist:EnglishWord {name: 'philanthropist'}), (philos:GreekRoot {transliteration: 'philos'})
CREATE (philanthropist)-[:DERIVES_FROM]->(philos);

MATCH (bibliophile:EnglishWord {name: 'bibliophile'}), (philos:GreekRoot {transliteration: 'philos'})
CREATE (bibliophile)-[:DERIVES_FROM]->(philos);

MATCH (sophisticated:EnglishWord {name: 'sophisticated'}), (sophia:GreekRoot {transliteration: 'sophia'})
CREATE (sophisticated)-[:DERIVES_FROM]->(sophia);

MATCH (demographic:EnglishWord {name: 'demographic'}), (demos:GreekRoot {transliteration: 'demos'})
CREATE (demographic)-[:DERIVES_FROM]->(demos);

MATCH (epidemic:EnglishWord {name: 'epidemic'}), (demos:GreekRoot {transliteration: 'demos'})
CREATE (epidemic)-[:DERIVES_FROM]->(demos);

MATCH (antibiotic:EnglishWord {name: 'antibiotic'}), (bios:GreekRoot {transliteration: 'bios'})
CREATE (antibiotic)-[:DERIVES_FROM]->(bios);
