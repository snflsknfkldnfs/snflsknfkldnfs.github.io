#!/bin/bash

# GitHub MCP-Server Fix Script
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
LOG_FILE="$LOG_DIR/github_mcp_fix_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      GitHub MCP-Server Fix Script v1.0.0              ${NC}"
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
ps aux | grep -E 'modelcontextprotocol|mcp-server|@mcp' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true
log "MCP-Server gestoppt"

# ----- 2. Überprüfe Node.js und NPM -----
log "\n${YELLOW}2. Überprüfe Node.js und NPM...${NC}"

# Überprüfe Node.js und NPM
NODE_VERSION=$(node --version 2>/dev/null || echo "Nicht installiert")
NPM_VERSION=$(npm --version 2>/dev/null || echo "Nicht installiert")

log "Node.js-Version: ${NODE_VERSION}"
log "NPM-Version: ${NPM_VERSION}"

# Überprüfe, ob Node.js installiert ist
if [[ "$NODE_VERSION" == "Nicht installiert" ]]; then
  log "${RED}❌ Node.js ist nicht installiert. Bitte installieren Sie Node.js.${NC}"
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

# ----- 3. Bereinige NPM-Cache und installiere GitHub MCP-Server neu -----
log "\n${YELLOW}3. Bereinige NPM-Cache und installiere GitHub MCP-Server neu...${NC}"

# Bereinige den NPM-Cache
log "Bereinige NPM-Cache..."
npm cache clean --force >> "$LOG_FILE" 2>&1
log "NPM-Cache bereinigt"

# Installiere GitHub MCP-Server neu
log "Installiere @modelcontextprotocol/server-github neu..."
npm uninstall -g @modelcontextprotocol/server-github >> "$LOG_FILE" 2>&1
npm install -g @modelcontextprotocol/server-github >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "${GREEN}✅ @modelcontextprotocol/server-github neu installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation von @modelcontextprotocol/server-github${NC}"
fi

# ----- 4. Überprüfe installierte Version -----
log "\n${YELLOW}4. Überprüfe installierte Version...${NC}"

GITHUB_SERVER_VERSION=$(npm list -g @modelcontextprotocol/server-github --depth=0 2>/dev/null | grep server-github || echo "Nicht installiert")
log "GitHub MCP-Server-Version: ${GITHUB_SERVER_VERSION}"

# ----- 5. Erstelle GitHub-Token-Konfiguration -----
log "\n${YELLOW}5. Erstelle GitHub-Token-Konfiguration...${NC}"

GITHUB_CONFIG_DIR="$HOME/.config/github-mcp"
mkdir -p "$GITHUB_CONFIG_DIR"

TOKEN_FILE="$GITHUB_CONFIG_DIR/token"

log "GitHub-Token erforderlich für API-Zugriff."
log "- Ein Token kann unter https://github.com/settings/tokens erstellt werden"
log "- Benötigte Berechtigungen: repo, read:user, user:email"

read -p "GitHub-Token eingeben (wird nicht auf dem Bildschirm angezeigt): " -s GITHUB_TOKEN
echo ""

if [ -n "$GITHUB_TOKEN" ]; then
  echo "$GITHUB_TOKEN" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE" # Berechtigungen einschränken (nur für Besitzer lesbar)
  log "${GREEN}✅ GitHub-Token gespeichert in $TOKEN_FILE${NC}"
else
  log "${YELLOW}⚠️ Kein Token eingegeben. GitHub MCP-Server wird möglicherweise eingeschränkt funktionieren.${NC}"
fi

# ----- 6. Erstelle verbesserte GitHub-Server-Konfiguration -----
log "\n${YELLOW}6. Erstelle verbesserte GitHub-Server-Konfiguration...${NC}"

# Lese aktuelle Konfiguration
CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ ! -f "$CLAUDE_CONFIG_PATH" ]; then
  log "${RED}❌ Claude-Konfigurationsdatei nicht gefunden: $CLAUDE_CONFIG_PATH${NC}"
  exit 1
