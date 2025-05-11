#!/usr/bin/env node

/**
 * ArtefaktCraft Material Creator
 * 
 * Dieses Skript erstellt neue Unterrichtsmaterialien basierend auf Templates
 * und Metadaten. Es kommuniziert mit dem mcp-Server, um:
 * 1. Verfügbare Templates abzurufen
 * 2. Metadaten zu validieren
 * 3. Dynamische Inhalte wie Lehrplanauszüge zu integrieren
 */

const fs = require('fs');
const path = require('path');
const axios = require('axios');
const matter = require('gray-matter');
const yaml = require('js-yaml');
const chalk = require('chalk');
const { program } = require('commander');
const { v4: uuidv4 } = require('uuid');

// Konfiguration
const MCP_SERVER_URL = 'http://localhost:3000';
const TEMPLATES_DIR = path.resolve(__dirname, '../templates');
const DEFAULT_OUTPUT_DIR = path.resolve(process.cwd(), 'notizen');

program
  .name('create-material')
  .description('Erstellt neue Unterrichtsmaterialien basierend auf Templates und Metadaten')
  .version('1.0.0');

program
  .option('-t, --template <name>', 'Name des zu verwendenden Templates')
  .option('-m, --metadata <file>', 'Pfad zur Metadaten-YAML-Datei')
  .option('-o, --output <file>', 'Ausgabepfad für das neue Material')
  .option('-l, --list-templates', 'Listet verfügbare Templates auf')
  .option('-d, --dynamic', 'Dynamische Inhalte vom mcp-Server einbinden', false);

program.parse();

const options = program.opts();

// Hauptfunktion
async function main() {
  try {
    // Prüfe, ob der mcp-Server erreichbar ist
    try {
      await axios.get(`${MCP_SERVER_URL}/status`);
      console.log(chalk.green('✓ mcp-Server ist erreichbar'));
    } catch (error) {
      console.error(chalk.red(`❌ mcp-Server ist nicht erreichbar: ${error.message}`));
      console.log(chalk.yellow('⚠️ Arbeite im Offline-Modus - Einige Funktionen sind nicht verfügbar'));
    }

    if (options.listTemplates) {
      await listTemplates();
      return;
    }

    if (!options.template) {
      console.error(chalk.red('❌ Kein Template angegeben. Verwenden Sie --template oder -t'));
      return;
    }

    if (!options.metadata) {
      console.error(chalk.red('❌ Keine Metadaten angegeben. Verwenden Sie --metadata oder -m'));
      return;
    }

    if (!options.output) {
      console.error(chalk.red('❌ Kein Ausgabepfad angegeben. Verwenden Sie --output oder -o'));
      return;
    }

    // Lade und validiere Metadaten
    let metadata;
    try {
      const metadataContent = fs.readFileSync(options.metadata, 'utf8');
      metadata = yaml.load(metadataContent);
      
      // Validiere Metadaten gegen Schema
      if (metadata.type) {
        try {
          await axios.post(`${MCP_SERVER_URL}/validate/metadata`, metadata);
          console.log(chalk.green('✓ Metadaten erfolgreich validiert'));
        } catch (error) {
          console.warn(chalk.yellow(`⚠️ Metadatenvalidierung fehlgeschlagen: ${error.message}`));
          console.log(chalk.yellow('⚠️ Fortfahren ohne Validierung...'));
        }
      }
    } catch (error) {
      console.error(chalk.red(`❌ Fehler beim Laden der Metadaten: ${error.message}`));
      return;
    }

    // Generiere eine eindeutige ID für die neue Ressource, falls nicht vorhanden
    if (!metadata.id) {
      const idBase = `${metadata.subject.toLowerCase()}_${metadata.type.toLowerCase()}_${metadata.topic.toLowerCase().replace(/\s+/g, '_')}_${metadata.grade}`;
      metadata.id = idBase;
    }

    // Lade Template
    let templateContent;
    try {
      // Versuche zuerst, das Template vom mcp-Server zu laden
      try {
        const response = await axios.get(`${MCP_SERVER_URL}/templates/${options.template}`);
        templateContent = response.data;
        console.log(chalk.green(`✓ Template "${options.template}" vom mcp-Server geladen`));
      } catch (error) {
        // Fallback: Lokales Template laden
        const templatePath = path.join(TEMPLATES_DIR, `${options.template}.md`);
        templateContent = fs.readFileSync(templatePath, 'utf8');
        console.log(chalk.green(`✓ Template "${options.template}" lokal geladen`));
      }
    } catch (error) {
      console.error(chalk.red(`❌ Fehler beim Laden des Templates: ${error.message}`));
      return;
    }

    // Ergänze dynamische Inhalte, wenn erforderlich
    if (options.dynamic) {
      templateContent = await enrichTemplateWithDynamicContent(templateContent, metadata);
    }

    // Füge Metadaten hinzu und ersetze Platzhalter
    let finalContent = matter.stringify(
      replaceTemplateVariables(templateContent, metadata),
      metadata
    );

    // Sicherstellen, dass der Ausgabepfad existiert
    const outputDir = path.dirname(options.output);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Schreibe die fertige Datei
    fs.writeFileSync(options.output, finalContent, 'utf8');

    console.log(chalk.green(`✓ Material erfolgreich erstellt: ${options.output}`));
    
    // Registriere die neue Ressource beim mcp-Server
    try {
      await axios.post(`${MCP_SERVER_URL}/resources/register`, {
        id: metadata.id,
        path: options.output,
        metadata: metadata
      });
      console.log(chalk.green(`✓ Ressource beim mcp-Server registriert mit ID: ${metadata.id}`));
    } catch (error) {
      console.warn(chalk.yellow(`⚠️ Ressourcenregistrierung fehlgeschlagen: ${error.message}`));
    }
    
  } catch (error) {
    console.error(chalk.red(`❌ Unerwarteter Fehler: ${error.message}`));
  }
}

