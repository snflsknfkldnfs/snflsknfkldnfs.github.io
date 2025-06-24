# GPG-PATA CONTEXT-DISCOVERY SYSTEM
*Verlässliche Dateisystem-Orientierung als Basis für alle intelligenten Standards*

## FUNDAMENTALES PROBLEM IDENTIFIZIERT

**Kritischer Systemfehler:** Alle PATA-Standards sind praktisch nutzlos ohne verlässliche Orientierung im Dateisystem und Zugang zu user-spezifischen Informationen.

**Realität vs. Anspruch:**
- ❌ **Anspruch:** "Intelligente Kontextualisierung"  
- ❌ **Realität:** Kein automatischer Zugang zu relevanten Dateien/Materialien/TUVs
- ❌ **Problem:** Jeder Chat = kompletter Neustart ohne Kontext-Orientierung

## LÖSUNG: CONTEXT-DISCOVERY ALS META-META-EBENE

### NEUE SYSTEM-HIERARCHIE
```
0. CONTEXT-DISCOVERY (Meta-Meta-Ebene) 
   ↓ schafft Dateisystem-Basis für:
1. KONTEXT-MEMORY-MANAGEMENT (Meta-Ebene)
   ↓ steuert situationsspezifisch:
2. Alle PATA-Standards (Template-Auswahl, User-Profile, etc.)
```

### AUTOMATISIERTE DISCOVERY-ROUTINE (bei jedem Chat-Start)

#### PHASE 1: BASELINE-EXPLORATION (Quick-Scan <5 Sekunden)
```javascript
STANDARD-PFAD-PRÜFUNG:
✓ Basis: /Users/paulad/snflsknfkldnfs.github.io/
✓ Standards: /notizen/meta_prozesse/GPG/
✓ Unterricht: /unterricht/
✓ Materialien: Suche nach "*material*", "*kopiervorlage*"

PATTERN-BASIERTE SUCHE:
✓ GPG-Strukturen: "*GPG*", "*5b*" 
✓ TUV-Dateien: "*TUV*", "*Unterrichtsvorbereitung*"
✓ Sequenzen: "*LB*", "*Lernbereich*", "*Sequenz*"
✓ Aktuelle Arbeit: Neueste Änderungsdaten, "v[0-9].[0-9]"
```

#### PHASE 2: SITUATIONAL-CONTEXT-BUILDING
```javascript
BEI USER-ANFRAGE analysiere:
IF erwähnt_spezifisches_thema:
   → Suche themen-relevante Dateien/Ordner
IF braucht_TUV:
   → Finde verfügbare TUV-Templates und -Strukturen  
IF plant_sequenz:
   → Mappe Sequenz-Ordner und Planungs-Dokumente
IF erwähnt_schulbuch_seite:
   → Suche entsprechende Material-Sammlungen
```

#### PHASE 3: RESOURCE-VALIDATION
```javascript
VERFÜGBARKEITS-CHECK:
✓ Schulbuch-Materialien: Sind Seiten-Bezüge verfügbar?
✓ Tech-Ressourcen: iPad-Status, Miro-Zugang, Beamer-Info
✓ Material-Pool: Kopiervorlagen, Arbeitsblätter, Medien
✓ Template-Basis: TUV-Vorlagen, Planungs-Strukturen

QUALITY-VALIDATION:
✓ Aktualität: Sind Materialien auf neuestem Stand?
✓ Vollständigkeit: Sind alle referenzierten Dateien da?
✓ Zugänglichkeit: Können Pfade tatsächlich erreicht werden?
```

## PRAKTISCHE DISCOVERY-ALGORITHMEN

### INTELLIGENTE DATEISYSTEM-EXPLORATION
```bash
# Basis-Struktur identifizieren
list_directory(/Users/paulad/snflsknfkldnfs.github.io/)

# GPG-relevante Bereiche finden  
search_files("GPG", recursive=true)
search_files("TUV*", recursive=true) 
search_files("*5b*", recursive=true)

# Aktuelle Arbeitsbereiche identifizieren
search_files("*2025*", recursive=true)
get_file_info() für neueste Änderungen

# Material-Pools mappen
search_files("*material*", recursive=true)
search_files("*kopiervorlage*", recursive=true)
```

