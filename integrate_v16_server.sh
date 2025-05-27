#!/bin/bash

# Integration des Node.js v16 kompatiblen MCP-Servers in Claude Desktop
# Autor: Claude
# Datum: 26.5.2025

echo "===== MCP Server v16 Integration ====="

# Aktuelle Verzeichnis
CURRENT_DIR=$(pwd)

# 1. Mache das Skript ausführbar
echo "🧰 Mache Server-Skript ausführbar..."
chmod +x simple_mcp_server_v16.js

# 2. Teste den Server
echo "🔍 Teste den MCP-Server..."
echo '{ "id": "test", "jsonrpc": "2.0", "method": "list_tools", "params": {} }' | node simple_mcp_server_v16.js

# 3. Integriere den Server in die Claude-Konfiguration
echo "🔄 Integriere Server in Claude-Konfiguration..."

# Claude Konfigurationspfad
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
BACKUP_CONFIG="${CLAUDE_CONFIG}.bak-v16"

# Backup erstellen
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "$CLAUDE_CONFIG" "$BACKUP_CONFIG"
  echo "✅ Backup der aktuellen Konfiguration erstellt: $BACKUP_CONFIG"
else
  echo "⚠️ Keine bestehende Claude-Konfiguration gefunden. Erstelle neue..."
  mkdir -p "$(dirname "$CLAUDE_CONFIG")"
  echo '{"mcpServers":{}}' > "$CLAUDE_CONFIG"
fi

# Lese bestehende Konfiguration und kopiere sie nach TMP_CONFIG
TMP_CONFIG="/tmp/claude_config_v16_$$.json"
cp "$CLAUDE_CONFIG" "$TMP_CONFIG"

# Server-ID für die Konfiguration
SERVER_ID="github.com/paulad/simple-mcp-server-v16"

# Aktualisiere die Konfigurationsdatei - lese alle vorhandenen Server und füge unseren hinzu
cat <<EOF > "$TMP_CONFIG"
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
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/snflsknfkldnfs.github.io"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "$SERVER_ID": {
      "command": "node",
      "args": ["$CURRENT_DIR/simple_mcp_server_v16.js"],
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
EOF

# Kopiere die neue Konfiguration
cp "$TMP_CONFIG" "$CLAUDE_CONFIG"
echo "✅ Server zur Claude-Konfiguration hinzugefügt"

# Kopiere auch zu VSCodium, falls vorhanden
VSCODIUM_CONFIG="$HOME/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
if [ -d "$(dirname "$VSCODIUM_CONFIG")" ]; then
  cp "$TMP_CONFIG" "$VSCODIUM_CONFIG"
  echo "✅ Server zur VSCodium-Konfiguration hinzugefügt"
fi

# Anleitung für nächste Schritte
echo ""
echo "===== Integration abgeschlossen ====="
echo ""
echo "Um den v16-kompatiblen MCP-Server zu verwenden:"
echo "1. Starten Sie Claude Desktop neu"
echo "2. Überprüfen Sie, ob der Server '$SERVER_ID' verbunden ist"
echo "3. Verwenden Sie das Tool 'hello_world' in einem Chat mit folgender Eingabe:"
echo ""
echo "   Bitte verwende den Simple_Server_V16 mit dem hello_world-Tool"
echo ""
echo "Der Server ist speziell für Node.js v16 optimiert und verwendet keine externen Abhängigkeiten."
echo "Dadurch werden Kompatibilitätsprobleme vermieden."
