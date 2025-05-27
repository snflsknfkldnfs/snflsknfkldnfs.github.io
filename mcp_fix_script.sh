#!/bin/bash

# MCP-Fix-Script für Claude Desktop
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Erstelle Verzeichnis für Logs
LOG_DIR="$HOME/claude_mcp_logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/mcp_fix_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      MCP-Fix-Script für Claude Desktop v1.0.0         ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# ----- 1. Diagnose -----
log "${YELLOW}1. Führe Diagnose durch...${NC}"

# Überprüfe Node.js und NPM
NODE_VERSION=$(node --version 2>/dev/null || echo "Nicht installiert")
NPM_VERSION=$(npm --version 2>/dev/null || echo "Nicht installiert")

log "Node.js-Version: ${NODE_VERSION}"
log "NPM-Version: ${NPM_VERSION}"

# Überprüfe MCP-SDK-Version
MCP_SDK_VERSION=$(npm list -g @modelcontextprotocol/sdk --depth=0 2>/dev/null | grep modelcontextprotocol || echo "Nicht installiert")
log "MCP-SDK: ${MCP_SDK_VERSION}"

# Überprüfe installierte MCP-Server
log "\nInstallierte MCP-Server:"
for pkg in "@modelcontextprotocol/server-sequential-thinking" "@modelcontextprotocol/server-filesystem" "@modelcontextprotocol/server-github" "@agentdeskai/browser-tools-mcp" "mcp-obsidian"; do
  VERSION=$(npm list -g $pkg --depth=0 2>/dev/null | grep "$pkg" || echo "$pkg: Nicht installiert")
  log "- $VERSION"
done

# Überprüfe Claude Desktop Konfiguration
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
  log "\nClaude Desktop Konfiguration gefunden: $CLAUDE_CONFIG"
  
  # Erstelle Backup der aktuellen Konfiguration
  CONFIG_BACKUP="${CLAUDE_CONFIG}.bak_$TIMESTAMP"
  cp "$CLAUDE_CONFIG" "$CONFIG_BACKUP"
  log "Backup erstellt: $CONFIG_BACKUP"
  
  # Extrahiere konfigurierte MCP-Server
  if command -v jq &> /dev/null; then
    SERVERS=$(jq -r '.mcpServers | keys[]' "$CLAUDE_CONFIG" 2>/dev/null || echo "Keine Server konfiguriert")
    log "\nKonfigurierte MCP-Server:"
    echo "$SERVERS" | while read -r server; do
      if [ -n "$server" ]; then
        log "- $server"
      fi
    done
  else
    log "${YELLOW}⚠️ jq ist nicht installiert. Konfigurierte Server können nicht analysiert werden.${NC}"
  fi
else
  log "${RED}❌ Claude Desktop Konfiguration nicht gefunden${NC}"
fi

# Überprüfe laufende MCP-Prozesse
log "\nLaufende MCP-Prozesse:"
ps aux | grep -E "modelcontextprotocol|mcp-server|@mcp" | grep -v grep | tee -a "$LOG_FILE" || log "Keine MCP-Prozesse gefunden"

# ----- 2. Bereinigen -----
log "\n${YELLOW}2. Bereinige problematische Prozesse und Umgebung...${NC}"

# Stoppe Claude Desktop, falls es läuft
log "Stoppe Claude Desktop, falls es läuft..."
pkill -f "Claude Desktop" || log "Claude Desktop läuft nicht"

# Stoppe alle laufenden MCP-Server
log "Stoppe alle laufenden MCP-Server..."
ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true
log "MCP-Server gestoppt"

# Bereinige den NPM-Cache
log "Bereinige NPM-Cache..."
npm cache clean --force >> "$LOG_FILE" 2>&1
log "NPM-Cache bereinigt"

# ----- 3. Installiere/Aktualisiere MCP-Pakete -----
log "\n${YELLOW}3. Installiere/Aktualisiere MCP-Pakete...${NC}"

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

# ----- 4. Erstelle lokalen Obsidian-Server -----
log "\n${YELLOW}4. Erstelle lokalen Obsidian-Server als Fallback...${NC}"

# Erstelle Verzeichnis für lokalen Server
OBSIDIAN_SERVER_DIR="$PWD/mcp-obsidian-local"
mkdir -p "$OBSIDIAN_SERVER_DIR"

# Erstelle package.json
log "Erstelle package.json..."
cat > "$OBSIDIAN_SERVER_DIR/package.json" <<EOL
{
  "name": "mcp-obsidian-local",
  "version": "1.0.0",
  "description": "Lokaler MCP-Server für Obsidian",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "1.12.0"
  }
}
EOL

