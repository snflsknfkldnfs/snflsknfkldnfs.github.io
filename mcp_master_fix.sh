#!/bin/bash

# Master MCP-Server Fix Script für Claude Desktop
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Erzeuge Verzeichnis für Logs
LOG_DIR="$HOME/claude_mcp_logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/mcp_master_fix_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# Funktion zur Anzeige des ASCII-Banner
show_banner() {
  echo -e "${BLUE}"
  echo " _____  _                 _        __  __  _____ ____   _____             "
  echo "|  __ \| |               | |      |  \/  |/ ____|  _ \ / ____|            "
  echo "| |__) | | __ _ _   _  __| | ___  | \  / | |    | |_) | (___   ___ _ __   "
  echo "|  ___/| |/ _\` | | | |/ _\` |/ _ \ | |\/| | |    |  _ < \___ \ / _ \ '__|  "
  echo "| |    | | (_| | |_| | (_| |  __/ | |  | | |____| |_) |____) |  __/ |     "
  echo "|_|    |_|\__,_|\__,_|\__,_|\___| |_|  |_|\_____|____/|_____/ \___|_|     "
  echo "                                                                          "
  echo -e "${NC}"
}

# Anzeigen des Banners
show_banner
log "${BLUE}======================================================${NC}"
log "${BLUE}      Master MCP-Server Fix Script v1.0.0              ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# ----- 1. Systemdiagnose -----
log "${YELLOW}1. Führe Systemdiagnose durch...${NC}"

# Überprüfe Node.js und NPM
NODE_VERSION=$(node --version 2>/dev/null || echo "Nicht installiert")
NPM_VERSION=$(npm --version 2>/dev/null || echo "Nicht installiert")

log "Node.js-Version: ${NODE_VERSION}"
log "NPM-Version: ${NPM_VERSION}"

# Überprüfe, ob Node.js installiert ist
if [[ "$NODE_VERSION" == "Nicht installiert" ]]; then
  log "${RED}❌ Node.js ist nicht installiert. MCP-Server benötigen Node.js.${NC}"
  log "Bitte installieren Sie Node.js und führen Sie dieses Skript erneut aus."
  log "Empfohlen: Node.js v16.x oder höher."
  log "Installation: https://nodejs.org/en/download/"
  exit 1
fi

# Extrahiere Hauptversionsnummer von Node.js
NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1 | tr -d 'v')

# Überprüfe, ob die Node.js-Version kompatibel ist
if [[ "$NODE_MAJOR_VERSION" -lt 16 ]]; then
  log "${RED}❌ Node.js-Version zu alt. Benötigt mindestens v16.x.${NC}"
  log "Empfohlen wird die Installation der LTS-Version mit nvm:"
  log "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
  log "nvm install --lts"
  exit 1
elif [[ "$NODE_MAJOR_VERSION" -ge 20 ]]; then
  log "${YELLOW}⚠️ Node.js v${NODE_MAJOR_VERSION} könnte Kompatibilitätsprobleme haben. Version 16-18 wird empfohlen.${NC}"
fi

# Überprüfe Claude Desktop Konfiguration
CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ ! -f "$CLAUDE_CONFIG_PATH" ]; then
  log "${RED}❌ Claude Desktop Konfigurationsdatei nicht gefunden: $CLAUDE_CONFIG_PATH${NC}"
  log "Bitte stellen Sie sicher, dass Claude Desktop installiert ist."
  exit 1
else
  log "${GREEN}✅ Claude Desktop Konfigurationsdatei gefunden${NC}"
  
  # Erstelle Backup der aktuellen Konfiguration
  CONFIG_BACKUP="${CLAUDE_CONFIG_PATH}.bak_master_$TIMESTAMP"
  cp "$CLAUDE_CONFIG_PATH" "$CONFIG_BACKUP"
  log "Backup der Claude-Konfiguration erstellt: $CONFIG_BACKUP"
fi

