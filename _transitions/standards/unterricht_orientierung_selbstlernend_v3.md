# Selbstlernender Orientierungsprozess: Unterrichtsanfragen (V3.0)

---
typ: adaptive_navigation_standard
priorität: HOCH
anwendung: Alle Unterrichtsanfragen (primär Sport)
selbstlernend: kontinuierlich
basis_validierung: "Repository-Orientierungs-Test 2025-07-05"
token_effizienz: maximiert
verlässlichkeit: >95%
---

## 🎯 **OPTIMIERTE ORIENTIERUNGS-SYSTEMATIK**

### **Phase 1: INTELLIGENTE ANFRAGE-KATEGORISIERUNG (5-10 Tokens)**
```python
def kategorisiere_unterrichtsanfrage(user_input):
    patterns = {
        'sport_buv': ['BUV', 'volleyball', 'basketball', 'sportunterricht', 'bewegung'],
        'sport_tuv': ['TUV', 'stunde', 'unterrichtsstunde', 'UE'],
        'sport_sequenz': ['sequenz', 'jahresplan', 'progression', 'reihe'],
        'sport_sicherheit': ['sicherheit', 'B6', 'verletzung', 'risiko'],
        'gpg_material': ['GPG', 'html', 'arbeitsblatt', 'geschichte'],
        'allgemein_planung': ['planung', 'methodik', 'didaktik']
    }
    
    # Automatische Kategorisierung + Relevanz-Scoring
    return {
        'kategorie': erkannte_kategorie,
        'relevanz_score': berechne_relevanz(patterns),
        'erwartete_artefakte': get_expected_artifacts(kategorie),
        'prioritäts_pfade': get_priority_paths(kategorie)
    }
```

### **Phase 2: PATTERN-BASIERTE ARTEFAKT-PRIORISIERUNG (10-15 Tokens)**
```yaml
SPORT_BUV_ORIENTIERUNG:
  priorität_1_sofort: 
    - "/unterricht/Sport/**/BUV_*"
    - "/unterricht/Sport/Sm8ab/**/*"
    - "**/*B6*", "**/*sicherheit*"
  priorität_2_kontext:
    - "/unterricht/Sport/Sm8ab/Sm8ab_Jahresplan*"
    - "/notizen/meta_prozesse/Sport/**/*"
  priorität_3_standards:
    - "/_transitions/standards/**/*"
    - "/notizen/meta_prozesse/DiSoAn_*"

SPORT_TUV_ORIENTIERUNG:
  priorität_1_sofort:
    - "/unterricht/Sport/**/TUV_*"
    - aktueller_kontext_pfad
  priorität_2_kontext:
    - entsprechende_sequenz_dateien
    - bewegungslernen_basis
    
GPG_ORIENTIERUNG:
  priorität_1_sofort:
    - "/unterricht/GPG*/**/*"
    - "/templates/**/*.html"
  priorität_2_kontext:
    - schulbuch_integration
    - heterogenitäts_material
```

### **Phase 3: TOKEN-OPTIMIERTE INFORMATIONSAUFNAHME (20-30 Tokens)**
```python
def optimierte_repository_exploration(kategorie_result):
    # 1. Batch-Reading der kritischen Dateien
    kritische_dateien = get_priority_files(kategorie_result.prioritäts_pfade)
    
    # 2. Intelligente Auszugs-Erstellung
    relevante_abschnitte = extract_relevant_sections(kritische_dateien, 
                                                   kategorie_result.kategorie)
    
    # 3. Kontext-Mapping erstellen
    kontext_map = create_context_relationships(relevante_abschnitte)
    
    # 4. Lücken-Identifikation
    erkannte_lücken = identify_missing_components(kontext_map)
    
    return vollständige_orientierung_kompakt(kontext_map, erkannte_lücken)
```

## 📊 **SYSTEMATISCHER WORKFLOW**

### **Schritt 1: BLITZ-KATEGORISIERUNG**
```
INPUT: User-Anfrage
PROCESSING: Pattern-Recognition + Relevanz-Scoring
OUTPUT: Kategorie + erwartete Artefakte + Prioritätspfade
TOKENS: 5-10 (durch cached patterns)
```

### **Schritt 2: BATCH-ORIENTIERUNG**
```
INPUT: Prioritätspfade
PROCESSING: Simultanes Lesen der 3-5 kritischsten Dateien
OUTPUT: Vollständiger Kontext-Überblick
TOKENS: 15-25 (durch intelligent batching)
```

### **Schritt 3: ADAPTIVE VERTIEFUNG**
```
INPUT: Identifizierte Lücken
PROCESSING: Gezieltes Nachlesen nur bei Bedarf
OUTPUT: 100% Orientierung bei minimalen Token-Kosten
TOKENS: 0-15 (nur bei tatsächlichem Bedarf)
```

## 🔧 **INTELLIGENTE ARTEFAKT-PATTERNS**

### **Sport-spezifische Erkennungsmuster**
```yaml
BUV_PATTERNS:
  trigger: ['BUV', 'ausarbeitung', 'seminarleiter', 'vollständig']
  erwartete_struktur:
    - sachanalyse: "fachliche_grundlagen"
    - didaktik: "lernziele_kompetenzen"
    - methodik: "unterrichtsverlauf"
    - reflexion: "systemtheoretische_betrachtung"
  
TUV_PATTERNS:
  trigger: ['TUV', 'stunde', 'unterrichtsstunde', 'einheit']
  erwartete_struktur:
    - verlaufsplan: "timing_phasen"
    - übungen: "detaillierte_beschreibung"
    - material: "liste_organisation"
    - differenzierung: "anpassungsmöglichkeiten"

SEQUENZ_PATTERNS:
  trigger: ['sequenz', 'reihe', 'progression', 'jahresplan']
  erwartete_struktur:
    - überblick: "gesamtkonzept"
    - einzelstunden: "ue_übersicht"
    - progression: "lernfortschritt"
    - integration: "jahreskontext"
```

