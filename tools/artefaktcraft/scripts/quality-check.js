#!/usr/bin/env node

/**
 * ArtefaktCraft Quality Check
 * 
 * Dieses Skript führt Qualitätsprüfungen für Unterrichtsmaterialien durch.
 * Es kommuniziert mit dem mcp-Server, um:
 * 1. Metadaten gegen Schemas zu validieren
 * 2. Strukturelle Integrität zu prüfen
 * 3. Links und Referenzen zu validieren
 * 4. Fachspezifische Qualitätsstandards zu prüfen
 */

const fs = require('fs');
const path = require('path');
const axios = require('axios');
const matter = require('gray-matter');
const chalk = require('chalk');
const { program } = require('commander');

// Konfiguration
const MCP_SERVER_URL = 'http://localhost:3000';
const LINK_PATTERN = /\[([^\]]+)\]\(mcp:\/\/resource\/([^)]+)\)/g;
const TEMPLATE_PATTERN = /\{\{([^}]+)\}\}/g;

program
  .name('quality-check')
  .description('Führt Qualitätsprüfungen für Unterrichtsmaterialien durch')
  .version('1.0.0');

program
  .option('-f, --file <path>', 'Zu prüfende Datei')
  .option('-d, --directory <path>', 'Zu prüfendes Verzeichnis')
  .option('-r, --recursive', 'Rekursive Prüfung bei Verzeichnissen', false)
  .option('-s, --strict', 'Strenge Prüfung (fehlerhafte Tests führen zu Exit-Code 1)', false)
  .option('-o, --output <path>', 'Ergebnisse in Datei speichern');

program.parse();

const options = program.opts();

// Hauptfunktion
async function main() {
  try {
    if (!options.file && !options.directory) {
      console.error(chalk.red('❌ Weder Datei noch Verzeichnis angegeben.'));
      process.exit(1);
    }

    let filesToCheck = [];

    if (options.file) {
      filesToCheck.push(options.file);
    }

    if (options.directory) {
      filesToCheck = filesToCheck.concat(
        findMarkdownFiles(options.directory, options.recursive)
      );
    }

    if (filesToCheck.length === 0) {
      console.log(chalk.yellow('⚠️ Keine Markdown-Dateien gefunden.'));
      process.exit(0);
    }

    console.log(chalk.blue(`\nPrüfe ${filesToCheck.length} Dateien...`));

    let results = [];
    let hasErrors = false;

    for (const file of filesToCheck) {
      const fileResult = await checkFile(file);
      results.push(fileResult);
      
      if (fileResult.errors > 0) {
        hasErrors = true;
      }
    }

    // Zusammenfassung ausgeben
    const totalFiles = results.length;
    const passedFiles = results.filter(r => r.errors === 0).length;
    const totalErrors = results.reduce((sum, r) => sum + r.errors, 0);
    const totalWarnings = results.reduce((sum, r) => sum + r.warnings, 0);

    console.log(chalk.blue('\n=== Zusammenfassung ==='));
    console.log(`Geprüfte Dateien: ${totalFiles}`);
    console.log(`Bestanden: ${passedFiles} (${Math.round(passedFiles / totalFiles * 100)}%)`);
    console.log(`Fehler: ${totalErrors}`);
    console.log(`Warnungen: ${totalWarnings}`);

    // Ergebnisse speichern, falls gewünscht
    if (options.output) {
      const output = {
        timestamp: new Date().toISOString(),
        summary: {
          totalFiles,
          passedFiles,
          totalErrors,
          totalWarnings
        },
        results
      };

      fs.writeFileSync(options.output, JSON.stringify(output, null, 2), 'utf8');
      console.log(chalk.green(`\nErgebnisse gespeichert in: ${options.output}`));
    }

    // Exit-Code setzen, falls im strengen Modus
    if (options.strict && hasErrors) {
      process.exit(1);
    }
  } catch (error) {
    console.error(chalk.red(`\n❌ Unerwarteter Fehler: ${error.message}`));
    process.exit(1);
  }
}

/**
 * Findet Markdown-Dateien in einem Verzeichnis
 */
