#!/usr/bin/env node

/**
 * ArtefaktCraft Resource Linker
 * 
 * Dieses Skript findet und aktualisiert dynamische Links in Markdown-Dateien.
 * Es kommuniziert mit dem mcp-Server, um:
 * 1. Ressourcen-IDs aufzulösen
 * 2. Ressourcen zu finden, die verlinkt werden sollten
 * 3. Links zu aktualisieren, wenn sich Ressourcen-Pfade ändern
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
const SUGGEST_THRESHOLD = 0.7; // Schwellenwert für Ähnlichkeit bei Vorschlägen

program
  .name('link-resources')
  .description('Findet und aktualisiert dynamische Links in Markdown-Dateien')
  .version('1.0.0');

program
  .command('check <file>')
  .description('Überprüft Links in einer Datei')
  .action(async (file) => {
    await checkLinks(file);
  });

program
  .command('update <file>')
  .description('Aktualisiert Links in einer Datei')
  .action(async (file) => {
    await updateLinks(file);
  });

program
  .command('suggest <file>')
  .description('Schlägt neue Links für eine Datei vor')
  .action(async (file) => {
    await suggestLinks(file);
  });

program.parse();

/**
 * Überprüft Links in einer Datei
 */
async function checkLinks(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const { data, content: markdown } = matter(content);
    
    console.log(chalk.blue(`\nÜberprüfe Links in: ${filePath}`));
    
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
      console.log(chalk.yellow(`Keine mcp-Links gefunden.`));
      return;
    }
    
    console.log(chalk.green(`${links.length} mcp-Links gefunden.`));
    
    // Ressourcen vom mcp-Server abrufen
    const resourcesResponse = await axios.get(`${MCP_SERVER_URL}/resources`, {
      params: { format: 'json', ids: links.map(link => link.resourceId).join(',') }
    });
    
    const resources = resourcesResponse.data;
    
    // Links validieren
    for (const link of links) {
      const resource = resources.find(r => r.id === link.resourceId);
      
      if (!resource) {
        console.log(chalk.red(`❌ Ungültiger Link: ${link.text} (${link.resourceId}) - Ressource nicht gefunden`));
        continue;
      }
      
      if (resource.path !== resource.currentPath) {
        console.log(chalk.yellow(`⚠️ Veralteter Link: ${link.text} (${link.resourceId}) - Pfad hat sich geändert`));
        continue;
      }
      
      console.log(chalk.green(`✓ Gültiger Link: ${link.text} → ${resource.title}`));
    }
  } catch (error) {
    console.error(chalk.red(`Fehler beim Überprüfen der Links: ${error.message}`));
  }
}

/**
 * Aktualisiert Links in einer Datei
 */
async function updateLinks(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const { data, content: markdown } = matter(content);
    
    console.log(chalk.blue(`\nAktualisiere Links in: ${filePath}`));
    
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
      console.log(chalk.yellow(`Keine mcp-Links gefunden.`));
      return;
    }
    
    // Ressourcen vom mcp-Server abrufen
    const resourcesResponse = await axios.get(`${MCP_SERVER_URL}/resources`, {
      params: { format: 'json', ids: links.map(link => link.resourceId).join(',') }
    });
    
    const resources = resourcesResponse.data;
    
    // Links aktualisieren
    let updatedContent = content;
    let updateCount = 0;
    
    for (const link of links) {
      const resource = resources.find(r => r.id === link.resourceId);
      
      if (!resource) {
        console.log(chalk.red(`❌ Überspringe ungültigen Link: ${link.text} (${link.resourceId})`));
        continue;
      }
      
      if (resource.title !== link.text) {
        const oldLink = link.fullMatch;
        const newLink = `[${resource.title}](mcp://resource/${link.resourceId})`;
        updatedContent = updatedContent.replace(oldLink, newLink);
        console.log(chalk.green(`✓ Titel aktualisiert: ${link.text} → ${resource.title}`));
        updateCount++;
      }
    }
    
    if (updateCount > 0) {
      fs.writeFileSync(filePath, updatedContent, 'utf8');
      console.log(chalk.green(`${updateCount} Links aktualisiert und gespeichert.`));
    } else {
      console.log(chalk.green(`Alle Links sind aktuell.`));
    }
  } catch (error) {
    console.error(chalk.red(`Fehler beim Aktualisieren der Links: ${error.message}`));
  }
}

/**
 * Schlägt neue Links für eine Datei vor
 */
async function suggestLinks(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const { data, content: markdown } = matter(content);
    
    if (!data.subject || !data.grade || !data.topic) {
      console.log(chalk.yellow(`\nUnzureichende Metadaten für Linkvorschläge. Benötigt werden subject, grade und topic.`));
      return;
    }
    
    console.log(chalk.blue(`\nGeneriere Linkvorschläge für: ${filePath}`));
    
    // Ähnliche Ressourcen vom mcp-Server abrufen
    const params = {
      subject: data.subject,
      grade: data.grade,
      topic: data.topic,
      similarity: SUGGEST_THRESHOLD,
      excludeId: data.id || path.basename(filePath, '.md')
    };
    
    const resourcesResponse = await axios.get(`${MCP_SERVER_URL}/resources/similar`, { params });
    const resources = resourcesResponse.data;
    
    if (resources.length === 0) {
      console.log(chalk.yellow(`Keine ähnlichen Ressourcen gefunden.`));
      return;
    }
    
    console.log(chalk.green(`${resources.length} ähnliche Ressourcen gefunden:`));
    
    // Extrahiere vorhandene Links
    let existingLinks = [];
    let match;
    while ((match = LINK_PATTERN.exec(markdown)) !== null) {
      existingLinks.push(match[2]); // Speichere nur die resourceId
    }
    
    // Zeige Vorschläge an
    for (const resource of resources) {
      if (existingLinks.includes(resource.id)) {
        console.log(chalk.gray(`- [${resource.title}] (bereits verlinkt)`));
        continue;
      }
      
      const similarity = resource.similarity || 'N/A';
      console.log(chalk.cyan(`- [${resource.title}] (${resource.id}) - Ähnlichkeit: ${similarity}`));
      console.log(`  Vorgeschlagener Link: [${resource.title}](mcp://resource/${resource.id})`);
    }
  } catch (error) {
    console.error(chalk.red(`Fehler beim Generieren von Linkvorschlägen: ${error.message}`));
  }
}
