#!/bin/bash

# Integration des einfachen MCP-Servers in Claude Desktop
# Autor: Claude
# Datum: 26.5.2025

echo "===== Simple MCP Server Integration ====="

# Aktuelle Verzeichnis
CURRENT_DIR=$(pwd)

# 1. Installiere Dependencies
echo "📦 Installiere Dependencies..."
npm install

# 2. Mache das Skript ausführbar
echo "🧰 Mache Server-Skript ausführbar..."
chmod +x simple_mcp_server.js

# 3. Teste den Server
echo "🔍 Teste den MCP-Server..."
npm test

# 4. Integriere den Server in die Claude-Konfiguration
echo "🔄 Integriere Server in Claude-Konfiguration..."

# Claude Konfigurationspfad
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
BACKUP_CONFIG="${CLAUDE_CONFIG}.bak"

# Backup erstellen
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "$CLAUDE_CONFIG" "$BACKUP_CONFIG"
  echo "✅ Backup der aktuellen Konfiguration erstellt: $BACKUP_CONFIG"
else
  echo "⚠️ Keine bestehende Claude-Konfiguration gefunden. Erstelle neue..."
  mkdir -p "$(dirname "$CLAUDE_CONFIG")"
  echo '{"mcpServers":{}}' > "$CLAUDE_CONFIG"
fi

# Temporäre Datei für die Konfiguration
TMP_CONFIG="/tmp/claude_config_$$.json"

# Server-ID für die Konfiguration
SERVER_ID="github.com/paulad/simple-mcp-server"

# Lese bestehende Konfiguration
jq . "$CLAUDE_CONFIG" > "$TMP_CONFIG" 2>/dev/null
if [ $? -ne 0 ]; then
  echo "⚠️ Fehler beim Lesen der Claude-Konfiguration. Stelle Default-Konfiguration her..."
  echo '{"mcpServers":{}}' > "$TMP_CONFIG"
fi

# Füge den einfachen Server zur Konfiguration hinzu
# Verwende temporäre Datei für die Änderungen
cat > "$TMP_CONFIG" <<EOL
{
  "mcpServers": {
    "$SERVER_ID": {
      "command": "node",
      "args": ["$CURRENT_DIR/simple_mcp_server.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Simple_Server"
      }
    }
  }
}
EOL

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
echo "Um den einfachen MCP-Server zu verwenden:"
echo "1. Starten Sie Claude Desktop neu"
echo "2. Überprüfen Sie, ob der Server 'github.com/paulad/simple-mcp-server' verbunden ist"
echo "3. Verwenden Sie das Tool 'hello_world' in einem Chat mit folgender Eingabe:"
echo ""
echo "   Bitte verwende den Simple_Server mit dem hello_world-Tool"
echo ""
echo "Der Server wird nur aktiv, wenn Claude Desktop gestartet ist."
echo ""
echo "Zum manuellen Testen des Servers:"
echo "   npm test"
echo "oder:"
echo "   echo '{\"id\":\"test\",\"jsonrpc\":\"2.0\",\"method\":\"list_tools\",\"params\":{}}' | node simple_mcp_server.js"