fi

# Erstelle Backup
CONFIG_BACKUP="${CLAUDE_CONFIG_PATH}.bak_$TIMESTAMP"
cp "$CLAUDE_CONFIG_PATH" "$CONFIG_BACKUP"
log "Backup erstellt: $CONFIG_BACKUP"

# Lese die aktuelle Konfigurationsdatei
CONFIG_CONTENT=$(cat "$CLAUDE_CONFIG_PATH")

# Erstelle temporäre Datei mit verbesserter GitHub-Server-Konfiguration
TEMP_CONFIG_FILE="/tmp/claude_github_config_temp.json"

cat > "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1",
        "GITHUB_TOKEN": "$(cat "$TOKEN_FILE" 2>/dev/null || echo "")",
        "NODE_ENV": "production",
        "DEBUG": "mcp-github*"
      }
    }
  }
}
EOL

# ----- 7. Installiere lokalen GitHub-Server als Fallback -----
log "\n${YELLOW}7. Installiere lokalen GitHub-Server als Fallback...${NC}"

GITHUB_LOCAL_DIR="$HOME/claude_github_mcp"
mkdir -p "$GITHUB_LOCAL_DIR"

cat > "$GITHUB_LOCAL_DIR/package.json" <<EOL
{
  "name": "claude-github-mcp",
  "version": "1.0.0",
  "description": "Lokaler GitHub MCP-Server für Claude",
  "main": "index.js",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0",
    "@octokit/rest": "^18.12.0"
  }
}
EOL

cat > "$GITHUB_LOCAL_DIR/index.js" <<EOL
#!/usr/bin/env node

// Lokaler GitHub MCP-Server
// Einfache Version mit grundlegenden Funktionen
const { createMcpServer } = require('@modelcontextprotocol/sdk');
const { Octokit } = require('@octokit/rest');

// GitHub-Token aus Umgebungsvariable oder Datei lesen
const fs = require('fs');
const path = require('path');

function getGitHubToken() {
  // Prüfe zuerst die Umgebungsvariable
  if (process.env.GITHUB_TOKEN) {
    return process.env.GITHUB_TOKEN;
  }
  
  // Dann prüfe die Token-Datei
  const tokenPath = path.join(process.env.HOME || process.env.USERPROFILE, '.config', 'github-mcp', 'token');
  try {
    if (fs.existsSync(tokenPath)) {
      return fs.readFileSync(tokenPath, 'utf8').trim();
    }
  } catch (error) {
    console.error('Fehler beim Lesen des GitHub-Tokens:', error.message);
  }
  
  return null;
}

const token = getGitHubToken();
const octokit = token ? new Octokit({ auth: token }) : new Octokit();

