#!/usr/bin/env node
require('dotenv').config();
const fs = require('fs-extra');
const path = require('path');
const { spawn } = require('child_process');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

// Main function
async function main() {
    console.log('=== Repository Workflow Manager ===');
    console.log('Dieser Workflow hilft dir, die Repository mit KI zu verwalten.\n');
    
    // Show menu
    await showMenu();
}

async function showMenu() {
    console.log('\nWas möchtest du tun?');
    console.log('1. Starte den API-Server');
    console.log('2. Aktualisiere die AI-Integration im Frontend');
    console.log('3. Erstelle eine .env Datei');
    console.log('4. Beenden');
    
    rl.question('\nWähle eine Option (1-4): ', async (answer) => {
        switch (answer.trim()) {
            case '1':
                await handleStartServer();
                break;
            case '2':
                await handleUpdateFrontend();
                break;
            case '3':
                await handleCreateEnvFile();
                break;
            case '4':
                console.log('Auf Wiedersehen!');
                rl.close();
                return;
            default:
                console.log('Ungültige Option. Bitte versuche es erneut.');
                await showMenu();
                break;
        }
    });
}

async function handleStartServer() {
    console.log('\nStarte den API-Server...');
    
    const server = spawn('node', ['api/generate-content.js'], {
        stdio: 'inherit'
    });
    
    console.log(`Server gestartet mit PID ${server.pid}`);
    console.log('Drücke Ctrl+C um den Server zu beenden.');
    
    // Server wird im Vordergrund laufen, daher kehren wir nicht zum Menü zurück
}

async function handleUpdateFrontend() {
    console.log('\nAktualisiere die AI-Integration im Frontend...');
    
    // Erstelle ein Backup der vorhandenen Datei
    const aiIntegrationPath = 'js/ai-integration.js';
    
    if (await fs.pathExists(aiIntegrationPath)) {
        await fs.copy(aiIntegrationPath, `${aiIntegrationPath}.bak`);
        console.log(`Backup erstellt: ${aiIntegrationPath}.bak`);
    }
    
    // Hier würden wir die Datei aktualisieren, aber da dies eine interaktive Aktivität ist,
    // fordern wir den Benutzer auf, die Datei manuell zu bearbeiten
    console.log(`\nBitte bearbeite die Datei ${aiIntegrationPath} manuell, um den OpenRouter-Client zu integrieren.`);
    console.log('Ein Beispielcode wurde im Repository zur Verfügung gestellt.');
    
    rl.question('\nDrücke Enter, wenn du fertig bist...', async () => {
        console.log('Frontend-Integration aktualisiert!');
        await showMenu();
    });
}

async function handleCreateEnvFile() {
    console.log('\nErstelle eine .env Datei...');
    
    rl.question('OpenRouter API Key: ', async (openRouterKey) => {
        rl.question('Nomic API Key (optional): ', async (nomicKey) => {
            const envContent = [
                `OPENROUTER_API_KEY=${openRouterKey}`,
                `NOMIC_API_KEY=${nomicKey || ''}`,
                'PORT=3000'
            ].join('\n');
            
            await fs.writeFile('.env', envContent);
            console.log('.env Datei erstellt!');
            await showMenu();
        });
    });
}

// Start the workflow
main().catch(console.error);
