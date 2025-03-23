#!/usr/bin/env node
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Helper functions for file operations
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function writeFile(filePath, content) {
  return new Promise((resolve, reject) => {
    fs.writeFile(filePath, content, 'utf8', (err) => {
      if (err) reject(err);
      else resolve();
    });
  });
}

function pathExists(filePath) {
  return new Promise((resolve) => {
    fs.access(filePath, fs.constants.F_OK, (err) => {
      resolve(!err);
    });
  });
}

function copyFile(src, dest) {
  return new Promise((resolve, reject) => {
    fs.copyFile(src, dest, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });
}

// Main function
function main() {
  console.log('=== Repository Workflow Manager ===');
  console.log('Dieser Workflow hilft dir, die Repository mit KI zu verwalten.\n');
  
  // Show menu
  showMenu();
}

function showMenu() {
  console.log('\nWas möchtest du tun?');
  console.log('1. Starte den verbesserten API-Server (mit Repository-Kontext)');
  console.log('2. Starte den einfachen API-Server (ohne Repository-Kontext)');
  console.log('3. Aktualisiere Repository-Embeddings');
  console.log('4. Suche im Repository');
  console.log('5. Erstelle eine .env Datei');
  console.log('6. Beenden');
  
  rl.question('\nWähle eine Option (1-6): ', (answer) => {
    switch (answer.trim()) {
      case '1':
        handleStartEnhancedServer();
        break;
      case '2':
        handleStartServer();
        break;
      case '3':
        handleUpdateEmbeddings();
        break;
      case '4':
        handleSearchRepository();
        break;
      case '5':
        handleCreateEnvFile();
        break;
      case '6':
        console.log('Auf Wiedersehen!');
        rl.close();
        return;
      default:
        console.log('Ungültige Option. Bitte versuche es erneut.');
        showMenu();
        break;
    }
  });
}

function handleStartEnhancedServer() {
  console.log('\nStarte den verbesserten API-Server...');
  
  const server = spawn('node', ['api/generate-content-enhanced.js'], {
    stdio: 'inherit'
  });
  
  console.log(`Server gestartet mit PID ${server.pid}`);
  console.log('Drücke Ctrl+C um den Server zu beenden.');
  
  // Server wird im Vordergrund laufen, daher kehren wir nicht zum Menü zurück
}

function handleStartServer() {
  console.log('\nStarte den einfachen API-Server...');
  
  const server = spawn('node', ['api/generate-content-compat.js'], {
    stdio: 'inherit'
  });
  
  console.log(`Server gestartet mit PID ${server.pid}`);
  console.log('Drücke Ctrl+C um den Server zu beenden.');
  
  // Server wird im Vordergrund laufen, daher kehren wir nicht zum Menü zurück
}

function handleUpdateEmbeddings() {
  console.log('\nAktualisiere Repository-Embeddings...');
  
  const embedProcess = spawn('node', ['scripts/local-embeddings.js', 'embed'], {
    stdio: 'inherit'
  });
  
  embedProcess.on('close', (code) => {
    console.log(`Embedding-Prozess beendet mit Code ${code}`);
    showMenu();
  });
}

function handleSearchRepository() {
  rl.question('\nGib deine Suchanfrage ein: ', (query) => {
    console.log(`\nSuche nach: "${query}"`);
    
    const searchProcess = spawn('node', ['scripts/local-embeddings.js', 'search', query], {
      stdio: 'inherit'
    });
    
    searchProcess.on('close', (code) => {
      console.log(`Suchprozess beendet mit Code ${code}`);
      showMenu();
    });
  });
}

function handleCreateEnvFile() {
  console.log('\nErstelle eine .env Datei...');
  
  rl.question('OpenRouter API Key: ', (openRouterKey) => {
    const envContent = [
      `OPENROUTER_API_KEY=${openRouterKey}`,
      'PORT=3000'
    ].join('\n');
    
    writeFile('.env', envContent).then(() => {
      console.log('.env Datei erstellt!');
      showMenu();
    }).catch(err => {
      console.error('Fehler beim Erstellen der .env Datei:', err);
      showMenu();
    });
  });
}

// Start the workflow
main();
