#!/bin/bash

# Obsidian MCP-Server Fix Script
# Autor: Claude
# Datum: 26.5.2025
# Version: 1.0.0

# Farben für formatierte Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Erzeuge Verzeichnis für Logs
LOG_DIR="$HOME/claude_mcp_logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/obsidian_mcp_fix_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      Obsidian MCP-Server Fix Script v1.0.0            ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# ----- 1. Stoppe laufende Prozesse -----
log "${YELLOW}1. Stoppe laufende MCP-Prozesse...${NC}"

# Stoppe Claude Desktop, falls es läuft
log "Stoppe Claude Desktop, falls es läuft..."
pkill -f "Claude Desktop" || log "Claude Desktop läuft nicht"

# Stoppe alle laufenden MCP-Server
log "Stoppe alle laufenden MCP-Server..."
ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp|mcp-obsidian' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true
log "MCP-Server gestoppt"

# ----- 2. Überprüfe Obsidian Installation und Pfade -----
log "\n${YELLOW}2. Überprüfe Obsidian Installation und Pfade...${NC}"

# Prüfe mögliche Obsidian-Pfade
OBSIDIAN_PATHS=(
  "$HOME/Documents/Obsidian"
  "$HOME/Obsidian"
  "$HOME/Library/Application Support/obsidian"
)

OBSIDIAN_PATH=""
for path in "${OBSIDIAN_PATHS[@]}"; do
  if [ -d "$path" ]; then
    OBSIDIAN_PATH="$path"
    log "${GREEN}✅ Obsidian-Verzeichnis gefunden: $OBSIDIAN_PATH${NC}"
    break
  fi
done

if [ -z "$OBSIDIAN_PATH" ]; then
  log "${RED}❌ Kein Obsidian-Verzeichnis gefunden.${NC}"
  log "Bitte geben Sie den Pfad zu Ihrem Obsidian-Verzeichnis an:"
  read -p "Obsidian-Pfad: " OBSIDIAN_PATH
  
  if [ -z "$OBSIDIAN_PATH" ] || [ ! -d "$OBSIDIAN_PATH" ]; then
    log "${RED}❌ Ungültiger Obsidian-Pfad. Skript wird beendet.${NC}"
    exit 1
  fi
fi

log "Obsidian-Verzeichnisstruktur:"
find "$OBSIDIAN_PATH" -type d -maxdepth 2 | sort | tee -a "$LOG_FILE" || log "${RED}❌ Konnte Verzeichnisstruktur nicht anzeigen${NC}"

# ----- 3. Bereinige NPM-Cache und installiere Obsidian MCP-Server neu -----
log "\n${YELLOW}3. Bereinige NPM-Cache und installiere Obsidian MCP-Server neu...${NC}"

# Bereinige den NPM-Cache
log "Bereinige NPM-Cache..."
npm cache clean --force >> "$LOG_FILE" 2>&1
log "NPM-Cache bereinigt"

# Installiere Obsidian MCP-Server neu
log "Installiere mcp-obsidian neu..."
npm uninstall -g mcp-obsidian >> "$LOG_FILE" 2>&1
npm install -g mcp-obsidian >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "${GREEN}✅ mcp-obsidian neu installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation von mcp-obsidian${NC}"
  log "Versuche Installation mit npm..."
  
  # Alternative Installation mit npm direkt
  npm install -g mcp-obsidian@latest >> "$LOG_FILE" 2>&1
  
  if [ $? -eq 0 ]; then
    log "${GREEN}✅ mcp-obsidian erfolgreich mit npm installiert${NC}"
  else
    log "${RED}❌ Alle Installationsversuche für mcp-obsidian gescheitert${NC}"
  fi
fi

# ----- 4. Überprüfe installierte Version -----
log "\n${YELLOW}4. Überprüfe installierte Version...${NC}"

OBSIDIAN_SERVER_VERSION=$(npm list -g mcp-obsidian --depth=0 2>/dev/null | grep mcp-obsidian || echo "Nicht installiert")
log "Obsidian MCP-Server-Version: ${OBSIDIAN_SERVER_VERSION}"

# ----- 5. Erstelle lokalen Obsidian-Server als zuverlässigen Fallback -----
log "\n${YELLOW}5. Erstelle lokalen Obsidian-Server als Fallback...${NC}"

OBSIDIAN_LOCAL_DIR="$HOME/claude_obsidian_mcp"
mkdir -p "$OBSIDIAN_LOCAL_DIR"

cat > "$OBSIDIAN_LOCAL_DIR/package.json" <<EOL
{
  "name": "claude-obsidian-mcp",
  "version": "1.0.0",
  "description": "Lokaler Obsidian MCP-Server für Claude",
  "main": "index.js",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0"
  }
}
EOL

