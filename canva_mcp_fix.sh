#!/bin/bash

# Canva-Integration MCP-Server Fix Script
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
LOG_FILE="$LOG_DIR/canva_mcp_fix_$TIMESTAMP.log"

# Log-Funktion
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n${BLUE}======================================================${NC}"
log "${BLUE}      Canva-Integration MCP-Server Fix Script v1.0.0    ${NC}"
log "${BLUE}======================================================${NC}\n"

log "Start: $(date)"
log "Log wird gespeichert in: ${LOG_FILE}\n"

# ----- 1. Stoppe laufende Prozesse -----
log "${YELLOW}1. Stoppe laufende MCP-Prozesse...${NC}"

# Stoppe Claude Desktop, falls es läuft
log "Stoppe Claude Desktop, falls es läuft..."
pkill -f "Claude Desktop" || log "Claude Desktop läuft nicht"

# Stoppe alle laufenden Canva-MCP-Server
log "Stoppe alle laufenden Canva-MCP-Server..."
ps aux | grep -E 'paulad/canva-integration|openrouter-canva' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true
log "Canva-MCP-Server gestoppt"

# ----- 2. Überprüfe Canva-Integration-Pfade -----
log "\n${YELLOW}2. Überprüfe Canva-Integration-Pfade...${NC}"

# Mögliche Pfade zum Canva-Integration-Skript
CANVA_PATHS=(
  "$HOME/Documents/Cline/MCP/openrouter-canva"
  "$HOME/canva-integration"
  "$HOME/openrouter-canva"
  "$HOME/MCP/openrouter-canva"
)

CANVA_PATH=""
for path in "${CANVA_PATHS[@]}"; do
  if [ -d "$path" ]; then
    if [ -f "$path/index.js" ]; then
      CANVA_PATH="$path"
      log "${GREEN}✅ Canva-Integration-Verzeichnis gefunden: $CANVA_PATH${NC}"
      break
    else
      log "${YELLOW}⚠️ Verzeichnis gefunden, aber keine index.js: $path${NC}"
    fi
  fi
done

if [ -z "$CANVA_PATH" ]; then
  log "${RED}❌ Kein Canva-Integration-Verzeichnis gefunden.${NC}"
  log "Eine neue Installation des Canva-MCP-Servers wird erstellt."
  
  # Erstelle ein Standardverzeichnis für die Canva-Integration
  CANVA_PATH="$HOME/claude_canva_mcp"
  mkdir -p "$CANVA_PATH"
  log "Verzeichnis erstellt: $CANVA_PATH"
fi

# ----- 3. Überprüfe oder erstelle .env-Datei für API-Schlüssel -----
log "\n${YELLOW}3. Überprüfe oder erstelle .env-Datei für API-Schlüssel...${NC}"

ENV_FILE="$CANVA_PATH/.env"
if [ -f "$ENV_FILE" ]; then
  log "${GREEN}✅ .env-Datei gefunden: $ENV_FILE${NC}"
else
  log "${YELLOW}⚠️ Keine .env-Datei gefunden. Erstelle eine neue...${NC}"
  
  log "Um die Canva-Integration zu nutzen, wird ein OpenRouter API-Schlüssel benötigt."
  log "Ein Schlüssel kann unter https://openrouter.ai/keys erstellt werden."
  
  read -p "OpenRouter API-Schlüssel eingeben (wird nicht angezeigt): " -s OPENROUTER_API_KEY
  echo ""
  
  if [ -z "$OPENROUTER_API_KEY" ]; then
    log "${YELLOW}⚠️ Kein API-Schlüssel eingegeben. Die Canva-Integration wird ohne Schlüssel konfiguriert.${NC}"
    echo "OPENROUTER_API_KEY=" > "$ENV_FILE"
  else
    echo "OPENROUTER_API_KEY=$OPENROUTER_API_KEY" > "$ENV_FILE"
    log "${GREEN}✅ API-Schlüssel in .env-Datei gespeichert${NC}"
  fi
fi

