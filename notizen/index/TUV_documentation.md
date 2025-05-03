# Dokumentation: Automatisierte TUV-Übersicht

Diese Dokumentation beschreibt das System zur automatischen Generierung einer Übersicht aller Unterrichtsvorbereitungen (TUVs) im Repository.

## Überblick

Das System besteht aus zwei Hauptkomponenten:

1. **TUV-Übersicht Generator** (`generate_tuv_overview.js`): Ein Node.js-Script, das alle TUV-Dateien im Repository findet, Metadaten extrahiert und eine strukturierte Markdown-Übersicht generiert.

2. **Workflow-Integration** (`update-tuv-workflow.sh`): Ein Bash-Script zur Integration des Generators in den bestehenden Workflow, inklusive optionalem Git Pre-Commit Hook.

## Funktionsweise

### TUV-Erkennung

Der Generator sucht TUV-Dateien anhand folgender Kriterien:

- **Pfade**: Alle `.md`-Dateien in den Verzeichnissen `/notizen/gpg`, `/notizen/wib` und `/unterricht`
- **Dateinamen**: Dateien, die bestimmte Muster im Namen enthalten (`_UE_`, `_TB_`, `_TUV_`)

### Metadaten-Extraktion

Für jede TUV-Datei werden Metadaten aus verschiedenen Quellen extrahiert:

1. **Frontmatter**: YAML-Metadaten am Anfang der Datei (höchste Priorität)
2. **Dateiname**: Informationen aus dem Dateinamen (z.B. Jahrgangsstufe, Thema)
3. **Pfadstruktur**: Informationen aus dem Dateipfad (z.B. Fach)
4. **Dateiinhalt**: Titel aus der ersten Überschrift

Extrahierte Metadaten umfassen:
- Titel
- Fach (GPG, WiB, etc.)
- Jahrgangsstufe
- Thema
- Materialtyp (Unterrichtseinheit, Tafelbild, etc.)
- Letztes Änderungsdatum

### Übersichtsstruktur

Die generierte Übersicht (`notizen/index/TUV_Uebersicht.md`) enthält:

1. **Filterbereich**: Links zu Listen nach Fach, Jahrgangsstufe und Materialtyp
2. **Statistikbereich**: Anzahl der Materialien nach Fach
3. **Fachspezifische Übersichten**: Strukturiert nach Jahrgangsstufen mit Tabellen
4. **Aktualisierungsbereich**: Die zuletzt bearbeiteten TUVs

## Metadaten-Schema

Für optimale Ergebnisse sollten TUV-Dateien ein konsistentes Frontmatter enthalten:

```yaml
---
title: "Titel der Unterrichtseinheit"
subject: "GPG"  # oder "WiB"
grade: "5"      # Jahrgangsstufe
topic: "Europa" # Themenbereich
type: "Unterrichtseinheit" # oder "Tafelbild", "Arbeitsblatt", etc.
---
```

Frontmatter-Angaben haben immer Vorrang vor automatisch extrahierten Informationen.

## Integration in den Workflow

### Automatische Aktualisierung

Die TUV-Übersicht kann auf drei Arten aktualisiert werden:

1. **Als Teil von `update_all.sh`**: Die Übersicht wird bei jedem Aufruf von `update_all.sh` aktualisiert.
2. **Manuell**: Durch Aufruf von `./scripts/generate_tuv_overview.sh`.
3. **Git Pre-Commit Hook**: Automatische Aktualisierung vor jedem Commit, wenn TUV-Dateien geändert wurden.

### Vorteile der Integration

- **Konsistente Dokumentation**: Die Übersicht bleibt immer aktuell.
- **Effizienter Workflow**: Keine manuelle Pflege der Übersicht notwendig.
- **Verbesserte Navigation**: Schneller Zugriff auf alle TUVs, kategorisiert und durchsuchbar.

## Anpassung und Erweiterung

Der Generator kann leicht angepasst werden:

- **Suchpfade**: Weitere Verzeichnisse in `config.searchPaths` hinzufügen.
- **TUV-Muster**: Muster für TUV-Dateien in `config.tuvPatterns` anpassen.
- **Ausgabeformat**: Die `generateOverview`-Funktion für andere Ausgabeformate anpassen.

## Fehlerbehebung

Falls Probleme auftreten:

1. **Fehlende Metadaten**: Füge passende Frontmatter zu den TUV-Dateien hinzu.
2. **Nicht erkannte TUVs**: Überprüfe die Dateinamen und Pfade gemäß der Konfiguration.
3. **Fehler bei der Generierung**: Prüfe, ob Node.js installiert ist und das Paket `gray-matter` verfügbar ist.

## Empfohlene Namenskonventionen

Für optimale automatische Erkennung empfehlen wir folgende Namenskonventionen:

- **Unterrichtseinheiten**: `XX_UE_Thema.md` (XX = Nummer der UE in der Sequenz)
- **Tafelbilder**: `XX_TB_Thema.md`
- **Arbeitsblätter**: `XX_AB_Thema.md`

Beispiel: `03_UE_Klimazonen-in-Europa.md`

## Nächste Schritte zur Verbesserung

1. **Lehrplanbezug**: Erweiterung um direkte Verknüpfung mit LehrplanPLUS-Kompetenzerwartungen.
2. **Materialzusammenhänge**: Visualisierung von Beziehungen zwischen TUVs innerhalb einer Sequenz.
3. **Metadaten-Validierung**: Prüfung und Vorschläge zur Vervollständigung fehlender Metadaten.
