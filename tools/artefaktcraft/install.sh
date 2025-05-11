#!/bin/bash
# ArtefaktCraft Installations-Skript
# Dieses Skript installiert alle Abhängigkeiten und richtet ArtefaktCraft ein

# Farbige Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktion zum Prüfen, ob ein Befehl verfügbar ist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funktion zum Anzeigen von Schritten
show_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Funktion zum Anzeigen von Erfolgen
show_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Funktion zum Anzeigen von Fehlern
show_error() {
    echo -e "${RED}✗${NC} $1"
}

# Funktion zum Anzeigen von Warnungen
show_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# ArtefaktCraft Logo anzeigen
echo -e "${BLUE}"
cat << "EOF"
    _         _       __       _    _  ____            __ _   
   / \   _ __| |_ ___|  | __  / \  | |/ ___|_ __ __ _ / _| |_ 
  / _ \ | '__| __/ _ \ |/ / / _ \ | | |   | '__/ _` | |_| __|
 / ___ \| |  | ||  __/   < / ___ \| | |___| | | (_| |  _| |_ 
/_/   \_\_|   \__\___|_|\_\_/   \_\_|\____|_|  \__,_|_|  \__|
                                                             
EOF
echo -e "${NC}"
echo "Willkommen beim ArtefaktCraft-Installationsprogramm!"
echo "Dieses Skript richtet ArtefaktCraft für Sie ein."
echo

# Systemvoraussetzungen prüfen
show_step "Systemvoraussetzungen werden geprüft..."

# Git prüfen
if command_exists git; then
    show_success "Git ist installiert."
else
    show_error "Git ist nicht installiert. Bitte installieren Sie Git und versuchen Sie es erneut."
    exit 1
fi

# Node.js prüfen
if command_exists node; then
    node_version=$(node -v)
    show_success "Node.js ist installiert (Version $node_version)."
    
    # Versionscheck (mindestens v14.x)
    if [[ $node_version =~ ^v([0-9]+) && ${BASH_REMATCH[1]} -lt 14 ]]; then
        show_warning "Ihre Node.js-Version ist möglicherweise zu alt. Für optimale Leistung wird Node.js v14 oder höher empfohlen."
    fi
else
    show_error "Node.js ist nicht installiert. Bitte installieren Sie Node.js und versuchen Sie es erneut."
    exit 1
fi

# npm prüfen
if command_exists npm; then
    npm_version=$(npm -v)
    show_success "npm ist installiert (Version $npm_version)."
else
    show_error "npm ist nicht installiert. Bitte installieren Sie npm und versuchen Sie es erneut."
    exit 1
fi

echo

# Verzeichnis bestimmen
if [ -d "./tools/artefaktcraft" ]; then
    ARTEFAKTCRAFT_DIR="./tools/artefaktcraft"
elif [ -d "../tools/artefaktcraft" ]; then
    ARTEFAKTCRAFT_DIR="../tools/artefaktcraft"
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    ARTEFAKTCRAFT_DIR="$SCRIPT_DIR"
fi

show_step "ArtefaktCraft wird im Verzeichnis $ARTEFAKTCRAFT_DIR installiert..."

# In das ArtefaktCraft-Verzeichnis wechseln
cd "$ARTEFAKTCRAFT_DIR" || {
    show_error "Konnte nicht in das ArtefaktCraft-Verzeichnis wechseln."
    exit 1
}

# Abhängigkeiten installieren
show_step "Abhängigkeiten werden installiert..."

(npm install --no-audit --no-fund) || {
    show_error "Fehler beim Installieren der Abhängigkeiten."
    exit 1
}

show_success "Abhängigkeiten wurden erfolgreich installiert."
echo

# mcp-Server einrichten
show_step "mcp-Server wird konfiguriert..."

# mcp-Server-Konfiguration prüfen
if [ -f "mcp-config.json" ]; then
    show_success "mcp-Server-Konfiguration gefunden."
    
    # Konfiguration an Benutzerumgebung anpassen
    current_dir=$(pwd)
    sed -i -e "s|\"repositoryRoot\": \".*\"|\"repositoryRoot\": \"$current_dir\"|g" mcp-config.json || {
        show_warning "Konnte die mcp-Server-Konfiguration nicht automatisch anpassen. Bitte prüfen Sie die Datei mcp-config.json manuell."
    }
else
    show_error "mcp-Server-Konfigurationsdatei nicht gefunden!"
    echo "Eine Standard-Konfiguration wird erstellt..."
    
    cat > mcp-config.json << EOF
{
  "repositoryRoot": "$(pwd)",
  "resourcePaths": [
    "notizen/wib",
    "notizen/gpg",
    "notizen/methodik",
    "notizen/leitfaden"
  ],
  "metadataSchemas": {
    "unterrichtseinheit": "./schemas/unterrichtseinheit-schema.json",
    "sequenzplanung": "./schemas/sequenzplanung-schema.json",
    "tafelbild": "./schemas/tafelbild-schema.json"
  },
  "templatePaths": [
    "./templates"
  ],
  "server": {
    "port": 3000,
    "cors": true
  }
}
EOF
    
    show_success "Standard-Konfiguration erstellt."
fi

echo

# Startup-Skript erstellen
show_step "Startup-Skript wird erstellt..."

cat > start-artefaktcraft.sh << 'EOF'
#!/bin/bash
# ArtefaktCraft Startup-Skript

# Farbige Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ArtefaktCraft-Verzeichnis bestimmen
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo -e "${BLUE}"
cat << "LOGO"
    _         _       __       _    _  ____            __ _   
   / \   _ __| |_ ___|  | __  / \  | |/ ___|_ __ __ _ / _| |_ 
  / _ \ | '__| __/ _ \ |/ / / _ \ | | |   | '__/ _` | |_| __|
 / ___ \| |  | ||  __/   < / ___ \| | |___| | | (_| |  _| |_ 
/_/   \_\_|   \__\___|_|\_\_/   \_\_|\____|_|  \__,_|_|  \__|
                                                             
LOGO
echo -e "${NC}"

echo -e "${BLUE}==>${NC} ArtefaktCraft wird gestartet..."

# Server-Prozess-ID-Datei
PID_FILE=".mcp-server.pid"

# Prüfen, ob der Server bereits läuft
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null; then
        echo -e "${YELLOW}!${NC} mcp-Server läuft bereits (PID: $OLD_PID)"
        echo -e "${YELLOW}!${NC} Server wird neu gestartet..."
        kill "$OLD_PID"
        sleep 1
    else
        echo -e "${YELLOW}!${NC} Veraltete PID-Datei gefunden. Der Server wurde wahrscheinlich unsauber beendet."
    fi
    rm "$PID_FILE"
fi

# mcp-Server starten
echo -e "${BLUE}==>${NC} mcp-Server wird gestartet..."
node mcp-server.js > .mcp-server.log 2>&1 &
echo $! > "$PID_FILE"
echo -e "${GREEN}✓${NC} mcp-Server gestartet (PID: $(cat "$PID_FILE"))"

# Warten, bis der Server bereit ist
echo -e "${BLUE}==>${NC} Warte auf Server-Bereitschaft..."
for i in {1..10}; do
    sleep 1
    if grep -q "Server listening" .mcp-server.log; then
        echo -e "${GREEN}✓${NC} mcp-Server ist bereit!"
        break
    fi
    if [ $i -eq 10 ]; then
        echo -e "${YELLOW}!${NC} Zeitüberschreitung beim Warten auf den Server. Versuche trotzdem fortzufahren..."
    fi
done

# Web-GUI starten
echo -e "${BLUE}==>${NC} Web-GUI wird gestartet..."

# Bestimme den Browser basierend auf dem Betriebssystem
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "http://localhost:3000/webapp/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "http://localhost:3000/webapp/"
    else
        echo -e "${YELLOW}!${NC} Konnte den Browser nicht automatisch öffnen. Bitte öffnen Sie manuell: http://localhost:3000/webapp/"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    start "http://localhost:3000/webapp/"
else
    echo -e "${YELLOW}!${NC} Konnte den Browser nicht automatisch öffnen. Bitte öffnen Sie manuell: http://localhost:3000/webapp/"
fi

echo -e "${GREEN}✓${NC} ArtefaktCraft wurde erfolgreich gestartet!"
echo
echo -e "Sie können ArtefaktCraft nun im Browser unter ${BLUE}http://localhost:3000/webapp/${NC} verwenden."
echo -e "Zum Beenden drücken Sie ${BLUE}Strg+C${NC}."

# Server-Logs anzeigen
echo
echo -e "${BLUE}==>${NC} Server-Logs:"
echo
tail -f .mcp-server.log

# Aufräumen beim Beenden
cleanup() {
    echo
    echo -e "${BLUE}==>${NC} ArtefaktCraft wird beendet..."
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm "$PID_FILE"
    fi
    echo -e "${GREEN}✓${NC} ArtefaktCraft wurde beendet!"
    exit 0
}

trap cleanup INT TERM
wait
EOF

chmod +x start-artefaktcraft.sh
show_success "Startup-Skript erstellt."
echo

# mcp-Server-Skript erstellen
show_step "mcp-Server-Skript wird erstellt..."

cat > mcp-server.js << 'EOF'
// mcp-Server für ArtefaktCraft
// Middleware-Komponente zur dynamischen Ressourcenverwaltung

const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs').promises;
const path = require('path');
const matter = require('gray-matter');
const cors = require('cors');

// Konfiguration laden
let config;
try {
    config = require('./mcp-config.json');
} catch (error) {
    console.error('Fehler beim Laden der Konfiguration:', error.message);
    process.exit(1);
}

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
EOF

show_success "mcp-Server-Skript erstellt."
echo

# Fehlende Verzeichnisse erstellen
show_step "Fehlende Verzeichnisse werden erstellt..."

mkdir -p data/curriculum/wib data/curriculum/gpg logs
show_success "Verzeichnisse erstellt."
echo

# package.json überprüfen und erstellen
show_step "package.json wird geprüft..."

if [ -f "package.json" ]; then
    show_success "package.json gefunden."
else
    cat > package.json << EOF
{
  "name": "artefaktcraft",
  "version": "1.0.0",
  "description": "Werkzeug zur standardisierten Erstellung von Unterrichtsmaterialien",
  "main": "mcp-server.js",
  "scripts": {
    "start": "./start-artefaktcraft.sh",
    "server": "node mcp-server.js",
    "link-checker": "node scripts/link-resources.js",
    "material-creator": "node scripts/create-material.js",
    "quality-check": "node scripts/quality-check.js"
  },
  "author": "",
  "license": "MIT",
  "dependencies": {
    "axios": "^0.24.0",
    "body-parser": "^1.19.0",
    "chalk": "^4.1.2",
    "commander": "^8.3.0",
    "cors": "^2.8.5",
    "express": "^4.17.1",
    "gray-matter": "^4.0.3",
    "uuid": "^8.3.2"
  }
}
EOF
    show_success "package.json erstellt."
fi
echo

# Verknüpfung für Desktop oder Anwendungsmenü erstellen
show_step "Desktop-Verknüpfung wird erstellt..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    cat > ~/Desktop/ArtefaktCraft.desktop << EOF
[Desktop Entry]
Type=Application
Name=ArtefaktCraft
Comment=Werkzeug zur standardisierten Erstellung von Unterrichtsmaterialien
Exec=bash -c 'cd "$ARTEFAKTCRAFT_DIR" && ./start-artefaktcraft.sh'
Icon=$ARTEFAKTCRAFT_DIR/webapp/images/artefaktcraft-logo.svg
Terminal=true
Categories=Education;Development;
EOF
    chmod +x ~/Desktop/ArtefaktCraft.desktop
    show_success "Desktop-Verknüpfung für Linux erstellt."
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - AppleScript erstellen
    cat > ~/Desktop/ArtefaktCraft.command << EOF
#!/bin/bash
cd "$ARTEFAKTCRAFT_DIR"
./start-artefaktcraft.sh
EOF
    chmod +x ~/Desktop/ArtefaktCraft.command
    show_success "Desktop-Verknüpfung für macOS erstellt."
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows - Batch-Datei erstellen
    cat > ~/Desktop/ArtefaktCraft.bat << EOF
@echo off
cd /d "$ARTEFAKTCRAFT_DIR"
start /b ./start-artefaktcraft.sh
EOF
    show_success "Desktop-Verknüpfung für Windows erstellt."
else
    show_warning "Desktop-Verknüpfung konnte nicht erstellt werden. Bitte erstellen Sie diese manuell."
fi
echo

# Installations-Nachricht anzeigen
echo -e "${GREEN}✓ ArtefaktCraft wurde erfolgreich installiert!${NC}"
echo
echo "Um ArtefaktCraft zu starten, führen Sie bitte einen der folgenden Befehle aus:"
echo "  ${BLUE}./start-artefaktcraft.sh${NC} (empfohlen)"
echo "  ${BLUE}npm start${NC}"
echo
echo "Alternativ können Sie die erstellte Desktop-Verknüpfung verwenden."
echo
echo "Nachdem der Server gestartet wurde, öffnen Sie in Ihrem Browser:"
echo "  ${BLUE}http://localhost:3000/webapp/${NC}"
echo
echo "Für Hilfe und weitere Informationen besuchen Sie:"
echo "  ${BLUE}https://github.com/snflsknfkldnfs/snflsknfkldnfs.github.io/tree/main/tools/artefaktcraft${NC}"
echo
