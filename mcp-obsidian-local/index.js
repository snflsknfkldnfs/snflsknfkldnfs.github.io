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
  console.error(`Fehler: Obsidian-Verzeichnis nicht gefunden: ${OBSIDIAN_PATH}`);
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
        : 'http://json-schema.org/draft-07/schema#'
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
        : 'http://json-schema.org/draft-07/schema#'
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
