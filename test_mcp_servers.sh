#!/bin/bash

# MCP-Server-Test-Skript für Claude Desktop
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log-Verzeichnis
LOG_DIR="$HOME/claude_mcp_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/mcp_test_$TIMESTAMP.log"

# Erstelle Log-Verzeichnis, falls es nicht existiert
mkdir -p "$LOG_DIR"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      MCP-Server-Test für Claude Desktop v1.0.0        ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# Konfigurationsdateien
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"

# Prüfe, ob die Konfigurationsdatei existiert
if [ ! -f "$CLAUDE_CONFIG" ]; then
  log "${RED}Fehler: Claude Desktop Konfigurationsdatei nicht gefunden.${NC}"
  log "Erwarteter Pfad: $CLAUDE_CONFIG"
  log "Prüfen Sie, ob Claude Desktop installiert ist und ausgeführt wurde."
  exit 1
fi

log "${YELLOW}Lese MCP-Konfiguration...${NC}"

# Prüfe, ob jq installiert ist
if ! command -v jq &> /dev/null; then
  log "${RED}Fehler: jq ist nicht installiert.${NC}"
  log "jq wird benötigt, um die JSON-Konfiguration zu parsen."
  log "Installation für macOS: brew install jq"
  exit 1
fi

# Extrahiere die MCP-Server aus der Konfiguration
SERVERS=$(jq -r '.mcpServers | keys[]' "$CLAUDE_CONFIG" 2>/dev/null)
if [ -z "$SERVERS" ]; then
  log "${RED}Fehler: Keine MCP-Server in der Konfiguration gefunden.${NC}"
  log "Die Konfiguration sollte einen 'mcpServers'-Eintrag mit mindestens einem Server enthalten."
  exit 1
fi

log "${GREEN}Gefundene Server:${NC}"
echo "$SERVERS" | while read -r server; do
  log "- $server"
done
log ""

# Teste jeden Server
log "${YELLOW}Teste MCP-Server...${NC}"

SUCCESSFUL_TESTS=0
FAILED_TESTS=0

echo "$SERVERS" | while read -r server; do
  log "\n${BLUE}Testing server: ${server}${NC}"
  
  # Extrahiere Befehl und Argumente
  COMMAND=$(jq -r ".mcpServers[\"$server\"].command" "$CLAUDE_CONFIG")
  ARGS_JSON=$(jq -r ".mcpServers[\"$server\"].args | @json" "$CLAUDE_CONFIG")
  # Konvertiere JSON-Array in Bash-Array
  readarray -t ARGS < <(jq -r '.[]' <<< "$ARGS_JSON")
  
  # Extrahiere Umgebungsvariablen
  ENV_VARS=$(jq -r ".mcpServers[\"$server\"].env" "$CLAUDE_CONFIG")
  
  log "Befehl: $COMMAND ${ARGS[@]}"
  
  # Erstelle temporäre Ausgabedatei
  TMP_OUTPUT="/tmp/mcp_test_${server//\//_}_$$.json"
  
  # Führe den Test aus
  log "Sende Test-Anfrage..."
  
  # Exportiere temporär die Umgebungsvariablen
  if [ "$ENV_VARS" != "null" ]; then
    for env_var in $(jq -r 'keys[]' <<< "$ENV_VARS"); do
      value=$(jq -r ".[\"$env_var\"]" <<< "$ENV_VARS")
      export "$env_var"="$value"
    done
  fi
  
  # Führe den Befehl mit einer Timeout-Begrenzung aus
  timeout 10 bash -c "echo '{\"jsonrpc\":\"2.0\",\"id\":\"test\",\"method\":\"list_tools\",\"params\":{}}' | $COMMAND ${ARGS[@]}" > "$TMP_OUTPUT" 2> /dev/null
  
  RESULT=$?
  
  if [ $RESULT -eq 0 ] && [ -s "$TMP_OUTPUT" ]; then
    # Prüfe auf valides JSON
    if jq . "$TMP_OUTPUT" > /dev/null 2>&1; then
      # Prüfe, ob die Antwort ein error-Feld enthält
      if jq -e '.error' "$TMP_OUTPUT" > /dev/null 2>&1; then
        log "${RED}❌ Server antwortet mit einem Fehler:${NC}"
        jq -r '.error' "$TMP_OUTPUT" 2>/dev/null | log
        FAILED_TESTS=$((FAILED_TESTS+1))
      else
        log "${GREEN}✅ Server antwortet korrekt${NC}"
        # Zeige verfügbare Tools
        if jq -e '.result.tools' "$TMP_OUTPUT" > /dev/null 2>&1; then
          TOOLS=$(jq -r '.result.tools | keys[]' "$TMP_OUTPUT" 2>/dev/null)
          log "  Verfügbare Tools:"
          echo "$TOOLS" | while read -r tool; do
            log "  - $tool"
          done
        fi
        SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS+1))
      fi
    else
      log "${RED}❌ Server antwortet nicht mit validem JSON${NC}"
      log "Antwort (erste 200 Zeichen):"
      head -c 200 "$TMP_OUTPUT" | log
      log "..."
      FAILED_TESTS=$((FAILED_TESTS+1))
    fi
  else
    log "${RED}❌ Server antwortet nicht oder Timeout erreicht${NC}"
    FAILED_TESTS=$((FAILED_TESTS+1))
  fi
  
  # Lösche die temporäre Ausgabedatei
  rm -f "$TMP_OUTPUT"