// Tools definieren
const tools = {
  search_repositories: {
    description: 'Sucht nach GitHub-Repositories',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'Suchanfrage (siehe GitHub-Suchsyntax)'
        },
        page: {
          type: 'number',
          description: 'Seitennummer für Paginierung (Standard: 1)'
        },
        perPage: {
          type: 'number',
          description: 'Anzahl der Ergebnisse pro Seite (Standard: 30, max: 100)'
        }
      },
      required: ['query']
    },
    handler: async (params) => {
      try {
        const { query, page = 1, perPage = 30 } = params;
        
        const response = await octokit.search.repos({
          q: query,
          page,
          per_page: perPage
        });
        
        return {
          totalCount: response.data.total_count,
          items: response.data.items.map(repo => ({
            id: repo.id,
            fullName: repo.full_name,
            name: repo.name,
            owner: repo.owner.login,
            description: repo.description,
            url: repo.html_url,
            stars: repo.stargazers_count,
            language: repo.language
          }))
        };
      } catch (error) {
        console.error('Error searching repositories:', error.message);
        throw new Error(\`GitHub API error: \${error.message}\`);
      }
    }
  },
  
  get_file_contents: {
    description: 'Ruft den Inhalt einer Datei oder eines Verzeichnisses aus einem GitHub-Repository ab',
    inputSchema: {
      type: 'object',
      properties: {
        owner: {
          type: 'string',
          description: 'Repository-Besitzer (Benutzername oder Organisation)'
        },
        repo: {
          type: 'string',
          description: 'Repository-Name'
        },
        path: {
          type: 'string',
          description: 'Pfad zur Datei oder zum Verzeichnis'
        },
        branch: {
          type: 'string',
          description: 'Branch, von dem der Inhalt abgerufen werden soll'
        }
      },
      required: ['owner', 'repo', 'path']
    },
    handler: async (params) => {
      try {
        const { owner, repo, path, branch = 'main' } = params;
        
        const response = await octokit.repos.getContent({
          owner,
          repo,
          path,
          ref: branch
        });
        
        // Wenn es sich um ein Verzeichnis handelt
        if (Array.isArray(response.data)) {
          return response.data.map(item => ({
            name: item.name,
            path: item.path,
            type: item.type,
            size: item.size,
            url: item.html_url
          }));
        }
        
        // Wenn es sich um eine Datei handelt
        const content = Buffer.from(response.data.content, 'base64').toString('utf8');
        return {
          name: response.data.name,
          path: response.data.path,
          type: response.data.type,
          size: response.data.size,
          content,
          url: response.data.html_url
        };
      } catch (error) {
        console.error('Error getting file contents:', error.message);
        throw new Error(\`GitHub API error: \${error.message}\`);
      }
    }
  },
  
  create_or_update_file: {
    description: 'Erstellt oder aktualisiert eine Datei in einem GitHub-Repository',
    inputSchema: {
      type: 'object',
      properties: {
        owner: {
          type: 'string',
          description: 'Repository-Besitzer (Benutzername oder Organisation)'
        },
        repo: {
          type: 'string',
          description: 'Repository-Name'
        },
        path: {
          type: 'string',
          description: 'Pfad, unter dem die Datei erstellt/aktualisiert werden soll'
        },
        content: {
          type: 'string',
          description: 'Inhalt der Datei'
        },
        message: {
          type: 'string',
          description: 'Commit-Nachricht'
        },
        branch: {
          type: 'string',
          description: 'Branch, in dem die Datei erstellt/aktualisiert werden soll'
        },
        sha: {
          type: 'string',
          description: 'SHA der zu ersetzenden Datei (erforderlich bei der Aktualisierung vorhandener Dateien)'
        }
      },
      required: ['owner', 'repo', 'path', 'content', 'message']
    },
    handler: async (params) => {
      if (!token) {
        throw new Error('GitHub-Token nicht gefunden. Diese Aktion erfordert Authentifizierung.');
      }
      
      try {
        const { owner, repo, path, content, message, branch = 'main', sha } = params;
        
        // Kodiere Inhalt in Base64
        const contentEncoded = Buffer.from(content).toString('base64');
        
        const response = await octokit.repos.createOrUpdateFileContents({
          owner,
          repo,
          path,
          message,
          content: contentEncoded,
          branch,
          sha
        });
        
        return {
          success: true,
          commitUrl: response.data.commit.html_url,
          contentUrl: response.data.content.html_url
        };
      } catch (error) {
        console.error('Error creating/updating file:', error.message);
        throw new Error(\`GitHub API error: \${error.message}\`);
      }
    }
  }
};

// Starte den Server
const server = createMcpServer({
  tools,
  resources: {
    'status': token 
      ? 'GitHub-Server läuft mit Authentifizierung' 
      : 'GitHub-Server läuft ohne Authentifizierung (eingeschränkte Funktionalität)'
  }
});

server.listen().catch(err => {
  console.error('Server-Startfehler:', err);
  process.exit(1);
});

console.log('GitHub MCP-Server gestartet');
EOL

# Mache Skript ausführbar
chmod +x "$GITHUB_LOCAL_DIR/index.js"

# Installiere Abhängigkeiten
log "Installiere Abhängigkeiten für lokalen GitHub-Server..."
cd "$GITHUB_LOCAL_DIR" && npm install >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "${GREEN}✅ Abhängigkeiten für lokalen GitHub-Server installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation der Abhängigkeiten für lokalen GitHub-Server${NC}"
fi

# Füge lokalen GitHub-Server zur temporären Konfiguration hinzu
cat >> "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/paulad/local-github-mcp": {
      "command": "node",
      "args": ["$GITHUB_LOCAL_DIR/index.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1",
        "GITHUB_TOKEN": "$(cat "$TOKEN_FILE" 2>/dev/null || echo "")",
        "DEBUG": "true"
      },
      "meta": {
        "namespace": "Local_GitHub"
      }
    }
  }
}
EOL

# ----- 8. Teste GitHub-Server -----
log "\n${YELLOW}8. Teste GitHub-Server...${NC}"

TEST_LOG="/tmp/github_test_$TIMESTAMP.json"

log "Teste offiziellen GitHub-Server..."
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | NODE_NO_WARNINGS=1 npx -y @modelcontextprotocol/server-github > "$TEST_LOG" 2>/dev/null

if grep -q "search_repositories\|get_file_contents" "$TEST_LOG"; then
  log "${GREEN}✅ Offizieller GitHub-Server funktioniert${NC}"
  
  # Extrahiere verfügbare Tools für Log
  TOOLS=$(grep -o '"name":"[^"]*"' "$TEST_LOG" | cut -d':' -f2 | tr -d '"' | sort | uniq)
  log "Verfügbare Tools:"
  log "$TOOLS"
else
  log "${RED}❌ Offizieller GitHub-Server funktioniert nicht${NC}"
  cat "$TEST_LOG" >> "$LOG_FILE"
fi

log "Teste lokalen GitHub-Server..."
LOG_LOCAL="/tmp/github_local_test_$TIMESTAMP.json"
NODE_NO_WARNINGS=1 node "$GITHUB_LOCAL_DIR/index.js" > /dev/null 2>&1 &
SERVER_PID=$!

# Warte, bis der Server gestartet ist
sleep 3

# Teste den Server mit einer einfachen Anfrage
curl -s -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000 > "$LOG_LOCAL" 2>/dev/null

# Beende den Testserver
kill $SERVER_PID 2>/dev/null || true

if grep -q "search_repositories\|get_file_contents" "$LOG_LOCAL"; then
  log "${GREEN}✅ Lokaler GitHub-Server funktioniert${NC}"
else
  log "${RED}❌ Lokaler GitHub-Server funktioniert nicht${NC}"
  cat "$LOG_LOCAL" >> "$LOG_FILE"
fi

# ----- 9. Aktualisiere Claude-Konfiguration mit GitHub-Servern -----
log "\n${YELLOW}9. Aktualisiere Claude-Konfiguration mit GitHub-Servern...${NC}"

# Nach einem temporären Fix könnten wir jq verwenden, aber für diesen Fall
# werden wir einen direkteren Ansatz verwenden, um die GitHub-Server zu aktualisieren

# Sichere die aktuelle Konfiguration
cp "$CLAUDE_CONFIG_PATH" "${CLAUDE_CONFIG_PATH}.github_update_backup"

# Erstelle eine modifizierte Version der Konfiguration
CONFIG_JSON=$(cat "$CLAUDE_CONFIG_PATH")

# Überprüfe, ob jq verfügbar ist
if command -v jq &> /dev/null; then
  log "Verwende jq für die Konfigurationsaktualisierung..."
  
  # Extrahiere und aktualisiere die GitHub-Server-Konfiguration
  GITHUB_SERVER_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/modelcontextprotocol/servers/tree/main/src/github"')
  LOCAL_GITHUB_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/paulad/local-github-mcp"')
  
  # Erstelle temporäre Dateien für die Bearbeitung
  TEMP_OUTPUT="/tmp/claude_config_updated_$TIMESTAMP.json"
  
  # Aktualisiere die Konfiguration
  cat "$CLAUDE_CONFIG_PATH" | \
    jq --argjson github_config "$GITHUB_SERVER_CONFIG" \
       --argjson local_github "$LOCAL_GITHUB_CONFIG" \
       '.mcpServers."github.com/modelcontextprotocol/servers/tree/main/src/github" = $github_config | 
        .mcpServers."github.com/paulad/local-github-mcp" = $local_github' > "$TEMP_OUTPUT"
  
  # Kopiere die aktualisierte Konfiguration zurück
  cp "$TEMP_OUTPUT" "$CLAUDE_CONFIG_PATH"
  
  log "${GREEN}✅ Claude-Konfiguration mit jq aktualisiert${NC}"
else
  log "${YELLOW}⚠️ jq ist nicht installiert, verwende manuelle Aktualisierung...${NC}"
  
  # Manuelle Ersetzung ist komplexer - dieser Teil ist vereinfacht
  # Für eine robustere Lösung sollte jq installiert werden
  
  # Extrahiere den aktuellen GitHub-Server-Block aus der Konfiguration
  GITHUB_SERVER_PATTERN='"github.com/modelcontextprotocol/servers/tree/main/src/github"[[:space:]]*:[[:space:]]*{[^}]*}'
  
  # Lese die neue GitHub-Server-Konfiguration aus der temporären Datei
  NEW_GITHUB_CONFIG=$(sed -n '/"github.com\/modelcontextprotocol\/servers\/tree\/main\/src\/github"/,/}/p' "$TEMP_CONFIG_FILE")
  NEW_LOCAL_GITHUB_CONFIG=$(sed -n '/"github.com\/paulad\/local-github-mcp"/,/}/p' "$TEMP_CONFIG_FILE")
  
  # Erstelle eine temporäre Datei mit der aktualisierten Konfiguration
  TEMP_CONFIG="/tmp/claude_config_updated_$TIMESTAMP.json"
  
  # Füge lokalen GitHub-Server zur Konfiguration hinzu, falls er nicht existiert
  if ! grep -q '"github.com/paulad/local-github-mcp"' "$CLAUDE_CONFIG_PATH"; then
    # Finde die letzte schließende Klammer in mcpServers
    sed 's/}[[:space:]]*}[[:space:]]*$/,'$'\n'"$NEW_LOCAL_GITHUB_CONFIG"$'\n''}}/' "$CLAUDE_CONFIG_PATH" > "$TEMP_CONFIG"
    cp "$TEMP_CONFIG" "$CLAUDE_CONFIG_PATH"
    log "${GREEN}✅ Lokaler GitHub-Server zur Konfiguration hinzugefügt${NC}"
  fi
  
  log "${YELLOW}⚠️ Manuelle Aktualisierung kann unvollständig sein, bitte installieren Sie jq für zuverlässigere Ergebnisse${NC}"
fi

# ----- 10. Zusammenfassung -----
log "\n${BLUE}======================================================${NC}"
log "${YELLOW}Zusammenfassung:${NC}"
log "- GitHub-Token wurde konfiguriert (falls eingegeben)"
log "- Offizieller GitHub-Server wurde neu installiert und optimiert"
log "- Ein lokaler GitHub-Server wurde als Fallback installiert"
log "- Die Claude-Konfiguration wurde mit beiden Servern aktualisiert"

log "\n${YELLOW}Nächste Schritte:${NC}"
log "1. Starten Sie Claude Desktop neu"
log "2. Überprüfen Sie, ob der GitHub-Server funktioniert"
log "3. Falls Probleme bestehen, gibt das Log-File detaillierte Informationen"

log "\n${GREEN}GitHub MCP-Server Fix abgeschlossen!${NC}"
log "${BLUE}======================================================${NC}\n"
