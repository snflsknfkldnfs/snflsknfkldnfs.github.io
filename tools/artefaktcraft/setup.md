# ArtefaktCraft: Setup und Installation

## Voraussetzungen

Für die Nutzung von ArtefaktCraft benötigen Sie:

1. **Git**: Versionskontrollsystem für die Repository-Verwaltung
2. **Node.js**: JavaScript-Runtime für den mcp-Server
3. **mcp-Server-Setup**: Die Middleware-Komponente zur dynamischen Ressourcenverwaltung
4. **Markdown-Editor**: VSCode oder ein anderer Markdown-Editor mit Vorschaufunktion

## Installationsschritte

### 1. Repository klonen

```bash
git clone https://github.com/snflsknfkldnfs/snflsknfkldnfs.github.io.git
cd snflsknfkldnfs.github.io
```

### 2. mcp-Server installieren

```bash
npm install mcp-server --save
```

### 3. mcp-Server konfigurieren

Erstellen Sie eine `mcp-config.json` im Hauptverzeichnis:

```json
{
  "repositoryRoot": "/Users/[username]/snflsknfkldnfs.github.io",
  "resourcePaths": [
    "notizen/wib",
    "notizen/gpg",
    "notizen/methodik",
    "notizen/leitfaden"
  ],
  "metadataSchemas": {
    "unterrichtseinheit": "./schemas/unterrichtseinheit-schema.json",
    "sequenzplanung": "./schemas/sequenzplanung-schema.json",
    "tafelbild": "./schemas/tafelbild-schema.json"
  },
  "port": 3000
}
```

### 4. ArtefaktCraft-Tools einrichten

```bash
cd tools/artefaktcraft
npm install
```

### 5. mcp-Server starten

```bash
node mcp-server.js
```

Der Server ist nun unter http://localhost:3000 erreichbar.

## Überprüfung der Installation

1. Öffnen Sie http://localhost:3000/resources im Browser
2. Sie sollten eine Liste aller verfügbaren Ressourcen aus den konfigurierten Pfaden sehen
3. Testen Sie die dynamische Verlinkung durch Aufruf von http://localhost:3000/resource/[ressourcen-id]

## Integration mit ArtefaktCraft

ArtefaktCraft nutzt den mcp-Server, um:
- Dynamische Metadaten aus der Repository zu laden
- Ressourcen auf Basis von Metadaten zu filtern
- Vorlagen mit Live-Daten zu befüllen
- Qualitätschecks gegen definierte Schemas durchzuführen

Alle ArtefaktCraft-Tools sind so konfiguriert, dass sie automatisch eine Verbindung zum lokalen mcp-Server herstellen.

## Nächste Schritte

Nach erfolgreicher Installation können Sie mit dem [ArtefaktCraft-Workflow](./workflow.md) beginnen.