/**
 * Listet verfügbare Templates auf
 */
async function listTemplates() {
  console.log(chalk.blue('\nVerfügbare Templates:'));
  
  try {
    // Versuche, Templates vom mcp-Server zu laden
    const response = await axios.get(`${MCP_SERVER_URL}/templates`);
    const serverTemplates = response.data;
    
    if (serverTemplates && serverTemplates.length > 0) {
      console.log(chalk.green('\nmcp-Server Templates:'));
      serverTemplates.forEach(template => {
        console.log(`  - ${chalk.cyan(template.id)}: ${template.description}`);
      });
    } else {
      console.log(chalk.yellow('  Keine Templates auf dem mcp-Server gefunden.'));
    }
  } catch (error) {
    console.warn(chalk.yellow(`⚠️ Konnte Templates nicht vom mcp-Server laden: ${error.message}`));
  }
  
  // Lokale Templates auflisten
  try {
    const localTemplates = fs.readdirSync(TEMPLATES_DIR)
      .filter(file => file.endsWith('.md'))
      .map(file => file.replace('.md', ''));
    
    if (localTemplates.length > 0) {
      console.log(chalk.green('\nLokale Templates:'));
      localTemplates.forEach(template => {
        const templatePath = path.join(TEMPLATES_DIR, `${template}.md`);
        const templateContent = fs.readFileSync(templatePath, 'utf8');
        const { data } = matter(templateContent);
        const description = data.description || 'Keine Beschreibung';
        
        console.log(`  - ${chalk.cyan(template)}: ${description}`);
      });
    } else {
      console.log(chalk.yellow('  Keine lokalen Templates gefunden.'));
    }
  } catch (error) {
    console.warn(chalk.yellow(`⚠️ Konnte lokale Templates nicht laden: ${error.message}`));
  }
}

/**
 * Ersetzt Platzhalter im Template durch Metadatenwerte
 */
