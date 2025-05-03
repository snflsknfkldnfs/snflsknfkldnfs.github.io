/**
 * TUV-Übersicht Generator
 * -----------------------
 * Dieses Skript generiert eine automatisierte Übersicht aller Unterrichtsvorbereitungen (TUVs)
 * im Repository und erstellt eine visuelle, durchsuchbare Markdown-Datei.
 * 
 * Integration in den bestehenden Workflow:
 * - Das Skript kann in update_all.sh integriert werden
 * - Alternativ kann es als Git pre-commit Hook eingerichtet werden
 * 
 * Funktionen:
 * - Findet alle TUV-Dateien im Repository
 * - Extrahiert Metadaten aus den Frontmattern
 * - Generiert eine strukturierte Übersicht nach Fach/Jahrgangsstufe/Thema
 * - Erstellt visuelle Filtermöglichkeiten
 */

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');

// Konfiguration
const config = {
  // Pfade für die Suche nach TUVs
  searchPaths: [
    './notizen/gpg',
    './notizen/wib',
    './unterricht'
  ],
  // Dateimuster für TUVs (können angepasst werden)
  tuvPatterns: [
    /.*_UE_.*/,
    /.*_TB_.*/,
    /.*_TUV_.*/
  ],
  // Ausgabedatei
  outputFile: './notizen/index/TUV_Uebersicht.md',
  // Standardwerte für fehlende Metadaten
  defaults: {
    subject: 'Unbekannt',
    grade: 'Unbekannt',
    topic: 'Unbekannt',
    type: 'Unbekannt'
  }
};

/**
 * Findet alle TUV-Dateien im Repository
 * @returns {Array} Liste aller gefundenen TUV-Dateien mit Pfad
 */
function findTUVFiles() {
  const tuvFiles = [];
  
  function searchDirectory(directory) {
    const files = fs.readdirSync(directory, { withFileTypes: true });
    
    for (const file of files) {
      const fullPath = path.join(directory, file.name);
      
      if (file.isDirectory()) {
        searchDirectory(fullPath);
      } else if (file.name.endsWith('.md')) {
        // Prüfen, ob der Dateiname einem TUV-Muster entspricht
        const isMatch = config.tuvPatterns.some(pattern => pattern.test(file.name));
        if (isMatch) {
          tuvFiles.push(fullPath);
        }
      }
    }
  }
  
  // Suche in allen konfigurierten Pfaden
  for (const searchPath of config.searchPaths) {
    if (fs.existsSync(searchPath)) {
      searchDirectory(searchPath);
    }
  }
  
  return tuvFiles;
}

/**
 * Extrahiert Metadaten aus einer TUV-Datei
 * @param {string} filePath Pfad zur TUV-Datei
 * @returns {Object} Extrahierte Metadaten
 */
