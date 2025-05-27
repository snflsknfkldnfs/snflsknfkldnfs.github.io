#!/bin/bash

# Claude Desktop MCP minimales Setup
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Erstelle temporäres Verzeichnis für Logs
TEMP_DIR="$HOME/claude_mcp_setup_temp"
mkdir -p "$TEMP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$TEMP_DIR/setup_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1"
  echo -e "$1" >> "$LOG_FILE"
}

log "🚀 Starte Claude Desktop MCP Setup..."

# Prüfe Node.js und NPM
if command -v node &> /dev/null && command -v npm &> /dev/null; then
  NODE_VERSION=$(node --version)
  NPM_VERSION=$(npm --version)
  log "✅ Node.js und NPM sind installiert: $NODE_VERSION, $NPM_VERSION"
else
  log "${RED}❌ Node.js und/oder NPM sind nicht installiert!${NC}"
  log "Bitte installieren Sie Node.js von https://nodejs.org/"
  exit 1
fi

# Stoppe Claude Desktop, falls es läuft
log "🛑 Stoppe Claude Desktop, falls es läuft..."
pkill -f "Claude Desktop" || log "Claude Desktop läuft nicht"

# Stoppe alle laufenden MCP-Server
log "🛑 Stoppe alle laufenden MCP-Server..."
ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true

# Bereinige den NPM-Cache
log "🧹 Bereinige NPM-Cache..."
npm cache clean --force >> "$LOG_FILE" 2>&1

# Installiere MCP-Pakete
log "📦 Installiere MCP-Pakete..."
npm install -g @modelcontextprotocol/sdk@1.12.0 >> "$LOG_FILE" 2>&1
npm install -g @modelcontextprotocol/server-sequential-thinking >> "$LOG_FILE" 2>&1
npm install -g @modelcontextprotocol/server-filesystem >> "$LOG_FILE" 2>&1
log "✅ MCP-Pakete installiert"

# Erstelle Konfigurationsdateien
log "📝 Erstelle MCP-Konfigurationsdateien..."

# Claude Desktop Konfiguration
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
mkdir -p "$(dirname "$CLAUDE_CONFIG")"

# Erstelle Backup der aktuellen Konfiguration, falls vorhanden
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "$CLAUDE_CONFIG" "${CLAUDE_CONFIG}.bak_$TIMESTAMP"
fi

# Erstelle neue Konfiguration mit minimalen MCP-Servern
cat > "$CLAUDE_CONFIG" <<EOL
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      }
    },
    "github.com/modelcontextprotocol/servers/tree/main/src/filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/snflsknfkldnfs.github.io"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      }
    }
  }
}
EOL

# VSCodium Konfiguration, falls vorhanden
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
VSCODIUM_CONFIG_DIR=$(dirname "$VSCODIUM_CONFIG")

if [ -d "$VSCODIUM_CONFIG_DIR" ]; then
  # Erstelle Backup der aktuellen Konfiguration, falls vorhanden
  if [ -f "$VSCODIUM_CONFIG" ]; then
    cp "$VSCODIUM_CONFIG" "${VSCODIUM_CONFIG}.bak_$TIMESTAMP"
  fi
  
  # Kopiere die gleiche Konfiguration zu VSCodium
  cp "$CLAUDE_CONFIG" "$VSCODIUM_CONFIG"
fi

log "✅ MCP-Konfiguration erstellt"

# Teste die MCP-Server
log "🧪 Teste MCP-Server..."

# Teste Sequential Thinking Server
log "Teste Sequential Thinking Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-sequential-thinking > /tmp/seqthink_test.json 2>/dev/null
if grep -q "sequentialthinking" /tmp/seqthink_test.json; then
  log "✅ Sequential Thinking Server funktioniert"
else
  log "${RED}❌ Sequential Thinking Server funktioniert nicht${NC}"
fi

# Teste Filesystem Server
log "Teste Filesystem Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-filesystem "$HOME/snflsknfkldnfs.github.io" > /tmp/filesystem_test.json 2>/dev/null
if grep -q "read_file\|write_file" /tmp/filesystem_test.json; then
  log "✅ Filesystem Server funktioniert"
else
  log "${RED}❌ Filesystem Server funktioniert nicht${NC}"
fi

# Abschluss
log "\n🎉 Setup abgeschlossen! Bitte führen Sie folgende Schritte aus:"
log "1. Starten Sie Claude Desktop neu"
log "2. Prüfen Sie, ob die MCP-Server verbunden sind"
log "3. Wenn alles funktioniert, können Sie weitere Server hinzufügen"
log "\nLogs wurden in $LOG_FILE gespeichert"
