#!/usr/bin/env node

/**
 * ArtefaktCraft Update-Checker
 * 
 * Prüft regelmäßig auf Updates und Standards-Aktualisierungen und hält
 * das System auf dem neuesten Stand.
 */

const fs = require('fs').promises;
const path = require('path');
const https = require('https');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const chalk = require('chalk');
const axios = require('axios').default;

// Konfiguration
const CONFIG = {
  updateUrl: 'https://updates.artefaktcraft.edu/api/check',
  versionsFile: path.join(__dirname, '..', 'data', 'versions.json'),
  standardsDirectory: path.join(__dirname, '..', 'data', 'standards'),
  templatesDirectory: path.join(__dirname, '..', 'templates'),
  autoUpdate: true,
  checkInterval: 24 * 60 * 60 * 1000, // 24 Stunden
  currentVersion: '1.0.0'
};

// Hauptfunktion
async function main() {
  console.log(chalk.blue('ArtefaktCraft Update-Checker gestartet'));

  try {
    // Versionen laden oder initialisieren
    let versions = await loadVersions();
    
    // Updates prüfen
    console.log(chalk.blue('Suche nach Updates...'));
    const updates = await checkForUpdates(versions);
    
    if (!updates || (!updates.hasSystemUpdate && !updates.hasStandardsUpdate && !updates.hasTemplateUpdate)) {
      console.log(chalk.green('Keine Updates verfügbar. ArtefaktCraft ist auf dem neuesten Stand.'));
      return;
    }
    
    // Updates anzeigen
    displayUpdates(updates);
    
    // Updates installieren, wenn aktiviert
    if (CONFIG.autoUpdate) {
      await installUpdates(updates, versions);
    } else {
      console.log(chalk.yellow('Auto-Update ist deaktiviert. Führen Sie "node update-checker.js --install" aus, um Updates zu installieren.'));
    }
  } catch (error) {
    console.error(chalk.red(`Fehler beim Update-Check: ${error.message}`));
  }
}

/**
 * Lädt die gespeicherten Versionsinformationen oder erstellt eine neue Datei
 */
