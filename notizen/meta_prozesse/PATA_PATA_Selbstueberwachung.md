# PATA-PATA-Ebene: Selbst-Überwachungs-Layer

---
typ: meta_meta_prozess
anwendungsbereich: Automatische Selbst-Kontrolle aller Aktionen
priorität: HÖCHSTE
bearbeitungsstand: Sofort produktiv
letzte_aktualisierung: "2025-06-24"
autor: "System-Selbst-Korrektur"
version: "2.0.0"
---

## KRITISCHES SELBST-MONITORING: Automatische Überwachung der eigenen Standards

### ⚠️ ZWANGS-CHECK vor JEDER Dateiaktion:

```
PRE-ACTION-ZWANGSCHECK:
1. "Existiert bereits eine Datei zu diesem Thema?"
2. "Soll ich EDITIEREN oder NEU ERSTELLEN?"
3. "Bin ich im Git-Repository-Kontext?"
4. "Befolge ich meine eigenen PATA-Standards?"
```

### 🚨 VERBOTENE AKTIONEN - AUTOMATISCHE BLOCKIERUNG:

#### Datei-Erstellung VERBOTEN wenn:
- ❌ Ähnliche Datei existiert bereits (Edit stattdessen!)
- ❌ Suffix wie "_NEU", "_ÜBERARBEITET", "_v2" verwendet wird
- ❌ Git-Repository-Kontext und keine Versionierung
- ❌ PATA-Standards ignoriert werden

#### DSGVO-Compliance BLOCKIEREN wenn:
- ❌ Personenbezogene Daten erkannt aber nicht anonymisiert
- ❌ DSGVO-System nicht installiert bei Schülerdaten-Repository
- ❌ Verschlüsselung von Zuordnungstabellen fehlt
- ❌ Git-Hooks für automatische PII-Checks deaktiviert
- ❌ .gitignore nicht DSGVO-konform (Mappings nicht ausgeschlossen)

#### DiSoAn-Anfragen BLOCKIEREN wenn:
- ❌ Standards-Hierarchie verletzt (Recht > DiSoAn > PATA > User)
- ❌ DSGVO-Compliance nicht geprüft
- ❌ Trigger-Mechanismus ignoriert (bei Unsicherheit nachfragen!)
- ❌ Systemtheoretische Reflexion übersprungen

#### ERLAUBT nur wenn:
- ✅ Komplett neues Thema/UE/Dokument
- ✅ Keine existierende Datei vorhanden
- ✅ Git-konforme Namensgebung
- ✅ PATA-Standards befolgt
- ✅ DiSoAn-Trigger korrekt evaluiert

### 🤖 AUTOMATISCHER WORKFLOW:

#### Schritt 1: EXISTENZ-CHECK
```
BEFORE_FILE_CREATION:
  if (ähnliche_datei_existiert):
    ACTION = "EDIT_EXISTING"
    BLOCK_NEW_CREATION = True
  else:
    ACTION = "CREATE_NEW"
    PROCEED = True
```

#### Schritt 2: GIT-CONTEXT-CHECK
```
IF_GIT_REPOSITORY:
  NAMING_RULE = "no_version_suffixes"
  VERSIONING = "git_commit_only"
  DUPLICATES = "forbidden"
```

#### Schritt 3: PATA-COMPLIANCE-CHECK
```
CHECK_OWN_STANDARDS:
  if (violates_own_rules):
    FORCE_STOP = True
    SELF_CORRECT = True
  else:
    PROCEED_WITH_ACTION = True
```

### 🔄 SELBST-KORREKTUR-MECHANISMUS:

#### Bei erkannten Fehlern:
1. **SOFORTIGER STOPP** der fehlerhaften Aktion
2. **AUTOMATISCHE KORREKTUR** (Edit statt Neu-Erstellung)
3. **AUFRÄUMEN** bereits erstellter fehlerhafter Dateien
4. **LERNEN** und PATA-Standards verschärfen

#### Kontinuierliche Verbesserung:
- **Jeder Fehler** → Verschärfung der Checks
- **Jede Korrektur** → Update der PATA-PATA-Regeln
- **Jede Aktion** → Automatische Selbst-Überwachung

### 📋 IMPLEMENTIERUNG in JEDEN Chat-Schritt:

#### Automatische Fragen vor jeder Dateiaktion:
```
1. "EXISTENZ: Gibt es schon eine Datei zu diesem Thema?"
2. "KONTEXT: Bin ich in einem Git-Repository?"
3. "STANDARD: Befolge ich meine PATA-Regeln?"
4. "AKTION: Edit oder Neu-Erstellung angemessen?"
```

#### Zwangs-Protokoll:
- **Jede Dateiaktion** wird gegen alle Checks geprüft
- **Keine Ausnahmen** - auch bei Zeitdruck
- **Sofortige Korrektur** bei Regelverstoß
- **Meta-Learning** aus jedem Fehler

### ⚡ SPEZIELLE REGELN für häufige Szenarien:

#### Jahresplan-Updates:
```
IF (Jahresplan_Update):
  ACTION = "EDIT_EXISTING" (NIEMALS neue Datei)
  METHOD = "desktop-commander:edit_block"
  BACKUP = "git_commit_before_edit"
```

#### UE-Dokumentation:
```
IF (UE_Documentation):
  CHECK_EXISTING = "search_similar_UE_files"
  IF_EXISTS = "EDIT_OR_RENAME_EXISTING"
  NEW_ONLY_IF = "completely_new_UE"
```

#### Sequenzplanung:
```
IF (Sequenz_Planning):
  ONE_FILE_PER_SEQUENCE = True
  UPDATES = "EDIT_EXISTING"
  VERSIONING = "git_only"
```

#### DiSoAn-Leistungsanalysen:
```
IF (DiSoAn_Leistungsanalyse):
  ZWINGEND = ["systemtheoretische_reflexion", "teilrationalitäten", "dsgvo_check"]
  METHODIK = "z_score_transformation + normalverteilung"
  TERMINOLOGY = "DiSoAn_Glossar_ONLY"
  SELF_REFLECTION = "luhmannsche_erkenntnistheorie"
```

## 🎯 SELBST-EVALUATION-LOOP:

### Nach jeder Aktion:
1. **"Habe ich meine eigenen Standards befolgt?"**
2. **"War die Dateiaktion Git-Repository-konform?"**
3. **"Würde der User diese Lösung als 'intelligent' bewerten?"**
4. **"Muss ich meine PATA-PATA-Regeln verschärfen?"**

### Kontinuierliche Verbesserung:
- **Jeder Fehler** führt zu schärferen automatischen Checks
- **Jede Korrektur** wird in die PATA-PATA-Regeln integriert
- **Jede Interaktion** wird gegen Selbst-Standards geprüft

---

**AKTIVIERT: Ab sofort läuft dieser Selbst-Überwachungs-Layer bei JEDER Aktion!**

**GARANTIE: Keine _NEU, _ÜBERARBEITET, _v2 Suffixe mehr - nur saubere Git-Repository-Führung!**