# Überprüfe laufende MCP-Server
log "\nÜberprüfe laufende MCP-Server..."
RUNNING_SERVERS=$(ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp|mcp-obsidian' | grep -v grep)
if [ -n "$RUNNING_SERVERS" ]; then
  log "Aktuell laufende MCP-Server:"
  echo "$RUNNING_SERVERS" | awk '{print $11, $12, $13}' | tee -a "$LOG_FILE"
else
  log "Keine laufenden MCP-Server gefunden."
fi

# ----- 2. Hauptmenü anzeigen -----
clear
show_banner

while true; do
  echo -e "\n${CYAN}=== MCP-SERVER FIX-TOOL FÜR CLAUDE DESKTOP ===${NC}"
  echo -e "\nBitte wählen Sie eine Option:"
  echo -e "${GREEN}1) Alle MCP-Server reparieren (Empfohlen)${NC}"
  echo -e "2) Nur GitHub MCP-Server reparieren"
  echo -e "3) Nur Obsidian MCP-Server reparieren"
  echo -e "4) Nur Canva-Integration MCP-Server reparieren"
  echo -e "5) Claude Desktop Konfiguration anzeigen"
  echo -e "6) Fehlersuche-Anleitung"
  echo -e "7) MCP-Server-Status prüfen"
  echo -e "${RED}8) Beenden${NC}"

  read -p "Wählen Sie eine Option (1-8): " option

  case $option in
    1)
      clear
      log "\n${BLUE}Führe Vollständige MCP-Server-Reparatur durch...${NC}"
      
      echo -e "\n${YELLOW}===== 1. GitHub MCP-Server-Reparatur =====${NC}"
      if [ -f "./github_mcp_fix.sh" ]; then
        log "GitHub MCP-Server-Reparatur wird gestartet..."
        bash ./github_mcp_fix.sh
        log "${GREEN}✅ GitHub MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ github_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      echo -e "\n${YELLOW}===== 2. Obsidian MCP-Server-Reparatur =====${NC}"
      if [ -f "./obsidian_mcp_fix.sh" ]; then
        log "Obsidian MCP-Server-Reparatur wird gestartet..."
        bash ./obsidian_mcp_fix.sh
        log "${GREEN}✅ Obsidian MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ obsidian_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      echo -e "\n${YELLOW}===== 3. Canva-Integration MCP-Server-Reparatur =====${NC}"
      if [ -f "./canva_mcp_fix.sh" ]; then
        log "Canva-Integration MCP-Server-Reparatur wird gestartet..."
        bash ./canva_mcp_fix.sh
        log "${GREEN}✅ Canva-Integration MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ canva_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      log "\n${GREEN}✅ Alle MCP-Server-Reparaturen abgeschlossen${NC}"
      log "\n${YELLOW}Bitte starten Sie nun Claude Desktop neu, um die Änderungen zu übernehmen.${NC}"
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    2)
      clear
      log "\n${BLUE}Führe GitHub MCP-Server-Reparatur durch...${NC}"
      if [ -f "./github_mcp_fix.sh" ]; then
        bash ./github_mcp_fix.sh
        log "${GREEN}✅ GitHub MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ github_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    3)
      clear
      log "\n${BLUE}Führe Obsidian MCP-Server-Reparatur durch...${NC}"
      if [ -f "./obsidian_mcp_fix.sh" ]; then
        bash ./obsidian_mcp_fix.sh
        log "${GREEN}✅ Obsidian MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ obsidian_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    4)
      clear
      log "\n${BLUE}Führe Canva-Integration MCP-Server-Reparatur durch...${NC}"
      if [ -f "./canva_mcp_fix.sh" ]; then
        bash ./canva_mcp_fix.sh
        log "${GREEN}✅ Canva-Integration MCP-Server-Reparatur abgeschlossen${NC}"
      else
        log "${RED}❌ canva_mcp_fix.sh nicht gefunden. Bitte führen Sie das Skript im richtigen Verzeichnis aus.${NC}"
      fi
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    5)
      clear
      log "\n${BLUE}Claude Desktop Konfiguration anzeigen...${NC}"
      if [ -f "$CLAUDE_CONFIG_PATH" ]; then
        log "Inhalt der Claude Desktop Konfigurationsdatei:"
        cat "$CLAUDE_CONFIG_PATH" | grep -v -E '"GITHUB_TOKEN"|"OPENROUTER_API_KEY"' | sed -E 's/"[^"]+_API_KEY": "[^"]+"/"\1": "[API-KEY AUSGEBLENDET]"/g' | tee -a "$LOG_FILE"
      else
        log "${RED}❌ Claude Desktop Konfigurationsdatei nicht gefunden: $CLAUDE_CONFIG_PATH${NC}"
      fi
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    6)
      clear
      log "\n${BLUE}Fehlersuche-Anleitung für MCP-Server...${NC}"
      cat << EOF | tee -a "$LOG_FILE"

