#!/bin/bash

# MCP-Dependencies-Installer für Claude Desktop
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
LOG_FILE="$LOG_DIR/dependencies_$TIMESTAMP.log"

# Erstelle Log-Verzeichnis, falls es nicht existiert
mkdir -p "$LOG_DIR"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      MCP-Dependencies-Installer v1.0.0               ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# Prüfe Node.js-Version und informiere den Benutzer
NODE_VERSION=$(node --version 2>/dev/null || echo "Nicht installiert")
NPM_VERSION=$(npm --version 2>/dev/null || echo "Nicht installiert")

log "${YELLOW}Systemumgebung:${NC}"
log "- Node.js-Version: ${NODE_VERSION}"
log "- NPM-Version: ${NPM_VERSION}"

# Prüfe, ob die Node-Version bekannte Kompatibilitätsprobleme hat
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -lt 16 ]; then
  log "${RED}⚠️ WARNUNG: Ihre Node.js-Version ist älter als v16 und kann Kompatibilitätsprobleme verursachen.${NC}"
  log "Es wird empfohlen, auf Node.js v16+ zu aktualisieren."
elif [ "$NODE_MAJOR" -gt 18 ]; then
  log "${YELLOW}⚠️ Hinweis: Sie verwenden Node.js $NODE_VERSION. Einige MCP-Server sind möglicherweise nicht vollständig kompatibel mit Node.js > v18.${NC}"
  log "Wenn Sie auf Probleme stoßen, empfehlen wir die Verwendung des mitgelieferten v16-kompatiblen Servers."
else
  log "${GREEN}✅ Ihre Node.js-Version ist kompatibel mit den meisten MCP-Servern.${NC}"
fi

# Prüfe, ob nvm installiert ist
NVM_INSTALLED=0
if command -v nvm &> /dev/null || [ -s "$HOME/.nvm/nvm.sh" ]; then
  NVM_INSTALLED=1
  log "${GREEN}✅ nvm (Node Version Manager) ist installiert${NC}"
else
  log "${YELLOW}ℹ️ nvm ist nicht installiert. Mit nvm könnten Sie einfach zwischen Node-Versionen wechseln.${NC}"
  log "Installation von nvm: https://github.com/nvm-sh/nvm#installing-and-updating"
fi

# Frage, ob globale NPM-Pakete installiert werden sollen
log "\n${YELLOW}Möchten Sie die benötigten MCP-Pakete global installieren? [j/n]${NC}"
read -p "Antwort: " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
  log "\n${BLUE}Installiere globale MCP-Pakete...${NC}"
  
  # Installiere MCP-SDK mit fester Version
  log "Installiere @modelcontextprotocol/sdk@1.12.0..."
  npm install -g @modelcontextprotocol/sdk@1.12.0 >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]; then
    log "${GREEN}✅ @modelcontextprotocol/sdk@1.12.0 installiert${NC}"
  else
    log "${RED}❌ Fehler bei der Installation von @modelcontextprotocol/sdk${NC}"
  fi
  
  # Array mit allen benötigten MCP-Paketen
  MCP_PACKAGES=(
    "@modelcontextprotocol/server-sequential-thinking"
    "@modelcontextprotocol/server-filesystem"
    "@modelcontextprotocol/server-github"
    "@agentdeskai/browser-tools-mcp"
    "mcp-obsidian"
  )
  
  # Installiere alle Pakete
  for package in "${MCP_PACKAGES[@]}"; do
    log "Installiere $package..."
    npm install -g "$package" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
      log "${GREEN}✅ $package installiert${NC}"
    else
      log "${RED}❌ Fehler bei der Installation von $package${NC}"
    fi
  done
else
  log "\n${YELLOW}Globale Installation übersprungen.${NC}"
fi

# Erstelle lokale Projektabhängigkeiten für Obsidian MCP
log "\n${BLUE}Erstelle lokale Projektabhängigkeiten für problematische MCP-Server...${NC}"