cat > "$OBSIDIAN_LOCAL_DIR/index.js" <<EOL
#!/usr/bin/env node

// Einfacher lokaler Obsidian MCP-Server
// Optimiert für bessere Kompatibilität mit Claude Desktop
const fs = require('fs');
const path = require('path');
const { createMcpServer } = require('@modelcontextprotocol/sdk');

// Konfiguriere Obsidian-Pfad aus Kommandozeile oder Standard
const OBSIDIAN_PATH = process.argv[2] || "$OBSIDIAN_PATH";

if (!fs.existsSync(OBSIDIAN_PATH)) {
  console.error(\`Fehler: Obsidian-Verzeichnis nicht gefunden: \${OBSIDIAN_PATH}\`);
  process.exit(1);
}

console.log(\`Obsidian-Server startet mit Vault-Pfad: \${OBSIDIAN_PATH}\`);

// Definiere die Tools
const tools = {
  read_notes: {
    description: 'Liest den Inhalt mehrerer Notizen aus dem Obsidian-Vault',
    inputSchema: {
      type: 'object',
      properties: {
        paths: {
          type: 'array',
          items: { type: 'string' }
        }
      },
      required: ['paths']
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
        query: { type: 'string' }
      },
      required: ['query']
    },
    handler: async (params) => {
      const { query } = params;
      const results = [];
      
      function searchDirectory(dirPath, relativePath = '') {
        try {
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
        } catch (error) {
          console.error(\`Fehler beim Durchsuchen von \${dirPath}: \${error.message}\`);
        }
      }
      
      searchDirectory(OBSIDIAN_PATH);
      return results;
    }
  },
  
  list_folders: {
    description: 'Listet alle Ordner im Obsidian-Vault auf',
    inputSchema: {
      type: 'object',
      properties: {
        path: { 
          type: 'string',
          description: 'Relativer Pfad im Vault (optional)'
        }
      }
    },
    handler: async (params) => {
      const relativePath = params.path || '';
      const dirPath = path.join(OBSIDIAN_PATH, relativePath);
      const folders = [];
      
      try {
        if (!fs.existsSync(dirPath)) {
          throw new Error(\`Verzeichnis nicht gefunden: \${relativePath}\`);
        }
        
        const entries = fs.readdirSync(dirPath, { withFileTypes: true });
        
        for (const entry of entries) {
          if (entry.isDirectory()) {
            folders.push({
              name: entry.name,
              path: path.join(relativePath, entry.name)
            });
          }
        }
        
        return folders;
      } catch (error) {
        throw new Error(\`Fehler beim Auflisten der Ordner: \${error.message}\`);
      }
    }
  },
  
  list_notes: {
    description: 'Listet alle Notizen in einem bestimmten Ordner im Obsidian-Vault',
    inputSchema: {
      type: 'object',
      properties: {
        folder: { 
          type: 'string',
          description: 'Relativer Pfad zum Ordner im Vault'
        }
      },
      required: ['folder']
    },
    handler: async (params) => {
      const { folder } = params;
      const dirPath = path.join(OBSIDIAN_PATH, folder);
      const notes = [];
      
      try {
        if (!fs.existsSync(dirPath)) {
          throw new Error(\`Verzeichnis nicht gefunden: \${folder}\`);
        }
        
        const entries = fs.readdirSync(dirPath, { withFileTypes: true });
        
        for (const entry of entries) {
          if (entry.isFile() && (entry.name.endsWith('.md') || entry.name.endsWith('.txt'))) {
            notes.push({
              name: entry.name,
              path: path.join(folder, entry.name)
            });
          }
        }
        
        return notes;
      } catch (error) {
        throw new Error(\`Fehler beim Auflisten der Notizen: \${error.message}\`);
      }
    }
  }
};

// Erstelle und starte den Server
const server = createMcpServer({
  tools,
  resources: {
    'vault_path': OBSIDIAN_PATH,
    'status': 'Lokaler Obsidian-Server läuft',
    'server_version': '1.0.0'
  }
});

server.listen().catch(err => {
  console.error('Server-Startfehler:', err);
  process.exit(1);
});

console.log('Obsidian MCP-Server gestartet');
EOL

# Mache Skript ausführbar
chmod +x "$OBSIDIAN_LOCAL_DIR/index.js"

# Installiere Abhängigkeiten
log "Installiere Abhängigkeiten für lokalen Obsidian-Server..."
cd "$OBSIDIAN_LOCAL_DIR" && npm install >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "${GREEN}✅ Abhängigkeiten für lokalen Obsidian-Server installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation der Abhängigkeiten für lokalen Obsidian-Server${NC}"
fi

# ----- 6. Erstelle vereinfachte Obsidian-Server-Konfiguration für Claude -----
log "\n${YELLOW}6. Erstelle verbesserte Obsidian-Server-Konfiguration...${NC}"

# Lese aktuelle Konfiguration
CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ ! -f "$CLAUDE_CONFIG_PATH" ]; then
  log "${RED}❌ Claude-Konfigurationsdatei nicht gefunden: $CLAUDE_CONFIG_PATH${NC}"
  exit 1
fi

# Erstelle Backup
CONFIG_BACKUP="${CLAUDE_CONFIG_PATH}.bak_obsidian_$TIMESTAMP"
cp "$CLAUDE_CONFIG_PATH" "$CONFIG_BACKUP"
log "Backup erstellt: $CONFIG_BACKUP"

# Erstelle temporäre Datei mit verbesserter Obsidian-Server-Konfiguration
TEMP_CONFIG_FILE="/tmp/claude_obsidian_config_temp.json"

cat > "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/smithery-ai/mcp-obsidian": {
      "command": "npx",
      "args": ["-y", "mcp-obsidian", "$OBSIDIAN_PATH"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "mcp-obsidian*",
        "NODE_ENV": "production",
        "NODE_OPTIONS": "--no-deprecation"
      }
    }
  }
}
EOL

# Füge lokalen Obsidian-Server zur temporären Konfiguration hinzu
cat >> "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/paulad/local-obsidian-mcp": {
      "command": "node",
      "args": ["$OBSIDIAN_LOCAL_DIR/index.js", "$OBSIDIAN_PATH"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "true",
        "NODE_OPTIONS": "--no-deprecation"
      },
      "meta": {
        "namespace": "Local_Obsidian"
      }
    }
  }
}
EOL

# ----- 7. Erstelle einfachen direkten Obsidian-Server mit minimaler Abhängigkeit -----
log "\n${YELLOW}7. Erstelle minimalen Obsidian-Server...${NC}"

MINIMAL_OBSIDIAN_DIR="$HOME/minimal_obsidian_mcp"
mkdir -p "$MINIMAL_OBSIDIAN_DIR"

cat > "$MINIMAL_OBSIDIAN_DIR/server.js" <<EOL
#!/usr/bin/env node

// Minimalistischer Obsidian MCP-Server ohne externe Abhängigkeiten
// Verwendet nur Node.js Standard-Module
const http = require('http');
const fs = require('fs');
const path = require('path');

// Konfiguration
const PORT = process.env.PORT || 0;
const HOST = process.env.HOST || 'localhost';
const OBSIDIAN_PATH = process.argv[2] || "$OBSIDIAN_PATH";

// Prüfe, ob Obsidian-Verzeichnis existiert
if (!fs.existsSync(OBSIDIAN_PATH)) {
  console.error(\`Fehler: Obsidian-Verzeichnis nicht gefunden: \${OBSIDIAN_PATH}\`);
  process.exit(1);
}

// Tools Definitionen
const tools = {
  read_notes: {
    description: 'Liest mehrere Notizen aus dem Obsidian-Vault',
    handler: async (params) => {
      const { paths } = params;
      if (!Array.isArray(paths)) {
        throw new Error('Parameter "paths" muss ein Array sein');
      }
      
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
    },
    inputSchema: {
      type: 'object',
      properties: {
        paths: {
          type: 'array',
          items: { type: 'string' }
        }
      },
      required: ['paths']
    }
  },
  
  search_notes: {
    description: 'Sucht nach Notizen anhand des Namens',
    handler: async (params) => {
      const { query } = params;
      if (typeof query !== 'string') {
        throw new Error('Parameter "query" muss ein String sein');
      }
      
      const results = [];
      
      function searchDirectory(dirPath, relativePath = '') {
        try {
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
        } catch (error) {
          console.error(\`Fehler beim Durchsuchen von \${dirPath}: \${error.message}\`);
        }
      }
      
      searchDirectory(OBSIDIAN_PATH);
      return results;
    },
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string' }
      },
      required: ['query']
    }
  }
};

// Ressourcen Definitionen
const resources = {
  'vault_path': OBSIDIAN_PATH,
  'status': 'Minimaler Obsidian MCP-Server läuft'
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
  console.log(\`Minimaler Obsidian MCP-Server läuft auf \${address.address}:\${address.port}\`);
  
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

# Mache Skript ausführbar
chmod +x "$MINIMAL_OBSIDIAN_DIR/server.js"

log "${GREEN}✅ Minimalen Obsidian-Server erstellt: $MINIMAL_OBSIDIAN_DIR/server.js${NC}"

# Füge minimalen Obsidian-Server zur temporären Konfiguration hinzu
cat >> "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/paulad/minimal-obsidian-mcp": {
      "command": "node",
      "args": ["$MINIMAL_OBSIDIAN_DIR/server.js", "$OBSIDIAN_PATH"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Minimal_Obsidian"
      }
    }
  }
}
EOL

# ----- 8. Teste Obsidian-Server -----
log "\n${YELLOW}8. Teste Obsidian-Server...${NC}"

TEST_LOG="/tmp/obsidian_test_$TIMESTAMP.json"

log "Teste offiziellen Obsidian-Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y mcp-obsidian "$OBSIDIAN_PATH" > "$TEST_LOG" 2>/dev/null

if grep -q "read_notes\|search_notes" "$TEST_LOG"; then
  log "${GREEN}✅ Offizieller Obsidian-Server funktioniert${NC}"
  
  # Extrahiere verfügbare Tools für Log
  TOOLS=$(grep -o '"name":"[^"]*"' "$TEST_LOG" | cut -d':' -f2 | tr -d '"' | sort | uniq)
  log "Verfügbare Tools:"
  log "$TOOLS"
else
  log "${RED}❌ Offizieller Obsidian-Server funktioniert nicht${NC}"
  cat "$TEST_LOG" >> "$LOG_FILE"
fi

log "Teste lokalen Obsidian-Server..."
LOG_LOCAL="/tmp/obsidian_local_test_$TIMESTAMP.json"
NODE_NO_WARNINGS=1 node "$OBSIDIAN_LOCAL_DIR/index.js" "$OBSIDIAN_PATH" > /dev/null 2>&1 &
SERVER_PID=$!

# Warte, bis der Server gestartet ist
sleep 3

# Teste den Server mit einer einfachen Anfrage
curl -s -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000 > "$LOG_LOCAL" 2>/dev/null

# Beende den Testserver
kill $SERVER_PID 2>/dev/null || true

if grep -q "read_notes\|search_notes" "$LOG_LOCAL"; then
  log "${GREEN}✅ Lokaler Obsidian-Server funktioniert${NC}"
else
  log "${RED}❌ Lokaler Obsidian-Server funktioniert nicht${NC}"
  cat "$LOG_LOCAL" >> "$LOG_FILE"
fi

log "Teste minimalen Obsidian-Server..."
LOG_MINIMAL="/tmp/obsidian_minimal_test_$TIMESTAMP.json"
NODE_NO_WARNINGS=1 node "$MINIMAL_OBSIDIAN_DIR/server.js" "$OBSIDIAN_PATH" > /dev/null 2>&1 &
SERVER_PID=$!

# Warte, bis der Server gestartet ist
sleep 3

# Teste den Server mit einer einfachen Anfrage
curl -s -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000 > "$LOG_MINIMAL" 2>/dev/null

# Beende den Testserver
kill $SERVER_PID 2>/dev/null || true

if grep -q "read_notes\|search_notes" "$LOG_MINIMAL"; then
  log "${GREEN}✅ Minimaler Obsidian-Server funktioniert${NC}"
else
  log "${RED}❌ Minimaler Obsidian-Server funktioniert nicht${NC}"
  cat "$LOG_MINIMAL" >> "$LOG_FILE"
fi

# ----- 9. Aktualisiere Claude-Konfiguration mit Obsidian-Servern -----
log "\n${YELLOW}9. Aktualisiere Claude-Konfiguration mit Obsidian-Servern...${NC}"

# Überprüfe, ob jq verfügbar ist
if command -v jq &> /dev/null; then
  log "Verwende jq für die Konfigurationsaktualisierung..."
  
  # Extrahiere und aktualisiere die Obsidian-Server-Konfigurationen
  OBSIDIAN_SERVER_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/smithery-ai/mcp-obsidian"')
  LOCAL_OBSIDIAN_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/paulad/local-obsidian-mcp"')
  MINIMAL_OBSIDIAN_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/paulad/minimal-obsidian-mcp"')
  
  # Erstelle temporäre Dateien für die Bearbeitung
  TEMP_OUTPUT="/tmp/claude_config_updated_obsidian_$TIMESTAMP.json"
  
  # Aktualisiere die Konfiguration
  cat "$CLAUDE_CONFIG_PATH" | \
    jq --argjson obsidian_config "$OBSIDIAN_SERVER_CONFIG" \
       --argjson local_obsidian "$LOCAL_OBSIDIAN_CONFIG" \
       --argjson minimal_obsidian "$MINIMAL_OBSIDIAN_CONFIG" \
       '.mcpServers."github.com/smithery-ai/mcp-obs
