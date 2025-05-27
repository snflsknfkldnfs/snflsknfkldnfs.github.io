#!/bin/bash

# Claude Desktop Log-Sammler
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Erzeuge Zeitstempel für die Dateinamen
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$HOME/claude_logs_$TIMESTAMP"
ARCHIVE_NAME="claude_logs_$TIMESTAMP.zip"

# Erstelle Log-Verzeichnis
mkdir -p "$LOG_DIR"

echo -e "\n${BLUE}======================================================${NC}"
echo -e "${BLUE}      Claude Desktop Log-Sammler v1.0.0               ${NC}"
echo -e "${BLUE}======================================================${NC}\n"

echo -e "${YELLOW}Sammle Logs und Konfigurationsdateien für die Diagnose...${NC}"
echo -e "Ergebnisse werden in $LOG_DIR gespeichert\n"

# ----- 1. Systemumgebung -----
echo -e "${YELLOW}1. Sammle Systemumgebungsinformationen...${NC}"

# Betriebssystem
system_info_file="$LOG_DIR/system_info.txt"
echo "=== Betriebssystem ===" > "$system_info_file"
uname -a >> "$system_info_file"
sw_vers >> "$system_info_file" 2>/dev/null

# Node.js und NPM
echo -e "\n=== Node.js und NPM ===" >> "$system_info_file"
node --version >> "$system_info_file" 2>/dev/null || echo "Node.js nicht installiert" >> "$system_info_file"
npm --version >> "$system_info_file" 2>/dev/null || echo "NPM nicht installiert" >> "$system_info_file"
which node >> "$system_info_file" 2>/dev/null
which npm >> "$system_info_file" 2>/dev/null

# NVM (falls installiert)
echo -e "\n=== NVM (Node Version Manager) ===" >> "$system_info_file"
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  echo "NVM installiert: $HOME/.nvm/nvm.sh" >> "$system_info_file"
  source "$HOME/.nvm/nvm.sh" > /dev/null 2>&1
  nvm --version >> "$system_info_file" 2>/dev/null
  nvm ls >> "$system_info_file" 2>/dev/null
else
  echo "NVM nicht gefunden" >> "$system_info_file"
fi

# Installierte globale NPM-Pakete
echo -e "\n=== Globale NPM-Pakete ===" >> "$system_info_file"
npm list -g --depth=0 >> "$system_info_file" 2>/dev/null || echo "Fehler beim Auflisten der globalen NPM-Pakete" >> "$system_info_file"

# Pfade
echo -e "\n=== Umgebungsvariablen und Pfade ===" >> "$system_info_file"
echo "PATH: $PATH" >> "$system_info_file"
echo "HOME: $HOME" >> "$system_info_file"

echo -e "${GREEN}✅ Systemumgebungsinformationen gesammelt${NC}"

# ----- 2. Claude Desktop Konfigurationen -----
echo -e "\n${YELLOW}2. Sammle Claude Desktop Konfigurationen...${NC}"

config_dir="$LOG_DIR/configurations"
mkdir -p "$config_dir"

# Claude Desktop Konfiguration
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "$CLAUDE_CONFIG" "$config_dir/claude_desktop_config.json"
  echo -e "${GREEN}✅ Claude Desktop Konfiguration kopiert${NC}"
else
  echo -e "${RED}❌ Claude Desktop Konfiguration nicht gefunden: $CLAUDE_CONFIG${NC}"
fi

# VSCodium Konfiguration (falls vorhanden)
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
if [ -f "$VSCODIUM_CONFIG" ]; then
  cp "$VSCODIUM_CONFIG" "$config_dir/cline_mcp_settings.json"
  echo -e "${GREEN}✅ VSCodium Claude Konfiguration kopiert${NC}"
fi

# ----- 3. Claude Desktop Logs -----
echo -e "\n${YELLOW}3. Sammle Claude Desktop Logs...${NC}"

logs_dir="$LOG_DIR/app_logs"
mkdir -p "$logs_dir"

