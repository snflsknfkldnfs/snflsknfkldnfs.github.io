# GPG-PATA-Ebene: Selbst-Überwachung für GPG-Unterrichtsentwicklung

---
typ: meta_meta_prozess
anwendungsbereich: Automatische Selbst-Kontrolle aller GPG-Aktionen
priorität: HÖCHSTE
bearbeitungsstand: Sofort produktiv
letzte_aktualisierung: "2025-06-24"
autor: "GPG-System-Selbst-Korrektur"
version: "1.0.0"
basiert_auf: WiB_PATA_PATA_Standards
---

## KRITISCHES GPG-SELBST-MONITORING: Automatische Überwachung der eigenen GPG-Standards

### ⚠️ GPG-ZWANGS-CHECK vor JEDER Aktion:

```
GPG-PRE-ACTION-ZWANGSCHECK:
1. "Ist Schulbuch-Referenz (GPG5 Trio Seitenzahl) angegeben?"
2. "Sind DaZ/LRS-Anpassungen berücksichtigt?"
3. "Ist Fachintegration (Geschichte/Politik/Geographie) gewährleistet?"
4. "Sind HTML-Artefakte iPad-ausfüllbar?"
5. "Befolge ich meine GPG-PATA-Standards?"
6. "BUV-CHECK: Ist Lernziel transparent für 5b formuliert?"
7. "BUV-CHECK: Sind maximal 3 Materialtypen verwendet?"
8. "BUV-CHECK: Ist roter Faden/Kohärenz erkennbar?"
9. "BUV-CHECK: Basiert das auf bewährten Strukturen?"
10. "BUV-CHECK: Ist Tafelbild-Entwicklung integriert?"
11. "BUV-CHECK: Ist Tech-Tool sinnvoll für 5b?"
12. "BUV-CHECK: Sind SuS in ersten 10min aktiviert?"
13. "BUV-CHECK: Sind Lehrervortragsphasen ≤5min?"
```

### 🚨 GPG-VERBOTENE AKTIONEN - AUTOMATISCHE BLOCKIERUNG:

#### GPG-TUV-Erstellung VERBOTEN wenn:
- ❌ Schulbuch-Seitenbezug fehlt
- ❌ DaZ/LRS-Aspekte ignoriert
- ❌ Nur ein Fach (H oder P oder G) berücksichtigt
- ❌ HTML-Artefakte nicht iPad-kompatibel
- ❌ Heterogenität der 5b nicht beachtet
- ❌ BUV-LEARNING: Lernziel nicht transparent
- ❌ BUV-LEARNING: Mehr als 3 Materialtypen
- ❌ BUV-LEARNING: Kein erkennbarer roter Faden
- ❌ BUV-LEARNING: Innovation ohne bewährte Basis
- ❌ BUV-LEARNING: Tafelbild-Entwicklung fehlt
- ❌ BUV-LEARNING: Miro für Material-Erarbeitung
- ❌ BUV-LEARNING: Lehrervortrag länger als 5min
- ❌ BUV-LEARNING: SuS-Aktivierung später als 10min

#### GPG-ERLAUBT nur wenn:
- ✅ GPG5 Trio Seitenbezug explizit angegeben
- ✅ DaZ-sprachsensible Gestaltung
- ✅ LRS-Anpassungen integriert
- ✅ Geschichte + Politik + Geographie verknüpft
- ✅ HTML-Artefakte mit Apple Pencil ausfüllbar
- ✅ BUV-LEARNING: Lernziel in ersten 5min transparent
- ✅ BUV-LEARNING: Maximal 3 verschiedene Materialtypen
- ✅ BUV-LEARNING: Roter Faden durch alle Phasen
- ✅ BUV-LEARNING: Bewährte Strukturen als Basis
- ✅ BUV-LEARNING: Schrittweise Tafelbild-Entwicklung
- ✅ BUV-LEARNING: HTML-Website für Material-Erarbeitung
- ✅ BUV-LEARNING: SuS-Aktivierung in ersten 10min
- ✅ BUV-LEARNING: Lehrervortragsphasen ≤5min

### 🤖 GPG-AUTOMATISCHER WORKFLOW:

#### Schritt 1: SCHULBUCH-CHECK
```
BEFORE_GPG_CONTENT_CREATION:
  if (no_schulbuch_reference):
    BLOCK_CREATION = True
    REQUEST = "Bitte GPG5 Trio Seitenbezug angeben"
  else:
    PROCEED = True
```

#### Schritt 2: HETEROGENITÄTS-CHECK
```
BEFORE_MATERIAL_CREATION:
  if (no_DaZ_consideration OR no_LRS_adaptation):
    FORCE_INTEGRATION = True
    ADD_HETEROGENITY_FEATURES = True
```

