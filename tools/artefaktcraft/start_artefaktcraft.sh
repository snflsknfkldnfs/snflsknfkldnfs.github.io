
#!/bin/bash

# ArtefaktCraft Startskript für macOS/Linux

# Verzeichnis des Skripts bestimmen
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# In das ArtefaktCraft-Verzeichnis wechseln
cd "$SCRIPT_DIR"

# Prüfen, ob Python installiert ist
if ! command -v python3 &> /dev/null
then
    echo "Python 3 ist nicht installiert. Bitte installieren Sie Python 3."
    exit 1
fi

# ArtefaktCraft-Weboberfläche starten
python3 artefaktcraft.py --web

# Alternativ für CLI-Modus:
# python3 artefaktcraft.py
