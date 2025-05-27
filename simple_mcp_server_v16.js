#!/usr/bin/env node

// Simple MCP Server für Node.js v16 - Kompatibel mit älteren Node-Versionen
// Autor: Claude
// Datum: 26.5.2025

// Direkte JSON-RPC-Implementierung für ältere Node-Versionen
console.error('Starting Simple MCP Server for Node.js v16...');

// Parse die eingehende Anfrage
async function processRequest(request) {
  try {
    const req = JSON.parse(request);
    
    // Prüfe, ob es eine valide JSON-RPC-Anfrage ist
    if (!req.jsonrpc || req.jsonrpc !== '2.0' || !req.method) {
      return {
        jsonrpc: '2.0',
        id: req.id,
        error: {
          code: -32600,
          message: 'Invalid Request'
        }
      };
    }
    
    // Handle die verschiedenen Methoden
    if (req.method === 'list_tools') {
      return {
        jsonrpc: '2.0',
        id: req.id,
        result: {
          tools: {
            hello_world: {
              description: 'Ein einfaches Hallo-Welt-Tool zum Testen der MCP-Integration',
              input_schema: {
                type: 'object',
                properties: {
                  text: {
                    type: 'string',
                    description: 'Optional text to echo back'
                  }
                }
              }
            }
          }
        }
      };
    }
    
    if (req.method === 'execute_tool' && req.params.tool_name === 'hello_world') {
      const text = req.params.arguments?.text || 'nicht angegeben';
      console.error(`Hello World Tool called with: ${text}`);
      
      return {
        jsonrpc: '2.0',
        id: req.id,
        result: {
          message: `Hallo! Dies ist eine Antwort vom Simple MCP Server. Der Eingabetext war: ${text}`,
          timestamp: new Date().toISOString()
        }
      };
    }
    
    if (req.method === 'list_resources') {
      return {
        jsonrpc: '2.0',
        id: req.id,
        result: {
          resources: ['status']
        }
      };
    }
    
    if (req.method === 'access_resource' && req.params.uri === 'status') {
      return {
        jsonrpc: '2.0',
        id: req.id,
        result: {
          status: 'online',
          version: '1.0.0',
          timestamp: new Date().toISOString(),
          node_version: process.version
        }
      };
    }
    
    // Methode nicht gefunden
    return {
      jsonrpc: '2.0',
      id: req.id,
      error: {
        code: -32601,
        message: 'Method not found'
      }
    };
    
  } catch (err) {
    console.error('Error processing request:', err);
    return {
      jsonrpc: '2.0',
      id: null,
      error: {
        code: -32700,
        message: 'Parse error'
      }
    };
  }
}

// Lese STDIN und verarbeite Anfragen
let buffer = '';
process.stdin.on('data', async (chunk) => {
  buffer += chunk.toString();
  
  try {
    // Versuche JSON zu parsen
    const request = JSON.parse(buffer);
    buffer = ''; // Leere den Buffer nach erfolgreicher Verarbeitung
    
    // Verarbeite die Anfrage
    const response = await processRequest(JSON.stringify(request));
    
    // Sende die Antwort
    process.stdout.write(JSON.stringify(response) + '\n');
  } catch (err) {
    // Wenn kein vollständiges JSON empfangen wurde, sammle weiter
    if (!(err instanceof SyntaxError)) {
      console.error('Unhandled error:', err);
      process.exit(1);
    }
  }
});

process.on('SIGINT', () => {
  console.error('Shutting down Simple MCP Server...');
  process.exit(0);
});

// Umleitung von Fehlermeldungen
console.error('Simple MCP Server for Node.js v16 is ready. Press Ctrl+C to stop.');