function extractMetadata(filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const { data, content } = matter(fileContent);
    
    // Extrahiere auch Informationen aus dem Pfad
    const pathInfo = filePath.split('/');
    const fileName = path.basename(filePath, '.md');
    
    // Prüfe auf Muster in Dateinamen für weitere Informationen
    const yearMatch = fileName.match(/(\d+)[a-z]?_/);
    const gradeFromFile = yearMatch ? yearMatch[1] : null;
    
    // Bestimme Fach aus Pfad
    let subjectFromPath = 'Unbekannt';
    if (filePath.includes('gpg')) subjectFromPath = 'GPG';
    if (filePath.includes('wib')) subjectFromPath = 'WiB';
    
    // Extrahiere Titel aus der ersten Überschrift, falls keine Metadaten vorhanden
    let titleFromContent = '';
    const titleMatch = content.match(/^# (.+)$/m);
    if (titleMatch) {
      titleFromContent = titleMatch[1];
    }
    
    // Bestimme Thema aus dem Dateinamen und Pfad
    let topicFromFile = '';
    const components = fileName.split('_');
    if (components.length >= 3) {
      topicFromFile = components.slice(2).join(' ')
        .replace(/-/g, ' ')
        .replace(/([A-Z])/g, ' $1')
        .trim();
    }
    
    // Bestimme Typ der Unterrichtseinheit
    let typeFromFile = 'Unterrichtseinheit';
    if (fileName.includes('_TB_')) typeFromFile = 'Tafelbild';
    if (fileName.includes('_AB_')) typeFromFile = 'Arbeitsblatt';
    
    // Kombiniere Metadaten mit Priorität: Frontmatter > Dateiname > Pfad > Defaults
    return {
      title: data.title || titleFromContent || fileName,
      subject: data.subject || subjectFromPath || config.defaults.subject,
      grade: data.grade || gradeFromFile || config.defaults.grade,
      topic: data.topic || topicFromFile || config.defaults.topic,
      type: data.type || typeFromFile || config.defaults.type,
      link: filePath.replace(/^\.\//, ''),
      lastModified: fs.statSync(filePath).mtime
    };
  } catch (error) {
    console.error(`Fehler beim Extrahieren der Metadaten aus ${filePath}:`, error);
    return {
      title: path.basename(filePath, '.md'),
      subject: config.defaults.subject,
      grade: config.defaults.grade,
      topic: config.defaults.topic,
      type: config.defaults.type,
      link: filePath.replace(/^\.\//, ''),
      lastModified: fs.statSync(filePath).mtime
    };
  }
}

/**
 * Generiert eine strukturierte Übersicht der TUVs
 * @param {Array} tuvData Liste der TUV-Metadaten
 * @returns {string} Markdown-formattierte Übersicht
 */
function generateOverview(tuvData) {
  // Sortiere nach Fach, Jahrgangsstufe, Thema
  tuvData.sort((a, b) => {
    if (a.subject !== b.subject) return a.subject.localeCompare(b.subject);
    if (a.grade !== b.grade) {
      // Numerisch sortieren, falls möglich
      const gradeA = parseInt(a.grade, 10);
      const gradeB = parseInt(b.grade, 10);
      if (!isNaN(gradeA) && !isNaN(gradeB)) return gradeA - gradeB;
      return a.grade.localeCompare(b.grade);
    }
    return a.topic.localeCompare(b.topic);
  });
  
  // Sammle alle eindeutigen Werte für Filter
  const subjects = [...new Set(tuvData.map(item => item.subject))];
  const grades = [...new Set(tuvData.map(item => item.grade))];
  const types = [...new Set(tuvData.map(item => item.type))];
  
  // Generiere Markdown
  let markdown = `# Übersicht aller Unterrichtsvorbereitungen\n\n`;
  markdown += `*Automatisch generiert am ${new Date().toLocaleDateString('de-DE')} um ${new Date().toLocaleTimeString('de-DE')}*\n\n`;
  
  // Filtersektion
  markdown += `## Filter\n\n`;
  markdown += `### Fächer\n\n`;
  subjects.forEach(subject => {
    markdown += `- [${subject}](#${subject.toLowerCase()})\n`;
  });
  
  markdown += `\n### Jahrgangsstufen\n\n`;
  grades.forEach(grade => {
    markdown += `- [${grade}](#jahrgangsstufe-${grade})\n`;
  });
  
  markdown += `\n### Materialtypen\n\n`;
  types.forEach(type => {
    markdown += `- [${type}](#typ-${type.toLowerCase().replace(/\s+/g, '-')})\n`;
  });
  
  // Statistiksektion
  markdown += `\n## Statistik\n\n`;
  markdown += `- **Gesamtzahl an Unterrichtsvorbereitungen:** ${tuvData.length}\n`;
  subjects.forEach(subject => {
    const count = tuvData.filter(item => item.subject === subject).length;
    markdown += `- **${subject}:** ${count} Materialien\n`;
  });
  
  // Hauptübersicht nach Fach geordnet
  markdown += `\n## Übersicht nach Fach\n\n`;
  
  subjects.forEach(subject => {
    markdown += `### ${subject}\n\n`;
    const subjectItems = tuvData.filter(item => item.subject === subject);
    
    // Gruppiere nach Jahrgangsstufe
    const gradeGroups = {};
    subjectItems.forEach(item => {
      if (!gradeGroups[item.grade]) gradeGroups[item.grade] = [];
      gradeGroups[item.grade].push(item);
    });
    
    // Ausgabe nach Jahrgangsstufen sortiert
    Object.keys(gradeGroups).sort((a, b) => {
      const numA = parseInt(a, 10);
      const numB = parseInt(b, 10);
      if (!isNaN(numA) && !isNaN(numB)) return numA - numB;
      return a.localeCompare(b);
    }).forEach(grade => {
      markdown += `#### Jahrgangsstufe ${grade}\n\n`;
      
      // Tabelle mit Materialien
      markdown += `| Titel | Thema | Typ | Letzte Änderung |\n`;
      markdown += `|-------|-------|-----|----------------|\n`;
      
      gradeGroups[grade].forEach(item => {
        const dateString = item.lastModified.toLocaleDateString('de-DE');
        markdown += `| [${item.title}](${item.link}) | ${item.topic} | ${item.type} | ${dateString} |\n`;
      });
      
      markdown += `\n`;
    });
  });
  
  // Zeitliche Übersicht (zuletzt bearbeitet)
  markdown += `## Zuletzt bearbeitet\n\n`;
  markdown += `| Titel | Fach | Jahrgangsstufe | Thema | Typ | Letzte Änderung |\n`;
  markdown += `|-------|------|----------------|-------|-----|----------------|\n`;
  
  // Sortiere nach Änderungsdatum (neueste zuerst)
  const recentItems = [...tuvData].sort((a, b) => b.lastModified - a.lastModified).slice(0, 10);
  
  recentItems.forEach(item => {
    const dateString = item.lastModified.toLocaleDateString('de-DE');
    markdown += `| [${item.title}](${item.link}) | ${item.subject} | ${item.grade} | ${item.topic} | ${item.type} | ${dateString} |\n`;
  });
  
  return markdown;
}

/**
 * Hauptfunktion
 */
function main() {
  console.log("Starte Generierung der TUV-Übersicht...");
  
  // Finde alle TUV-Dateien
  const tuvFiles = findTUVFiles();
  console.log("TUV-Dateien:", tuvFiles);
  console.log(`${tuvFiles.length} TUV-Dateien gefunden.`);
  
  // Extrahiere Metadaten
  const tuvData = tuvFiles.map(filePath => extractMetadata(filePath));
  
  // Generiere Übersicht
  const overview = generateOverview(tuvData);
  
  // Schreibe Ergebnis in Datei
  const outputDir = path.dirname(config.outputFile);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  fs.writeFileSync(config.outputFile, overview);
  console.log(`TUV-Übersicht wurde erfolgreich nach ${config.outputFile} geschrieben.`);
}

main();
