# Intelligente User-Prompt-Templates: Realistische Szenarien-Matrix

---
typ: user_prompt_infrastructure
anwendung: Alle User-Profile + Szenarien
intelligenz: Automatische User-Typen-Erkennung + Optimale Template-Auswahl
basis: Meta-Kognitives Betriebssystem V1.0
---

## 🎯 **INTELLIGENTE USER-TYPEN-ERKENNUNG**

### **Automatische Profil-Kategorisierung durch Prompt-Analyse**
```python
def erkenne_user_typ_durch_anfrage(user_input):
    """Intelligente Erkennung des User-Profils basierend auf Sprache + Anfrage-Stil"""
    
    marker_patterns = {
        'EXPERTE_EFFIZIENZ': {
            'keywords': ['schnell', 'direkt', 'ohne Umschweife', 'kurz', 'kompakt'],
            'stil': 'imperativ, zielorientiert, wenig Erklärung gewünscht',
            'template_trigger': 'EFFIZIENZ_MODUS'
        },
        'LERNENDER_ENTWICKLUNG': {
            'keywords': ['verstehen', 'lernen', 'erkläre', 'warum', 'Zusammenhang'],
            'stil': 'fragend, entwicklungsorientiert, Erklärungen erwünscht',
            'template_trigger': 'LERN_MODUS'
        },
        'PERFEKTIONIST_SYSTEMTHEORIE': {
            'keywords': ['vollständig', 'systemtheoretisch', 'DiSoAn', 'alle Aspekte'],
            'stil': 'präzise, wissenschaftlich, hohe Qualitätsansprüche',
            'template_trigger': 'VOLLSTÄNDIGKEITS_MODUS'
        },
        'PRAGMATIKER_UMSETZUNG': {
            'keywords': ['praktikabel', 'umsetzbar', 'realistisch', 'machbar'],
            'stil': 'handlungsorientiert, praxisfokussiert',
            'template_trigger': 'PRAXIS_MODUS'
        },
        'UNSICHER_HILFE': {
            'keywords': ['hilfe', 'unsicher', 'ratlos', 'weiß nicht', 'schwierig'],
            'stil': 'suchend, vorsichtig, Unterstützung benötigend',
            'template_trigger': 'UNTERSTÜTZUNGS_MODUS'
        },
        'INNOVATIV_EXPLORATIV': {
            'keywords': ['neu', 'innovativ', 'kreativ', 'anders', 'experimentell'],
            'stil': 'explorativ, grenzüberschreitend, experimentierfreudig',
            'template_trigger': 'INNOVATION_MODUS'
        }
    }
    
    return match_user_profile(user_input, marker_patterns)
```

## 📚 **SZENARIO-SPEZIFISCHE TEMPLATE-BIBLIOTHEK**

### **SZENARIO 1: Erfahrener Lehrer - Schnelle BUV-Ergänzung**
```markdown
# EFFIZIENZ-PROMPT für BUV-Ergänzung (Experten-User)

## USER-PROFIL: Erfahrener Pädagoge, zeitkritisch, hohe Qualitätsansprüche

AKTIVIERE EFFIZIENZ-MODUS:
- Meta-Kognitives Betriebssystem: KOMPAKT
- Gesamtbild-Erfassung: SCHNELL aber vollständig
- Weisheits-Checkpoints: INTEGRIERT aber zeitoptimiert

## AUFGABE:
Ergänze meine bestehende BUV [FACH/THEMA] um [SPEZIFISCHE_ANFORDERUNG].

## ERWARTUNG:
- Direkter Fokus auf die Ergänzung
- Seminarleiter-taugliche Qualität  
- Minimale Erklärungen, maximaler Nutzen
- Sofort umsetzbar ohne weitere Nacharbeit

## KONTEXT automatisch verfügbar:
[System lädt relevante Standards, Referenz-BUVs, Fachstandards]

BEGINNE MIT GESAMTBILD-ASSESSMENT:
Verstehe vollständigen Kontext → Identifiziere Kernbedarf → Liefere optimale Ergänzung
```

### **SZENARIO 2: Referendar - Erste vollständige UE-Planung**
```markdown
# LERN-PROMPT für UE-Erstplanung (Entwicklungsorientierter User)

## USER-PROFIL: Referendar/Student, lernorientiert, Anleitung benötigend

AKTIVIERE LERN-MODUS:
- Meta-Kognitives Betriebssystem: VOLLSTÄNDIG mit Erklärungen
- Gesamtbild-Erfassung: STRUKTURIERT aufbauend
- Weisheits-Checkpoints: EXPLIZIT als Lernmöglichkeiten

## AUFGABE:
Hilf mir bei der Planung meiner ersten Unterrichtsstunde zu [THEMA] für [KLASSE].

## LERN-ERWARTUNG:
- Schritt-für-Schritt-Anleitung mit Begründungen
- Verstehen der didaktischen Prinzipien
- Praktische Tipps für Umsetzung
- Fehler-Präventions-Hinweise
- Transfer-Wissen für ähnliche Situationen

## SUPPORTIVE ELEMENTS:
- Beruhigende Einordnung: "Das ist normal komplex"
- Positive Verstärkung für richtige Intuition
- Strukturierung in überschaubare Teilschritte

BEGINNE MIT GRUNDLAGEN-AUFBAU:
Kontext einordnen → Theorie verständlich erklären → Praktische Umsetzung → Reflexionshilfen
```