#### Schritt 3: BUV-LEARNINGS-CHECK (NEU)
```
BEFORE_TUV_FINALIZATION:
  // Lernziel-Transparenz-Check
  if (lernziel_not_explicit):
    FORCE_LERNZIEL_TRANSPARENT = True
    ADD_TO_EINSTIEG = "Was können Sie nach der Stunde?"
  
  // Komplexitäts-Check
  if (materialtypen > 3):
    AUTO_REDUCE_COMPLEXITY = True
    KEEP_ONLY_ESSENTIAL_MATERIALS = True
  
  // Bewährte-Strukturen-Check  
  if (not_based_on_established_structures):
    PRIORITIZE_BAUSTEINSKRIPT = True
    SCAN_FOR_PROVEN_TEMPLATES = True
  
  // Tech-Tool-Sinnhaftigkeit-Check
  if (miro_for_material_erarbeitung):
    SUGGEST_HTML_ALTERNATIVE = True
    WARNING = "HTML-Website einfacher für 5b"
  
  // Aktivierungs-Timing-Check
  if (sus_aktivierung > 10min):
    AUTO_RESTRUCTURE_TIMING = True
    MOVE_ACTIVATION_EARLIER = True
  
  // Lehrervortrag-Länge-Check
  if (lehrervortrag > 5min):
    AUTO_SPLIT_INTO_CHUNKS = True
    ADD_ACTIVATION_BREAKS = True
```
  else:
    PROCEED_WITH_CREATION = True
```

#### Schritt 3: FACHINTEGRATIONS-CHECK
```
CHECK_FACHINTEGRATION:
  if (only_single_subject):
    DEMAND_INTEGRATION = True
    BLOCK_SINGLE_SUBJECT_APPROACH = True
  else:
    APPROVE_INTEGRATED_APPROACH = True
```

#### Schritt 4: IPAD-KOMPATIBILITÄTS-CHECK
```
HTML_ARTEFAKT_CHECK:
  if (not_ipad_compatible):
    FORCE_APPLE_PENCIL_OPTIMIZATION = True
    ADD_FILLABLE_FIELDS = True
  else:
    APPROVE_ARTEFAKT = True
```

### 🔄 GPG-SELBST-KORREKTUR-MECHANISMUS:

#### Bei erkannten GPG-Fehlern:
1. **SOFORTIGER STOPP** der fehlerhaften GPG-Aktion
2. **AUTOMATISCHE KORREKTUR**: 
   - Schulbuch-Referenz nachrüsten
   - DaZ/LRS-Anpassungen integrieren
   - Fachintegration erzwingen
   - iPad-Optimierung implementieren
3. **AUFRÄUMEN** unvollständiger GPG-Materialien
4. **LERNEN** und GPG-Standards verschärfen

#### GPG-Kontinuierliche Verbesserung:
- **Jeder Schulbuch-Referenz-Fehler** → Verstärkte Seitenbezug-Checks
- **Jede DaZ/LRS-Vernachlässigung** → Schärfere Heterogenitäts-Regeln
- **Jede Fachverengung** → Stärkere Integrations-Erzwingung
- **Jede iPad-Inkompatibilität** → Verschärfte Kompatibilitäts-Tests

### 📋 GPG-IMPLEMENTIERUNG in JEDEN Chat-Schritt:

#### Automatische GPG-Fragen vor jeder Aktion:
```
1. "SCHULBUCH: Welche GPG5 Trio Seiten sind relevant?"
2. "HETEROGENITÄT: Wie unterstütze ich DaZ/LRS-Kinder?"
3. "FACHINTEGRATION: Wie verknüpfe ich H+P+G?"
4. "IPAD: Ist das Artefakt mit Apple Pencil ausfüllbar?"
5. "KLASSE: Berücksichtige ich 5b-Spezifika?"
```

#### GPG-Zwangs-Protokoll:
- **Jede TUV-Erstellung** wird gegen alle GPG-Checks geprüft
- **Keine Ausnahmen** - auch bei Zeitdruck
- **Sofortige Korrektur** bei GPG-Regelverstoß
- **GPG-Meta-Learning** aus jedem fachspezifischen Fehler

### ⚡ GPG-SPEZIELLE REGELN für häufige Szenarien:

#### TUV-Vollausarbeitung:
```
IF (TUV_Entwicklung):
  SCHULBUCH_REFERENCE = "MANDATORY GPG5 Trio S.XXX"
  FACHINTEGRATION = "Geschichte UND Politik UND Geographie"
  DaZ_LRS_ADAPTATION = "AUTOMATIC_INTEGRATION"
  HTML_ARTEFAKTE = "IPAD_OPTIMIZED_MANDATORY"
```

#### BUV-Entwicklung:
```
IF (BUV_Entwicklung):
  HABU_INTEGRATION = "MANDATORY_SCENARIO"
  MIRO_DIGITAL_TOOLS = "REQUIRED"
  EXTENDED_TIMELINE = "90+ Minutes"
  FACHINTEGRATION = "DEEP_H_P_G_CONNECTION"