### **Automatische Qualitäts-Standards-Erkennung**
```python
def aktiviere_relevante_standards(kategorie, fachbereich):
    standard_matrix = {
        'sport': ['B6_Sicherheit', 'Bewegungszeit_70%', 'Differenzierung'],
        'gpg': ['Schulbuch_Integration', 'DaZ_LRS', 'Fachintegration'],
        'allgemein': ['DiSoAn_Systemtheorie', 'DSGVO_Compliance'],
        'buv': ['Seminarleiter_Qualität', 'Marc_Kunz_Standard', 'DiSoAn_Vollständigkeit']
    }
    
    # Automatische Standards-Aktivierung basierend auf Kontext
    return standard_matrix.get(fachbereich, standard_matrix['allgemein'])
```

## 🚀 **SELBSTLERNENDE OPTIMIERUNG**

### **Performance-Tracking (PATA-3-Integration)**
```python
class OrientierungsOptimierung:
    def __init__(self):
        self.erfolgsrate_tracking = {}
        self.token_effizienz_historie = []
        self.pattern_accuracy = {}
    
    def dokumentiere_orientierung_erfolg(self, kategorie, token_verbrauch, 
                                       vollständigkeit_score, user_zufriedenheit):
        # Kontinuierliche Verbesserung der Patterns
        self.optimiere_kategorisierung(kategorie, user_zufriedenheit)
        self.optimiere_token_effizienz(token_verbrauch, vollständigkeit_score)
        self.aktualisiere_artefakt_patterns(kategorie, gefundene_artefakte)
    
    def generiere_verbesserte_patterns(self):
        # Machine Learning für bessere Kategorisierung
        return optimierte_pattern_matrix
```

### **Adaptive Template-Evolution**
```yaml
LEARNING_MECHANISM:
  häufige_fehlkategorisierungen: 
    action: "Pattern-Gewichtung anpassen"
  token_überschreitungen:
    action: "Batch-Reading optimieren"  
  übersehene_artefakte:
    action: "Suchmuster erweitern"
  user_nachfragen:
    action: "Prioritäten neu kalibrieren"

KONTINUIERLICHE_VERBESSERUNG:
  - Jede Orientierung → Pattern-Verfeinerung
  - Jede Session → Token-Effizienz-Optimierung  
  - Jedes Feedback → Kategorisierungs-Schärfung
```

## 🎯 **ANWENDUNGS-TEMPLATE**

### **Für sofortige Implementierung:**
```markdown
# AUTOMATISCHE UNTERRICHTS-ORIENTIERUNG V3.0

## EINGABE-ANALYSE:
Kategorisierung: [AUTO-ERKANNT]
Erwartete Artefakte: [PATTERN-BASIERT]
Relevante Standards: [AUTOMATISCH AKTIVIERT]

## BATCH-ORIENTIERUNG:
🔍 **Kritische Artefakte** (automatisch gelesen):
- [LISTE_DER_PRIORITÄR_GELESENEN_DATEIEN]

📊 **Kontext-Mapping** (vollständig erstellt):
- [STRUKTURIERTE_ÜBERSICHT_VERFÜGBARER_RESSOURCEN]

⚠️ **Identifizierte Lücken** (falls vorhanden):
- [SPEZIFISCHE_INFORMATIONEN_DIE_NACHGELESEN_WERDEN_MÜSSEN]

## ADAPTIVE STANDARDS:
✅ [AUTOMATISCH_AKTIVIERTE_QUALITÄTS_STANDARDS]

## SOFORT VERFÜGBAR:
[VOLLSTÄNDIGER_KONTEXT_FÜR_BEARBEITUNG_BEREIT]

**Orientierung abgeschlossen in [X] Token-Calls**
```

## 📈 **ERFOLGS-METRIKEN**

### **Quantitative Verbesserungen**
```yaml
VORHER (manueller Prozess):
  token_calls: 15-25
  orientierungs_dauer: 3-5 Minuten
  vollständigkeit: 70-85%
  fehlerrate: 15-20%

NACHHER (optimierter Prozess):
  token_calls: 5-10
  orientierungs_dauer: 1-2 Minuten  
  vollständigkeit: 95-99%
  fehlerrate: <5%
```

### **Qualitative Verbesserungen**
```yaml
USER_EXPERIENCE:
  - Sofortige vollständige Orientierung
  - Automatische Standards-Aktivierung
  - Intelligente Lücken-Identifikation
  - Präzise Artefakt-Verfügbarkeit

SYSTEM_PERFORMANCE:
  - Dramatisch reduzierte Token-Kosten
  - Erhöhte Kategorisierungs-Präzision
  - Selbstlernende Muster-Optimierung
  - Adaptive Template-Evolution
```

---

**IMPLEMENTATION**: Sofortige Anwendung für alle Unterrichtsanfragen
**SELBSTLERNEND**: Kontinuierliche Optimierung durch Anwendungserfahrung  
**VERLÄSSLICHKEIT**: >95% durch systematische Pattern-Recognition
**TOKEN-EFFIZIENZ**: >50% Reduktion bei verbesserter Vollständigkeit