function replaceTemplateVariables(content, metadata) {
  let result = content;
  
  // Ersetze einfache Platzhalter
  for (const [key, value] of Object.entries(metadata)) {
    if (typeof value === 'string' || typeof value === 'number') {
      const placeholder = new RegExp(`\\{\\{\\s*${key}\\s*\\}\\}`, 'g');
      result = result.replace(placeholder, value.toString());
    }
  }
  
  // Ersetze Listen-Platzhalter
  const listPlaceholderRegex = /\{\{\s*#each\s+([^\s]+)\s*\}\}([\s\S]*?)\{\{\s*\/each\s*\}\}/g;
  let match;
  
  while ((match = listPlaceholderRegex.exec(content)) !== null) {
    const listName = match[1];
    const itemTemplate = match[2];
    
    if (Array.isArray(metadata[listName])) {
      let replacement = '';
      
      for (const item of metadata[listName]) {
        let itemContent = itemTemplate;
        
        if (typeof item === 'object') {
          for (const [key, value] of Object.entries(item)) {
            const itemPlaceholder = new RegExp(`\\{\\{\\s*item\\.${key}\\s*\\}\\}`, 'g');
            itemContent = itemContent.replace(itemPlaceholder, value.toString());
          }
        } else {
          itemContent = itemContent.replace(/\{\{\s*item\s*\}\}/g, item.toString());
        }
        
        replacement += itemContent;
      }
      
      result = result.replace(match[0], replacement);
    }
  }
  
  // Ersetze bedingte Platzhalter
  const condPlaceholderRegex = /\{\{\s*#if\s+([^\s]+)\s*\}\}([\s\S]*?)(?:\{\{\s*else\s*\}\}([\s\S]*?))?\{\{\s*\/if\s*\}\}/g;
  
  while ((match = condPlaceholderRegex.exec(content)) !== null) {
    const condition = match[1];
    const trueContent = match[2];
    const falseContent = match[3] || '';
    
    const value = condition.split('.').reduce((obj, key) => obj && obj[key], metadata);
    
    if (value) {
      result = result.replace(match[0], trueContent);
    } else {
      result = result.replace(match[0], falseContent);
    }
  }
  
  return result;
}

/**
 * Ergänzt das Template mit dynamischen Inhalten vom mcp-Server
 */
async function enrichTemplateWithDynamicContent(template, metadata) {
  try {
    let enrichedTemplate = template;
    
    // Lehrplan-Inhalte abrufen und einfügen
    if (metadata.subject && metadata.grade && (metadata.learningAreas || metadata.topic)) {
      try {
        const params = {
          subject: metadata.subject,
          grade: metadata.grade,
          learningAreas: Array.isArray(metadata.learningAreas) ? metadata.learningAreas.join(',') : metadata.learningAreas,
          topic: metadata.topic
        };
        
        const response = await axios.get(`${MCP_SERVER_URL}/curriculum`, { params });
        const curriculum = response.data;
        
        // Lehrplanbezug in Template einfügen
        if (curriculum.competencyExpectations) {
          const competencyPlaceholder = /\{\{\s*curriculum\.competencyExpectations\s*\}\}/g;
          let competencyExpectations = '';
          
          curriculum.competencyExpectations.forEach(expectation => {
            competencyExpectations += `- ${expectation}\n`;
          });
          
          enrichedTemplate = enrichedTemplate.replace(competencyPlaceholder, competencyExpectations.trim());
        }
        
        if (curriculum.contents) {
          const contentsPlaceholder = /\{\{\s*curriculum\.contents\s*\}\}/g;
          let contents = '';
          
          curriculum.contents.forEach(content => {
            contents += `- ${content}\n`;
          });
          
          enrichedTemplate = enrichedTemplate.replace(contentsPlaceholder, contents.trim());
        }
      } catch (error) {
        console.warn(chalk.yellow(`⚠️ Konnte Lehrplaninhalte nicht laden: ${error.message}`));
      }
    }
    
    // Ähnliche Ressourcen einfügen
    try {
      const params = {
        subject: metadata.subject,
        grade: metadata.grade,
        topic: metadata.topic,
        limit: 5
      };
      
      const response = await axios.get(`${MCP_SERVER_URL}/resources/similar`, { params });
      const similarResources = response.data;
      
      if (similarResources.length > 0) {
        const linksPlaceholder = /\{\{\s*similar_resources\s*\}\}/g;
        let links = '';
        
        similarResources.forEach(resource => {
          links += `- [${resource.title}](mcp://resource/${resource.id})\n`;
        });
        
        enrichedTemplate = enrichedTemplate.replace(linksPlaceholder, links.trim());
      }
    } catch (error) {
      console.warn(chalk.yellow(`⚠️ Konnte ähnliche Ressourcen nicht laden: ${error.message}`));
    }
    
    return enrichedTemplate;
  } catch (error) {
    console.warn(chalk.yellow(`⚠️ Fehler beim Anreichern des Templates: ${error.message}`));
    return template; // Fallback auf Original-Template
  }
}

// Starte das Skript
main();