```

#### HTML-Artefakt-Erstellung:
```
IF (HTML_Artefakt):
  APPLE_PENCIL = "MANDATORY_COMPATIBILITY"
  FILLABLE_FIELDS = "REQUIRED"
  DaZ_LANGUAGE = "SIMPLE_CLEAR_GERMAN"
  LRS_ADAPTATION = "LARGER_FONTS_LESS_TEXT"
```

#### Schulbuch-Integration:
```
IF (Schulbuch_Usage):
  PAGE_REFERENCE = "EXPLICIT_S.XXX_REQUIRED"
  TASK_INTEGRATION = "SCHULBUCH_AUFGABEN_REFERENCED"
  CONTENT_ALIGNMENT = "SCHULBUCH_CONTENT_BASED"
```

## 🎯 GPG-SELBST-EVALUATION-LOOP:

### Nach jeder GPG-Aktion:
1. **"Habe ich GPG5 Trio Seitenbezug korrekt angegeben?"**
2. **"Sind DaZ/LRS-Kinder optimal unterstützt?"**
3. **"Ist Geschichte+Politik+Geographie sinnvoll integriert?"**
4. **"Sind alle HTML-Artefakte iPad-ausfüllbar?"**
5. **"Entspricht das den 5b-Klassenspezifika?"**

### GPG-Kontinuierliche Verbesserung:
- **Jeder Schulbuch-Fehler** führt zu schärferen Referenz-Checks
- **Jede Heterogenitäts-Lücke** verschärft DaZ/LRS-Regeln
- **Jede Fach-Verengung** verstärkt Integrations-Erzwingung
- **Jede iPad-Inkompatibilität** verschärft Kompatibilitäts-Tests

### 🎪 GPG-SPEZIFISCHE QUALITÄTS-GATEKEEPER:

#### Schulbuch-Integration-Gatekeeper:
```
SCHULBUCH_CHECK:
  if (no_page_reference):
    BLOCK_PUBLICATION = True
    DEMAND = "GPG5 Trio S.XXX Reference"
  if (no_task_integration):
    REQUIRE = "Schulbuch-Aufgaben Integration"
```

#### Fachintegrations-Gatekeeper:
```
FACH_INTEGRATION_CHECK:
  if (only_Geschichte OR only_Politik OR only_Geographie):
    BLOCK_SINGLE_SUBJECT = True
    ENFORCE = "H+P+G Integration"
  else:
    APPROVE_INTEGRATION = True
```

#### Heterogenitäts-Gatekeeper:
```
HETEROGENITY_CHECK:
  if (no_DaZ_features):
    ADD_LANGUAGE_SUPPORT = True
  if (no_LRS_adaptations):
    ADD_READING_SUPPORT = True
  if (no_differentiation):
    ADD_LEVEL_VARIATIONS = True
```

#### iPad-Kompatibilitäts-Gatekeeper:
```
IPAD_CHECK:
  if (not_fillable):
    ADD_INPUT_FIELDS = True
  if (not_pencil_compatible):
    OPTIMIZE_FOR_HANDWRITING = True
  if (not_responsive):
    ADD_MOBILE_OPTIMIZATION = True
```

## 🚀 GPG-AUTOMATISCHE KORREKTUR-ALGORITHMEN:

### Auto-Schulbuch-Integration:
```
IF (missing_schulbuch_reference):
  AUTO_ADD = "Basierend auf GPG5 Trio, S. [RELEVANT_PAGES]"
  CROSS_REFERENCE = "Siehe Schulbuch-Aufgaben S.XXX"
```

### Auto-Heterogenitäts-Features:
```
IF (missing_DaZ_support):
  AUTO_ADD = "Sprachsensible Formulierungen"
  AUTO_ADD = "Visualisierungs-Elemente"
IF (missing_LRS_support):
  AUTO_ADD = "Größere Schriftarten"
  AUTO_ADD = "Reduzierte Textmenge"
```

### Auto-Fachintegration:
```
IF (single_subject_detected):
  AUTO_SUGGEST = "Geschichte-Verbindung: Chronologie"
  AUTO_SUGGEST = "Politik-Verbindung: Demokratie-Aspekte"
  AUTO_SUGGEST = "Geographie-Verbindung: Raumverständnis"
```

### Auto-iPad-Optimierung:
```
IF (not_ipad_optimized):
  AUTO_ADD = "Apple Pencil kompatible Eingabefelder"
  AUTO_ADD = "Touch-freundliche Buttons"
  AUTO_ADD = "Responsive Design für iPad-Bildschirm"
```

---

**AKTIVIERT: Ab sofort läuft dieser GPG-Selbst-Überwachungs-Layer bei JEDER GPG-Aktion!**

**GPG-GARANTIE: Keine TUV ohne Schulbuch-Bezug, keine Materialien ohne DaZ/LRS-Anpassung, keine HTML-Artefakte ohne iPad-Optimierung!**

**FACHINTEGRATIONS-GARANTIE: Geschichte + Politik + Geographie werden automatisch verknüpft!**