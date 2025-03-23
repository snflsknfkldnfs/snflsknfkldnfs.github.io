#!/usr/bin/env node
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Verzeichnisse konfigurieren
const REPO_DIR = process.cwd();
const EMBEDDINGS_DIR = path.join(REPO_DIR, 'scripts', 'embeddings');
const CACHE_DIR = path.join(EMBEDDINGS_DIR, 'cache');
const VECTOR_DIR = path.join(EMBEDDINGS_DIR, 'vectors');

// Dateifilter
const IGNORED_DIRS = ['.git', 'node_modules', 'scripts/embeddings', 'scripts/logs'];
const SUPPORTED_EXTENSIONS = ['.html', '.js', '.css', '.md', '.txt', '.json', '.sh'];

// Verzeichnisse erstellen, falls sie nicht existieren
function ensureDirExists(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// MD5-Hash einer Datei berechnen
function getFileHash(filePath) {
  const fileContent = fs.readFileSync(filePath);
  return crypto.createHash('md5').update(fileContent).digest('hex');
}

// Prüfen, ob eine Datei aktualisiert werden muss
function needsUpdate(filePath, cacheDir) {
  const relativePath = path.relative(REPO_DIR, filePath);
  const cacheFilePath = path.join(cacheDir, `${relativePath.replace(/\//g, '_')}.json`);
  
  if (!fs.existsSync(cacheFilePath)) {
    return true;
  }
  
  const cachedData = JSON.parse(fs.readFileSync(cacheFilePath, 'utf8'));
  const currentHash = getFileHash(filePath);
  
  return cachedData.hash !== currentHash;
}

// Text in kleinere Abschnitte aufteilen
function chunkText(text, maxLength = 1000) {
  const chunks = [];
  let currentChunk = '';
  
  // Nach Absätzen aufteilen
  const paragraphs = text.split(/\n\s*\n/);
  
  for (const paragraph of paragraphs) {
    if (currentChunk.length + paragraph.length <= maxLength) {
      currentChunk += (currentChunk ? '\n\n' : '') + paragraph;
    } else {
      if (currentChunk) {
        chunks.push(currentChunk);
      }
      // Wenn ein Paragraph zu lang ist, teile ihn in Sätze
      if (paragraph.length > maxLength) {
        const sentences = paragraph.split(/(?<=[.!?])\s+/);
        currentChunk = '';
        for (const sentence of sentences) {
          if (currentChunk.length + sentence.length <= maxLength) {
            currentChunk += (currentChunk ? ' ' : '') + sentence;
          } else {
            if (currentChunk) {
              chunks.push(currentChunk);
            }
            currentChunk = sentence;
          }
        }
      } else {
        currentChunk = paragraph;
      }
    }
  }
  
  if (currentChunk) {
    chunks.push(currentChunk);
  }
  
  return chunks;
}

// Einfaches Embedding für text erstellen (Mock-Version)
// In der vollständigen Version würde hier ein Embedding-Modell verwendet
function createSimpleEmbedding(text) {
  // Dies ist eine sehr einfache Mock-Implementierung
  // Für eine richtige Implementierung solltest du ein echtes Embedding-Modell verwenden
  const words = text.toLowerCase().replace(/[^\w\s]/g, '').split(/\s+/);
  const uniqueWords = [...new Set(words)];
  
  // Wir verwenden hier eine einfache Bag-of-Words als "Embedding"
  const vector = new Array(1000).fill(0);
  
  for (const word of uniqueWords) {
    const hash = crypto.createHash('md5').update(word).digest('hex');
    const index = parseInt(hash.substring(0, 8), 16) % 1000;
    vector[index] += 1;
  }
  
  // Normalisierung
  const magnitude = Math.sqrt(vector.reduce((sum, val) => sum + val * val, 0));
  return vector.map(val => magnitude ? val / magnitude : 0);
}

// Alle Dateien im Repository finden, die unterstützt werden
function findAllFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      if (!IGNORED_DIRS.some(ignored => filePath.includes(ignored))) {
        findAllFiles(filePath, fileList);
      }
    } else {
      const ext = path.extname(file);
      if (SUPPORTED_EXTENSIONS.includes(ext)) {
        fileList.push(filePath);
      }
    }
  }
  
  return fileList;
}

