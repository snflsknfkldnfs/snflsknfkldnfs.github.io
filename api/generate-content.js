require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const openRouterClient = require('../scripts/openrouter-client');
const fs = require('fs-extra');

// Initialize server
const app = express();
app.use(cors());
app.use(bodyParser.json());

// Serve static files from the repository root
app.use(express.static(path.resolve('.')));

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
});
