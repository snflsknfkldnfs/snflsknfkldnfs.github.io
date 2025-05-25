#!/usr/bin/env node

/**
 * ArtefaktCraft Standards-Validator
 * 
 * Dieses Skript prüft Unterrichtsmaterialien gegen fachspezifische didaktische
 * und methodische Standards, um eine hohe Qualität sicherzustellen.
 */

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const chalk = require('chalk');
const { program } = require('commander');

// Konfiguration
const MCP_SERVER_URL = 'http://localhost:3000';
let standardsRegistry = {};

program
  .name('validate-standards')
  .description('Prüft Unterrichtsmaterialien gegen fachspezifische Standards')
  .version('1.0.0');

program
  .option('-f, --file <path>', 'Zu prüfende Datei')
  .option('-s, --subject <subject>', 'Fach (WiB, GPG)')
  .option('-t, --type <type>', 'Materialtyp (unterrichtseinheit, sequenzplanung, etc.)')
  .option('-c, --config <path>', 'Pfad zur Konfigurationsdatei')
  .option('--detail', 'Detaillierte Ausgabe')
  .option('--json', 'Ausgabe im JSON-Format')
  .option('--strict', 'Strikte Prüfung');

program.parse();

const options = program.opts();

// Hauptfunktion
async function main() {
  try {
    // Lade Standards-Registry
    await loadStandardsRegistry();

    // Prüfe, ob eine Datei angegeben wurde
    if (!options.file) {
      console.error(chalk.red('Keine Datei angegeben. Verwenden Sie --file oder -f'));
      process.exit(1);
    }

    // Datei einlesen
    const filePath = options.file;
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const { data: metadata, content } = matter(fileContent);

    // Fach und Materialtyp bestimmen (aus Argumenten oder Metadaten)
    const subject = options.subject || metadata.subject;
    const type = options.type || metadata.type;

    if (!subject || !type) {
      console.error(chalk.red('Fach und Materialtyp konnten nicht bestimmt werden. Bitte geben Sie diese mit --subject und --type an oder stellen Sie sicher, dass die Metadaten diese Informationen enthalten.'));
      process.exit(1);
    }

    // Standards für das angegebene Fach und den Materialtyp abrufen
    const standards = getStandards(subject, type);

    if (!standards) {
      console.error(chalk.yellow(`Keine Standards für Fach "${subject}" und Typ "${type}" definiert.`));
      process.exit(0);
    }

    // Material gegen Standards prüfen
    const results = validateAgainstStandards(metadata, content, standards);

    // Ergebnisse ausgeben
    if (options.json) {
      console.log(JSON.stringify(results, null, 2));
    } else {
      displayResults(results);
    }

    // Exit-Code setzen
    if (options.strict && (results.errors > 0 || results.warnings > 0)) {
      process.exit(1);
    }
  } catch (error) {
    console.error(chalk.red(`Fehler: ${error.message}`));
    process.exit(1);
  }
}

/**
 * Lädt die Standards-Registry aus der Konfiguration oder der Standard-Registry
 */