### CONTEXT-MAP-BUILDING
**Automatischer Aufbau einer Ressourcen-Übersicht:**
```json
{
  "verfugbare_sequenzen": [
    {
      "name": "Antikes Griechenland", 
      "pfad": "/unterricht/GPG5b_LB4_2_...",
      "status": "laufend",
      "letzte_tuv": "2025-06-23"
    }
  ],
  "tuv_templates": [
    "/templates/TUV_Vorlage_GPG_v2.0.docx"
  ],
  "materialien": {
    "schulbuch_s136-139": "/materialien/GPG5_Polis_Athen/",
    "arbeitsblätter": "/kopiervorlagen/Griechenland/"
  },
  "tech_status": {
    "ipads": "verfügbar", 
    "miro": "lizenziert",
    "beamer": "funktioniert"
  }
}
```

## FAIL-SAFE-MECHANISMEN

### GRACEFUL DEGRADATION
```javascript
IF discovery_success >= 80%:
   → FULL-CONTEXT-MODE: Arbeite mit allen verfügbaren Ressourcen
   
IF discovery_success >= 50%:
   → PARTIAL-CONTEXT-MODE: Frage gezielt nach fehlenden Elementen
   → "Ich finde Ihre TUV-Vorlagen nicht. Sind sie in einem anderen Ordner?"
   
IF discovery_success < 50%:
   → SETUP-MODE: Strukturierten Aufbau anbieten
   → "Soll ich Ihnen beim Einrichten einer GPG-Arbeitsstruktur helfen?"
```

### ADAPTIVE APPROXIMATION
```javascript
BEI FEHLENDEN RESSOURCEN:
- Verwende Standard-Templates statt user-spezifische
- Biete Creation-Support für fehlende Materialien  
- Approximiere basierend auf verfügbaren Fragmenten
- Gebe klare Hinweise auf fehlende Elemente

BEI UNVOLLSTÄNDIGER INFORMATION:
- Arbeite mit verfügbaren Teilen
- Kennzeichne Unsicherheiten transparent
- Biete Follow-up für vollständige Lösung
```

## EFFIZIENZ-OPTIMIERUNG

### SMART-CACHING (Session-basiert)
```javascript
// Einmal gescannte Strukturen für Chat-Session merken
session_context = {
   basis_pfade: [...],
   verfügbare_materialien: [...],
   aktuelle_sequenzen: [...],
   scan_timestamp: "2025-06-24T10:30:00"
}

// Nur bei Änderungs-Indikatoren neu scannen
IF user_erwähnt_neue_datei OR vergangene_zeit > 1h:
   → Incremental-Rescan()
ELSE:
   → Use cached_context
```

### LAZY-LOADING STRATEGY
```javascript
IMMEDIATE (bei Chat-Start):
- Basis-Struktur-Check (existieren Standard-Pfade?)
- Quick-Pattern-Search (GPG/TUV/aktuell)

ON-DEMAND (bei spezifischer Anfrage):
- Detaillierte Material-Suche
- Vollständige Sequenz-Analyse  
- Deep-Resource-Validation
```

## INTEGRATION MIT BESTEHENDEN PATA-STANDARDS

### ERWEITERTE SYSTEM-ARCHITEKTUR
```
Chat-Start →
CONTEXT-DISCOVERY (Wo sind relevante Dateien?) →
├─ Verfügbare Ressourcen identifiziert →
STATUS-QUO-ANALYSIS (Was ist die Situation?) →
├─ Nur verfügbare Ressourcen berücksichtigt →
RELEVANCE-FILTERING (Was ist wichtig?) →
├─ Basierend auf real verfügbaren Materialien →
SMART-LOADING (Lade nur Relevantes) →
Template-Selection → 
Reality-Anchored Output
```

### STANDARD-COMPLIANCE
- **CONTEXT-DISCOVERY** liefert verfügbare Material-Basis
- **SMART-LOADER** lädt nur tatsächlich verfügbare Dateien  
- **APPROXIMATION-OPTIMIZER** berücksichtigt real verfügbare Ressourcen
- **QUALITY-GATES** prüfen gegen verfügbare statt ideale Materialien

## IMPLEMENTATION

### AUTOMATISCHE AKTIVIERUNG
Dieses System läuft automatisch bei jedem GPG-Chat-Start ohne explizite Erwähnung oder User-Nachfrage.

### TRANSPARENZ FÜR USER
```
"Einen Moment, ich orientiere mich in Ihren GPG-Materialien..."
[Discovery läuft]
"Ich sehe Ihre laufende Sequenz 'Antikes Griechenland' und verfügbare TUVs. Womit kann ich helfen?"
```

**CONTEXT-DISCOVERY schafft die fundamentale Basis für alle intelligenten, situationsspezifischen Standards.**