// Repository-Dateien einbetten
function embedRepository() {
  console.log('Starte Embedding-Prozess für das Repository...');
  
  // Sicherstellen, dass Verzeichnisse existieren
  ensureDirExists(EMBEDDINGS_DIR);
  ensureDirExists(CACHE_DIR);
  ensureDirExists(VECTOR_DIR);
  
  // Alle relevanten Dateien finden
  const files = findAllFiles(REPO_DIR);
  console.log(`Gefunden: ${files.length} relevante Dateien`);
  
  let updatedFiles = 0;
  let processedChunks = 0;
  
  // Metadata für das gesamte Repository
  const metadata = {
    lastUpdated: new Date().toISOString(),
    totalFiles: files.length,
    totalChunks: 0,
    files: {}
  };
  
  // Jede Datei verarbeiten
  for (const filePath of files) {
    const relativePath = path.relative(REPO_DIR, filePath);
    console.log(`Verarbeite: ${relativePath}`);
    
    // Prüfen, ob die Datei aktualisiert werden muss
    if (!needsUpdate(filePath, CACHE_DIR)) {
      console.log(`  Keine Änderungen erkannt, verwende Cache`);
      const cacheFilePath = path.join(CACHE_DIR, `${relativePath.replace(/\//g, '_')}.json`);
      const cachedData = JSON.parse(fs.readFileSync(cacheFilePath, 'utf8'));
      metadata.files[relativePath] = cachedData.metadata;
      metadata.totalChunks += cachedData.metadata.chunks.length;
      continue;
    }
    
    updatedFiles++;
    
    try {
      // Dateiinhalt lesen
      const content = fs.readFileSync(filePath, 'utf8');
      
      // Text in Chunks aufteilen
      const chunks = chunkText(content);
      processedChunks += chunks.length;
      
      // Dateimetadaten erstellen
      const fileMetadata = {
        path: relativePath,
        lastUpdated: new Date().toISOString(),
        size: content.length,
        chunks: []
      };
      
      // Jeden Chunk verarbeiten
      for (let i = 0; i < chunks.length; i++) {
        const chunk = chunks[i];
        const chunkId = `${relativePath.replace(/\//g, '_')}_${i}`;
        
        // Embedding erstellen
        const embedding = createSimpleEmbedding(chunk);
        
        // Chunk-Daten speichern
        const chunkData = {
          id: chunkId,
          text: chunk,
          embedding: embedding
        };
        
        // Embedding in separater Datei speichern
        fs.writeFileSync(
          path.join(VECTOR_DIR, `${chunkId}.json`),
          JSON.stringify(chunkData, null, 2)
        );
        
        // Zum Metadaten-Objekt hinzufügen
        fileMetadata.chunks.push({
          id: chunkId,
          startChar: content.indexOf(chunk),
          endChar: content.indexOf(chunk) + chunk.length
        });
      }
      
      // Cache-Eintrag erstellen
      const cacheEntry = {
        hash: getFileHash(filePath),
        metadata: fileMetadata
      };
      
      // Cache-Eintrag speichern
      fs.writeFileSync(
        path.join(CACHE_DIR, `${relativePath.replace(/\//g, '_')}.json`),
        JSON.stringify(cacheEntry, null, 2)
      );
      
      // Zur Repository-Metadaten hinzufügen
      metadata.files[relativePath] = fileMetadata;
      metadata.totalChunks += fileMetadata.chunks.length;
      
    } catch (error) {
      console.error(`  Fehler bei der Verarbeitung von ${relativePath}:`, error);
    }
  }
  
  // Metadaten speichern
  fs.writeFileSync(
    path.join(EMBEDDINGS_DIR, 'metadata.json'),
    JSON.stringify(metadata, null, 2)
  );
  
  console.log(`Embedding-Prozess abgeschlossen!`);
  console.log(`  Verarbeitete Dateien: ${files.length}`);
  console.log(`  Aktualisierte Dateien: ${updatedFiles}`);
  console.log(`  Gesamt Chunks: ${metadata.totalChunks}`);
}

// Einfache Vektorsuche mit Kosinusähnlichkeit
function searchRepository(query, topK = 5) {
  // Metadaten laden
  const metadata = JSON.parse(fs.readFileSync(path.join(EMBEDDINGS_DIR, 'metadata.json'), 'utf8'));
  
  // Query-Embedding erstellen
  const queryEmbedding = createSimpleEmbedding(query);
  
  // Alle Chunks durchsuchen
  const results = [];
  
  for (const filePath in metadata.files) {
    const fileMetadata = metadata.files[filePath];
    
    for (const chunk of fileMetadata.chunks) {
      // Chunk-Embedding laden
      const chunkData = JSON.parse(fs.readFileSync(path.join(VECTOR_DIR, `${chunk.id}.json`), 'utf8'));
      
      // Kosinusähnlichkeit berechnen
      const similarity = calculateCosineSimilarity(queryEmbedding, chunkData.embedding);
      
      results.push({
        similarity,
        chunk: chunkData,
        filePath
      });
    }
  }
  
  // Nach Ähnlichkeit sortieren und die Top-K zurückgeben
  return results
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, topK);
}

// Kosinusähnlichkeit zwischen zwei Vektoren berechnen
function calculateCosineSimilarity(vec1, vec2) {
  let dotProduct = 0;
  let mag1 = 0;
  let mag2 = 0;
  
  for (let i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    mag1 += vec1[i] * vec1[i];
    mag2 += vec2[i] * vec2[i];
  }
  
  mag1 = Math.sqrt(mag1);
  mag2 = Math.sqrt(mag2);
  
  if (mag1 === 0 || mag2 === 0) return 0;
  
  return dotProduct / (mag1 * mag2);
}

// Kommandozeilenargumente verarbeiten
const args = process.argv.slice(2);
const command = args[0];

if (command === 'embed') {
  embedRepository();
} else if (command === 'search') {
  const query = args.slice(1).join(' ');
  if (!query) {
    console.log('Bitte gib eine Suchanfrage an. Zum Beispiel: node scripts/local-embeddings.js search "Leben im alten Ägypten"');
    process.exit(1);
  }
  
  const results = searchRepository(query);
  console.log(`Top ${results.length} Ergebnisse für "${query}":`);
  
  for (let i = 0; i < results.length; i++) {
    const result = results[i];
    console.log(`\n--- Ergebnis ${i + 1} (Ähnlichkeit: ${result.similarity.toFixed(4)}) ---`);
    console.log(`Datei: ${result.filePath}`);
    console.log(`Text: ${result.chunk.text.substring(0, 200)}...`);
  }
} else {
  console.log('Verfügbare Befehle:');
  console.log('  embed   - Repository-Dateien einbetten');
  console.log('  search  - Nach Inhalten im Repository suchen');
  console.log('\nBeispiel:');
  console.log('  node scripts/local-embeddings.js embed');
  console.log('  node scripts/local-embeddings.js search "Leben im alten Ägypten"');
}
