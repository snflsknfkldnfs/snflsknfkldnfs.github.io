
# ArtefaktCraft Dokumentation

## Übersicht

ArtefaktCraft ist ein spezialisiertes Tool zur standardisierten Erstellung pädagogischer Artefakte für die Fächer WiB (Wirtschaft und Beruf) und GPG (Geschichte/Politik/Geographie). Es bietet eine dialoggestützte Erstellung von Dokumenten wie Sequenzplanungen und Unterrichtseinheiten nach einheitlichen Standards.

## Funktionen

- **Dialoggestützte Erstellung**: Führt Sie durch die Eingabe aller notwendigen Informationen für Ihr Artefakt
- **KI-Unterstützung**: Generiert Vorschläge für bestimmte Felder (mit OpenAI-Integration)
- **Standardisierte Vorlagen**: Sorgt für einheitliche Formate und Strukturen
- **Web- und CLI-Schnittstelle**: Bietet sowohl eine grafische als auch eine Kommandozeilen-Schnittstelle
- **Git-Integration**: Automatische Versionskontrolle Ihrer Artefakte
- **MCP-Server-Integration**: Unterstützung für MCP-Server zur Verteilung und Synchronisation im Netzwerk

## Installation

### Voraussetzungen

- Python 3.8+ 
- pip (Python-Paketmanager)
- Git (optional, für die Git-Integration)

### Python-Abhängigkeiten

Folgende Python-Pakete werden benötigt:

```
pyyaml
jinja2
colorama
flask
requests
openai (optional, für KI-Unterstützung)
```

Installation der Abhängigkeiten:

```bash
pip install -r requirements.txt
```

## Konfiguration

ArtefaktCraft wird über die Datei `config/config.yaml` konfiguriert. Hier können Sie Folgendes anpassen:

- **Repository-Pfade**: Basis-Pfad, Template-Pfad und Ausgabepfade
- **Artefakt-Typen**: Definition der verschiedenen Artefakt-Typen und ihrer Metadaten-Schemata
- **OpenAI-Integration**: API-Schlüssel und Modelleinstellungen
- **Web-Interface**: Host, Port und Verzeichnisse
- **Git-Integration**: Commit-Nachrichten und automatische Commits

## Verwendung

### Weboberfläche

Starten der Weboberfläche:

```bash
python artefaktcraft.py --web
```

Optionen:
- `--port PORT`: Port für die Weboberfläche (Standard: 8080)
- `--host HOST`: Host für die Weboberfläche (Standard: 127.0.0.1)
- `--no-browser`: Öffnet keinen Browser automatisch
- `--log-level LEVEL`: Log-Level (DEBUG, INFO, WARNING, ERROR, CRITICAL)

### Kommandozeile

Starten der Kommandozeile:

```bash
python artefaktcraft.py
```

Im interaktiven Modus stehen folgende Befehle zur Verfügung:
- `create <artefakt_typ>`: Erstellt ein neues Artefakt
- `list`: Listet verfügbare Artefakt-Typen auf
- `validate`: Validiert die Repository-Struktur
- `init`: Initialisiert fehlende Repository-Struktur
- `help`: Zeigt die Hilfe an
- `exit` oder `quit`: Beendet die Anwendung

Direkte Befehlsausführung:

```bash
python artefaktcraft.py list
python artefaktcraft.py create sequenzplanung
python artefaktcraft.py validate
python artefaktcraft.py init
```

## Artefakt-Typen

ArtefaktCraft unterstützt standardmäßig folgende Artefakt-Typen:

### Sequenzplanung

Eine strukturierte Planung einer Unterrichtssequenz mit:
- Basisinformationen (Jahrgangsstufe, Thema, Zeitraum, Umfang)
- Lehrplanbezug
- Gegenstandsbereiche und prozessbezogene Kompetenzen
- Sequenzüberblick
- Differenzierungsaspekte
- Lernprodukte und Leistungserhebung
- Verknüpfung mit anderen Fächern
- Reflexion und Evaluation

### Unterrichtseinheit

Eine detaillierte Planung einer einzelnen Unterrichtsstunde oder -einheit mit:
- Basisinformationen (Jahrgangsstufe, Fach, Lernbereich, Dauer)
- Lehrplanbezug
- Lernziel
- Verlaufsplanung
- Materialien
- Differenzierung
- Reflexion

## Eigene Artefakt-Typen hinzufügen

Um eigene Artefakt-Typen hinzuzufügen:

1. **Template erstellen**: Erstellen Sie eine neue Template-Datei im `templates`-Verzeichnis
2. **Dialog definieren**: Erstellen Sie eine Dialog-Definition im YAML-Format
3. **Konfiguration anpassen**: Fügen Sie den neuen Artefakt-Typ in der `config.yaml` hinzu

Beispiel für einen Eintrag in der Konfiguration:

```yaml
- id: "mein_artefakt"
  name: "Mein Artefakt"
  template: "mein_artefakt_template.md"
  output_dir: "${fach}/meine_artefakte"
  dialog_flow: "mein_artefakt_dialog.yaml"
  metadata_schema:
    - name: "title"
      type: "string"
      required: true
      prompt: "Titel des Artefakts"
    # Weitere Felder...
```

## Repository-Struktur verstehen

ArtefaktCraft verwendet eine definierte Verzeichnisstruktur:

- **src/**: Quellcode der Anwendung
  - **core/**: Kernkomponenten
  - **interfaces/**: Benutzeroberflächen
  - **web/**: Weboberfläche
- **config/**: Konfigurationsdateien
- **templates/**: Vorlagen für Artefakte
- **docs/**: Dokumentation

Die erstellten Artefakte werden in den konfigurierten Ausgabepfaden gespeichert, standardmäßig unter:
- `/Users/paulad/snflsknfkldnfs.github.io/notizen/wib/` für WiB-Artefakte
- `/Users/paulad/snflsknfkldnfs.github.io/notizen/gpg/` für GPG-Artefakte

## Fehlersuche

### Häufige Probleme

- **Fehlende Verzeichnisse**: Führen Sie `python artefaktcraft.py init` aus, um fehlende Verzeichnisse zu erstellen.
- **Template nicht gefunden**: Stellen Sie sicher, dass die Template-Datei im konfigurierten Template-Verzeichnis existiert.
- **Fehler bei der OpenAI-Integration**: Überprüfen Sie Ihren API-Schlüssel und die Internetverbindung.

### Logs

Die Logs finden Sie standardmäßig im Verzeichnis `logs`. Sie können das Log-Level beim Start anpassen:

```bash
python artefaktcraft.py --log-level DEBUG
```

## Support und Weiterentwicklung

ArtefaktCraft ist ein internes Tool für die standardisierte Erstellung pädagogischer Artefakte. Bei Fragen oder Problemen wenden Sie sich an den Repository-Verwalter.

### Beitrag zur Weiterentwicklung

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch
3. Reichen Sie einen Pull-Request ein

### Roadmap

- Integration weiterer Artefakt-Typen (Arbeitsblätter, Tafelbilder, etc.)
- Verbesserte KI-Unterstützung für die Artefakterstellung
- Erweiterung der Weboberfläche um zusätzliche Funktionen
- Fortgeschrittene Differenzierungsmöglichkeiten für Artefakte