${CYAN}===== FEHLERSUCHE FÜR MCP-SERVER IN CLAUDE DESKTOP =====${NC}

${YELLOW}TYPISCHE PROBLEME UND LÖSUNGEN:${NC}

1) ${RED}Problem:${NC} "Could not attach to MCP server" Fehlermeldungen
   ${GREEN}Lösung:${NC} 
   - Stellen Sie sicher, dass die erforderlichen Node.js-Module installiert sind:
     npm cache clean --force
     npm install -g @modelcontextprotocol/sdk
   - Überprüfen Sie die Pfade in der Konfigurationsdatei
   - Starten Sie Claude Desktop neu

2) ${RED}Problem:${NC} "Unexpected token 'X', ... is not valid JSON" Fehler
   ${GREEN}Lösung:${NC}
   - Dies deutet auf eine fehlerhafte Ausgabe des MCP-Servers hin
   - Verwenden Sie die lokalen Server-Versionen statt der NPX-Versionen
   - Setzen Sie NODE_NO_WARNINGS=1 in den Umgebungsvariablen

3) ${RED}Problem:${NC} "Server disconnected" Meldungen
   ${GREEN}Lösung:${NC}
   - Überprüfen Sie, ob der Server-Prozess noch läuft
   - Achten Sie auf Berechtigungsprobleme bei Zugriff auf Dateien
   - Prüfen Sie, ob API-Schlüssel korrekt konfiguriert sind

4) ${RED}Problem:${NC} MCP-Server ist in der Liste, reagiert aber nicht
   ${GREEN}Lösung:${NC}
   - Prüfen Sie die Fehlermeldungen mit: tail -f /var/log/system.log | grep Claude
   - Verwenden Sie abwechselnd die offiziellen und lokalen Server-Versionen
   - Starten Sie den betreffenden MCP-Server manuell, um Fehlermeldungen zu sehen

${YELLOW}DEBUGGING-TIPPS:${NC}

1) Manuelle Server-Überprüfung:
   - Führen Sie den Server-Befehl manuell in einem Terminal aus
   - Die meisten Server laufen auf Port 3000
   - Testen Sie mit: curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000

2) Konfigurationsprobleme:
   - Überprüfen Sie, ob alle Pfade in claude_desktop_config.json korrekt sind
   - Achten Sie auf richtige Anführungszeichen und Kommas (JSON-Syntax)
   - Umgebungsvariablen wie PATH richtig konfiguriert?

3) Node.js-Probleme:
   - Bei Versionskonflikten verwenden Sie nvm: nvm install 16 && nvm use 16
   - Stellen Sie sicher, dass alle Abhängigkeiten installiert sind

4) Allgemeine Tipps:
   - Stoppen Sie alle laufenden MCP-Server vor der Fehlerbehebung
   - Sichern Sie die Konfigurationsdatei vor Änderungen
   - Beginnen Sie mit minimalen Konfigurationen und fügen Sie Server schrittweise hinzu

${YELLOW}KONTAKTIEREN SIE UNS:${NC}

Falls Sie weiterhin Probleme haben, senden Sie die Log-Dateien aus dem Verzeichnis
$LOG_DIR an den Support.

