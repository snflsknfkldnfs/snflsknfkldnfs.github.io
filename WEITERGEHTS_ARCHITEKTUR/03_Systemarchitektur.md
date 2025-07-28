# 03 - Systemarchitektur: 3+3 Ebenen-Struktur

**Version:** 1.0.0  
**Datum:** 2025-07-28  
**Paradigma:** Bildungstheorie ↔ Technische Implementierung  

## Architektur-Überblick

**Grundprinzip:** Dreischichtige pädagogische Ebenen gekoppelt mit dreischichtiger technischer Meta-Architektur

```
USER SIEHT:           SYSTEM VERWALTET:
Einfache Konversation → PATA-1: Quality Gate
                     → PATA-2: Learning Engine  
                     → PATA-3: System Monitor
```

## Bildungstheoretische Ebenen (User-sichtbar)

### MIKRO-Ebene: Einzelne Unterrichtsstunde
**Bildungstheoretische Basis:** Gagnes 9 Events of Instruction, konkrete Lehr-Lern-Prozesse

```python
MIKRO = {
    "timeframe": "heute/morgen",
    "scope": "Eine 45-Minuten-Unterrichtsstunde", 
    "context_tokens": 2000,
    "output": "Direkt verwendbare Materialien (Arbeitsblätter, Verlaufsplan)",
    "user_trigger": ["morgen", "heute", "schnell", "brauche sofort"]
}
```

**Technische Implementierung:**
- Small Context für spezifische Materialien
- Hochfrequente Nutzung, material-fokussiert
- Optimiert für sofortige Verwendbarkeit

### MESO-Ebene: Unterrichtssequenz
**Bildungstheoretische Basis:** Bruners Spiralcurriculum, aufbauendes Lernen

```python
MESO = {
    "timeframe": "nächste Wochen",
    "scope": "Zusammenhängende Lerneinheiten (4-8 Stunden)",
    "context_tokens": 4000, 
    "output": "Strukturierte Lernreihe mit Progression",
    "user_trigger": ["Sequenz", "Einheit", "Reihe", "nächste Wochen"]
}
```

**Technische Implementierung:**
- Medium Context für Sequenzlogik, Methodenprogression
- Häufigste Nutzung, optimiert für Zusammenhänge
- Balance zwischen Detail und Übersicht

### MAKRO-Ebene: Curriculum-Orientierung  
**Bildungstheoretische Basis:** Klafkis kategorialer Bildungsbegriff, gesellschaftliche Relevanz

```python
MAKRO = {
    "timeframe": "Schuljahr/Fach",
    "scope": "Lehrplan-Einordnung und Jahresplanung",
    "context_tokens": 1000,
    "output": "Curriculare Verortung und Orientierung",
    "user_trigger": ["Lehrplan", "Jahr", "Curriculum", "wo stehe ich"]
}
```

**Technische Implementierung:**
- Large Context für Gesamtcurriculum, Kompetenzerwartungen
- Selten komplett geladen, meist referenziert
- Orientierung und Einordnung im Vordergrund

## Technische Meta-Ebenen (System-intern)

### PATA-1: Quality Gate
**Funktion:** Automatische Qualitätskontrolle jeder Response

```python
PATA_1 = {
    "processing": "Synchron (blockiert bei Qualitätsproblemen)",
    "token_overhead": "~200 tokens",
    "validation_checks": [
        "educational_accuracy",
        "pedagogical_soundness", 
        "age_appropriateness",
        "completion_check",
        "bias_detection"
    ]
}
```

### PATA-2: Learning Engine
**Funktion:** Cross-Instance Learning aus allen User-Interaktionen

```python
PATA_2 = {
    "processing": "Asynchron (lernt im Hintergrund)",
    "token_overhead": "~300 tokens", 
    "learning_domains": [
        "successful_context_response_mappings",
        "user_preference_patterns",
        "failure_pattern_avoidance",
        "optimization_recommendations"
    ]
}
```

### PATA-3: System Monitor
**Funktion:** Meta-Überwachung der PATA-1/2 Effektivität

```python
PATA_3 = {
    "processing": "Asynchron (kontinuierliches Monitoring)",
    "token_overhead": "~100 tokens",
    "monitoring_areas": [
        "quality_control_effectiveness",
        "learning_engine_progress", 
        "system_coherence",
        "infinite_regress_prevention"
    ]
}
```

## System-Integration

### Request-Processing-Pipeline