async function loadVersions() {
  try {
    const data = await fs.readFile(CONFIG.versionsFile, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    // Wenn die Datei nicht existiert, neue Versionen initialisieren
    const versions = {
      system: CONFIG.currentVersion,
      lastCheck: new Date().toISOString(),
      standards: {},
      templates: {}
    };
    
    // Verzeichnissstruktur erstellen, falls nötig
    const dir = path.dirname(CONFIG.versionsFile);
    await fs.mkdir(dir, { recursive: true });
    
    // Datei speichern
    await fs.writeFile(CONFIG.versionsFile, JSON.stringify(versions, null, 2));
    
    return versions;
  }
}

/**
 * Speichert die aktuellen Versionsinformationen
 */
async function saveVersions(versions) {
  versions.lastCheck = new Date().toISOString();
  await fs.writeFile(CONFIG.versionsFile, JSON.stringify(versions, null, 2));
}

/**
 * Prüft, ob Updates verfügbar sind
 */
async function checkForUpdates(versions) {
  try {
    // Sichere HTTP-Anfrage statt direktem HTTP-Request
    // Hinweis: In der Produktionsversion würde hier der tatsächliche Update-Server angesprochen
    // Für dieses Beispiel simulieren wir ein Update
    
    // Simulierte Antwort
    const updates = {
      hasSystemUpdate: false,
      systemVersion: CONFIG.currentVersion,
      systemChanges: [],
      hasStandardsUpdate: true,
      standardsUpdates: [
        {
          subject: "WiB",
          type: "unterrichtseinheit",
          version: "1.0.1",
          changes: ["Verbesserte Lernzielvalidierung", "Neue Standards für Differenzierung"]
        }
      ],
      hasTemplateUpdate: true,
      templateUpdates: [
        {
          id: "ue_wib_standard",
          version: "1.0.1",
          changes: ["Verbesserte Struktur der Verlaufsplanung", "Neue Reflexionselemente"]
        }
      ]
    };
    
    return updates;
  } catch (error) {
    console.error(chalk.red(`Fehler bei der Update-Prüfung: ${error.message}`));
    return null;
  }
}

/**
 * Zeigt verfügbare Updates an
 */
function displayUpdates(updates) {
  console.log(chalk.blue('\nVerfügbare Updates:'));
  
  if (updates.hasSystemUpdate) {
    console.log(chalk.green(`System-Update verfügbar: ${CONFIG.currentVersion} → ${updates.systemVersion}`));
    console.log('Änderungen:');
    updates.systemChanges.forEach(change => console.log(`- ${change}`));
    console.log();
  }
  
  if (updates.hasStandardsUpdate) {
    console.log(chalk.green('Standards-Updates verfügbar:'));
    updates.standardsUpdates.forEach(update => {
      console.log(`- ${update.subject} / ${update.type}: Version ${update.version}`);
      update.changes.forEach(change => console.log(`  - ${change}`));
    });
    console.log();
  }
  
  if (updates.hasTemplateUpdate) {
    console.log(chalk.green('Template-Updates verfügbar:'));
    updates.templateUpdates.forEach(update => {
      console.log(`- Template ${update.id}: Version ${update.version}`);
      update.changes.forEach(change => console.log(`  - ${change}`));
    });
    console.log();
  }
}

/**
 * Installiert verfügbare Updates
 */
async function installUpdates(updates, versions) {
  console.log(chalk.blue('\nInstalliere Updates...'));
  
  try {
    // System-Update installieren
    if (updates.hasSystemUpdate) {
      await installSystemUpdate(updates.systemVersion);
      versions.system = updates.systemVersion;
    }
    
    // Standards-Updates installieren
    if (updates.hasStandardsUpdate) {
      await installStandardsUpdates(updates.standardsUpdates, versions);
    }
    
    // Template-Updates installieren
    if (updates.hasTemplateUpdate) {
      await installTemplateUpdates(updates.templateUpdates, versions);
    }
    
    // Versionsinformationen speichern
    await saveVersions(versions);
    
    console.log(chalk.green('\nAlle Updates wurden erfolgreich installiert.'));
  } catch (error) {
    console.error(chalk.red(`Fehler bei der Update-Installation: ${error.message}`));
  }
}

/**
 * Installiert ein System-Update
 */
async function installSystemUpdate(newVersion) {
  console.log(chalk.blue(`Installiere System-Update auf Version ${newVersion}...`));
  
  // In einer vollständigen Implementierung würden hier komplexere Update-Schritte durchgeführt
  // Für dieses Beispiel simulieren wir eine erfolgreiche Installation
  
  return new Promise(resolve => {
    setTimeout(() => {
      console.log(chalk.green('System-Update erfolgreich installiert.'));
      resolve();
    }, 1000);
  });
}

/**
 * Installiert Standards-Updates
 */
async function installStandardsUpdates(standardsUpdates, versions) {
  console.log(chalk.blue('Installiere Standards-Updates...'));
  
  // In einer vollständigen Implementierung würden hier die Standards-Dateien aktualisiert
  // Für dieses Beispiel simulieren wir eine erfolgreiche Installation
  
  for (const update of standardsUpdates) {
    console.log(chalk.blue(`Aktualisiere Standards für ${update.subject}/${update.type} auf Version ${update.version}...`));
    
    // Standards-Verzeichnis erstellen, falls nötig
    const subjectDir = path.join(CONFIG.standardsDirectory, update.subject);
    await fs.mkdir(subjectDir, { recursive: true });
    
    // Dummy-Standards-Datei erstellen/aktualisieren
    const standardsFile = path.join(subjectDir, `${update.type}.json`);
    const standardsData = {
      version: update.version,
      updated: new Date().toISOString(),
      standards: [
        {
          name: "Beispiel-Standard",
          description: "Dies ist ein Beispiel-Standard",
          pattern: "Beispiel-Pattern",
          level: "warning",
          message: "Beispiel-Nachricht"
        }
      ]
    };
    
    await fs.writeFile(standardsFile, JSON.stringify(standardsData, null, 2));
    
    // Version aktualisieren
    if (!versions.standards[update.subject]) {
      versions.standards[update.subject] = {};
    }
    versions.standards[update.subject][update.type] = update.version;
    
    console.log(chalk.green(`Standards für ${update.subject}/${update.type} wurden aktualisiert.`));
  }
}

/**
 * Installiert Template-Updates
 */
async function installTemplateUpdates(templateUpdates, versions) {
  console.log(chalk.blue('Installiere Template-Updates...'));
  
  // In einer vollständigen Implementierung würden hier die Template-Dateien aktualisiert
  // Für dieses Beispiel simulieren wir eine erfolgreiche Installation
  
  for (const update of templateUpdates) {
    console.log(chalk.blue(`Aktualisiere Template ${update.id} auf Version ${update.version}...`));
    
    const templateFile = path.join(CONFIG.templatesDirectory, `${update.id}.md`);
    
    try {
      // Prüfen, ob die Datei existiert
      await fs.access(templateFile);
      
      // Vorhandene Datei lesen
      const templateContent = await fs.readFile(templateFile, 'utf8');
      
      // In einer vollständigen Implementierung würde hier der tatsächliche Template-Inhalt aktualisiert
      // Für dieses Beispiel ändern wir nur die Versionsangabe
      const updatedContent = templateContent.replace(
        /version: ".*"/,
        `version: "${update.version}"`
      );
      
      // Aktualisierte Datei speichern
      await fs.writeFile(templateFile, updatedContent);
      
      // Version aktualisieren
      if (!versions.templates[update.id]) {
        versions.templates[update.id] = {};
      }
      versions.templates[update.id] = update.version;
      
      console.log(chalk.green(`Template ${update.id} wurde aktualisiert.`));
    } catch (error) {
      console.warn(chalk.yellow(`Template ${update.id} konnte nicht aktualisiert werden: ${error.message}`));
    }
  }
}

// Starte das Skript
main();