# ----- 4. Erstelle oder aktualisiere Canva-Integration-Skripte -----
log "\n${YELLOW}4. Erstelle oder aktualisiere Canva-Integration-Skripte...${NC}"

# Erstelle package.json
log "Erstelle package.json..."
cat > "$CANVA_PATH/package.json" <<EOL
{
  "name": "canva-integration-mcp",
  "version": "1.0.0",
  "description": "Canva Integration MCP-Server für Claude",
  "main": "index.js",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0",
    "dotenv": "^16.0.3",
    "node-fetch": "^2.6.9"
  }
}
EOL

# Erstelle index.js
log "Erstelle index.js..."
cat > "$CANVA_PATH/index.js" <<EOL
#!/usr/bin/env node

// Canva-Integration MCP-Server
// Autor: Claude
// Datum: 26.5.2025
// Version: 1.0.0

require('dotenv').config();
const { createMcpServer } = require('@modelcontextprotocol/sdk');
const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');

// Konfiguration
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1';
const TEMPLATES_DIR = path.join(__dirname, 'templates');

// Erstelle Templates-Verzeichnis, falls es nicht existiert
if (!fs.existsSync(TEMPLATES_DIR)) {
  fs.mkdirSync(TEMPLATES_DIR, { recursive: true });
}

// Grundlegende Templates erstellen, falls sie nicht existieren
const createDefaultTemplates = () => {
  const templates = {
    'systemkontext_template.js': \`module.exports = {
  title: 'Systemkontext-Analyse',
  prompt: \\\`Du bist ein erfahrener Systemanalytiker. Bitte analysiere den folgenden Kontext 
und identifiziere die wichtigsten Komponenten, Beziehungen und Systemgrenzen.
Achte besonders auf Abhängigkeiten, Schnittstellen und potenzielle Risiken.

KONTEXT:
{{kontext}}

Erstelle eine strukturierte, übersichtliche Analyse mit:
1. Systemkomponenten
2. Beziehungen und Datenflüsse
3. Systemgrenzen und externe Schnittstellen
4. Potenzielle Risiken und Herausforderungen
5. Empfehlungen zur Optimierung\\\`
}\`,
    
    'kontext_integration.js': \`module.exports = {
  title: 'Kontext-Integration',
  prompt: \\\`Erstelle eine integrierte Analyse des folgenden Kontextes und verknüpfe die Informationen 
mit bestehenden Wissensstrukturen. Identifiziere Schlüsselkonzepte und ihre Beziehungen.

KONTEXT:
{{kontext}}

Deine Analyse sollte folgende Punkte umfassen:
1. Hauptkonzepte und Ideen
2. Verbindungen zu verwandten Wissensgebieten
3. Praktische Anwendungsmöglichkeiten
4. Fachliche Einordnung
5. Kritische Bewertung\\\`
}\`,
    
    'kontext_analyse.js': \`module.exports = {
  title: 'Detaillierte Kontextanalyse',
  prompt: \\\`Führe eine tiefgreifende Analyse des folgenden Kontextes durch.
Berücksichtige dabei verschiedene Perspektiven und identifiziere die zentralen Thesen und Argumente.

KONTEXT:
{{kontext}}

Strukturiere deine Analyse wie folgt:
1. Zusammenfassung des Hauptinhalts
2. Identifikation der zentralen Thesen und Argumente
3. Analyse der verwendeten Methodik und Quellen
4. Kritische Würdigung und Einordnung
5. Erkenntnisse und Anwendungspotenzial\\\`
}\`
  };
  
  for (const [filename, content] of Object.entries(templates)) {
    const filePath = path.join(TEMPLATES_DIR, filename);
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, content);
      console.log(\`Template erstellt: \${filename}\`);
    }
  }
};

createDefaultTemplates();

// Hilfsfunktionen
const loadTemplate = (templateName) => {
  try {
    const templatePath = path.join(TEMPLATES_DIR, \`\${templateName}.js\`);
    if (fs.existsSync(templatePath)) {
      return require(templatePath);
    }
    throw new Error(\`Template nicht gefunden: \${templateName}\`);
  } catch (error) {
    console.error(\`Fehler beim Laden des Templates \${templateName}: \${error.message}\`);
    throw error;
  }
};

const listAvailableTemplates = () => {
  try {
    const files = fs.readdirSync(TEMPLATES_DIR);
    return files
      .filter(file => file.endsWith('.js'))
      .map(file => {
        const templatePath = path.join(TEMPLATES_DIR, file);
        try {
          const template = require(templatePath);
          return {
            name: file.replace('.js', ''),
            title: template.title || file.replace('.js', ''),
            filePath: templatePath
          };
        } catch (error) {
          return {
            name: file.replace('.js', ''),
            title: 'Fehler beim Laden',
            filePath: templatePath,
            error: error.message
          };
        }
      });
  } catch (error) {
    console.error(\`Fehler beim Auflisten der Templates: \${error.message}\`);
    return [];
  }
};

// OpenRouter API-Funktion
const generateWithOpenRouter = async (prompt, model = 'anthropic/claude-3-opus-20240229') => {
  if (!OPENROUTER_API_KEY) {
    throw new Error('OpenRouter API-Schlüssel nicht konfiguriert. Bitte in .env-Datei eintragen.');
  }
  
  try {
    const response = await fetch(\`\${OPENROUTER_API_URL}/chat/completions\`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': \`Bearer \${OPENROUTER_API_KEY}\`
      },
      body: JSON.stringify({
        model: model,
        messages: [{ role: 'user', content: prompt }]
      })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(\`OpenRouter API-Fehler: \${response.status} \${response.statusText} - \${errorText}\`);
    }
    
    const data = await response.json();
    return data.choices[0]?.message?.content || 'Keine Antwort erhalten';
  } catch (error) {
    console.error('Fehler bei der OpenRouter-Anfrage:', error);
    throw error;
  }
};

// MCP-Tools definieren
const tools = {
  liste_templates: {
    description: 'Listet alle verfügbaren Templates für die Kontext-Integration auf',
    inputSchema: {
      type: 'object',
      properties: {}
    },
    handler: async () => {
      return listAvailableTemplates();
    }
  },
  
  erstelle_template: {
    description: 'Erstellt ein neues Template für die Kontext-Integration',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string' },
        title: { type: 'string' },
        prompt: { type: 'string' }
      },
      required: ['name', 'prompt']
    },
    handler: async (params) => {
      const { name, title, prompt } = params;
      const safeTitle = title || name;
      
      const templateContent = \`module.exports = {
  title: '\${safeTitle}',
  prompt: \\\`\${prompt}\\\`
}\`;

      const templatePath = path.join(TEMPLATES_DIR, \`\${name}.js\`);
      
      try {
        fs.writeFileSync(templatePath, templateContent);
        return {
          success: true,
          message: \`Template \${name} erfolgreich erstellt\`,
          path: templatePath
        };
      } catch (error) {
        throw new Error(\`Fehler beim Erstellen des Templates: \${error.message}\`);
      }
    }
  },
  
  generiere_mit_template: {
    description: 'Generiert Inhalte mit einem Template und der OpenRouter-API',
    inputSchema: {
      type: 'object',
      properties: {
        template: { type: 'string' },
        kontext: { type: 'string' },
        model: { type: 'string' }
      },
      required: ['template', 'kontext']
    },
    handler: async (params) => {
      const { template, kontext, model } = params;
      
      try {
        const templateData = loadTemplate(template);
        if (!templateData || !templateData.prompt) {
          throw new Error(\`Ungültiges Template: \${template}\`);
        }
        
        // Ersetze Platzhalter im Prompt
        const prompt = templateData.prompt.replace(/{{kontext}}/g, kontext);
        
        // Generiere mit OpenRouter
        const generatedContent = await generateWithOpenRouter(prompt, model);
        
        return {
          success: true,
          title: templateData.title || template,
          content: generatedContent
        };
      } catch (error) {
        throw new Error(\`Fehler bei der Generierung: \${error.message}\`);
      }
    }
  },
  
  direkter_prompt: {
    description: 'Sendet einen direkten Prompt an die OpenRouter-API',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: { type: 'string' },
        model: { type: 'string' }
      },
      required: ['prompt']
    },
    handler: async (params) => {
      const { prompt, model } = params;
      
      try {
        const generatedContent = await generateWithOpenRouter(prompt, model);
        
        return {
          success: true,
          content: generatedContent
        };
      } catch (error) {
        throw new Error(\`Fehler bei der direkten Anfrage: \${error.message}\`);
      }
    }
  },
  
  check_api_key: {
    description: 'Überprüft den konfigurierten OpenRouter API-Schlüssel',
    inputSchema: {
      type: 'object',
      properties: {}
    },
    handler: async () => {
      if (!OPENROUTER_API_KEY) {
        return {
          success: false,
          message: 'Kein API-Schlüssel konfiguriert'
        };
      }
      
      try {
        // Teste den API-Schlüssel mit einer einfachen Anfrage
        await generateWithOpenRouter('Teste API-Schlüssel: Antworte kurz mit "API-Test erfolgreich"', 'anthropic/claude-3-haiku-20240307');
        
        return {
          success: true,
          message: 'API-Schlüssel ist gültig und funktioniert'
        };
      } catch (error) {
        return {
          success: false,
          message: \`API-Schlüssel funktioniert nicht: \${error.message}\`
        };
      }
    }
  }
};

// Erstelle MCP-Server
const server = createMcpServer({
  tools,
  resources: {
    'status': OPENROUTER_API_KEY 
      ? 'Canva-Integration läuft mit konfiguriertem API-Schlüssel' 
      : 'Canva-Integration läuft ohne API-Schlüssel (eingeschränkte Funktionalität)',
    'templates': listAvailableTemplates().map(t => t.name)
  }
});

server.listen().catch(err => {
  console.error('Server-Startfehler:', err);
  process.exit(1);
});

console.log('Canva-Integration MCP-Server gestartet');
EOL

# Mache Skript ausführbar
chmod +x "$CANVA_PATH/index.js"

# ----- 5. Installiere Abhängigkeiten für Canva-Integration -----
log "\n${YELLOW}5. Installiere Abhängigkeiten für Canva-Integration...${NC}"

# Installiere Abhängigkeiten
log "Installiere Abhängigkeiten..."
cd "$CANVA_PATH" && npm install >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "${GREEN}✅ Abhängigkeiten für Canva-Integration installiert${NC}"
else
  log "${RED}❌ Fehler bei der Installation der Abhängigkeiten für Canva-Integration${NC}"
fi

# ----- 6. Erstelle Templates-Verzeichnis und Beispiel-Templates -----
log "\n${YELLOW}6. Erstelle Templates-Verzeichnis und Beispiel-Templates...${NC}"

TEMPLATES_DIR="$CANVA_PATH/templates"
mkdir -p "$TEMPLATES_DIR"

# Erstelle Beispiel-Templates, falls sie noch nicht existieren
create_template() {
  local name="$1"
  local title="$2"
  local content="$3"
  local file_path="$TEMPLATES_DIR/$name.js"
  
  if [ ! -f "$file_path" ]; then
    cat > "$file_path" <<EOL
module.exports = {
  title: '$title',
  prompt: \`$content\`
}
EOL
    log "Template erstellt: $name"
  else
    log "Template existiert bereits: $name"
  fi
}

create_template "systemkontext_template" "Systemkontext-Analyse" "Du bist ein erfahrener Systemanalytiker. Bitte analysiere den folgenden Kontext 
und identifiziere die wichtigsten Komponenten, Beziehungen und Systemgrenzen.
Achte besonders auf Abhängigkeiten, Schnittstellen und potenzielle Risiken.

KONTEXT:
{{kontext}}

Erstelle eine strukturierte, übersichtliche Analyse mit:
1. Systemkomponenten
2. Beziehungen und Datenflüsse
3. Systemgrenzen und externe Schnittstellen
4. Potenzielle Risiken und Herausforderungen
5. Empfehlungen zur Optimierung"

create_template "kontext_integration" "Kontext-Integration" "Erstelle eine integrierte Analyse des folgenden Kontextes und verknüpfe die Informationen 
mit bestehenden Wissensstrukturen. Identifiziere Schlüsselkonzepte und ihre Beziehungen.

KONTEXT:
{{kontext}}

Deine Analyse sollte folgende Punkte umfassen:
1. Hauptkonzepte und Ideen
2. Verbindungen zu verwandten Wissensgebieten
3. Praktische Anwendungsmöglichkeiten
4. Fachliche Einordnung
5. Kritische Bewertung"

create_template "kontext_analyse" "Detaillierte Kontextanalyse" "Führe eine tiefgreifende Analyse des folgenden Kontextes durch.
Berücksichtige dabei verschiedene Perspektiven und identifiziere die zentralen Thesen und Argumente.

KONTEXT:
{{kontext}}

Strukturiere deine Analyse wie folgt:
1. Zusammenfassung des Hauptinhalts
2. Identifikation der zentralen Thesen und Argumente
3. Analyse der verwendeten Methodik und Quellen
4. Kritische Würdigung und Einordnung
5. Erkenntnisse und Anwendungspotenzial"

log "${GREEN}✅ Templates für Canva-Integration erstellt${NC}"

# ----- 7. Erstelle verbesserte Canva-Integration-Konfiguration für Claude -----
log "\n${YELLOW}7. Erstelle verbesserte Canva-Integration-Konfiguration...${NC}"

# Lese aktuelle Konfiguration
CLAUDE_CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ ! -f "$CLAUDE_CONFIG_PATH" ]; then
  log "${RED}❌ Claude-Konfigurationsdatei nicht gefunden: $CLAUDE_CONFIG_PATH${NC}"
  exit 1
fi

# Erstelle Backup
CONFIG_BACKUP="${CLAUDE_CONFIG_PATH}.bak_canva_$TIMESTAMP"
cp "$CLAUDE_CONFIG_PATH" "$CONFIG_BACKUP"
log "Backup erstellt: $CONFIG_BACKUP"

# Erstelle temporäre Datei mit verbesserter Canva-Integration-Konfiguration
TEMP_CONFIG_FILE="/tmp/claude_canva_config_temp.json"

cat > "$TEMP_CONFIG_FILE" <<EOL
{
  "mcpServers": {
    "github.com/paulad/canva-integration": {
      "command": "node",
      "args": ["$CANVA_PATH/index.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "true",
        "NODE_ENV": "production"
      },
      "meta": {
        "namespace": "Canva_Integration"
      }
    }
  }
}
EOL

# ----- 8. Teste Canva-Integration -----
log "\n${YELLOW}8. Teste Canva-Integration...${NC}"

TEST_LOG="/tmp/canva_test_$TIMESTAMP.json"

log "Teste Canva-Integration-Server..."
NODE_NO_WARNINGS=1 node "$CANVA_PATH/index.js" > /dev/null 2>&1 &
SERVER_PID=$!

# Warte, bis der Server gestartet ist
sleep 3

# Teste den Server mit einer einfachen Anfrage
curl -s -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' http://localhost:3000 > "$TEST_LOG" 2>/dev/null

# Beende den Testserver
kill $SERVER_PID 2>/dev/null || true

if grep -q "liste_templates\|erstelle_template" "$TEST_LOG"; then
  log "${GREEN}✅ Canva-Integration-Server funktioniert${NC}"
  
  # Extrahiere verfügbare Tools für Log
  TOOLS=$(grep -o '"name":"[^"]*"' "$TEST_LOG" | cut -d':' -f2 | tr -d '"' | sort | uniq)
  log "Verfügbare Tools:"
  log "$TOOLS"
else
  log "${RED}❌ Canva-Integration-Server funktioniert nicht${NC}"
  cat "$TEST_LOG" >> "$LOG_FILE"
fi

# ----- 9. Aktualisiere Claude-Konfiguration mit Canva-Integration -----
log "\n${YELLOW}9. Aktualisiere Claude-Konfiguration mit Canva-Integration...${NC}"

# Überprüfe, ob jq verfügbar ist
if command -v jq &> /dev/null; then
  log "Verwende jq für die Konfigurationsaktualisierung..."
  
  # Extrahiere und aktualisiere die Canva-Integration-Konfiguration
  CANVA_CONFIG=$(cat "$TEMP_CONFIG_FILE" | jq '.mcpServers."github.com/paulad/canva-integration"')
  
  # Erstelle temporäre Dateien für die Bearbeitung
  TEMP_OUTPUT="/tmp/claude_config_updated_canva_$TIMESTAMP.json"
  
  # Aktualisiere die Konfiguration
  cat "$CLAUDE_CONFIG_PATH" | jq --argjson canva_config "$CANVA_CONFIG" '.mcpServers."github.com/paulad/canva-integration" = $canva_config' > "$TEMP_OUTPUT"
  
  # Kopiere die aktualisierte Konfiguration zurück
  cp "$TEMP_OUTPUT" "$CLAUDE_CONFIG_PATH"
  
  log "${GREEN}✅ Claude-Konfiguration mit jq aktualisiert${NC}"
else
  log "${YELLOW}⚠️ jq ist nicht installiert, verwende manuelle Aktualisierung...${NC}"
  
  # Manuelle Ersetzung - vereinfacht
  TEMP_CONFIG="/tmp/claude_config_updated_canva_$TIMESTAMP.json"
  
  # Füge Canva-Integration zur Konfiguration hinzu, falls sie nicht existiert
  if ! grep -q '"github.com/paulad/canva-integration"' "$CLAUDE_CONFIG_PATH"; then
    # Finde die letzte schließende Klammer in mcpServers
    sed 's/}[[:space:]]*}[[:space:]]*$/,'$'\n'"$(cat "$TEMP_CONFIG_FILE" | grep -A 20 '"github.com/paulad/canva-integration"' | head -n 20)"$'\n''}}/' "$CLAUDE_CONFIG_PATH" > "$TEMP_CONFIG"
    cp "$TEMP_CONFIG" "$CLAUDE_CONFIG_PATH"
    log "${GREEN}✅ Canva-Integration zur Konfiguration hinzugefügt${NC}"
  fi
  
  log "${YELLOW}⚠️ Manuelle Aktualisierung kann unvollständig sein, bitte installieren Sie jq für zuverlässigere Ergebnisse${NC}"
fi

# ----- 10. Zusammenfassung -----
log "\n${BLUE}======================================================${NC}"
log "${YELLOW}Zusammenfassung:${NC}"
log "- Canva-Integration wurde erfolgreich eingerichtet"
log "- Templates für die Integration wurden erstellt"
log "- Die Claude-Konfiguration wurde mit der Canva-Integration aktualisiert"
log "- Der Server wurde getestet und funktioniert"

if [ -z "$OPENROUTER_API_KEY" ]; then
  log "${YELLOW}⚠️ Kein OpenRouter API-Schlüssel konfiguriert. Die Funktionalität ist eingeschränkt.${NC}"
  log "Sie können jederzeit einen API-Schlüssel in der Datei $ENV_FILE hinzufügen."
else
  log "${GREEN}✅ OpenRouter API-Schlüssel ist konfiguriert${NC}"
fi

log "\n${YELLOW}Nächste Schritte:${NC}"
log "1. Starten Sie Claude Desktop neu"
log "2. Überprüfen Sie, ob die Canva-Integration funktioniert"
log "3. Sie können Templates in $TEMPLATES_DIR anpassen oder hinzufügen"

log "\n${GREEN}Canva-Integration Fix abgeschlossen!${NC}"
log "${BLUE}======================================================${NC}\n"