# Erstelle index.js für lokalen Server
log "Erstelle index.js..."
cat > "$OBSIDIAN_SERVER_DIR/index.js" <<EOL
#!/usr/bin/env node

// Vereinfachter MCP-Server für Obsidian
// Optimiert für Claude Desktop Kompatibilität
const fs = require('fs');
const path = require('path');
const { createMcpServer } = require('@modelcontextprotocol/sdk');

// Konfiguriere Obsidian-Pfad
const OBSIDIAN_PATH = process.argv[2] || path.join(process.env.HOME, 'Documents', 'Obsidian');

// Prüfe, ob Obsidian-Verzeichnis existiert
if (!fs.existsSync(OBSIDIAN_PATH)) {
  console.error(\`Fehler: Obsidian-Verzeichnis nicht gefunden: \${OBSIDIAN_PATH}\`);
  console.error('Bitte geben Sie den korrekten Pfad als Parameter an: node index.js /pfad/zu/obsidian');
  process.exit(1);
}

// Erstelle Server
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
            const fullPath = path.join(OBSIDIAN_PATH, notePath);
            
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
          searchDirectory(OBSIDIAN_PATH);
          return results;
        } catch (error) {
          return { error: error.message };
        }
      }
    }
  },
  resources: {}
});

// Starte Server
server.listen();
EOL

# Mache das Skript ausführbar
chmod +x "$OBSIDIAN_SERVER_DIR/index.js"

# Installiere Abhängigkeiten
log "Installiere Abhängigkeiten für lokalen Obsidian-Server..."
cd "$OBSIDIAN_SERVER_DIR" && npm install >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "${GREEN}✅ Abhängigkeiten für lokalen Obsidian-Server installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation der Abhängigkeiten für lokalen Obsidian-Server${NC}"
fi

cd - > /dev/null

# ----- 5. Erstelle lokalen einfachen Server für Fehlerbehandlung -----
log "\n${YELLOW}5. Erstelle einfachen lokalen MCP-Server als Fallback...${NC}"

# Erstelle simple_mcp_server_v16.js falls noch nicht vorhanden
if [ ! -f "simple_mcp_server_v16.js" ]; then
  log "Erstelle simple_mcp_server_v16.js..."
  
  cat > "simple_mcp_server_v16.js" <<EOL
#!/usr/bin/env node

// Einfacher MCP-Server für Claude Desktop
// Node.js v16 kompatibel, ohne externe Abhängigkeiten
// Stabile JSON-RPC-Antworten für problemlose Claude-Integration

const http = require('http');

// Konfiguration
const PORT = process.env.PORT || 0; // 0 = zufälliger Port
const HOST = process.env.HOST || 'localhost';

// Tools Definitionen
const tools = {
  echo: {
    description: 'Gibt den Input zurück',
    handler: async (params) => params,
    inputSchema: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          description: 'Nachricht zum Zurückgeben'
        }
      },
      required: ['message']
    }
  },
  get_time: {
    description: 'Gibt die aktuelle Zeit zurück',
    handler: async () => {
      return {
        time: new Date().toISOString(),
        timestamp: Date.now()
      };
    },
    inputSchema: {
      type: 'object',
      properties: {},
      required: []
    }
  },
  read_file_v16: {
    description: 'Liest eine Datei (v16-kompatibler Weg)',
    handler: async (params) => {
      const fs = require('fs');
      const path = require('path');
      
      try {
        const fullPath = path.resolve(params.path);
        const content = fs.readFileSync(fullPath, 'utf8');
        return { content };
      } catch (error) {
        return { error: error.message };
      }
    },
    inputSchema: {
      type: 'object',
      properties: {
        path: {
          type: 'string',
          description: 'Pfad zur zu lesenden Datei'
        }
      },
      required: ['path']
    }
  },
  system_info: {
    description: 'Liefert Systeminformationen',
    handler: async () => {
      const os = require('os');
      return {
        platform: os.platform(),
        release: os.release(),
        hostname: os.hostname(),
        uptime: os.uptime(),
        nodeVersion: process.version
      };
    },
    inputSchema: {
      type: 'object',
      properties: {},
      required: []
    }
  }
};

// Ressourcen Definitionen
const resources = {
  'example': 'Dies ist eine Beispielressource für Tests'
};

// JSON-RPC-Methoden-Handler
const methodHandlers = {
  list_tools: async () => {
    return Object.keys(tools).map(name => ({
      name,
      description: tools[name].description,
      inputSchema: tools[name].inputSchema
    }));
  },
  
  execute_tool: async (params) => {
    const { tool_name, arguments: args } = params;
    const tool = tools[tool_name];
    
    if (!tool) {
      throw new Error(\`Tool nicht gefunden: \${tool_name}\`);
    }
    
    return await tool.handler(args);
  },
  
  list_resources: async () => {
    return Object.keys(resources).map(id => ({ id }));
  },
  
  get_resource: async (params) => {
    const { id } = params;
    const resource = resources[id];
    
    if (resource === undefined) {
      throw new Error(\`Ressource nicht gefunden: \${id}\`);
    }
    
    return resource;
  }
};

// Server erstellen
const server = http.createServer((req, res) => {
  // Nur POST-Anfragen akzeptieren
  if (req.method !== 'POST') {
    res.statusCode = 405;
    res.end(JSON.stringify({
      jsonrpc: '2.0',
      error: { code: -32700, message: 'Nur POST-Methode wird unterstützt' },
      id: null
    }));
    return;
  }

  // JSON-RPC-Anfrage verarbeiten
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });
  
  req.on('end', async () => {
    // Content-Type und CORS-Header setzen
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Antwort vorbereiten
    let response;
    
    try {
      // JSON-RPC-Anfrage parsen
      const request = JSON.parse(body);
      const { jsonrpc, method, params, id } = request;
      
      // Basis-Validierung
      if (jsonrpc !== '2.0') {
        throw new Error('Ungültige oder fehlende jsonrpc Version');
      }
      
      if (!method) {
        throw new Error('Keine Methode angegeben');
      }
      
      // Methode ausführen
      const handler = methodHandlers[method];
      if (!handler) {
        throw new Error(\`Methode nicht gefunden: \${method}\`);
      }
      
      const result = await handler(params || {});
      
      // Erfolgreiche Antwort
      response = {
        jsonrpc: '2.0',
        result,
        id
      };
      
    } catch (error) {
      // Fehlerbehandlung
      console.error('Fehler:', error.message);
      
      response = {
        jsonrpc: '2.0',
        error: {
          code: -32603,
          message: error.message || 'Interner Fehler'
        },
        id: (body && JSON.parse(body).id) || null
      };
    }
    
    // Antwort senden
    res.end(JSON.stringify(response));
  });
});

// Server starten
server.listen(PORT, HOST, () => {
  const address = server.address();
  console.log(\`MCP-Server läuft auf \${address.address}:\${address.port}\`);
  
  // Sende Serverinfo an stdout für MCP-Integration
  console.log(JSON.stringify({
    server_info: {
      host: address.address === '::' ? 'localhost' : address.address,
      port: address.port
    }
  }));
});

// Fehlerbehandlung für Server
server.on('error', (error) => {
  console.error('Server-Fehler:', error.message);
  process.exit(1);
});

// Beende Server sauber bei Programmende
process.on('SIGINT', () => {
  console.log('Server wird beendet...');
  server.close(() => {
    process.exit(0);
  });
});
EOL

  # Mache das Skript ausführbar
  chmod +x "simple_mcp_server_v16.js"
  log "${GREEN}✅ Einfacher lokaler MCP-Server erstellt${NC}"
else
  log "Einfacher lokaler MCP-Server existiert bereits"
fi

# ----- 6. Erstelle und installiere optimale MCP-Konfiguration -----
log "\n${YELLOW}6. Erstelle und installiere optimale MCP-Konfiguration...${NC}"

# Bestimme den Obsidian-Pfad
OBSIDIAN_PATH="$HOME/Documents/Obsidian"
if [ ! -d "$OBSIDIAN_PATH" ]; then
  # Alternative Pfade prüfen
  for alt_path in "$HOME/Obsidian" "$HOME/Library/Application Support/obsidian"; do
    if [ -d "$alt_path" ]; then
      OBSIDIAN_PATH="$alt_path"
      break
    fi
  done
fi

# Bestimme den Canva-Integration-Pfad
CANVA_PATH=""
for path in "$HOME/Documents/Cline/MCP/openrouter-canva" "$HOME/openrouter-canva" "$HOME/canva-integration"; do
  if [ -d "$path" ]; then
    CANVA_PATH="$path"
    break
  fi
done

# Erstelle optimierte Konfiguration
log "Erstelle optimierte MCP-Konfiguration..."

# Grundlegende Konfiguration erstellen
cat > "optimal_mcp_config.json" <<EOL
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
    "github.com/paulad/simple-mcp-server-v16": {
      "command": "node",
      "args": ["$PWD/simple_mcp_server_v16.js"],
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
EOL

# Füge Obsidian-Server hinzu
if [ -n "$OBSIDIAN_PATH" ]; then
  cat >> "optimal_mcp_config.json" <<EOL
,
    "github.com/smithery-ai/mcp-obsidian": {
      "command": "npx",
      "args": ["-y", "mcp-obsidian", "$OBSIDIAN_PATH"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/paulad/mcp-obsidian-local": {
      "command": "node",
      "args": ["$OBSIDIAN_SERVER_DIR/index.js", "$OBSIDIAN_PATH"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Local_Obsidian"
      }
    }
EOL
fi

# Füge Canva-Integration hinzu, falls vorhanden
if [ -n "$CANVA_PATH" ] && [ -f "$CANVA_PATH/index.js" ]; then
  cat >> "optimal_mcp_config.json" <<EOL
,
    "github.com/paulad/canva-integration": {
      "command": "node",
      "args": ["$CANVA_PATH/index.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Canva_Integration"
      }
    }
EOL
fi

# Schließe die JSON-Struktur
cat >> "optimal_mcp_config.json" <<EOL
  }
}
EOL

# Installiere die Konfiguration
log "Installiere optimierte MCP-Konfiguration..."

# Claude Desktop Konfiguration
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "optimal_mcp_config.json" "$CLAUDE_CONFIG"
  log "${GREEN}✅ Optimierte MCP-Konfiguration für Claude Desktop installiert${NC}"
else
  log "${RED}❌ Claude Desktop Konfigurationsdatei nicht gefunden${NC}"
  mkdir -p "$(dirname "$CLAUDE_CONFIG")"
  cp "optimal_mcp_config.json" "$CLAUDE_CONFIG"
  log "${YELLOW}⚠️ Konfigurationsdatei neu angelegt: $CLAUDE_CONFIG${NC}"
fi

# VSCodium Konfiguration, falls vorhanden
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
if [ -d "$(dirname "$VSCODIUM_CONFIG")" ]; then
  if [ -f "$VSCODIUM_CONFIG" ]; then
    cp "$VSCODIUM_CONFIG" "${VSCODIUM_CONFIG}.bak_$TIMESTAMP"
    log "Backup der VSCodium-Konfiguration erstellt: ${VSCODIUM_CONFIG}.bak_$TIMESTAMP"
  fi
  
  cp "optimal_mcp_config.json" "$VSCODIUM_CONFIG"
  log "${GREEN}✅ Optimierte MCP-Konfiguration für VSCodium installiert${NC}"
fi

# ----- 7. Teste MCP-Server -----
log "\n${YELLOW}7. Teste MCP-Server...${NC}"

# Teste Sequential Thinking Server
log "Teste Sequential Thinking Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-sequential-thinking > /tmp/seqthink_test.json 2>/dev/null
if grep -q "sequentialthinking" /tmp/seqthink_test.json; then
  log "${GREEN}✅ Sequential Thinking Server funktioniert${NC}"
else
  log "${RED}❌ Sequential Thinking Server funktioniert nicht${NC}"
fi

# Teste Filesystem Server
log "Teste Filesystem Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-filesystem "$HOME" > /tmp/filesystem_test.json 2>/dev/null
if grep -q "read_file\|write_file" /tmp/filesystem_test.json; then
  log "${GREEN}✅ Filesystem Server funktioniert${NC}"
else
  log "${RED}❌ Filesystem Server funktioniert nicht${NC}"
fi

# Teste GitHub Server
log "Teste GitHub Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-github > /tmp/github_test.json 2>/dev/null
if grep -q "create_repository\|search_repositories" /tmp/github_test.json; then
  log "${GREEN}✅ GitHub Server funktioniert${NC}"
else
  log "${RED}❌ GitHub Server funktioniert nicht${NC}"
fi

# Teste Browser Tools Server
log "Teste Browser Tools Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @agentdeskai/browser-tools-mcp > /tmp/browser_tools_test.json 2>/dev/null
if grep -q "getConsoleLogs\|takeScreenshot" /tmp/browser_tools_test.json; then
  log "${GREEN}✅ Browser Tools Server funktioniert${NC}"
else
  log "${RED}❌ Browser Tools Server funktioniert nicht${NC}"
fi

# Teste Obsidian Server
if [ -n "$OBSIDIAN_PATH" ]; then
  log "Teste Obsidian Server..."
  echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y mcp-obsidian "$OBSIDIAN_PATH" > /tmp/obsidian_test.json 2>/dev/null
  if grep -q "read_notes\|search_notes" /tmp/obsidian_test.json; then
    log "${GREEN}✅ Obsidian Server funktioniert${NC}"
  else
    log "${RED}❌ Obsidian Server funktioniert nicht${NC}"
    
    # Teste lokalen Obsidian-Server als Fallback
    log "Teste lokalen Obsidian-Server als Fallback..."
