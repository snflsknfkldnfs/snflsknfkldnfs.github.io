
# ArtefaktCraft Installation

## Schnellstart

1. **Prerequisites**
   ```bash
   # Python 3.8+ ist erforderlich
   python --version
   
   # Installieren Sie pip, falls noch nicht verfügbar
   # Unter macOS/Linux
   curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
   python get-pip.py
   
   # Unter Windows (in PowerShell)
   Invoke-WebRequest -Uri https://bootstrap.pypa.io/get-pip.py -OutFile get-pip.py
   python get-pip.py
   ```

2. **Abhängigkeiten installieren**
   ```bash
   pip install -r requirements.txt
   ```

3. **Konfiguration anpassen**
   - Öffnen Sie `config/config.yaml`
   - Passen Sie die Pfade an Ihr System an
   - Fügen Sie optional einen OpenAI API-Schlüssel hinzu

4. **Anwendung starten**
   ```bash
   # Starten der Weboberfläche
   python artefaktcraft.py --web
   
   # ODER: Starten der Kommandozeile
   python artefaktcraft.py
   ```

5. **Repository-Struktur initialisieren**
   ```bash
   # Mit der CLI
   python artefaktcraft.py init
   
   # ODER: Über die Weboberfläche, Menüpunkt "Repository"
   ```

## Installation für weniger technisch versierte Nutzer

### Windows

1. **Python installieren**
   - Besuchen Sie [python.org](https://www.python.org/downloads/windows/)
   - Laden Sie den neuesten Python-Installer herunter (Version 3.8 oder höher)
   - Führen Sie den Installer aus
   - **Wichtig**: Aktivieren Sie "Add Python to PATH" während der Installation

2. **ArtefaktCraft herunterladen**
   - Laden Sie das ArtefaktCraft-Paket herunter und entpacken Sie es

3. **Installationsskript ausführen**
   - Navigieren Sie zum entpackten ArtefaktCraft-Verzeichnis
   - Doppelklicken Sie auf `install_windows.bat`

4. **ArtefaktCraft starten**
   - Doppelklicken Sie auf `start_artefaktcraft.bat`

### macOS

1. **Python installieren**
   - Besuchen Sie [python.org](https://www.python.org/downloads/mac-osx/)
   - Laden Sie den neuesten Python-Installer herunter (Version 3.8 oder höher)
   - Führen Sie den Installer aus

2. **ArtefaktCraft herunterladen**
   - Laden Sie das ArtefaktCraft-Paket herunter und entpacken Sie es

3. **Installationsskript ausführen**
   - Öffnen Sie Terminal
   - Navigieren Sie zum entpackten ArtefaktCraft-Verzeichnis
   - Führen Sie aus: `chmod +x install_macos.sh && ./install_macos.sh`

4. **ArtefaktCraft starten**
   - Führen Sie aus: `./start_artefaktcraft.sh`

## Erweiterte Konfiguration

### OpenAI-Integration

Für die KI-Unterstützung bei der Artefakterstellung ist ein OpenAI API-Schlüssel erforderlich:

1. Besuchen Sie [OpenAI API](https://beta.openai.com/signup/)
2. Erstellen Sie einen Account und generieren Sie einen API-Schlüssel
3. Fügen Sie den Schlüssel in die `config.yaml` ein oder setzen Sie die Umgebungsvariable `OPENAI_API_KEY`

```yaml
openai:
  api_key: "${OPENAI_API_KEY}"  # Oder direkt: "sk-..."
  model: "gpt-4"
  temperature: 0.7
  max_tokens: 4000
```

### Git-Integration

Die Git-Integration ermöglicht die automatische Versionskontrolle der erstellten Artefakte:

1. Stellen Sie sicher, dass Git installiert ist
2. Konfigurieren Sie die Git-Integration in der `config.yaml`:

```yaml
integration:
  git:
    enabled: true
    commit_message_template: "ArtefaktCraft: {artefakt_type} '{title}' erstellt"
    auto_commit: true  # Auf 'false' setzen, um manuelle Commits zu ermöglichen
```

### MCP-Server-Integration

Für die Integration mit MCP-Servern zur Verteilung und Synchronisation:

```yaml
integration:
  mcp_server:
    enabled: true
    url: "http://ihr-mcp-server:9000"
    auth_token: "ihr-auth-token"
```

## Fehlerbehebung

### Python wird nicht gefunden

**Problem**: `python: command not found` oder ähnlicher Fehler
**Lösung**: Stellen Sie sicher, dass Python korrekt installiert ist und in der PATH-Umgebungsvariable enthalten ist

### Pip-Installationsfehler

**Problem**: Fehler bei der Installation der Abhängigkeiten
**Lösung**: Versuchen Sie einen der folgenden Befehle:

```bash
# Aktualisieren Sie pip
python -m pip install --upgrade pip

# Installieren Sie die Abhängigkeiten einzeln
pip install pyyaml
pip install jinja2
pip install colorama
pip install flask
pip install requests
```

### Konfigurationsfehler

**Problem**: Fehler beim Laden der Konfiguration
**Lösung**: Überprüfen Sie, ob die `config.yaml` korrekt formatiert ist und alle erforderlichen Felder enthält

### Fehlende Verzeichnisse

**Problem**: Fehlermeldungen zu fehlenden Verzeichnissen
**Lösung**: Führen Sie die Repository-Initialisierung aus:

```bash
python artefaktcraft.py init
```

## Support

Bei weiteren Problemen wenden Sie sich an den Repository-Verwalter oder eröffnen Sie ein Issue im GitHub-Repository.
