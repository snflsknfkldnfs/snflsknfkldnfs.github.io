#!/usr/bin/env node

// Simple MCP Server - Minimal funktionierender MCP-Server
// Autor: Claude
// Datum: 26.5.2025

const { MCPServer } = require('@modelcontextprotocol/sdk');

// Die Versionsnummer auf 1.12.0 festlegen (wichtig für Kompatibilität)
console.error('Starting Simple MCP Server...');

// Tool-Implementierung
const helloWorldTool = async (input) => {
  console.error('Hello World Tool called with:', input);
  
  // Tool-Antwort
  return {
    message: `Hallo! Dies ist eine Antwort vom Simple MCP Server. Der Eingabetext war: ${input.text || 'nicht angegeben'}`,
    timestamp: new Date().toISOString()
  };
};

// MCP-Server erstellen
const server = new MCPServer({
  // Tools registrieren
  tools: {
    hello_world: {
      description: 'Ein einfaches Hallo-Welt-Tool zum Testen der MCP-Integration',
      parameters: {
        type: 'object',
        properties: {
          text: {
            type: 'string',
            description: 'Optional text to echo back'
          }
        }
      },
      handler: helloWorldTool
    }
  },
  
  // Ressourcen registrieren
  resources: {
    'status': async () => {
      return {
        status: 'online',
        version: '1.0.0',
        timestamp: new Date().toISOString()
      };
    }
  }
});

// Server starten
process.on('SIGINT', () => {
  console.error('Shutting down Simple MCP Server...');
  process.exit(0);
});

// Debugging-Ausgabe minimieren (wichtig für JSON-RPC-Kommunikation)
console.error('Simple MCP Server is ready. Press Ctrl+C to stop.');

// Server über STDIN/STDOUT starten
server.listen(process.stdin, process.stdout).catch(err => {
  console.error('Error starting server:', err);
  process.exit(1);
});