# Erstelle Verzeichnis für Obsidian MCP, falls noch nicht vorhanden
OBSIDIAN_MCP_DIR="$PWD/mcp-obsidian-local"
mkdir -p "$OBSIDIAN_MCP_DIR"

# Erstelle package.json für Obsidian MCP
log "Erstelle Konfigurationsdateien für Obsidian MCP..."
cat > "$OBSIDIAN_MCP_DIR/package.json" <<EOL
{
  "name": "mcp-obsidian-local",
  "version": "1.0.0",
  "description": "Lokale Version des Obsidian MCP-Servers",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "author": "",
  "license": "MIT",
  "dependencies": {
    "@modelcontextprotocol/sdk": "1.12.0"
  }
}
EOL

# Erstelle index.js für Obsidian MCP
cat > "$OBSIDIAN_MCP_DIR/index.js" <<EOL
#!/usr/bin/env node

// Vereinfachter MCP-Server für Obsidian
// Basierend auf github.com/smithery-ai/mcp-obsidian, aber mit weniger Abhängigkeiten
// Für Claude Desktop Kompatibilität optimiert

const fs = require('fs');
const path = require('path');
const { createMcpServer } = require('@modelcontextprotocol/sdk');

// Konfigurierbare Variablen
const OBSIDIAN_VAULT_PATH = process.argv[2] || path.join(process.env.HOME, 'Documents', 'Obsidian');

