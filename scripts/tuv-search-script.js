#!/usr/bin/env node

/**
 * TUV-Suchscript (Diagnostisch)
 * Dieses Script sucht nach allen Markdown-Dateien im Repository und gibt Informationen aus,
 * die helfen können, die richtigen Pfade und Muster für TUV-Dateien zu identifizieren.
 */

const fs = require('fs');
const path = require('path');

// Konfiguration
const rootPath = '.'; // aktuelles Verzeichnis
const ignorePatterns = [
  /node_modules/,
  /\.git/,
  /\.obsidian/
];

// Statistik
let totalFiles = 0;
let mdFiles = 0;
const filePatterns = {};

/**
 * Rekursive Suche nach Markdown-Dateien
 */
function searchMarkdownFiles(directory, depth = 0) {
  try {
    if (!fs.existsSync(directory)) {
      return [];
    }
    
    // Prüfe, ob das Verzeichnis ignoriert werden soll
    if (ignorePatterns.some(pattern => pattern.test(directory))) {
      return [];
    }
    
    const files = fs.readdirSync(directory, { withFileTypes: true });
    totalFiles += files.length;
    
    const markdownFiles = [];
    
    for (const file of files) {
      const fullPath = path.join(directory, file.name);
      
      if (file.isDirectory()) {
        // Rekursiv in Unterverzeichnissen suchen
        const subDirFiles = searchMarkdownFiles(fullPath, depth + 1);
        markdownFiles.push(...subDirFiles);
      } else if (file.name.endsWith('.md')) {
        mdFiles++;
        markdownFiles.push(fullPath);
        
        // Analysiere Dateinamen für Muster
        analyzeFilename(file.name);
      }
    }
    
    return markdownFiles;
  } catch (error) {
    console.error(`Fehler beim Durchsuchen von ${directory}:`, error);
    return [];
  }
}

/**
 * Analysiert den Dateinamen und extrahiert mögliche Muster
 */
function analyzeFilename(filename) {
  // Bekannte Muster für TUV-Dateien
  const patterns = [
    { pattern: /TUV/i, name: "TUV" },
    { pattern: /UE/i, name: "UE" },
    { pattern: /TB/i, name: "TB" },
    { pattern: /AB/i, name: "AB" },
    { pattern: /Unterricht/i, name: "Unterricht" }
  ];
  
  patterns.forEach(p => {
    if (p.pattern.test(filename)) {
      if (!filePatterns[p.name]) {
        filePatterns[p.name] = {
          count: 0,
          examples: []
        };
      }
      
      filePatterns[p.name].count++;
      
      // Speichere einige Beispiele für dieses Muster
      if (filePatterns[p.name].examples.length < 5) {
        filePatterns[p.name].examples.push(filename);
      }
    }
  });
}

/**
 * Analysiere Verzeichnisstruktur und suche nach potenziellen TUV-Verzeichnissen
 */
function findPotentialTUVDirectories() {
  const potentialDirs = [];
  
  function searchDirectories(directory, depth = 0) {
    try {
      if (!fs.existsSync(directory)) {
        return;
      }
      
      // Prüfe, ob das Verzeichnis ignoriert werden soll
      if (ignorePatterns.some(pattern => pattern.test(directory))) {
        return;
      }
      
      const files = fs.readdirSync(directory, { withFileTypes: true });
      
      // Prüfe, ob dieses Verzeichnis TUV-relevante Namen enthält
      const dirName = path.basename(directory).toLowerCase();
      if (
        dirName === 'tuv' || 
        dirName === 'unterricht' || 
        dirName.includes('unterrichtsvorbereit') ||
        dirName.includes('unterrichtsplan')
      ) {
        potentialDirs.push(directory);
      }
      
      // Rekursive Suche in Unterverzeichnissen
      for (const file of files) {
        if (file.isDirectory()) {
          searchDirectories(path.join(directory, file.name), depth + 1);
        }
      }
    } catch (error) {
      console.error(`Fehler beim Durchsuchen von ${directory}:`, error);
    }
  }
  
  searchDirectories(rootPath);
  return potentialDirs;
}

/**
 * Prüft, ob ein Verzeichnis Markdown-Dateien mit bestimmten Mustern enthält
 */
function checkDirectoryForPattern(directory, pattern) {
  try {
    if (!fs.existsSync(directory)) {
      return [];
    }
    
    const files = fs.readdirSync(directory, { withFileTypes: true });
    const matchingFiles = [];
    
    for (const file of files) {
      if (!file.isDirectory() && file.name.endsWith('.md') && pattern.test(file.name)) {
        matchingFiles.push(path.join(directory, file.name));
      }
    }
    
    return matchingFiles;
  } catch (error) {
    console.error(`Fehler beim Prüfen von ${directory}:`, error);
    return [];
  }
}

/**
 * Hauptfunktion
 */
function main() {
  console.log("Starte Diagnose für TUV-Dateien...");
  
  // Finde alle Markdown-Dateien im Repository
  console.log("Suche nach allen Markdown-Dateien im Repository...");
  const mdFiles = searchMarkdownFiles(rootPath);
  console.log(`Gesamtzahl der Dateien: ${totalFiles}`);
  console.log(`Markdown-Dateien gefunden: ${mdFiles.length}`);
  
  // Analysiere gefundene Dateinamenmuster
  console.log("\nGefundene Muster in Dateinamen:");
  Object.keys(filePatterns).forEach(pattern => {
    console.log(`- ${pattern}: ${filePatterns[pattern].count} Dateien`);
    console.log("  Beispiele:");
    filePatterns[pattern].examples.forEach(example => {
      console.log(`  - ${example}`);
    });
  });
  
  // Finde potenzielle TUV-Verzeichnisse
  console.log("\nPotenzielle TUV-Verzeichnisse:");
  const potentialDirs = findPotentialTUVDirectories();
  potentialDirs.forEach(dir => {
    console.log(`- ${dir}`);
    
    // Prüfe, wie viele Dateien mit TUV-Mustern in diesem Verzeichnis sind
    const patterns = [
      { pattern: /TUV/i, name: "TUV" },
      { pattern: /UE/i, name: "UE" },
      { pattern: /TB/i, name: "TB" }
    ];
    
    patterns.forEach(p => {
      const files = checkDirectoryForPattern(dir, p.pattern);
      if (files.length > 0) {
        console.log(`  - ${files.length} Dateien mit Muster "${p.name}"`);
        if (files.length > 0 && files.length <= 3) {
          console.log("    Beispiele:");
          files.forEach(file => {
            console.log(`    - ${path.basename(file)}`);
          });
        }
      }
    });
  });
  
  // Empfehlungen für die Konfiguration
  console.log("\nEmpfehlungen für die TUV-Generator Konfiguration:");
  
  // Empfohlene Suchpfade
  console.log("Empfohlene Suchpfade:");
  potentialDirs.forEach(dir => {
    console.log(`- '${dir}',`);
  });
  
  // Empfohlene Dateimuster
  console.log("\nEmpfohlene Dateimuster:");
  Object.keys(filePatterns)
    .filter(pattern => filePatterns[pattern].count > 0)
    .forEach(pattern => {
      console.log(`- /${pattern}/i,  // ${filePatterns[pattern].count} Dateien gefunden`);
    });
  
  console.log("\nDiagnose abgeschlossen!");
}

// Starte das Programm
main();
