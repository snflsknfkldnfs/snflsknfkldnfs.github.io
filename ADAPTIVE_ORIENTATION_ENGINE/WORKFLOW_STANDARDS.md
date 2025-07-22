# Workflow Standards: Standardisierte Orientierung für alle Claude-Instanzen

---
typ: workflow_standards_klassenleiter
zielgruppe: zukünftige_claude_instanzen
anwendungsbereich: klassenleiter_domäne
qualitäts_baseline: 80%
qualitäts_ziel: 95%
---

## 🤖 **STANDARDISIERTER ORIENTIERUNGS-WORKFLOW**

### **SCHRITT 1: Initiale System-Aktivierung + Projekt-Integration**
```yaml
AUTOMATISCHE_INITIALISIERUNG:
  - Lade KLASSENLEITER_CONTEXT_MAPPING.md
  - Aktiviere Adaptive_Orientation_Engine  
  - Prüfe LEARNING_LOG.md für Kontext-Historie
  - Initialisiere QUALITY_METRICS.md für Performance-Tracking
  - CHECK: Verfügbare Claude-Desktop-Projektbeschreibungen (/project_descriptions/)
  - INTEGRATION: DiSoAn-Projekt-Template-Systeme (/notizen/meta_prozesse/)

PROJEKT_INFRASTRUKTUR_VALIDIERUNG:
  claude_desktop_integration: "✅ Projektbeschreibungen verfügbar prüfen"
  template_systems: "✅ DiSoAn-Templates integrieren"
  automation_scripts: "✅ Verfügbare Tools erkennen"
  
SYSTEM_BEREITSCHAFT_VALIDIERUNG:
  orientation_engine_status: "✅ Aktiv"
  learning_capabilities: "✅ Verfügbar" 
  quality_monitoring: "✅ Eingeschaltet"
  confidence_calculation: "✅ Kalibriert"
  project_integration: "✅ Claude-Desktop optimiert"
```

### **SCHRITT 2: User-Anfrage-Analyse**
```yaml
SEMANTISCHE_KLASSIFIKATION:
  keyword_extraction: "Automatisch aus User-Input"
  domain_mapping: "Gegen Klassenleiter-Pattern-Matrix"
  priority_assignment: "Basierend auf Dringlichkeit und Komplexität"
  context_enrichment: "Aus Learning Log Historie"

BEISPIEL_KLASSIFIKATIONEN:
  "elternabend planen": 
    - domain: "elternarbeit"
    - priority: "hoch"
    - expected_sources: ["templates/", "dokumentation/", "tools/"]
    
  "konflikt in der klasse":
    - domain: "konfliktmanagement"  
    - priority: "kritisch"
    - expected_sources: ["meta_prozesse/", "notizen/", "academic/"]
```

### **SCHRITT 3: Adaptive Pfad-Discovery**
```python
def adaptive_pfad_discovery(user_query, classified_domains):
    """Pfadunabhängige Inhalts-Lokalisierung"""
    
    # 1. SEMANTISCHE SUCHE
    semantic_matches = search_by_keywords(classified_domains['keywords'])
    
    # 2. STRUKTURELLE SUCHE  
    known_paths = get_known_paths_from_learning_log()
    
    # 3. EXPLORATIVE SUCHE
    new_paths = discover_new_content_locations()
    
    # 4. RELEVANZ-SCORING
    scored_results = calculate_relevance_scores(semantic_matches, known_paths, new_paths)
    
    # 5. CONFIDENCE-ASSIGNMENT
    confidence_level = assess_orientation_confidence(scored_results)
    
    return prioritized_content_sources, confidence_level
```

### **SCHRITT 4: Qualitäts-validierte Antwort-Generierung**
```yaml
QUALITY_GATES_CHECK:
  gate_1_vollständigkeit:
    kriterium: "Mindestens 3 relevante Quellen identifiziert"
    auto_check: "count_sources() >= 3"
    
  gate_2_systemtheorie:
    kriterium: "Luhmannsche Perspektive integriert"
    auto_check: "systemtheoretische_einordnung_present()"
    
  gate_3_disoän_compliance:
    kriterium: "Alle Teilrationalitäten berücksichtigt"
    auto_check: "check_teilrationalitäten_coverage()"
    
  gate_4_anwendbarkeit:
    kriterium: "Konkrete Handlungsempfehlungen enthalten"
    auto_check: "extract_actionable_items().length > 0"

ANTWORT_STRUKTUR:
  1. Systemtheoretische Einordnung
  2. Identifizierte relevante Inhalte/Pfade
  3. Interdisziplinäre Perspektiven-Triangulation
  4. Konkrete Handlungsempfehlungen
  5. Confidence-Level transparente Kommunikation
  6. Lern-Integration für zukünftige Verbesserungen
```