async function loadStandardsRegistry() {
  try {
    if (options.config) {
      // Konfigurationsdatei laden
      const configPath = options.config;
      if (!fs.existsSync(configPath)) {
        throw new Error(`Konfigurationsdatei nicht gefunden: ${configPath}`);
      }
      standardsRegistry = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    } else {
      // Eingebaute Standards laden
      standardsRegistry = {
        "WiB": {
          "unterrichtseinheit": [
            {
              "name": "Lernzielformulierung",
              "description": "Lernziele sollten nach dem Mager-Schema formuliert sein",
              "pattern": "Die Schülerinnen und Schüler.+indem sie.+was daran erkennbar wird, dass",
              "level": "error",
              "message": "Lernziele sollten nach dem Mager-Schema formuliert werden: \"Die SuS [Kompetenz], indem sie [Methode], was daran erkennbar wird, dass [Maßstab]\"."
            },
            {
              "name": "Kompetenzorientierung",
              "description": "Bezug zu prozessbezogenen Kompetenzen herstellen",
              "pattern": "(Handeln|Analysieren|Kommunizieren|Beurteilen)",
              "level": "warning",
              "message": "Der Bezug zu prozessbezogenen Kompetenzen (Handeln, Analysieren, Kommunizieren, Beurteilen) sollte deutlicher hergestellt werden."
            },
            {
              "name": "Differenzierung",
              "description": "Differenzierungsmaßnahmen sollten enthalten sein",
              "pattern": "## Differenzierung",
              "level": "warning",
              "message": "Differenzierungsmaßnahmen für verschiedene Leistungsniveaus sollten enthalten sein."
            },
            {
              "name": "Verlaufsplanung",
              "description": "Detaillierte Verlaufsplanung mit Sozialformen",
              "pattern": "[Ss]ozialform|Einzelarbeit|Partnerarbeit|Gruppenarbeit|Plenum",
              "level": "error",
              "message": "Die Verlaufsplanung sollte Angaben zu Sozialformen enthalten."
            },
            {
              "name": "Lehrplanbezug",
              "description": "Bezug zu Lehrplaninhalten herstellen",
              "pattern": "Kompetenzerwartungen|Lehrplan|Lernbereich",
              "level": "error",
              "message": "Der Bezug zum Lehrplan sollte deutlich hergestellt werden."
            },
            {
              "name": "Materialangaben",
              "description": "Benötigte Materialien auflisten",
              "pattern": "## Material|## Medien|## Materialien und Medien",
              "level": "warning",
              "message": "Eine Auflistung der benötigten Materialien und Medien sollte enthalten sein."
            }
          ],
          "sequenzplanung": [
            {
              "name": "Kompetenzerwartungen",
              "description": "Auflistung der Kompetenzerwartungen aus dem Lehrplan",
              "pattern": "Kompetenzerwartungen|LehrplanPLUS",
              "level": "error",
              "message": "Die Kompetenzerwartungen aus dem LehrplanPLUS sollten explizit aufgeführt werden."
            },
            {
              "name": "Sequenzübersicht",
              "description": "Tabellarische Übersicht über alle Stunden",
              "pattern": "Sequenz(übersicht|überblick)|Stunden(übersicht|überblick)",
              "level": "error",
              "message": "Eine tabellarische Übersicht über alle Stunden der Sequenz sollte enthalten sein."
            },
            {
              "name": "Lernprogression",
              "description": "Darstellung der Lernprogression über die Sequenz",
              "pattern": "Progression|Lernweg|Aufbau",
              "level": "warning",
              "message": "Die Lernprogression über die Sequenz sollte deutlicher dargestellt werden."
            }
          ],
          "tafelbild": [
            {
              "name": "Visualisierung",
              "description": "Visualisierung des Tafelbilds",
              "pattern": "Skizze|Visualisierung|Tafelbild",
              "level": "error",
              "message": "Eine visuelle Darstellung oder Skizze des Tafelbilds sollte enthalten sein."
            },
            {
              "name": "Entwicklung",
              "description": "Erläuterung zur Entwicklung des Tafelbilds",
              "pattern": "Entwicklung|Erarbeitung|Entstehung",
              "level": "warning",
              "message": "Erläuterungen zur schrittweisen Entwicklung des Tafelbilds sollten enthalten sein."
            }
          ]
        },
        "GPG": {
          "unterrichtseinheit": [
            {
              "name": "Multiperspektivität",
              "description": "Berücksichtigung verschiedener Perspektiven",
              "pattern": "Perspektive|multiperspektivisch|verschiedene Sichtweisen",
              "level": "warning",
              "message": "Es sollten verschiedene Perspektiven (historisch, politisch, geographisch) berücksichtigt werden."
            },
            {
              "name": "Quellenarbeit",
              "description": "Arbeit mit historischen/politischen Quellen",
              "pattern": "Quelle|Material|Dokument",
              "level": "warning",
              "message": "Die Arbeit mit Quellen oder Dokumenten sollte stärker berücksichtigt werden."
            }
          ]
        }
      };
    }
  } catch (error) {
    console.error(chalk.red(`Fehler beim Laden der Standards-Registry: ${error.message}`));
    process.exit(1);
  }
}

