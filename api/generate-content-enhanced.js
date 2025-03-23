require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const axios = require('axios');
const fs = require('fs');
const { execSync } = require('child_process');
const crypto = require('crypto');

// Initialize server
const app = express();
app.use(cors());
app.use(bodyParser.json());

// Serve static files from the repository root
app.use(express.static(path.resolve('.')));

// Konfiguration
const EMBEDDINGS_DIR = path.join(__dirname, '..', 'scripts', 'embeddings');
const VECTOR_DIR = path.join(EMBEDDINGS_DIR, 'vectors');

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

// Einfaches Embedding für text erstellen (Mock-Version)
function createSimpleEmbedding(text) {
  const words = text.toLowerCase().replace(/[^\w\s]/g, '').split(/\s+/);
  const uniqueWords = [...new Set(words)];
  
  const vector = new Array(1000).fill(0);
  
  for (const word of uniqueWords) {
    const hash = crypto.createHash('md5').update(word).digest('hex');
    const index = parseInt(hash.substring(0, 8), 16) % 1000;
    vector[index] += 1;
  }
  
  const magnitude = Math.sqrt(vector.reduce((sum, val) => sum + val * val, 0));
  return vector.map(val => magnitude ? val / magnitude : 0);
}

// Repository nach ähnlichen Inhalten durchsuchen
function searchRepository(query, topK = 5) {
  try {
    // Prüfen, ob Metadaten existieren
    const metadataPath = path.join(EMBEDDINGS_DIR, 'metadata.json');
    if (!fs.existsSync(metadataPath)) {
      console.log('Keine Embeddings gefunden. Erstelle Embeddings...');
      execSync('node scripts/local-embeddings.js embed');
    }
  
    // Metadaten laden
    const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
    
    // Query-Embedding erstellen
    const queryEmbedding = createSimpleEmbedding(query);
    
    // Alle Chunks durchsuchen
    const results = [];
    
    for (const filePath in metadata.files) {
      const fileMetadata = metadata.files[filePath];
      
      for (const chunk of fileMetadata.chunks) {
        // Chunk-Embedding laden
        const chunkPath = path.join(VECTOR_DIR, `${chunk.id}.json`);
        if (fs.existsSync(chunkPath)) {
          const chunkData = JSON.parse(fs.readFileSync(chunkPath, 'utf8'));
          
          // Kosinusähnlichkeit berechnen
          const similarity = calculateCosineSimilarity(queryEmbedding, chunkData.embedding);
          
          results.push({
            similarity,
            chunk: chunkData,
            filePath
          });
        }
      }
    }
    
    // Nach Ähnlichkeit sortieren und die Top-K zurückgeben
    return results
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, topK);
  } catch (error) {
    console.error('Fehler bei der Repository-Suche:', error);
    return [];
  }
}

// Create a simple OpenRouter client
const openRouterClient = {
  apiKey: process.env.OPENROUTER_API_KEY,
  baseUrl: 'https://openrouter.ai/api/v1',
  model: 'deepseek/deepseek-coder-33b-instruct',
  
  async generateContent(prompt, systemPrompt = '', options = {}) {
    try {
      // Repository nach relevanten Inhalten durchsuchen
      const searchResults = searchRepository(prompt, 3);
      
      // Kontext aus den Such-Ergebnissen extrahieren
      let contextText = '';
      if (searchResults.length > 0) {
        contextText = 'Basierend auf folgenden relevanten Inhalten aus dem Repository:\n\n';
        
        for (let i = 0; i < searchResults.length; i++) {
          const result = searchResults[i];
          contextText += `[Datei: ${result.filePath}]\n${result.chunk.text.substring(0, 300)}\n\n`;
        }
      }
      
      // Erweiterten Prompt erstellen
      const enhancedPrompt = contextText + prompt;
      
      const requestBody = {
        model: this.model,
        messages: [
          { role: 'system', content: systemPrompt || 'You are a helpful assistant.' },
          { role: 'user', content: enhancedPrompt }
        ],
        max_tokens: options.maxTokens || 2000,
        temperature: options.temperature || 0.7,
      };
      
      const response = await axios.post(
        `${this.baseUrl}/chat/completions`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );
      
      return response.data.choices[0].message.content;
    } catch (error) {
      console.error('Error generating content:', error.response ? error.response.data : error.message);
      throw error;
    }
  }
};

// API endpoint for content generation
app.post('/api/generate-content', async (req, res) => {
  try {
    const { prompt, template } = req.body;
    
    if (!prompt || !template) {
      return res.status(400).json({ error: 'Prompt and template are required' });
    }
    
    // Get system prompt based on template
    const systemPrompt = getSystemPrompt(template);
    
    // Generate content
    const content = await openRouterClient.generateContent(prompt, systemPrompt);
    
    // Return generated content
    res.json({ content });
  } catch (error) {
    console.error('Error generating content:', error);
    res.status(500).json({ error: 'Error generating content' });
  }
});

// Endpunkt zur Ausführung des Embedding-Prozesses
app.post('/api/update-embeddings', (req, res) => {
  try {
    console.log('Aktualisiere Repository-Embeddings...');
    execSync('node scripts/local-embeddings.js embed');
    res.json({ success: true, message: 'Embeddings erfolgreich aktualisiert' });
  } catch (error) {
    console.error('Fehler beim Aktualisieren der Embeddings:', error);
    res.status(500).json({ error: 'Fehler beim Aktualisieren der Embeddings' });
  }
});

// Get template-specific system prompt
function getSystemPrompt(template) {
  switch (template) {
    case 'tabelle':
      return `Du bist ein Spezialist für die Erstellung von Bildungsinhalten im Tabellenformat für Schüler der 5. Klasse. 
      Erstelle präzise, klare und altersgerechte HTML-Tabellenzeilen für Unterrichtsmaterialien.
      Deine Antwort sollte nur den HTML-Code enthalten, keine Erklärungen oder Einleitungen.`;
      
    case 'bildkarten':
      return `Du bist ein Spezialist für die Erstellung von Bildkarten für den Unterricht in der 5. Klasse.
      Erstelle ansprechende, informative und altersgerechte HTML-Inhalte für Bildkarten.
      Verwende passende Emojis für die visuelle Unterstützung.
      Deine Antwort sollte nur den HTML-Code enthalten, keine Erklärungen oder Einleitungen.`;
      
    case 'arbeitsblatt':
      return `Du bist ein Spezialist für die Erstellung von interaktiven Arbeitsblättern für Schüler der 5. Klasse.
      Erstelle klar strukturierte, lehrreiche und altersgerechte HTML-Inhalte für Arbeitsblätter.
      Verwende passende Emojis zur Visualisierung der Aufgaben.
      Deine Antwort sollte nur den HTML-Code enthalten, keine Erklärungen oder Einleitungen.`;
      
    default:
      return 'Du bist ein Spezialist für die Erstellung von Bildungsinhalten für Schüler.';
  }
}

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  
  // Prüfen, ob Embeddings existieren, sonst erstellen
  const metadataPath = path.join(EMBEDDINGS_DIR, 'metadata.json');
  if (!fs.existsSync(metadataPath)) {
    console.log('Keine Embeddings gefunden. Erstelle initiale Embeddings...');
    try {
      execSync('node scripts/local-embeddings.js embed');
      console.log('Initiale Embeddings erstellt!');
    } catch (error) {
      console.error('Fehler beim Erstellen der initialen Embeddings:', error);
    }
  }
});