# Claude Desktop Logs
CLAUDE_LOGS_DIR="$HOME/Library/Application Support/Claude/logs"
if [ -d "$CLAUDE_LOGS_DIR" ]; then
  cp -r "$CLAUDE_LOGS_DIR"/* "$logs_dir/" 2>/dev/null
  echo -e "${GREEN}✅ Claude Desktop Logs kopiert${NC}"
else
  echo -e "${RED}❌ Claude Desktop Logs nicht gefunden: $CLAUDE_LOGS_DIR${NC}"
  
  # Alternative Logverzeichnisse durchsuchen
  ALT_LOG_DIRS=(
    "$HOME/Library/Logs/Claude"
    "$HOME/Library/Application Support/Claude Desktop/logs"
    "$HOME/Library/Caches/Claude"
  )
  
  for dir in "${ALT_LOG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      cp -r "$dir"/* "$logs_dir/" 2>/dev/null
      echo -e "${GREEN}✅ Alternative Claude Logs gefunden und kopiert: $dir${NC}"
    fi
  done
fi

# MCP-Server Logs (falls vorhanden)
MCP_LOG_DIR="$HOME/claude_mcp_logs"
if [ -d "$MCP_LOG_DIR" ]; then
  mkdir -p "$logs_dir/mcp_logs"
  cp -r "$MCP_LOG_DIR"/* "$logs_dir/mcp_logs/" 2>/dev/null
  echo -e "${GREEN}✅ MCP-Server Logs kopiert${NC}"
fi

# ----- 4. Laufende Prozesse -----
echo -e "\n${YELLOW}4. Sammle Informationen über laufende Prozesse...${NC}"

processes_file="$LOG_DIR/running_processes.txt"

# Claude Desktop Prozesse
echo "=== Claude Desktop Prozesse ===" > "$processes_file"
ps aux | grep -E "Claude|claude" | grep -v grep >> "$processes_file"

# MCP und Node.js Prozesse
echo -e "\n=== MCP und Node.js Prozesse ===" >> "$processes_file"
ps aux | grep -E "node|npx|mcp|modelcontextprotocol" | grep -v grep >> "$processes_file"

echo -e "${GREEN}✅ Prozessinformationen gesammelt${NC}"

# ----- 5. MCP-Server Tests -----
echo -e "\n${YELLOW}5. Teste MCP-Server...${NC}"

mcp_tests_dir="$LOG_DIR/mcp_tests"
mkdir -p "$mcp_tests_dir"

# Teste Sequential Thinking Server
echo -e "Teste Sequential Thinking Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-sequential-thinking > "$mcp_tests_dir/sequential_thinking_test.json" 2> "$mcp_tests_dir/sequential_thinking_error.log" || true

# Teste Filesystem Server
echo -e "Teste Filesystem Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-filesystem "$HOME" > "$mcp_tests_dir/filesystem_test.json" 2> "$mcp_tests_dir/filesystem_error.log" || true

# Teste GitHub Server
echo -e "Teste GitHub Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-github > "$mcp_tests_dir/github_test.json" 2> "$mcp_tests_dir/github_error.log" || true

# Teste Browser Tools Server
echo -e "Teste Browser Tools Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @agentdeskai/browser-tools-mcp > "$mcp_tests_dir/browser_tools_test.json" 2> "$mcp_tests_dir/browser_tools_error.log" || true

# Teste Obsidian Server
echo -e "Teste Obsidian Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y mcp-obsidian "$HOME/Documents/Obsidian" > "$mcp_tests_dir/obsidian_test.json" 2> "$mcp_tests_dir/obsidian_error.log" || true

# Teste lokalen einfachen Server
if [ -f "simple_mcp_server_v16.js" ]; then
  echo -e "Teste lokalen einfachen Server..."
  echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | node simple_mcp_server_v16.js > "$mcp_tests_dir/simple_server_test.json" 2> "$mcp_tests_dir/simple_server_error.log" || true
fi

echo -e "${GREEN}✅ MCP-Server Tests abgeschlossen${NC}"

# ----- 6. Obsidian Konfiguration -----
echo -e "\n${YELLOW}6. Sammle Obsidian Konfiguration...${NC}"

obsidian_dir="$LOG_DIR/obsidian"
mkdir -p "$obsidian_dir"

# Überprüfe mögliche Obsidian-Pfade
OBSIDIAN_PATHS=(
  "$HOME/Documents/Obsidian"
  "$HOME/Obsidian"
  "$HOME/Library/Application Support/obsidian"
)

for path in "${OBSIDIAN_PATHS[@]}"; do
  if [ -d "$path" ]; then
    echo "Obsidian-Verzeichnis gefunden: $path" > "$obsidian_dir/obsidian_info.txt"
    
    # Kopiere nur Konfigurationsdateien, keine Notizen
    if [ -d "$path/.obsidian" ]; then
      cp -r "$path/.obsidian" "$obsidian_dir/"
    fi
    
    # Liste der Ordner (ohne Inhalt)
    find "$path" -type d -maxdepth 2 -mindepth 1 | sort > "$obsidian_dir/folder_structure.txt"
    
    echo -e "${GREEN}✅ Obsidian Konfiguration von $path kopiert${NC}"
    break
  fi
done

if [ ! -f "$obsidian_dir/obsidian_info.txt" ]; then
  echo -e "${RED}❌ Kein Obsidian-Verzeichnis gefunden${NC}"
  echo "Kein Obsidian-Verzeichnis gefunden in:" > "$obsidian_dir/obsidian_info.txt"
  for path in "${OBSIDIAN_PATHS[@]}"; do
    echo "- $path" >> "$obsidian_dir/obsidian_info.txt"
  done
fi

# ----- 7. Canva Integration -----
echo -e "\n${YELLOW}7. Sammle Informationen über Canva-Integration...${NC}"

canva_dir="$LOG_DIR/canva_integration"
mkdir -p "$canva_dir"

# Suche nach möglichen Canva-Integration-Verzeichnissen
CANVA_PATHS=(
  "$HOME/Documents/Cline/MCP/openrouter-canva"
  "$HOME/openrouter-canva"
  "$HOME/canva-integration"
)

for path in "${CANVA_PATHS[@]}"; do
  if [ -d "$path" ]; then
    echo "Canva-Integration-Verzeichnis gefunden: $path" > "$canva_dir/canva_info.txt"
    
    # Kopiere package.json und index.js, falls vorhanden
    if [ -f "$path/package.json" ]; then
      cp "$path/package.json" "$canva_dir/"
    fi
    
    if [ -f "$path/index.js" ]; then
      cp "$path/index.js" "$canva_dir/"
    fi
    
    # Liste aller Dateien (ohne Inhalt)
    find "$path" -type f -name "*.js" | sort > "$canva_dir/js_files.txt"
    
    echo -e "${GREEN}✅ Canva-Integration-Informationen von $path kopiert${NC}"
    break
  fi
done

if [ ! -f "$canva_dir/canva_info.txt" ]; then
  echo -e "${RED}❌ Kein Canva-Integration-Verzeichnis gefunden${NC}"
  echo "Kein Canva-Integration-Verzeichnis gefunden in:" > "$canva_dir/canva_info.txt"
  for path in "${CANVA_PATHS[@]}"; do
    echo "- $path" >> "$canva_dir/canva_info.txt"
  done
fi

# ----- 8. Erstelle eine optimierte MCP-Konfiguration -----
echo -e "\n${YELLOW}8. Erstelle eine optimierte MCP-Konfiguration...${NC}"

optimal_config_dir="$LOG_DIR/optimal_config"
mkdir -p "$optimal_config_dir"

# Erstelle eine optimale MCP-Konfiguration mit allen gewünschten Servern
cat > "$optimal_config_dir/optimal_mcp_config.json" <<EOL
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/modelcontextprotocol/servers/tree/main/src/filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/modelcontextprotocol/servers/tree/main/src/github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/AgentDeskAI/browser-tools-mcp": {
      "command": "npx",
      "args": ["-y", "@agentdeskai/browser-tools-mcp"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/smithery-ai/mcp-obsidian": {
      "command": "npx",
      "args": ["-y", "mcp-obsidian", "$HOME/Documents/Obsidian"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/paulad/simple-mcp-server-v16": {
      "command": "node",
      "args": ["$(pwd)/simple_mcp_server_v16.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Simple_Server_V16"
      }
    }
  }
}
EOL

# Erstelle ein Installations-Skript für diese optimale Konfiguration
cat > "$optimal_config_dir/install_optimal_config.sh" <<EOL
#!/bin/bash

# Claude Desktop optimale MCP-Konfiguration Installer
# Automatisch generiert: $(date)

# Stoppe Claude Desktop, falls es läuft
pkill -f "Claude Desktop" || echo "Claude Desktop läuft nicht"

# Stoppe alle laufenden MCP-Server
ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp' | grep -v grep | awk '{print \$2}' | xargs kill 2>/dev/null || true

# Bereinige den NPM-Cache
npm cache clean --force

# Installiere MCP-Pakete mit fester Version
npm install -g @modelcontextprotocol/sdk@1.12.0
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
npm install -g @agentdeskai/browser-tools-mcp
npm install -g mcp-obsidian

# Konfigurationsdatei für Claude Desktop
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
mkdir -p "\$(dirname "\$CLAUDE_CONFIG")"

# Backup erstellen
if [ -f "\$CLAUDE_CONFIG" ]; then
  cp "\$CLAUDE_CONFIG" "\${CLAUDE_CONFIG}.bak_\$(date +%Y%m%d_%H%M%S)"
fi

# Optimale Konfiguration kopieren
cp "$(pwd)/optimal_mcp_config.json" "\$CLAUDE_CONFIG"

# VSCodium Konfiguration, falls vorhanden
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
VSCODIUM_CONFIG_DIR=\$(dirname "\$VSCODIUM_CONFIG")

if [ -d "\$VSCODIUM_CONFIG_DIR" ]; then
  if [ -f "\$VSCODIUM_CONFIG" ]; then
    cp "\$VSCODIUM_CONFIG" "\${VSCODIUM_CONFIG}.bak_\$(date +%Y%m%d_%H%M%S)"
  fi
  cp "$(pwd)/optimal_mcp_config.json" "\$VSCODIUM_CONFIG"
fi

echo "✅ Optimale MCP-Konfiguration installiert"
echo "🚀 Starten Sie Claude Desktop neu, um die Änderungen zu übernehmen"
EOL

chmod +x "$optimal_config_dir/install_optimal_config.sh"

echo -e "${GREEN}✅ Optimierte MCP-Konfiguration erstellt${NC}"

# ----- 9. Erstelle Zip-Archiv -----
echo -e "\n${YELLOW}9. Erstelle Zip-Archiv...${NC}"

# Erstelle eine README-Datei
cat > "$LOG_DIR/README.txt" <<EOL
Claude Desktop Log-Sammlung
===========================
Erstellt am: $(date)

Diese Sammlung enthält Diagnose-Informationen zu Claude Desktop und MCP-Servern.

Inhalt:
- system_info.txt: Informationen zur Systemumgebung
- configurations/: Claude Desktop Konfigurationsdateien
- app_logs/: Claude Desktop Anwendungslogs
- running_processes.txt: Laufende Prozesse zum Zeitpunkt der Sammlung
- mcp_tests/: Ergebnisse der MCP-Server-Tests
- obsidian/: Obsidian Konfigurationsinformationen
- canva_integration/: Informationen zur Canva-Integration
- optimal_config/: Optimierte MCP-Konfiguration und Installationsskript

Um die optimierte Konfiguration zu installieren:
1. Entpacken Sie dieses Archiv
2. Führen Sie das Skript optimal_config/install_optimal_config.sh aus
3. Starten Sie Claude Desktop neu
EOL

# Erstelle das Zip-Archiv
cd "$(dirname "$LOG_DIR")"
zip -r "$ARCHIVE_NAME" "$(basename "$LOG_DIR")" > /dev/null

echo -e "${GREEN}✅ Zip-Archiv erstellt: $(pwd)/$ARCHIVE_NAME${NC}"

# ----- 10. Zusammenfassung -----
echo -e "\n${BLUE}======================================================${NC}"
echo -e "${YELLOW}Zusammenfassung:${NC}"
echo -e "- Systemumgebungsinformationen wurden gesammelt"
echo -e "- Claude Desktop Konfigurationen wurden kopiert"
echo -e "- Claude Desktop Logs wurden gesammelt"
echo -e "- Informationen über laufende Prozesse wurden gesammelt"
echo -e "- MCP-Server wurden getestet"
echo -e "- Obsidian Konfiguration wurde gesammelt"
echo -e "- Canva-Integration-Informationen wurden gesammelt"
echo -e "- Eine optimierte MCP-Konfiguration wurde erstellt"
echo -e "- Ein Zip-Archiv wurde erstellt: $(pwd)/$ARCHIVE_NAME"

echo -e "\n${YELLOW}Nächste Schritte:${NC}"
echo -e "1. Senden Sie das Zip-Archiv $(pwd)/$ARCHIVE_NAME zur Analyse"
echo -e "2. Folgen Sie den Anweisungen in der Analyse"
echo -e "3. Optional: Führen Sie optimal_config/install_optimal_config.sh aus"

echo -e "\n${GREEN}Log-Sammlung abgeschlossen!${NC}"
echo -e "${BLUE}======================================================${NC}\n"