function findMarkdownFiles(directory, recursive) {
  const files = [];
  
  function scanDir(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      if (entry.isDirectory() && recursive) {
        scanDir(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  
  scanDir(directory);
  return files;
}

/**
 * Prüft eine einzelne Datei
 */
async function checkFile(filePath) {
  console.log(chalk.blue(`\nPrüfe Datei: ${filePath}`));
  
  const result = {
    file: filePath,
    errors: 0,
    warnings: 0,
    tests: []
  };
  
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const { data: metadata, content: markdown } = matter(content);
    
    // Test 1: Grundlegende Metadaten
    const basicMetadataResult = testBasicMetadata(metadata);
    result.tests.push(basicMetadataResult);
    if (basicMetadataResult.status === 'error') result.errors++;
    if (basicMetadataResult.status === 'warning') result.warnings++;
    
    // Test 2: Metadaten-Schema-Validierung
    const schemaValidationResult = await testSchemaValidation(metadata);
    result.tests.push(schemaValidationResult);
    if (schemaValidationResult.status === 'error') result.errors++;
    if (schemaValidationResult.status === 'warning') result.warnings++;
    
    // Test 3: Strukturelle Integrität
    const structuralIntegrityResult = testStructuralIntegrity(markdown, metadata.type);
    result.tests.push(structuralIntegrityResult);
    if (structuralIntegrityResult.status === 'error') result.errors++;
    if (structuralIntegrityResult.status === 'warning') result.warnings++;
    
    // Test 4: Links und Referenzen
    const linksResult = await testLinks(markdown);
    result.tests.push(linksResult);
    if (linksResult.status === 'error') result.errors++;
    if (linksResult.status === 'warning') result.warnings++;
    
    // Test 5: Template-Vollständigkeit
    const templateResult = testTemplateCompleteness(markdown);
    result.tests.push(templateResult);
    if (templateResult.status === 'error') result.errors++;
    if (templateResult.status === 'warning') result.warnings++;
    
    // Test 6: Fachspezifische Standards
    const subjectSpecificResult = await testSubjectSpecificStandards(metadata, markdown);
    result.tests.push(subjectSpecificResult);
    if (subjectSpecificResult.status === 'error') result.errors++;
    if (subjectSpecificResult.status === 'warning') result.warnings++;
    
    // Gesamtergebnis
    if (result.errors > 0) {
      console.log(chalk.red(`❌ Datei hat ${result.errors} Fehler und ${result.warnings} Warnungen.`));
    } else if (result.warnings > 0) {
      console.log(chalk.yellow(`⚠️ Datei hat ${result.warnings} Warnungen.`));
    } else {
      console.log(chalk.green('✓ Datei hat alle Tests bestanden.'));
    }
    
    return result;
  } catch (error) {
    console.error(chalk.red(`❌ Fehler beim Prüfen der Datei: ${error.message}`));
    result.errors++;
    result.tests.push({
      name: 'Dateizugriff',
      status: 'error',
      message: `Fehler beim Zugriff/Parsen der Datei: ${error.message}`
    });
    return result;
  }
}

/**
 * Test 1: Prüft grundlegende Metadaten
 */
function testBasicMetadata(metadata) {
  const result = {
    name: 'Grundlegende Metadaten',
    status: 'success',
    message: 'Alle grundlegenden Metadaten sind vorhanden.',
    details: []
  };
  
  const requiredFields = ['type', 'title', 'subject', 'grade'];
  const missingFields = [];
  
  for (const field of requiredFields) {
    if (!metadata[field]) {
      missingFields.push(field);
    }
  }
  
  if (missingFields.length > 0) {
    result.status = 'error';
    result.message = `Folgende grundlegende Metadaten fehlen: ${missingFields.join(', ')}`;
  }
  
  // Empfohlene, aber nicht zwingend erforderliche Felder
  const recommendedFields = ['topic', 'author', 'created'];
  const missingRecommended = [];
  
  for (const field of recommendedFields) {
    if (!metadata[field]) {
      missingRecommended.push(field);
    }
  }
  
  if (missingRecommended.length > 0) {
    if (result.status === 'success') {
      result.status = 'warning';
      result.message = `Folgende empfohlene Metadaten fehlen: ${missingRecommended.join(', ')}`;
    } else {
      result.details.push(`Folgende empfohlene Metadaten fehlen: ${missingRecommended.join(', ')}`);
    }
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Test 2: Validiert Metadaten gegen Schema
 */
async function testSchemaValidation(metadata) {
  const result = {
    name: 'Metadaten-Schema-Validierung',
    status: 'success',
    message: 'Metadaten entsprechen dem Schema.',
    details: []
  };
  
  if (!metadata.type) {
    result.status = 'warning';
    result.message = 'Kein Typ angegeben, Schema-Validierung übersprungen.';
    console.log(formatTestResult(result));
    return result;
  }
  
  try {
    await axios.post(`${MCP_SERVER_URL}/validate/metadata`, metadata);
  } catch (error) {
    if (error.response && error.response.data && error.response.data.errors) {
      result.status = 'error';
      result.message = 'Metadaten entsprechen nicht dem Schema.';
      result.details = error.response.data.errors.map(e => e.message);
    } else if (error.response && error.response.status === 404) {
      result.status = 'warning';
      result.message = `Kein Schema für Typ "${metadata.type}" verfügbar.`;
    } else {
      result.status = 'warning';
      result.message = `Schema-Validierung nicht möglich: ${error.message}`;
    }
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Test 3: Prüft strukturelle Integrität basierend auf dem Typ
 */
function testStructuralIntegrity(markdown, type) {
  const result = {
    name: 'Strukturelle Integrität',
    status: 'success',
    message: 'Inhalt hat die erwartete Struktur.',
    details: []
  };
  
  if (!type) {
    result.status = 'warning';
    result.message = 'Kein Typ angegeben, strukturelle Prüfung übersprungen.';
    console.log(formatTestResult(result));
    return result;
  }
  
  // Typspezifische Prüfungen
  switch (type) {
    case 'unterrichtseinheit':
      if (!markdown.includes('## Lernziele') && !markdown.includes('## Lernziel')) {
        result.status = 'warning';
        result.details.push('Keine Lernziele gefunden.');
      }
      
      if (!markdown.includes('## Verlaufsplanung')) {
        result.status = 'warning';
        result.details.push('Keine Verlaufsplanung gefunden.');
      }
      
      if (!markdown.match(/##\s+Material/)) {
        result.status = 'warning';
        result.details.push('Kein Materialabschnitt gefunden.');
      }
      break;
      
    case 'sequenzplanung':
      if (!markdown.match(/##\s+Lehrplanbezug/)) {
        result.status = 'warning';
        result.details.push('Kein Lehrplanbezug gefunden.');
      }
      
      if (!markdown.match(/##\s+Sequenzüberblick/) && !markdown.match(/##\s+Sequenzübersicht/)) {
        result.status = 'warning';
        result.details.push('Kein Sequenzüberblick gefunden.');
      }
      break;
      
    case 'tafelbild':
      if (!markdown.match(/##\s+Skizze/) && !markdown.match(/##\s+Visualisierung/)) {
        result.status = 'warning';
        result.details.push('Keine Tafelbild-Skizze gefunden.');
      }
      break;
      
    default:
      // Generische Prüfungen für alle Typen
      if (!markdown.match(/^#\s+/m)) {
        result.status = 'error';
        result.details.push('Keine Hauptüberschrift (H1) gefunden.');
      }
      
      if (!markdown.match(/##\s+/m)) {
        result.status = 'warning';
        result.details.push('Keine Unterüberschriften (H2) gefunden.');
      }
  }
  
  if (result.details.length > 0 && result.status === 'success') {
    result.status = 'warning';
  }
  
  if (result.details.length > 0) {
    result.message = `${result.details.length} strukturelle Probleme gefunden.`;
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Test 4: Prüft Links und Referenzen
 */
async function testLinks(markdown) {
  const result = {
    name: 'Links und Referenzen',
    status: 'success',
    message: 'Alle Links sind gültig.',
    details: []
  };
  
  // Extract mcp links
  let links = [];
  let match;
  while ((match = LINK_PATTERN.exec(markdown)) !== null) {
    links.push({
      text: match[1],
      resourceId: match[2],
      fullMatch: match[0]
    });
  }
  
  if (links.length === 0) {
    result.status = 'info';
    result.message = 'Keine mcp-Links gefunden.';
    console.log(formatTestResult(result));
    return result;
  }
  
  try {
    const resourcesResponse = await axios.get(`${MCP_SERVER_URL}/resources`, {
      params: { format: 'json', ids: links.map(link => link.resourceId).join(',') }
    });
    
    const resources = resourcesResponse.data;
    
    for (const link of links) {
      const resource = resources.find(r => r.id === link.resourceId);
      
      if (!resource) {
        result.status = 'error';
        result.details.push(`Ungültiger Link: ${link.text} (${link.resourceId}) - Ressource nicht gefunden`);
        continue;
      }
      
      if (resource.path !== resource.currentPath) {
        result.status = 'warning';
        result.details.push(`Veralteter Link: ${link.text} (${link.resourceId}) - Pfad hat sich geändert`);
      }
    }
  } catch (error) {
    result.status = 'warning';
    result.message = `Link-Prüfung nicht möglich: ${error.message}`;
  }
  
  if (result.details.length > 0) {
    result.message = `${result.details.length} Probleme mit Links gefunden.`;
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Test 5: Prüft auf unersetzten Template-Platzhalter
 */
function testTemplateCompleteness(markdown) {
  const result = {
    name: 'Template-Vollständigkeit',
    status: 'success',
    message: 'Keine unersetzten Template-Platzhalter gefunden.',
    details: []
  };
  
  // Finde Template-Platzhalter
  let templateMatches = [];
  let match;
  while ((match = TEMPLATE_PATTERN.exec(markdown)) !== null) {
    templateMatches.push(match[0]);
  }
  
  if (templateMatches.length > 0) {
    result.status = 'error';
    result.message = `${templateMatches.length} unersetzten Template-Platzhalter gefunden.`;
    result.details = templateMatches;
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Test 6: Fachspezifische Qualitätsstandards
 */
async function testSubjectSpecificStandards(metadata, markdown) {
  const result = {
    name: 'Fachspezifische Standards',
    status: 'success',
    message: 'Alle fachspezifischen Standards erfüllt.',
    details: []
  };
  
  if (!metadata.subject) {
    result.status = 'warning';
    result.message = 'Kein Fach angegeben, fachspezifische Prüfung übersprungen.';
    console.log(formatTestResult(result));
    return result;
  }
  
  try {
    const response = await axios.post(`${MCP_SERVER_URL}/validate/subjectStandards`, {
      subject: metadata.subject,
      type: metadata.type,
      content: markdown
    });
    
    if (response.data.issues && response.data.issues.length > 0) {
      result.status = response.data.status || 'warning';
      result.message = `${response.data.issues.length} fachspezifische Probleme gefunden.`;
      result.details = response.data.issues;
    }
  } catch (error) {
    if (error.response && error.response.status === 404) {
      result.status = 'info';
      result.message = `Keine fachspezifischen Standards für ${metadata.subject} verfügbar.`;
    } else {
      result.status = 'warning';
      result.message = `Fachspezifische Prüfung nicht möglich: ${error.message}`;
    }
  }
  
  console.log(formatTestResult(result));
  return result;
}

/**
 * Formatiert ein Testergebnis für die Konsolenausgabe
 */
function formatTestResult(result) {
  let icon;
  let color;
  
  switch (result.status) {
    case 'success':
      icon = '✓';
      color = chalk.green;
      break;
    case 'warning':
      icon = '⚠️';
      color = chalk.yellow;
      break;
    case 'error':
      icon = '❌';
      color = chalk.red;
      break;
    case 'info':
      icon = 'ℹ️';
      color = chalk.blue;
      break;
    default:
      icon = '?';
      color = chalk.gray;
  }
  
  let output = color(`${icon} ${result.name}: ${result.message}`);
  
  if (result.details && result.details.length > 0) {
    output += '\n' + result.details.map(detail => `  - ${detail}`).join('\n');
  }
  
  return output;
}

// Starte das Skript
main();
