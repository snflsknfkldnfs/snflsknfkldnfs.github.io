// mcp-Server für ArtefaktCraft
// Middleware-Komponente zur dynamischen Ressourcenverwaltung

const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs').promises;
const path = require('path');
const config = require(path.join(__dirname, 'mcp-config.json'));
const matter = require('gray-matter');
const cors = require('cors');


const app = express();
const PORT = config.server?.port || 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors());
app.use(express.static('webapp'));

// Globale Variablen
let resourceIndex = [];
let templates = [];

// Server-Status-Endpunkt
app.get('/status', (req, res) => {
    res.json({
        status: 'online',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

// Ressourcen-Endpunkte
app.get('/resources', async (req, res) => {
    try {
        // Ressourcen nach Parametern filtern
        let filteredResources = [...resourceIndex];
        
        // Filter nach IDs
        if (req.query.ids) {
            const ids = req.query.ids.split(',');
            filteredResources = filteredResources.filter(resource => ids.includes(resource.id));
        }
        
        // Filter nach Metadaten
        if (req.query.subject) {
            filteredResources = filteredResources.filter(resource => 
                resource.metadata?.subject?.toLowerCase() === req.query.subject.toLowerCase());
        }
        
        if (req.query.grade) {
            filteredResources = filteredResources.filter(resource => 
                resource.metadata?.grade === req.query.grade);
        }
        
        if (req.query.topic) {
            filteredResources = filteredResources.filter(resource => 
                resource.metadata?.topic?.toLowerCase().includes(req.query.topic.toLowerCase()));
        }
        
        if (req.query.type) {
            filteredResources = filteredResources.filter(resource => 
                resource.metadata?.type?.toLowerCase() === req.query.type.toLowerCase());
        }
        
        // Format der Antwort
        const format = req.query.format || 'json';
        if (format === 'json') {
            res.json(filteredResources);
        } else if (format === 'simple') {
            const simpleResources = filteredResources.map(resource => ({
                id: resource.id,
                title: resource.metadata?.title || resource.filename,
                path: resource.path
            }));
            res.json(simpleResources);
        } else {
            res.status(400).json({ error: 'Ungültiges Format' });
        }
    } catch (error) {
        console.error('Fehler beim Abrufen der Ressourcen:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

app.get('/resources/similar', async (req, res) => {
    try {
        // Parameter abrufen
        const subject = req.query.subject;
        const grade = req.query.grade;
        const topic = req.query.topic;
        const excludeId = req.query.excludeId;
        const similarity = parseFloat(req.query.similarity) || 0.5;
        
        if (!subject || !grade) {
            return res.status(400).json({ error: 'Fach und Jahrgangsstufe sind erforderlich' });
        }
        
        // Ähnliche Ressourcen finden
        let similarResources = resourceIndex.filter(resource => {
            if (excludeId && resource.id === excludeId) return false;
            
            // Basisübereinstimmung
            const matchesSubject = resource.metadata?.subject?.toLowerCase() === subject.toLowerCase();
            const matchesGrade = resource.metadata?.grade === grade;
            
            if (!matchesSubject || !matchesGrade) return false;
            
            // Themenähnlichkeit
            if (topic && resource.metadata?.topic) {
                // Einfache Ähnlichkeitsberechnung
                const resourceTopic = resource.metadata.topic.toLowerCase();
                const queryTopic = topic.toLowerCase();
                
                if (resourceTopic.includes(queryTopic) || queryTopic.includes(resourceTopic)) {
                    resource.similarity = 1.0;
                    return true;
                }
                
                // Wortüberschneidungen
                const resourceWords = new Set(resourceTopic.split(/\s+/));
                const queryWords = new Set(queryTopic.split(/\s+/));
                
                const intersection = new Set(
                    [...resourceWords].filter(word => queryWords.has(word))
                );
                
                const overlapRatio = intersection.size / Math.max(resourceWords.size, queryWords.size);
                resource.similarity = overlapRatio;
                
                return overlapRatio >= similarity;
            }
            
            return true;
        });
        
        // Nach Ähnlichkeit sortieren
        similarResources.sort((a, b) => (b.similarity || 0) - (a.similarity || 0));
        
        // Limit anwenden
        const limit = parseInt(req.query.limit) || 10;
        similarResources = similarResources.slice(0, limit);
        
        res.json(similarResources);
    } catch (error) {
        console.error('Fehler beim Finden ähnlicher Ressourcen:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

app.post('/resources/register', async (req, res) => {
    try {
        const { id, path: resourcePath, metadata } = req.body;
        
        if (!id || !resourcePath) {
            return res.status(400).json({ error: 'ID und Pfad sind erforderlich' });
        }
        
        // Prüfen, ob die Ressource bereits existiert
        const existingIndex = resourceIndex.findIndex(resource => resource.id === id);
        
        if (existingIndex !== -1) {
            // Ressource aktualisieren
            resourceIndex[existingIndex] = {
                id,
                path: resourcePath,
                metadata: metadata || resourceIndex[existingIndex].metadata,
                modified: new Date().toISOString()
            };
            
            res.json({ message: 'Ressource aktualisiert', resource: resourceIndex[existingIndex] });
        } else {
            // Neue Ressource hinzufügen
            const newResource = {
                id,
                path: resourcePath,
                metadata: metadata || {},
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            };
            
            resourceIndex.push(newResource);
            res.status(201).json({ message: 'Ressource registriert', resource: newResource });
        }
    } catch (error) {
        console.error('Fehler beim Registrieren der Ressource:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Template-Endpunkte
app.get('/templates', async (req, res) => {
    try {
        // Templates nach Parametern filtern
        let filteredTemplates = [...templates];
        
        if (req.query.type) {
            filteredTemplates = filteredTemplates.filter(template => 
                template.metadata?.type?.toLowerCase() === req.query.type.toLowerCase());
        }
        
        if (req.query.subject) {
            filteredTemplates = filteredTemplates.filter(template => 
                !template.metadata?.subject || template.metadata.subject.toLowerCase() === req.query.subject.toLowerCase());
        }
        
        if (req.query.grade) {
            filteredTemplates = filteredTemplates.filter(template => 
                !template.metadata?.grade || template.metadata.grade === req.query.grade);
        }
        
        const simpleTemplates = filteredTemplates.map(template => ({
            id: template.id,
            name: template.metadata?.description || template.id,
            type: template.metadata?.type || 'generic',
            subject: template.metadata?.subject || 'all'
        }));
        
        res.json(simpleTemplates);
    } catch (error) {
        console.error('Fehler beim Abrufen der Templates:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

app.get('/templates/:id', async (req, res) => {
    try {
        const templateId = req.params.id;
        const template = templates.find(t => t.id === templateId);
        
        if (!template) {
            return res.status(404).json({ error: 'Template nicht gefunden' });
        }
        
        res.send(template.content);
    } catch (error) {
        console.error('Fehler beim Abrufen des Templates:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Lehrplan-Endpunkte
app.get('/curriculum', async (req, res) => {
    try {
        const { subject, grade, learningAreas } = req.query;
        
        if (!subject || !grade) {
            return res.status(400).json({ error: 'Fach und Jahrgangsstufe sind erforderlich' });
        }
        
        // In einer vollständigen Implementierung würden hier echte Lehrplaninhalte geladen
        // Für dieses Beispiel geben wir Beispielinhalte zurück
        
        const curriculum = {
            subject: subject,
            grade: grade,
            learningAreas: learningAreas ? learningAreas.split(',') : [],
            competencyExpectations: [
                'Die Schülerinnen und Schüler analysieren wirtschaftliche Zusammenhänge in ihrem Alltag.',
                'Die Schülerinnen und Schüler bewerten Konsumentscheidungen nach ökonomischen Kriterien.',
                'Die Schülerinnen und Schüler erklären grundlegende Marktmechanismen mit eigenen Worten.'
            ],
            contents: [
                'Bedürfnisse und Güter',
                'Wirtschaftskreislauf',
                'Preisbildung nach Angebot und Nachfrage',
                'Verbraucherrechte und -pflichten'
            ]
        };
        
        res.json(curriculum);
    } catch (error) {
        console.error('Fehler beim Abrufen der Lehrplaninhalte:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Metadaten-Validierung
app.post('/validate/metadata', async (req, res) => {
    try {
        const metadata = req.body;
        
        if (!metadata || !metadata.type) {
            return res.status(400).json({ error: 'Keine gültigen Metadaten oder kein Typ angegeben' });
        }
        
        // In einer vollständigen Implementierung würden hier die Schemas geladen und validiert
        // Für dieses Beispiel prüfen wir nur einige Grundlagen
        
        const requiredFields = {
            unterrichtseinheit: ['type', 'title', 'subject', 'grade', 'topic'],
            sequenzplanung: ['type', 'title', 'subject', 'grade', 'topic'],
            tafelbild: ['type', 'title', 'subject', 'grade'],
            arbeitsblatt: ['type', 'title', 'subject', 'grade']
        };
        
        const errors = [];
        
        const requiredForType = requiredFields[metadata.type] || [];
        for (const field of requiredForType) {
            if (!metadata[field]) {
                errors.push({
                    field,
                    message: `Feld "${field}" ist erforderlich für Typ "${metadata.type}"`
                });
            }
        }
        
        if (errors.length > 0) {
            return res.status(400).json({ valid: false, errors });
        }
        
        res.json({ valid: true });
    } catch (error) {
        console.error('Fehler bei der Metadaten-Validierung:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Qualitätsprüfung
app.post('/quality-check', async (req, res) => {
    try {
        const { content, metadata } = req.body;
        
        if (!content) {
            return res.status(400).json({ error: 'Kein Inhalt angegeben' });
        }
        
        // In einer vollständigen Implementierung würde hier eine umfassende Qualitätsprüfung durchgeführt
        // Für dieses Beispiel führen wir einige grundlegende Prüfungen durch
        
        const results = {
            score: 0,
            errors: 0,
            warnings: 0,
            tests: []
        };
        
        // 1. Metadaten-Prüfung
        const metadataTest = {
            name: 'Grundlegende Metadaten',
            status: 'success',
            message: 'Alle grundlegenden Metadaten sind vorhanden.',
            details: []
        };
        
        if (!metadata) {
            metadataTest.status = 'error';
            metadataTest.message = 'Keine Metadaten gefunden.';
            results.errors++;
        } else {
            const requiredFields = ['type', 'title', 'subject', 'grade'];
            const missingFields = [];
            
            for (const field of requiredFields) {
                if (!metadata[field]) {
                    missingFields.push(field);
                }
            }
            
            if (missingFields.length > 0) {
                metadataTest.status = 'error';
                metadataTest.message = `Folgende grundlegende Metadaten fehlen: ${missingFields.join(', ')}`;
                results.errors += missingFields.length;
            }
            
            // Empfohlene Felder
            const recommendedFields = ['topic', 'author', 'created'];
            const missingRecommended = [];
            
            for (const field of recommendedFields) {
                if (!metadata[field]) {
                    missingRecommended.push(field);
                }
            }
            
            if (missingRecommended.length > 0) {
                if (metadataTest.status === 'success') {
                    metadataTest.status = 'warning';
                    metadataTest.message = `Folgende empfohlene Metadaten fehlen: ${missingRecommended.join(', ')}`;
                } else {
                    metadataTest.details.push(`Folgende empfohlene Metadaten fehlen: ${missingRecommended.join(', ')}`);
                }
                results.warnings += missingRecommended.length;
            }
        }
        
        results.tests.push(metadataTest);
        
        // 2. Struktur-Prüfung
        const structureTest = {
            name: 'Strukturelle Integrität',
            status: 'success',
            message: 'Inhalt hat die erwartete Struktur.',
            details: []
        };
        
        if (!content.match(/^#\s+/m)) {
            structureTest.status = 'error';
            structureTest.details.push('Keine Hauptüberschrift (H1) gefunden.');
            results.errors++;
        }
        
        if (metadata && metadata.type === 'unterrichtseinheit') {
            if (!content.includes('## Lernziele') && !content.includes('## Lernziel')) {
                structureTest.status = 'warning';
                structureTest.details.push('Keine Lernziele gefunden.');
                results.warnings++;
            }
            
            if (!content.includes('## Verlaufsplanung')) {
                structureTest.status = 'warning';
                structureTest.details.push('Keine Verlaufsplanung gefunden.');
                results.warnings++;
            }
            
            if (!content.match(/##\s+Material/)) {
                structureTest.status = 'warning';
                structureTest.details.push('Kein Materialabschnitt gefunden.');
                results.warnings++;
            }
        }
        
        if (structureTest.details.length > 0 && structureTest.status === 'success') {
            structureTest.status = 'warning';
        }
        
        if (structureTest.details.length > 0) {
            structureTest.message = `${structureTest.details.length} strukturelle Probleme gefunden.`;
        }
        
        results.tests.push(structureTest);
        
        // 3. Template-Vollständigkeit
        const templateTest = {
            name: 'Template-Vollständigkeit',
            status: 'success',
            message: 'Keine unersetzten Template-Platzhalter gefunden.',
            details: []
        };
        
        const placeholderPattern = /\{\{([^}]+)\}\}/g;
        let match;
        const placeholders = [];
        
        while ((match = placeholderPattern.exec(content)) !== null) {
            placeholders.push(match[0]);
        }
        
        if (placeholders.length > 0) {
            templateTest.status = 'error';
            templateTest.message = `${placeholders.length} unersetzten Template-Platzhalter gefunden.`;
            templateTest.details = placeholders;
            results.errors += placeholders.length;
        }
        
        results.tests.push(templateTest);
        
        // Gesamtbewertung
        results.score = Math.max(0, 100 - (results.errors * 10) - (results.warnings * 5));
        
        res.json(results);
    } catch (error) {
        console.error('Fehler bei der Qualitätsprüfung:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Fachspezifische Standards
app.post('/validate/subjectStandards', async (req, res) => {
    try {
        const { subject, type, content } = req.body;
        
        if (!subject || !type || !content) {
            return res.status(400).json({ error: 'Fach, Typ und Inhalt sind erforderlich' });
        }
        
        // In einer vollständigen Implementierung würden hier fachspezifische Standards geladen und validiert
        // Für dieses Beispiel simulieren wir einige einfache Prüfungen
        
        const issues = [];
        
        if (subject === 'WiB' && type === 'unterrichtseinheit') {
            // Prüfung auf kompetenzorientierte Lernziele
            if (!content.match(/Die Schülerinnen und Schüler\s+.*\s+indem\s+.*\s+was daran erkennbar wird, dass/)) {
                issues.push('Lernziele sollten nach dem Mager-Schema formuliert werden: "Die SuS [Kompetenz], indem sie [Methode], was daran erkennbar wird, dass [Maßstab]".');
            }
            
            // Prüfung auf differenzierte Verlaufsplanung
            if (!content.match(/##\s+Differenzierung/)) {
                issues.push('Eine Differenzierung für verschiedene Leistungsniveaus sollte enthalten sein.');
            }
        }
        
        res.json({
            subject,
            type,
            status: issues.length > 0 ? 'warning' : 'success',
            issues
        });
    } catch (error) {
        console.error('Fehler bei der Validierung fachspezifischer Standards:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});

// Aktualisiert den Ressourcen-Index beim Serverstart
async function updateResourceIndex() {
    try {
        console.log('Ressourcen-Index wird aktualisiert...');
        const newIndex = [];
        
        // Konfigurierte Pfade durchsuchen
        for (const basePath of config.resourcePaths || []) {
            const fullPath = path.join(config.repositoryRoot, basePath);
            
            try {
                await processDirectory(fullPath, basePath, newIndex);
            } catch (error) {
                console.warn(`Warnung: Konnte Verzeichnis nicht verarbeiten: ${fullPath}`, error);
            }
        }
        
        resourceIndex = newIndex;
        console.log(`Ressourcen-Index aktualisiert. ${resourceIndex.length} Ressourcen gefunden.`);
    } catch (error) {
        console.error('Fehler beim Aktualisieren des Ressourcen-Index:', error);
    }
}

// Durchsucht ein Verzeichnis rekursiv nach Markdown-Dateien
async function processDirectory(dirPath, relativePath, index) {
    try {
        const entries = await fs.readdir(dirPath, { withFileTypes: true });
        
        for (const entry of entries) {
            const entryPath = path.join(dirPath, entry.name);
            const entryRelativePath = path.join(relativePath, entry.name);
            
            if (entry.isDirectory()) {
                // Rekursiv in Unterverzeichnisse gehen
                await processDirectory(entryPath, entryRelativePath, index);
            } else if (entry.isFile() && entry.name.endsWith('.md')) {
                // Markdown-Datei verarbeiten
                try {
                    const fileContent = await fs.readFile(entryPath, 'utf8');
                    const { data: metadata, content } = matter(fileContent);
                    
                    // Ressourcen-ID generieren
                    let id = metadata.id;
                    if (!id) {
                        // ID aus Dateiname und Pfad ableiten
                        const filenameWithoutExt = entry.name.replace('.md', '');
                        const pathSegments = relativePath.split(path.sep).filter(Boolean);
                        
                        if (metadata.type && metadata.subject) {
                            id = `${metadata.subject.toLowerCase()}_${metadata.type.toLowerCase()}_${filenameWithoutExt.toLowerCase().replace(/\s+/g, '_')}`;
                        } else {
                            id = `${pathSegments.length > 0 ? pathSegments[0].toLowerCase() + '_' : ''}${filenameWithoutExt.toLowerCase().replace(/\s+/g, '_')}`;
                        }
                    }
                    
                    // Titel ableiten
                    let title = metadata.title;
                    if (!title) {
                        // Aus der ersten Überschrift extrahieren
                        const titleMatch = content.match(/^#\s+(.+)$/m);
                        if (titleMatch) {
                            title = titleMatch[1];
                        } else {
                            title = filenameWithoutExt;
                        }
                    }
                    
                    // Ressource dem Index hinzufügen
                    index.push({
                        id,
                        path: entryRelativePath,
                        filename: entry.name,
                        metadata: { ...metadata, title },
                        modified: new Date().toISOString()
                    });
                } catch (error) {
                    console.warn(`Warnung: Konnte Datei nicht verarbeiten: ${entryPath}`, error);
                }
            }
        }
    } catch (error) {
        console.error(`Fehler beim Verarbeiten des Verzeichnisses ${dirPath}:`, error);
        throw error;
    }
}

// Lädt Templates beim Serverstart
async function loadTemplates() {
    try {
        console.log('Templates werden geladen...');
        const templatesList = [];
        
        // Konfigurierte Template-Pfade durchsuchen
        for (const templatePath of config.templatePaths || []) {
            const fullPath = path.join(config.repositoryRoot, templatePath);
            
            try {
                const entries = await fs.readdir(fullPath, { withFileTypes: true });
                
                for (const entry of entries) {
                    if (entry.isFile() && entry.name.endsWith('.md')) {
                        const templatePath = path.join(fullPath, entry.name);
                        const templateId = entry.name.replace('.md', '');
                        
                        try {
                            const content = await fs.readFile(templatePath, 'utf8');
                            const { data: metadata } = matter(content);
                            
                            templatesList.push({
                                id: templateId,
                                path: templatePath,
                                content,
                                metadata
                            });
                        } catch (error) {
                            console.warn(`Warnung: Konnte Template nicht laden: ${templatePath}`, error);
                        }
                    }
                }
            } catch (error) {
                console.warn(`Warnung: Konnte Template-Verzeichnis nicht verarbeiten: ${fullPath}`, error);
            }
        }
        
        templates = templatesList;
        console.log(`Templates geladen. ${templates.length} Templates gefunden.`);
    } catch (error) {
        console.error('Fehler beim Laden der Templates:', error);
    }
}

// Initialisierung und Server-Start
async function init() {
    try {
        // Ressourcen-Index erstellen
        await updateResourceIndex();
        
        // Templates laden
        await loadTemplates();
        
        // Server starten
        app.listen(PORT, () => {
            console.log(`Server listening on port ${PORT}`);
            console.log(`API available at http://localhost:${PORT}`);
            console.log(`Web-GUI available at http://localhost:${PORT}/webapp/`);
        });
    } catch (error) {
        console.error('Fehler bei der Initialisierung:', error);
        process.exit(1);
    }
}

// Initialisierung starten
init();
