#!/bin/bash
# ArtefaktCraft Startup-Skript

# Farbige Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ArtefaktCraft-Verzeichnis bestimmen
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo -e "${BLUE}"
cat << "LOGO"
    _         _       __       _    _  ____            __ _   
   / \   _ __| |_ ___|  | __  / \  | |/ ___|_ __ __ _ / _| |_ 
  / _ \ | '__| __/ _ \ |/ / / _ \ | | |   | '__/ _` | |_| __|
 / ___ \| |  | ||  __/   < / ___ \| | |___| | | (_| |  _| |_ 
/_/   \_\_|   \__\___|_|\_\_/   \_\_|\____|_|  \__,_|_|  \__|
                                                             
LOGO
echo -e "${NC}"

echo -e "${BLUE}==>${NC} ArtefaktCraft wird gestartet..."

# Server-Prozess-ID-Datei
PID_FILE=".mcp-server.pid"

# Prüfen, ob der Server bereits läuft
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null; then
        echo -e "${YELLOW}!${NC} mcp-Server läuft bereits (PID: $OLD_PID)"
        echo -e "${YELLOW}!${NC} Server wird neu gestartet..."
        kill "$OLD_PID"
        sleep 1
    else
        echo -e "${YELLOW}!${NC} Veraltete PID-Datei gefunden. Der Server wurde wahrscheinlich unsauber beendet."
    fi
    rm "$PID_FILE"
fi

# mcp-Server starten
echo -e "${BLUE}==>${NC} mcp-Server wird gestartet..."
node mcp-server.js > .mcp-server.log 2>&1 &
echo $! > "$PID_FILE"
echo -e "${GREEN}✓${NC} mcp-Server gestartet (PID: $(cat "$PID_FILE"))"

# Warten, bis der Server bereit ist
echo -e "${BLUE}==>${NC} Warte auf Server-Bereitschaft..."
for i in {1..10}; do
    sleep 1
    if grep -q "Server listening" .mcp-server.log; then
        echo -e "${GREEN}✓${NC} mcp-Server ist bereit!"
        break
    fi
    if [ $i -eq 10 ]; then
        echo -e "${YELLOW}!${NC} Zeitüberschreitung beim Warten auf den Server. Versuche trotzdem fortzufahren..."
    fi
done

# Web-GUI starten
echo -e "${BLUE}==>${NC} Web-GUI wird gestartet..."

# Bestimme den Browser basierend auf dem Betriebssystem
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "http://localhost:3000/webapp/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "http://localhost:3000/webapp/"
    else
        echo -e "${YELLOW}!${NC} Konnte den Browser nicht automatisch öffnen. Bitte öffnen Sie manuell: http://localhost:3000/webapp/"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    start "http://localhost:3000/webapp/"
else
    echo -e "${YELLOW}!${NC} Konnte den Browser nicht automatisch öffnen. Bitte öffnen Sie manuell: http://localhost:3000/webapp/"
fi

echo -e "${GREEN}✓${NC} ArtefaktCraft wurde erfolgreich gestartet!"
echo
echo -e "Sie können ArtefaktCraft nun im Browser unter ${BLUE}http://localhost:3000/webapp/${NC} verwenden."
echo -e "Zum Beenden drücken Sie ${BLUE}Strg+C${NC}."

# Server-Logs anzeigen
echo
echo -e "${BLUE}==>${NC} Server-Logs:"
echo
tail -f .mcp-server.log

# Aufräumen beim Beenden
cleanup() {
    echo
    echo -e "${BLUE}==>${NC} ArtefaktCraft wird beendet..."
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm "$PID_FILE"
    fi
    echo -e "${GREEN}✓${NC} ArtefaktCraft wurde beendet!"
    exit 0
}

trap cleanup INT TERM
wait