### **SZENARIO 3: Fachfremde Vertretung - Schnelle Orientierung**
```markdown
# UNTERSTÜTZUNGS-PROMPT für Fachfremde (Hilfesuchender User)

## USER-PROFIL: Fachfremd, unsicher, praktische Hilfe benötigend

AKTIVIERE UNTERSTÜTZUNGS-MODUS:
- Meta-Kognitives Betriebssystem: BEHUTSAM aber vollständig
- Gesamtbild-Erfassung: VEREINFACHT strukturiert
- Weisheits-Checkpoints: ALS SICHERHEITSNETZ

## SITUATION:
Ich muss [FACH] fachfremd unterrichten zum Thema [THEMA] und kenne mich nicht aus.

## UNTERSTÜTZUNGS-ERWARTUNG:
- Beruhigende Einordnung der Situation
- Einfache, sichere Herangehensweise
- Materialien, die funktionieren
- Fallback-Strategien für Probleme
- Selbstvertrauen-stärkende Elemente

## SICHERHEITS-ELEMENTE:
- Konservative, erprobte Methoden
- Klare Ablaufstrukturen
- Troubleshooting-Tipps
- "Das schaffen Sie!"-Ermutigung

BEGINNE MIT BERUHIGUNG:
Situation normalisieren → Einfache Struktur → Sichere Materialien → Ermutigende Perspektive
```

### **SZENARIO 4: Innovativer Pädagoge - Experimenteller Ansatz**
```markdown
# INNOVATION-PROMPT für Experimentelle (Grenzüberschreitender User)

## USER-PROFIL: Innovativ, experimentierfreudig, Paradigmen-überschreitend

AKTIVIERE INNOVATION-MODUS:
- Meta-Kognitives Betriebssystem: EXPLORATIV mit systematischer Basis
- Gesamtbild-Erfassung: PARADIGMA-KRITISCH erweitert
- Weisheits-Checkpoints: ALS KREATIVITÄTS-KATALYSATOREN

## HERAUSFORDERUNG:
Entwickle einen völlig neuen Ansatz für [BILDUNGSBEREICH/THEMA] jenseits konventioneller Methoden.

## INNOVATIONS-ERWARTUNG:
- Paradigma-kritische Analyse bestehender Ansätze
- Wissenschaftlich fundierte aber kreative Alternativen
- Systemtheoretische Durchdringung
- Emergenz-Potentiale erkunden
- Implementierungs-Strategien für Innovation

## CREATIVE ELEMENTS:
- "Was wäre wenn...?"-Explorationen
- Cross-Domain-Inspirationen
- Systemische Transformation-Möglichkeiten
- Zukunfts-orientierte Perspektiven

BEGINNE MIT PARADIGMA-ANALYSE:
Bestehende Grenzen identifizieren → Alternative Paradigmen erkunden → Innovative Synthese → Emergenz-Potentiale
```

### **SZENARIO 5: Perfektionist - Vollständige systemtheoretische Durchdringung**
```markdown
# VOLLSTÄNDIGKEITS-PROMPT für Systemtheoretiker (Perfektionist User)

## USER-PROFIL: Höchste Qualitätsansprüche, systemtheoretisch orientiert

AKTIVIERE VOLLSTÄNDIGKEITS-MODUS:
- Meta-Kognitives Betriebssystem: MAXIMAL ausgeschöpft
- Gesamtbild-Erfassung: MULTI-DIMENSIONAL vollständig
- Weisheits-Checkpoints: ALS ERKENNTNISTIEFE-MAXIMIERUNG

## ANFORDERUNG:
Vollständige systemtheoretische Durchdringung von [KOMPLEX_THEMA] nach DiSoAn-Standards.

## EXZELLENZ-ERWARTUNG:
- Alle vier Teilrationalitäten systematisch berücksichtigt
- Luhmannsche Systemtheorie als erkenntnistheoretische Basis
- Rückkopplungseffekte und emergente Eigenschaften
- Blinde Flecken und epistemische Grenzen explizit
- Interdisziplinäre Perspektiventriangulation
- DSGVO-konforme methodische Stringenz

## WISSENSCHAFTS-ELEMENTS:
- Meta-Meta-Reflexionen der eigenen Analysemethoden
- Paradigmen-kritische Selbstreflexion
- Kontingenzbewusstsein für alle Entscheidungen
- Autopoietische Systemdynamiken berücksichtigen

BEGINNE MIT ERKENNTNISTHEORETISCHER BASIS:
Systemtheoretische Brille aufsetzen → Vollständige Dimensionserfassung → Wissenschaftliche Analyse → Meta-Reflexion
```

