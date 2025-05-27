# MCP-Server Fix Toolkit für Claude Desktop

Dieses Toolkit enthält Skripte zur Behebung häufiger Probleme mit MCP-Servern in Claude Desktop für macOS.

## Überblick

Model Context Protocol (MCP) Server ermöglichen es Claude Desktop, auf externe Ressourcen und Tools zuzugreifen. 
Diese Skripte helfen bei der Behebung von Verbindungs- und Konfigurationsproblemen für die folgenden MCP-Server:

- **GitHub MCP-Server** - Für GitHub-Integration und Zugriff auf Repositories
- **Obsidian MCP-Server** - Für den Zugriff auf Obsidian-Notizen und Vaults
- **Canva-Integration MCP-Server** - Für API-gestützte Dokumentenanalyse und -generierung

## Enthaltene Skripte

- `mcp_master_fix.sh` - Hauptskript mit interaktivem Menü zur Auswahl der zu reparierenden Server
- `github_mcp_fix.sh` - Repariert nur GitHub MCP-Server-Verbindungsprobleme
- `obsidian_mcp_fix.sh` - Repariert nur Obsidian MCP-Server-Verbindungsprobleme
- `canva_mcp_fix.sh` - Repariert nur Canva-Integration-MCP-Server-Probleme

## Voraussetzungen

- macOS-System mit Claude Desktop installiert
- Node.js (Version 16+ empfohlen)
- npm (Node Package Manager)
- Terminal-Zugriff

## Installation

1. Laden Sie alle Skripte in ein Verzeichnis herunter
2. Öffnen Sie ein Terminal und navigieren Sie zu diesem Verzeichnis
3. Führen Sie die folgenden Befehle aus, um die Skripte ausführbar zu machen:

```bash
chmod +x mcp_master_fix.sh
chmod +x github_mcp_fix.sh
chmod +x obsidian_mcp_fix.sh
chmod +x canva_mcp_fix.sh
```

## Verwendung

### Master-Fix-Tool (empfohlen)

Das Master-Fix-Tool bietet eine benutzerfreundliche Menüoberfläche für alle Reparaturoptionen:

```bash
./mcp_master_fix.sh
```

Wählen Sie im Menü die gewünschte Option aus:

1. **Alle MCP-Server reparieren** - Führt alle Reparaturskripte nacheinander aus
2. **Nur GitHub MCP-Server reparieren** - Behebt nur GitHub-Verbindungsprobleme
3. **Nur Obsidian MCP-Server reparieren** - Behebt nur Obsidian-Verbindungsprobleme 
4. **Nur Canva-Integration MCP-Server reparieren** - Behebt nur Canva-Integration-Probleme
5. **Claude Desktop Konfiguration anzeigen** - Zeigt die aktuelle Konfiguration an
6. **Fehlersuche-Anleitung** - Zeigt Tipps zur manuellen Fehlerbehebung
7. **MCP-Server-Status prüfen** - Testet den aktuellen Status Ihrer MCP-Server
8. **Beenden** - Beendet das Programm

### Einzelne Fix-Skripte

Sie können die einzelnen Skripte auch direkt ausführen:

- Zur Reparatur nur des GitHub MCP-Servers:
  ```bash
  ./github_mcp_fix.sh
  ```

- Zur Reparatur nur des Obsidian MCP-Servers:
  ```bash
  ./obsidian_mcp_fix.sh
  ```

- Zur Reparatur nur des Canva-Integration MCP-Servers:
  ```bash
  ./canva_mcp_fix.sh
  ```

## Was die Skripte tun

Diese Skripte führen folgende Aktionen aus:

1. **Stoppen laufender MCP-Server-Prozesse** - Um Konflikte zu vermeiden
2. **Überprüfen der Installation und Pfade** - Um sicherzustellen, dass alle notwendigen Komponenten vorhanden sind
3. **Bereinigen des NPM-Caches** - Um potenzielle Modulprobleme zu beheben
4. **Neuinstallation der MCP-Server** - Um sicherzustellen, dass die neuesten Versionen verwendet werden
5. **Erstellung lokaler Server-Alternativen** - Um zuverlässigere lokale Alternativen zu bieten
6. **Aktualisierung der Claude Desktop Konfiguration** - Um die korrekten Einstellungen zu gewährleisten
7. **Testen der Server-Funktionalität** - Um zu bestätigen, dass die Reparatur erfolgreich war

Alle Änderungen werden protokolliert, und Backups der Claude Desktop Konfigurationsdatei werden vor Änderungen erstellt.

## Fehlerbehebung

Wenn Probleme mit den MCP-Servern bestehen bleiben:

1. Öffnen Sie das Master-Fix-Tool und wählen Sie Option 6 "Fehlersuche-Anleitung"
2. Prüfen Sie den MCP-Server-Status mit Option 7
3. Überprüfen Sie die Log-Dateien im Verzeichnis `~/claude_mcp_logs/`

## Hinweis

Nach der Ausführung der Reparaturskripte müssen Sie Claude Desktop neu starten, damit die Änderungen wirksam werden.

## Feedback und Probleme

Bei weiteren Problemen oder für Feedback senden Sie die Log-Dateien aus dem Verzeichnis `~/claude_mcp_logs/` an den Support.