// Prüfe, ob Obsidian-Verzeichnis existiert
if (!fs.existsSync(OBSIDIAN_VAULT_PATH)) {
  console.error(\`Fehler: Obsidian Vault-Verzeichnis nicht gefunden: \${OBSIDIAN_VAULT_PATH}\`);
  console.error('Bitte geben Sie den korrekten Pfad als Parameter an: node index.js /pfad/zu/obsidian_vault');
  process.exit(1);
}

// Server erstellen
const server = createMcpServer({
  tools: {
    read_notes: {
      description: 'Liest den Inhalt mehrerer Notizen aus dem Obsidian-Vault',
      inputSchema: {
        type: 'object',
        properties: {
          paths: {
            type: 'array',
            items: {
              type: 'string'
            }
          }
        },
        required: ['paths'],
        additionalProperties: false,
        $schema: 'http://json-schema.org/draft-07/schema#'
      },
      handler: async (params) => {
        const { paths } = params;
        const results = {};
        
        for (const notePath of paths) {
          try {
            const fullPath = path.join(OBSIDIAN_VAULT_PATH, notePath);
            
            if (fs.existsSync(fullPath)) {
              results[notePath] = fs.readFileSync(fullPath, 'utf8');
            } else {
              results[notePath] = { error: 'Datei nicht gefunden' };
            }
          } catch (error) {
            results[notePath] = { error: error.message };
          }
        }
        
        return results;
      }
    },
    search_notes: {
      description: 'Sucht nach Notizen anhand ihres Namens im Obsidian-Vault',
      inputSchema: {
        type: 'object',
        properties: {
          query: {
            type: 'string'
          }
        },
        required: ['query'],
        additionalProperties: false,
        $schema: 'http://json-schema.org/draft-07/schema#'
      },
      handler: async (params) => {
        const { query } = params;
        const results = [];
        
        // Rekursive Funktion zum Durchsuchen von Verzeichnissen
        function searchDirectory(dirPath, relativePath = '') {
          const entries = fs.readdirSync(dirPath, { withFileTypes: true });
          
          for (const entry of entries) {
            const entryRelativePath = path.join(relativePath, entry.name);
            
            if (entry.isDirectory()) {
              searchDirectory(path.join(dirPath, entry.name), entryRelativePath);
            } else if (entry.name.toLowerCase().includes(query.toLowerCase()) && 
                      (entry.name.endsWith('.md') || entry.name.endsWith('.txt'))) {
              results.push(entryRelativePath);
            }
          }
        }
        
        try {
          searchDirectory(OBSIDIAN_VAULT_PATH);
          return results;
        } catch (error) {
          return { error: error.message };
        }
      }
    }
  },
  resources: {}
});

// Server starten
server.listen();
EOL

# Mache das Skript ausführbar
chmod +x "$OBSIDIAN_MCP_DIR/index.js"

# NPM-Pakete installieren
log "Installiere Abhängigkeiten für lokalen Obsidian MCP-Server..."
cd "$OBSIDIAN_MCP_DIR" && npm install >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "${GREEN}✅ Abhängigkeiten für Obsidian MCP-Server installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation der Abhängigkeiten für Obsidian MCP-Server${NC}"
fi

cd - > /dev/null

# Füge den lokalen Obsidian-Server zur MCP-Konfiguration hinzu
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
BACKUP_CONFIG="${CLAUDE_CONFIG}.bak_dependencies_$TIMESTAMP"

if [ -f "$CLAUDE_CONFIG" ]; then
  # Sicherungskopie erstellen
  cp "$CLAUDE_CONFIG" "$BACKUP_CONFIG"
  log "Backup der Claude-Konfiguration erstellt: $BACKUP_CONFIG"
  
  log "Aktualisiere MCP-Konfiguration mit lokalen Servern..."
  # Extrahiere vorhandene MCP-Server und füge den lokalen Obsidian-Server hinzu
  TMP_CONFIG="/tmp/claude_config_local_$$.json"
  
  # Prüfe ob jq installiert ist
  if ! command -v jq &> /dev/null; then
    log "${YELLOW}⚠️ jq ist nicht installiert. Manuelle Konfiguration erforderlich.${NC}"
    log "Fügen Sie den folgenden Eintrag zu Ihrer MCP-Konfiguration hinzu:"
    log '{
  "github.com/smithery-ai/mcp-obsidian": {
    "command": "node",
    "args": ["'$OBSIDIAN_MCP_DIR'/index.js", "'$HOME'/Documents/Obsidian"],
    "disabled": false,
    "autoApprove": [],
    "env": {
      "PATH": "'$HOME'/.local/bin:/usr/local/bin:/usr/bin:/bin",
      "NODE_NO_WARNINGS": "1"
    }
  }
}'
  else
    # Benutze jq, um die Konfiguration zu aktualisieren
    jq --arg obsidian_path "$OBSIDIAN_MCP_DIR/index.js" --arg home "$HOME" '.mcpServers["github.com/smithery-ai/mcp-obsidian"] = {
      "command": "node",
      "args": [$obsidian_path, $home + "/Documents/Obsidian"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": $home + "/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      }
    }' "$CLAUDE_CONFIG" > "$TMP_CONFIG"
    
    if [ $? -eq 0 ] && [ -s "$TMP_CONFIG" ]; then
      cp "$TMP_CONFIG" "$CLAUDE_CONFIG"
      log "${GREEN}✅ Lokaler Obsidian MCP-Server zur Konfiguration hinzugefügt${NC}"
    else
      log "${RED}❌ Fehler beim Aktualisieren der Konfiguration${NC}"
    fi
  fi
else
  log "${YELLOW}⚠️ Claude-Konfigurationsdatei nicht gefunden. Erstelle sie mit ./setup_claude_mcp.sh${NC}"
fi

# Zusammenfassung
log "\n${BLUE}======================================================${NC}"
log "${YELLOW}Zusammenfassung:${NC}"
log "- MCP-Abhängigkeiten wurden installiert und konfiguriert"
log "- Ein lokaler Obsidian MCP-Server wurde erstellt in: $OBSIDIAN_MCP_DIR"
log "- Die Claude-Konfiguration wurde aktualisiert (falls vorhanden)"

log "\n${YELLOW}Nächste Schritte:${NC}"
log "1. Starten Sie Claude Desktop neu"
log "2. Falls der Obsidian-Server immer noch Probleme verursacht:"
log "   node $OBSIDIAN_MCP_DIR/index.js \$HOME/Documents/Obsidian"
log "3. Bei weiteren Problemen führen Sie './mcp_fix_script.sh' aus"

log "\n${GREEN}Installation abgeschlossen!${NC}"
log "${BLUE}======================================================${NC}\n"