done

# Teste den lokalen v16-Server
if [ -f "simple_mcp_server_v16.js" ]; then
  log "\n${BLUE}Testing local v16 server: simple_mcp_server_v16.js${NC}"
  
  # Erstelle temporäre Ausgabedatei
  TMP_OUTPUT="/tmp/mcp_test_v16_$$.json"
  
  # Führe den Test aus
  log "Sende Test-Anfrage..."
  
  timeout 10 bash -c "echo '{\"jsonrpc\":\"2.0\",\"id\":\"test\",\"method\":\"list_tools\",\"params\":{}}' | node simple_mcp_server_v16.js" > "$TMP_OUTPUT" 2> /dev/null
  
  RESULT=$?
  
  if [ $RESULT -eq 0 ] && [ -s "$TMP_OUTPUT" ]; then
    # Prüfe auf valides JSON
    if jq . "$TMP_OUTPUT" > /dev/null 2>&1; then
      log "${GREEN}✅ Lokaler v16-Server antwortet korrekt${NC}"
      SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS+1))
    else
      log "${RED}❌ Lokaler v16-Server antwortet nicht mit validem JSON${NC}"
      FAILED_TESTS=$((FAILED_TESTS+1))
    fi
  else
    log "${RED}❌ Lokaler v16-Server antwortet nicht oder Timeout erreicht${NC}"
    FAILED_TESTS=$((FAILED_TESTS+1))
  fi
  
  # Lösche die temporäre Ausgabedatei
  rm -f "$TMP_OUTPUT"
fi

# Zeige Zusammenfassung
log "\n${BLUE}======================================================${NC}"
log "${YELLOW}Zusammenfassung:${NC}"
log "${GREEN}✅ Erfolgreiche Tests: $SUCCESSFUL_TESTS${NC}"
log "${RED}❌ Fehlgeschlagene Tests: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
  log "\n${YELLOW}Empfehlungen bei fehlgeschlagenen Tests:${NC}"
  log "1. Prüfen Sie, ob die Server korrekt installiert sind"
  log "2. Fügen Sie 'NODE_NO_WARNINGS=1' zu den Umgebungsvariablen hinzu"
  log "3. Führen Sie './mcp_fix_script.sh' für eine umfassende Reparatur aus"
  log "4. Starten Sie mit einer minimalen Konfiguration (.setup_claude_mcp.sh)"
fi

log "\nTest abgeschlossen: $(date)"
log "${BLUE}======================================================${NC}\n"

if [ $FAILED_TESTS -gt 0 ]; then
  exit 1
else
  exit 0
fi