EOF
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    7)
      clear
      log "\n${BLUE}Überprüfe MCP-Server-Status...${NC}"
      
      # Überprüfe ob Claude Desktop läuft
      if pgrep -f "Claude Desktop" > /dev/null; then
        log "${YELLOW}⚠️ Claude Desktop läuft. Für eine genaue Überprüfung sollte die App beendet werden.${NC}"
        read -p "Möchten Sie Claude Desktop beenden? (j/N): " close_app
        if [[ "$close_app" == "j" || "$close_app" == "J" ]]; then
          pkill -f "Claude Desktop"
          log "Claude Desktop wurde beendet."
          sleep 2
        fi
      fi
      
      # Erstelle temporäres Verzeichnis für Tests
      TEST_DIR="/tmp/claude_mcp_test_$TIMESTAMP"
      mkdir -p "$TEST_DIR"
      
      # Funktion zum Testen eines MCP-Servers
      test_mcp_server() {
        local server_command="$1"
        local server_args="$2"
        local server_name="$3"
        local test_log="$TEST_DIR/${server_name// /_}_test.json"
        
        log "\nTeste $server_name..."
        
        # Starte den Server
        NODE_NO_WARNINGS=1 $server_command $server_args > /dev/null 2>&1 &
        local server_pid=$!
        
        # Warte, bis der Server gestartet ist
        sleep 3
        
        # Teste den Server mit einer einfachen Anfrage
        curl -s -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000 > "$test_log" 2>/dev/null
        
        # Beende den Server
        kill $server_pid 2>/dev/null || true
        
        # Prüfe das Ergebnis
        if grep -q '"result":\|"tools":\|"name":' "$test_log"; then
          log "${GREEN}✅ $server_name funktioniert${NC}"
          return 0
        else
          log "${RED}❌ $server_name funktioniert nicht${NC}"
          return 1
        fi
      }
      
      # Teste verschiedene MCP-Server
      TEST_RESULTS=()
      
      # GitHub MCP-Server
      if command -v npx &> /dev/null; then
        if test_mcp_server "npx" "-y @modelcontextprotocol/server-github" "GitHub MCP-Server"; then
          TEST_RESULTS+=("GitHub MCP-Server: Funktioniert")
        else
          TEST_RESULTS+=("GitHub MCP-Server: Fehler")
        fi
      fi
      
      # Obsidian MCP-Server
      OBSIDIAN_PATH="$HOME/Documents/Obsidian"
      if [ -d "$OBSIDIAN_PATH" ] && command -v npx &> /dev/null; then
        if test_mcp_server "npx" "-y mcp-obsidian \"$OBSIDIAN_PATH\"" "Obsidian MCP-Server"; then
          TEST_RESULTS+=("Obsidian MCP-Server: Funktioniert")
        else
          TEST_RESULTS+=("Obsidian MCP-Server: Fehler")
        fi
      fi
      
      # Lokaler Canva-Server
      CANVA_PATH="$HOME/Documents/Cline/MCP/openrouter-canva"
      if [ -f "$CANVA_PATH/index.js" ]; then
        if test_mcp_server "node" "\"$CANVA_PATH/index.js\"" "Canva-Integration MCP-Server"; then
          TEST_RESULTS+=("Canva-Integration MCP-Server: Funktioniert")
        else
          TEST_RESULTS+=("Canva-Integration MCP-Server: Fehler")
        fi
      else
        CANVA_PATH="$HOME/claude_canva_mcp"
        if [ -f "$CANVA_PATH/index.js" ]; then
          if test_mcp_server "node" "\"$CANVA_PATH/index.js\"" "Lokaler Canva-Integration MCP-Server"; then
            TEST_RESULTS+=("Lokaler Canva-Integration MCP-Server: Funktioniert")
          else
            TEST_RESULTS+=("Lokaler Canva-Integration MCP-Server: Fehler")
          fi
        fi
      fi
      
      # Ergebnisse anzeigen
      log "\n${CYAN}===== TEST-ERGEBNISSE =====${NC}"
      for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == *"Funktioniert"* ]]; then
          log "${GREEN}$result${NC}"
        else
          log "${RED}$result${NC}"
        fi
      done
      
      log "\n${BLUE}Überprüfung der MCP-Server abgeschlossen.${NC}"
      log "Detaillierte Testergebnisse wurden in $TEST_DIR gespeichert."
      
      read -p "Drücken Sie eine beliebige Taste, um zum Hauptmenü zurückzukehren..."
      clear
      show_banner
      ;;
      
    8)
      log "\n${BLUE}MCP-Server Fix-Tool wird beendet.${NC}"
      log "Logs wurden in $LOG_FILE gespeichert.\n"
      exit 0
      ;;
      
    *)
      echo -e "${RED}Ungültige Option. Bitte wählen Sie eine Zahl zwischen 1 und 8.${NC}"
      ;;
  esac
done

exit 0