/**
 * Ruft die Standards für ein bestimmtes Fach und einen Materialtyp ab
 */
function getStandards(subject, type) {
  if (standardsRegistry[subject] && standardsRegistry[subject][type]) {
    return standardsRegistry[subject][type];
  }
  return null;
}

/**
 * Validiert ein Material gegen die definierten Standards
 */
function validateAgainstStandards(metadata, content, standards) {
  const results = {
    subject: metadata.subject,
    type: metadata.type,
    title: metadata.title || 'Unbekannter Titel',
    totalStandards: standards.length,
    passed: 0,
    warnings: 0,
    errors: 0,
    standardResults: []
  };

  // Jeden Standard prüfen
  for (const standard of standards) {
    const result = {
      name: standard.name,
      description: standard.description,
      level: standard.level,
      message: standard.message,
      passed: false
    };

    // Pattern-basierte Prüfung
    if (standard.pattern) {
      const regex = new RegExp(standard.pattern, 'i');
      result.passed = regex.test(content);
    }

    // Ergebnis speichern
    if (!result.passed) {
      if (standard.level === 'error') {
        results.errors++;
      } else if (standard.level === 'warning') {
        results.warnings++;
      }
    } else {
      results.passed++;
    }

    results.standardResults.push(result);
  }

  return results;
}

/**
 * Gibt die Ergebnisse formatiert aus
 */
function displayResults(results) {
  console.log(chalk.blue(`\nStandards-Validierung für: ${results.title}`));
  console.log(chalk.blue(`Fach: ${results.subject}, Typ: ${results.type}`));
  console.log(chalk.blue('--------------------------------------------------'));

  console.log(`Geprüfte Standards: ${results.totalStandards}`);
  console.log(`Erfüllte Standards: ${results.passed} (${Math.round(results.passed / results.totalStandards * 100)}%)`);
  console.log(`Fehler: ${results.errors}`);
  console.log(`Warnungen: ${results.warnings}`);

  console.log(chalk.blue('\nDetailergebnisse:'));

  // Sortieren: Erst Fehler, dann Warnungen, dann bestandene Tests
  const sortedResults = [...results.standardResults].sort((a, b) => {
    const levelOrder = { 'error': 0, 'warning': 1, 'info': 2 };
    if (a.passed !== b.passed) {
      return a.passed ? 1 : -1;
    }
    return (levelOrder[a.level] || 3) - (levelOrder[b.level] || 3);
  });

  for (const result of sortedResults) {
    if (!result.passed) {
      const prefix = result.level === 'error' ? chalk.red('✗') : chalk.yellow('⚠');
      const title = result.level === 'error' ? chalk.red(result.name) : chalk.yellow(result.name);
      console.log(`${prefix} ${title}: ${result.message}`);
      
      if (options.detail) {
        console.log(`   Beschreibung: ${result.description}`);
      }
    } else if (options.detail) {
      console.log(`${chalk.green('✓')} ${chalk.green(result.name)}: Standard erfüllt`);
    }
  }

  console.log(chalk.blue('\nZusammenfassung:'));
  if (results.errors > 0) {
    console.log(chalk.red(`❌ Material erfüllt nicht alle notwendigen Standards. ${results.errors} Fehler müssen behoben werden.`));
  } else if (results.warnings > 0) {
    console.log(chalk.yellow(`⚠️ Material erfüllt die Grundstandards, kann aber in ${results.warnings} Bereichen verbessert werden.`));
  } else {
    console.log(chalk.green('✓ Material erfüllt alle Standards.'));
  }
}

// Starte das Skript
main();
