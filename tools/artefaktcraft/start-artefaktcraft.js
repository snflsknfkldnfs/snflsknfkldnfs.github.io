const config = require('/Users/paulad/snflsknfkldnfs.github.io/mcp-config.json');
const repositoryRoot = config.repositoryRoot;

// Nutze absolute Pfade basierend auf repositoryRoot
const resolvePath = (relativePath) => path.join(repositoryRoot, relativePath);

// Beispiel:
console.log(resolvePath('notizen/wib')); // Gibt den vollständigen Pfad aus
// 
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Pfade und Konfigurationsdateien
const repositoryRoot = path.resolve(__dirname, '../../..'); // Wurzelverzeichnis des Repos
const mcpServerPath = path.join(__dirname, 'mcp-server.js');
const configPath = path.join(repositoryRoot, 'mcp-config.json');

// Starte den mcp-Server
function startServer() {
    console.log('Starte mcp-Server...');

    // Prüfen, ob die mcp-config.json existiert
    if (!fs.existsSync(configPath)) {
        console.error(`Konfigurationsdatei "${configPath}" fehlt.`);
        process.exit(1);
    }

    // Prüfen, ob der mcp-server.js existiert
    if (!fs.existsSync(mcpServerPath)) {
        console.error(`Server-Datei "${mcpServerPath}" fehlt.`);
        process.exit(1);
    }

    // Server starten
    const serverProcess = exec(`node ${mcpServerPath}`, { cwd: repositoryRoot });

    serverProcess.stdout.on('data', (data) => {
        console.log(`[SERVER]: ${data}`);
    });

    serverProcess.stderr.on('data', (data) => {
        console.error(`[SERVER-ERROR]: ${data}`);
    });

    serverProcess.on('close', (code) => {
        console.log(`Server wurde mit Code ${code} beendet.`);
    });
}

// Prüfen, ob notwendige Verzeichnisse und Dateien existieren
function validatePaths() {
    console.log('Überprüfen der Verzeichnisse und Dateien...');

    const pathsToCheck = [
        path.join(repositoryRoot, 'notizen/wib'),
        path.join(repositoryRoot, 'notizen/gpg'),
        path.join(repositoryRoot, 'notizen/methodik'),
        path.join(repositoryRoot, 'notizen/leitfaden'),
        path.join(repositoryRoot, 'schemas/unterrichtseinheit-schema.json'),
        path.join(repositoryRoot, 'schemas/sequenzplanung-schema.json'),
        path.join(repositoryRoot, 'schemas/tafelbild-schema.json'),
        path.join(repositoryRoot, 'templates'),
        path.join(repositoryRoot, 'data/curriculum/wib'),
        path.join(repositoryRoot, 'data/curriculum/gpg'),
        path.join(repositoryRoot, 'public'),
        path.join(repositoryRoot, 'logs'),
    ];

    for (const filePath of pathsToCheck) {
        if (!fs.existsSync(filePath)) {
            console.warn(`WARNUNG: Pfad fehlt: ${filePath}`);
        } else {
            console.log(`Pfad OK: ${filePath}`);
        }
    }
}

// Hauptprogramm
function main() {
    console.log('ArtefaktCraft: Automatischer Start');
    validatePaths();
    startServer();
}

main();