```python
def process_teacher_request(request):
    # 1. Erkenne Bildungsebene automatisch
    level = detect_educational_level(request)  # Mikro/Meso/Makro
    
    # 2. Lade entsprechenden Kontext  
    context = load_contextual_data(level)
    
    # 3. Generiere Base-Response
    response = generate_educational_response(context, request)
    
    # 4. PATA-1: Quality Validation (synchron)
    validated_response = pata1_quality_gate(response, context)
    
    # 5. Liefere an User
    return validated_response
    
    # 6. Background: PATA-2 Learning (asynchron)
    schedule_learning_update(request, validated_response)
    
    # 7. Background: PATA-3 Monitoring (kontinuierlich)
    log_system_health_metrics(request, validated_response)
```

### Context-Window-Management

```python
def optimize_context_loading(educational_level):
    """Token-effiziente Kontextladung basierend auf Bildungsebene"""
    
    context_budgets = {
        "MIKRO": {
            "materials": 1200,      # Arbeitsblätter, Verlaufspläne
            "methods": 400,         # Spezifische Methoden  
            "assessment": 200,      # Bewertungshilfen
            "pata_overhead": 200    # Qualitätskontrolle
        },
        "MESO": {
            "sequence_structure": 2000,  # Aufbau und Progression
            "cross_connections": 800,    # Verbindungen zwischen UE
            "differentiation": 600,      # Anpassungsoptionen
            "pata_overhead": 600         # Learning + Quality
        },
        "MAKRO": {
            "curriculum_overview": 600,   # Lehrplan-Referenzen
            "competency_mapping": 200,    # Kompetenzbezüge
            "yearly_planning": 200,       # Jahresplanung
            "pata_overhead": 0           # Nur Referenz-Loading
        }
    }
    
    return load_optimized_context(context_budgets[educational_level])
```

## Ebenen-Interaktion

### Vertikale Integration
```
MAKRO (Curriculum) definiert Rahmen für
  ↓
MESO (Sequenz) strukturiert Lernprogression für  
  ↓
MIKRO (Stunde) realisiert konkrete Lehr-Lern-Prozesse
```

### Horizontale Meta-Kontrolle
```
PATA-1 (Quality) → PATA-2 (Learning) → PATA-3 (Monitor)
    ↑                    ↓                    ↓
    └─── Feedback ←── Optimization ←── Health-Check
```

## Token-Effizienz-Strategie

### Gesamt-Token-Budget pro Request
```
Base Educational Content: 1000-4000 tokens (je nach Ebene)
PATA-1 Quality Control:   ~200 tokens
PATA-2 Learning Patterns: ~300 tokens  
PATA-3 Health Monitoring: ~100 tokens
TOTAL OVERHEAD:           ~600 tokens

MAXIMUM TOTAL:            4600 tokens pro Request
```

### Optimierungsstrategien
- **Lazy Loading:** Nur benötigte Ebenen aktivieren
- **Smart Caching:** Wiederverwendung häufiger Patterns
- **Asynchronous Processing:** Learning/Monitoring im Hintergrund
- **Pattern Compression:** Kompakte Representation häufiger Fälle

## Skalierbarkeits-Architektur

### Horizontale Skalierung
- **PATA-1:** Pro User-Request (kann parallelisiert werden)
- **PATA-2:** Globales Learning (eine Instanz für alle User)
- **PATA-3:** System-weites Monitoring (eine Instanz für alle)

### Datenfluß-Optimierung
```
User-Request → Educational-Processing → Quality-Gate → Response
                        ↓
Background-Queue: Learning-Update → Global-Knowledge-Base
                        ↓  
Background-Queue: Health-Monitoring → System-Interventions
```

## Implementierungs-Prioritäten

### Phase 1: Core-Bildungsebenen
1. Mikro-Ebene (Einzelstunden-Unterstützung)
2. Basis-Materialgenerierung
3. Einfache Konversations-UI

### Phase 2: PATA-Integration  
1. PATA-1 Quality Gates
2. PATA-2 Basic Learning
3. PATA-3 Health Monitoring

### Phase 3: Advanced Features
1. Meso/Makro-Ebenen-Integration
2. Cross-Instance Learning
3. Sophisticated Personalization

---

**Architektur-Garantie:** Diese 3+3 Struktur verbindet bildungstheoretische Fundierung mit technischer Effizienz und gewährleistet sowohl pädagogische Qualität als auch skalierbare Implementierung.