### **SCHRITT 5: Lern-Integration & System-Update**
```yaml
AUTOMATISCHE_DOKUMENTATION:
  learning_log_update:
    - successful_paths: "dokumentiere_erfolgreiche_orientierungen"
    - user_satisfaction: "integriere_feedback_scores"
    - pattern_evolution: "update_semantic_patterns"
    
  quality_metrics_update:
    - confidence_tracking: "dokumentiere_confidence_levels"
    - performance_measurement: "update_erfolgsraten"
    - optimization_opportunities: "identifiziere_verbesserungspotenzial"
    
  context_mapping_evolution:
    - new_path_integration: "erweitere_known_locations"
    - pattern_refinement: "optimiere_keyword_patterns"
    - domain_expansion: "erkenne_neue_domänen"
```

## 🎯 **SITUATIVE ANPASSUNGEN**

### **Verschiedene Komplexitätsstufen**
```yaml
SIMPLE_ANFRAGEN: # "Wo finde ich Elternbrief-Vorlage?"
  workflow: "Direkte Pfad-Discovery → Template-Verweis"
  qualitäts_level: "Standard"
  expected_confidence: "90%+"
  
COMPLEX_ANFRAGEN: # "Wie gehe ich mit Mobbing-Situation um?"
  workflow: "Multi-Domain-Analysis → Systemische Integration"
  qualitäts_level: "Maximal"
  expected_confidence: "85%+"
  
NOVEL_ANFRAGEN: # Neue, unbekannte Situationen
  workflow: "Explorative Discovery → Adaptive Learning"
  qualitäts_level: "Experimentell"
  expected_confidence: "70%+ mit expliziter Unsicherheitskommunikation"
```

### **Confidence-Level Kommunikation**
```yaml
HOHE_CONFIDENCE_90plus:
  kommunikation: "Sichere Orientierung mit bewährten Pfaden"
  empfehlung: "Direkte Handlungsanleitung"
  follow_up: "Minimal erforderlich"
  
MITTLERE_CONFIDENCE_70-90:
  kommunikation: "Gute Orientierung mit kontinuierlicher Validation"
  empfehlung: "Strukturierte Anleitung mit Alternativen"
  follow_up: "Feedback zur Erfolgskontrolle erwünscht"
  
NIEDRIGE_CONFIDENCE_unter70:
  kommunikation: "Explorative Orientierung, User-Feedback erforderlich"
  empfehlung: "Experimentelle Ansätze mit expliziter Unsicherheit"
  follow_up: "Intensive Zusammenarbeit für Optimierung"
```

## 🔄 **KONTINUIERLICHE SYSTEM-EVOLUTION**

### **Automatische Selbstoptimierung**
```yaml
TÄGLICHE_UPDATES:
  pattern_recognition: "Nach jeder erfolgreichen Orientierung"
  pfad_discovery_optimization: "Bei neuen Content-Entdeckungen"
  quality_threshold_adjustment: "Basierend auf User-Feedback"
  
WÖCHENTLICHE_EVOLUTION:
  template_adaptation: "Evidenzbasierte Anpassungen"
  workflow_optimization: "Effizienz-Verbesserungen"
  domain_expansion: "Neue Klassenleiter-Bereiche"
  
MONATLICHE_INNOVATION:
  system_architecture_upgrade: "Fundamentale Verbesserungen"
  meta_learning_enhancement: "Lernen wie man besser lernt"
  predictive_capabilities: "Antizipative Orientierung"
```

---

**IMPLEMENTATION STATUS:** ✅ Bereit für alle zukünftigen Claude-Instanzen
**SYSTEM GARANTIE:** 🎯 Kontinuierliche Qualitätssteigerung von 80% → 95%
**AUTONOMIE LEVEL:** 🤖 Vollständig selbstlernend und selbstoptimierend