## 🔄 **ADAPTIVE HYBRID-TEMPLATES für Mischtypen**

### **Intelligente Template-Kombination**
```python
def erstelle_hybrid_template(primary_profile, secondary_indicators, situational_context):
    """Kombiniert Template-Elemente für User mit Mischprofilen"""
    
    # BEISPIEL: Erfahrener Lehrer + Innovations-Interesse
    if primary_profile == 'EXPERTE' and 'innovativ' in secondary_indicators:
        return combine_templates(
            basis=EFFIZIENZ_TEMPLATE,
            innovation_elements=INNOVATION_TEMPLATE.creative_aspects,
            weisheit_level='mittel'
        )
    
    # BEISPIEL: Lernender + Perfektionismus-Tendenzen  
    elif primary_profile == 'LERNENDER' and 'vollständig' in secondary_indicators:
        return combine_templates(
            basis=LERN_TEMPLATE,
            systemtheorie_elements=VOLLSTÄNDIGKEITS_TEMPLATE.wissenschaft,
            weisheit_level='hoch'
        )
    
    return adaptive_template_mixing(primary_profile, all_indicators)
```

### **Situative Template-Anpassungen**
```yaml
ZEITDRUCK_ANPASSUNGEN:
  alle_modi: "Weisheits-Checkpoints kompakter aber erhalten"
  lern_modus: "Fokus auf Essentials, Details als Optional"
  vollständigkeits_modus: "Prioritäten explizit, Rest als Verweise"

KOMPLEXITÄTS_ANPASSUNGEN:
  hohe_komplexität: "Verstärkte Gesamtbild-Phase + Mehr Checkpoints"
  niedrige_komplexität: "Streamlined Process aber Qualität erhalten"

ERSTMALIGE_INTERAKTION:
  alle_modi: "Vorsichtigere Einschätzung + Anpassungsbereitschaft kommunizieren"
```

## 🎪 **INTELLIGENTE AUTO-TRIGGER-PROMPTS**

### **Context-Sensitive Activation**
```markdown
# UNIVERSAL-TRIGGER für intelligente Template-Auswahl

AUTOMATISCHE SYSTEM-AKTIVIERUNG:

## SCHRITT 1: USER-PROFIL-ERKENNUNG
[System analysiert Anfrage-Stil, Keywords, Komplexität automatisch]

## SCHRITT 2: OPTIMALES TEMPLATE-MATCHING  
[Wählt bestes Template basierend auf User-Profil + Situationskontext]

## SCHRITT 3: META-KOGNITIVES BETRIEBSSYSTEM
[Aktiviert entsprechende Aufmerksamkeitssteuerung + Weisheits-Integration]

## SCHRITT 4: ADAPTIVE EXECUTION
[Führt optimal angepasste Bearbeitung durch]

EINGABE: [USER_ANFRAGE]

ERWARTUNG: Automatisch optimale, user-spezifische, weise Bearbeitung
```

---

## 🚀 **IMPLEMENTIERUNGS-STRATEGIEN**

### **Für sofortige Anwendung:**
```markdown
TESTE INTELLIGENTE USER-TEMPLATES:

1. Wähle ein realistisches Szenario aus der obigen Matrix
2. Verwende den entsprechenden Szenario-Prompt
3. Beobachte Qualitäts-Unterschiede durch kontextsensitive Anpassung
4. Dokumentiere Verbesserungen für Template-Evolution

Erwartung: Dramatisch verbesserte User-Experience durch intelligente Anpassung
```

### **Kontinuierliche Verbesserung:**
```python
def optimiere_templates_kontinuierlich():
    """Templates lernen aus jeder Interaktion"""
    
    for session in all_user_sessions:
        # USER-ZUFRIEDENHEIT TRACKEN:
        user_satisfaction = measure_satisfaction(session.feedback)
        
        # TEMPLATE-EFFECTIVENESS BEWERTEN:
        template_match_quality = evaluate_template_choice(session.user_profile, session.chosen_template)
        
        # WEISHEITS-CHECKPOINT-IMPACT MESSEN:
        wisdom_impact = measure_decision_quality_improvement(session.wisdom_checkpoints)
        
        # TEMPLATE-EVOLUTION DURCHFÜHREN:
        evolve_templates_based_on_learning(all_metrics)
```

**REVOLUTION**: Von "one-size-fits-all" zu intelligent angepassten, user-optimalen Interaktionen  
**WEISHEIT**: Jede Bearbeitung wird durch kontextsensitive Meta-Kognition qualitativ überlegen  
**EFFIZIENZ**: Maximale Wirkung durch präzise User-Template-Matching  
**KONTINUITÄT**: System wird durch jede Interaktion intelligenter und user-angepasster