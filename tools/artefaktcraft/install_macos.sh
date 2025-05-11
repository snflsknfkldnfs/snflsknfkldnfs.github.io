
#!/bin/bash

# ArtefaktCraft Installations-Skript für macOS

# Verzeichnis des Skripts bestimmen
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# In das ArtefaktCraft-Verzeichnis wechseln
cd "$SCRIPT_DIR"

echo "=== ArtefaktCraft Installation für macOS ==="
echo "Überprüfe Python-Installation..."

# Prüfen, ob Python installiert ist
if ! command -v python3 &> /dev/null
then
    echo "Python 3 ist nicht installiert. Bitte installieren Sie Python 3 von python.org"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "Python-Version: $PYTHON_VERSION"

# Prüfen, ob pip installiert ist
if ! command -v pip3 &> /dev/null
then
    echo "pip ist nicht installiert. Installiere pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
fi

echo "Installiere Abhängigkeiten..."
pip3 install -r requirements.txt

echo "Mache Startskript ausführbar..."
chmod +x start_artefaktcraft.sh

echo "Erstelle log-Verzeichnis..."
mkdir -p logs

echo "Konfiguriere Repository..."
python3 artefaktcraft.py init

echo ""
echo "=== Installation abgeschlossen ==="
echo "ArtefaktCraft wurde erfolgreich installiert!"
echo "Starten Sie ArtefaktCraft mit: ./start_artefaktcraft.sh"
echo ""
