# Ausführliche Anleitung zur MCP-Integration in Claude Desktop

Diese Dokumentation erklärt detailliert, wie man MCP-Server (Model Context Protocol) korrekt in Claude Desktop integriert und häufige Probleme behebt.

## Inhalt

1. [Überblick über MCP](#1-überblick-über-mcp)
2. [Voraussetzungen](#2-voraussetzungen)
3. [MCP-Server-Typen](#3-mcp-server-typen)
4. [Konfigurationsdatei](#4-konfigurationsdatei)
5. [Häufige Fehlermeldungen](#5-häufige-fehlermeldungen)
6. [Troubleshooting-Guide](#6-troubleshooting-guide)
7. [Beispiel-Setups](#7-beispiel-setups)

## 1. Überblick über MCP

Das Model Context Protocol (MCP) ermöglicht Claude Desktop den Zugriff auf externe Tools und Ressourcen. MCP-Server sind separate Prozesse, die von Claude Desktop gestartet werden und über ein definiertes JSON-RPC-Protokoll kommunizieren.

## 2. Voraussetzungen

- **Node.js**: Version 16+ (empfohlen: Version 18+)
- **NPM**: Aktuelle Version (8+)
- **Claude Desktop**: Neueste Version
- **MCP SDK**: Version 1.12.0 (für beste Kompatibilität)

## 3. MCP-Server-Typen

MCP-Server können auf verschiedene Arten bereitgestellt werden:

1. **NPM-Pakete** (empfohlen): `npx -y @modelcontextprotocol/server-name`
2. **Lokale Skripte**: Direkte Ausführung von JavaScript-Dateien
3. **Eigene Implementierungen**: Selbst entwickelte Server, die das MCP-Protokoll unterstützen

## 4. Konfigurationsdatei

Die MCP-Konfiguration wird in einer JSON-Datei gespeichert:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **VSCodium**: `~/Library/Application Support/VSCodium/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

### Aufbau der Konfigurationsdatei

```json
{
  "mcpServers": {
    "server-id": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Namespace_Name"
      }
    }
  }
}
```

### Wichtige Eigenschaften

- **server-id**: Eindeutige Kennung (meist GitHub-URL)
- **command**: Auszuführender Befehl
- **args**: Argumente für den Befehl
- **disabled**: Server aktivieren/deaktivieren
- **autoApprove**: Liste automatisch zu genehmigender Tools
- **env**: Umgebungsvariablen
- **meta.namespace**: Optionaler Namespace für Tools

## 5. Häufige Fehlermeldungen

### "Could not attach to MCP server"

Mögliche Ursachen:
- Server ist nicht installiert
- Falscher Pfad in der Konfiguration
- Kompatibilitätsprobleme mit Node.js
- Server startet nicht oder stürzt sofort ab

### "Unexpected token X ... is not valid JSON"

Mögliche Ursachen:
- Server gibt zusätzliche Debug-Informationen aus, die das JSON stören
- Fehlende `NODE_NO_WARNINGS=1`-Umgebungsvariable
- Inkompatibilität zwischen MCP-Server und SDK-Version

### "Server disconnected"

Mögliche Ursachen:
- Server stürzt während der Ausführung ab
- Zeitüberschreitung bei der Kommunikation
- Prozess wird vom System beendet

## 6. Troubleshooting-Guide

### A. Allgemeiner Problemlösungsprozess

1. **Stoppen Sie alle MCP-Prozesse**:
   ```bash
   ps aux | grep -E 'modelcontextprotocol|mcp-server' | grep -v grep | awk '{print $2}' | xargs kill
   ```

2. **Bereinigen Sie den NPM-Cache**:
   ```bash
   npm cache clean --force
   ```

3. **Stellen Sie eine Minimalkonfiguration her**:
   ```bash
   ./setup_claude_mcp.sh
   ```

4. **Testen Sie jeden Server einzeln**:
   ```bash
   echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | npx -y @modelcontextprotocol/server-name
   ```

### B. Fixieren Sie die MCP-SDK-Version

Bei allen Server-Installationen die SDK-Version festlegen:
```bash
npm install -g @modelcontextprotocol/sdk@1.12.0
```

### C. Debuggen Sie die Server-Kommunikation

Um die JSON-RPC-Kommunikation zu sehen:
```bash
echo '{"jsonrpc":"2.0","id":"test","method":"list_tools","params":{}}' | npx -y @modelcontextprotocol/server-name | jq
```

### D. Optimierte Umgebungsvariablen

Fügen Sie diese Umgebungsvariablen zur Konfiguration hinzu:
```json
"env": {
  "PATH": "/usr/local/bin:/usr/bin:/bin",
  "NODE_NO_WARNINGS": "1",
  "DEBUG": "false",
  "NODE_ENV": "production"
}
```

## 7. Beispiel-Setups

### Minimalsetup (empfohlen für Problemlösung)

```json
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      }
    }
  }
}
```

### Lokaler einfacher Server (komplett unabhängig)

Dieser Server verwendet keine externen Abhängigkeiten und ist Node.js-Version-unabhängig:

```json
{
  "mcpServers": {
    "github.com/paulad/simple-mcp-server-v16": {
      "command": "node",
      "args": ["/pfad/zu/simple_mcp_server_v16.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Simple_Server_V16"
      }
    }
  }
}
```

### Komplettsetup (nach Problemlösung)

Ein vollständiges Setup mit allen wichtigen Servern:

```json
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/modelcontextprotocol/servers/tree/main/src/filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/projects"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
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
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "GITHUB_TOKEN": "ghp_YOUR_TOKEN_HERE",
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
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1",
        "DEBUG": "false",
        "NODE_ENV": "production"
      }
    },
    "github.com/paulad/simple-mcp-server-v16": {
      "command": "node",
      "args": ["/pfad/zu/simple_mcp_server_v16.js"],
      "disabled": false,
      "autoApprove": [],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "NODE_NO_WARNINGS": "1"
      },
      "meta": {
        "namespace": "Simple_Server_V16"
      }
    }
  }
}
```

## Best Practices für zuverlässige MCP-Integration

1. **Starten Sie mit einer minimalen Konfiguration**
   - Beginnen Sie mit nur einem oder zwei Servern
   - Fügen Sie weitere Server schrittweise hinzu und testen Sie nach jedem Hinzufügen

2. **Verwenden Sie konsistente SDK-Versionen**
   - Installieren Sie die gleiche Version des MCP SDK für alle Server
   - Aktuell empfohlen: Version 1.12.0

3. **Vermeiden Sie Debug-Ausgaben**
   - Setzen Sie `NODE_NO_WARNINGS=1` und `DEBUG=false`
   - Verwenden Sie `NODE_ENV=production`

4. **Testen Sie regelmäßig**
   - Führen Sie `./test_mcp_servers.sh` aus, um alle Server zu testen
   - Überprüfen Sie die Logs auf Fehler

5. **Sichern Sie Ihre Konfigurationen**
   - Erstellen Sie Backups vor größeren Änderungen
   - Nutzen Sie die bereitgestellten Backup-Skripte
