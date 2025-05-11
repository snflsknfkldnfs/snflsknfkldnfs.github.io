// ArtefaktCraft Web-App
// Hauptanwendungsskript

document.addEventListener('DOMContentLoaded', function() {
    // Konfiguration und Konstanten
    const API_URL = 'http://localhost:3000';
    let editor;
    let currentMaterial = null;
    let serverStatus = false;

    // DOM-Elemente
    const serverStatusIndicator = document.getElementById('server-status-indicator');
    const serverStatusText = document.getElementById('server-status-text');
    const materialTypeSelect = document.getElementById('material-type');
    const subjectSelect = document.getElementById('subject');
    const gradeSelect = document.getElementById('grade');
    const templateSelect = document.getElementById('template');
    const createMaterialButton = document.getElementById('create-material');
    const saveMaterialButton = document.getElementById('save-material');
    const qualityCheckButton = document.getElementById('quality-check');
    const togglePreviewButton = document.getElementById('toggle-preview');
    const markdownPreview = document.getElementById('markdown-preview');
    const updateMetadataButton = document.getElementById('update-metadata');
    const fetchCurriculumButton = document.getElementById('fetch-curriculum');
    const tutorialOverlay = document.getElementById('tutorial-overlay');
    const showTutorialButton = document.getElementById('show-tutorial');
    const closeTutorialButton = document.getElementById('close-tutorial');
    const prevStepButton = document.getElementById('prev-step');
    const nextStepButton = document.getElementById('next-step');
    const stepIndicator = document.getElementById('step-indicator');
    const qualityModal = document.getElementById('quality-modal');
    const closeQualityModalButton = document.getElementById('close-quality-modal');
    const applyFixesButton = document.getElementById('apply-fixes');
    const statusMessage = document.getElementById('status-message');

    // Initialisierung des Markdown-Editors
    setupEditor();
    
    // Server-Status prüfen
    checkServerStatus();
    
    // Templates laden
    loadTemplates();
    
    // Event-Listener registrieren
    registerEventListeners();
    
    /**
     * Initialisiert den Markdown-Editor
     */
    function setupEditor() {
        // CodeMirror Editor initialisieren
        editor = CodeMirror(document.getElementById('markdown-editor'), {
            mode: 'markdown',
            lineNumbers: true,
            lineWrapping: true,
            theme: 'default',
            extraKeys: {"Ctrl-Space": "autocomplete"}
        });
        
        // Standard-Inhalt setzen
        editor.setValue('# Neues Material\n\nWählen Sie einen Materialtyp und ein Template, um zu beginnen.');
        
        // Änderungsereignis registrieren
        editor.on('change', function() {
            // Vorschau aktualisieren, falls sichtbar
            if (!markdownPreview.classList.contains('hidden')) {
                updatePreview();
            }
        });
    }
    
    /**
     * Prüft den Status des mcp-Servers
     */
    function checkServerStatus() {
        fetch(`${API_URL}/status`)
            .then(response => {
                if (response.ok) {
                    serverStatus = true;
                    serverStatusIndicator.classList.add('online');
                    serverStatusText.textContent = 'Server online';
                    return response.json();
                } else {
                    throw new Error('Server nicht erreichbar');
                }
            })
            .then(data => {
                console.log('Server-Status:', data);
            })
            .catch(error => {
                console.error('Server-Fehler:', error);
                serverStatus = false;
                serverStatusIndicator.classList.add('offline');
                serverStatusText.textContent = 'Server offline - Eingeschränkte Funktionalität';
                showWarning('Der mcp-Server ist nicht erreichbar. Einige Funktionen sind möglicherweise nicht verfügbar.');
            });
    }
    
    /**
     * Lädt verfügbare Templates vom Server
     */
    function loadTemplates() {
        // Materialtyp, Fach und Stufe abrufen
        const type = materialTypeSelect.value;
        const subject = subjectSelect.value;
        const grade = gradeSelect.value;
        
        // Anzeige zurücksetzen
        templateSelect.innerHTML = '<option value="loading">Wird geladen...</option>';
        
        if (serverStatus) {
            // Templates vom Server laden
            fetch(`${API_URL}/templates?type=${type}&subject=${subject}&grade=${grade}`)
                .then(response => response.json())
                .then(templates => {
                    templateSelect.innerHTML = '';
                    
                    if (templates.length === 0) {
                        templateSelect.innerHTML = '<option value="">Keine Templates verfügbar</option>';
                    } else {
                        templates.forEach(template => {
                            const option = document.createElement('option');
                            option.value = template.id;
                            option.textContent = template.name;
                            templateSelect.appendChild(option);
                        });
                    }
                })
                .catch(error => {
                    console.error('Fehler beim Laden der Templates:', error);
                    templateSelect.innerHTML = '<option value="">Fehler beim Laden</option>';
                    loadFallbackTemplates();
                });
        } else {
            // Offline-Modus: Lokale Templates laden
            loadFallbackTemplates();
        }
    }
    
    /**
     * Lädt lokale Fallback-Templates
     */
    function loadFallbackTemplates() {
        const type = materialTypeSelect.value;
        const subject = subjectSelect.value;
        
        templateSelect.innerHTML = '';
        
        // Standardvorlagen basierend auf Typ und Fach
        if (type === 'unterrichtseinheit' && subject === 'WiB') {
            const option = document.createElement('option');
            option.value = 'ue_wib_standard';
            option.textContent = 'Standard WiB-Unterrichtseinheit';
            templateSelect.appendChild(option);
        } else if (type === 'sequenzplanung' && subject === 'WiB') {
            const option = document.createElement('option');
            option.value = 'seq_wib_standard';
            option.textContent = 'Standard WiB-Sequenzplanung';
            templateSelect.appendChild(option);
        } else {
            templateSelect.innerHTML = '<option value="">Keine passenden Templates</option>';
        }
    }
    
    /**
     * Registriert alle Event-Listener
     */
    function registerEventListeners() {
        // Änderungen an Auswahlfeldern
        materialTypeSelect.addEventListener('change', loadTemplates);
        subjectSelect.addEventListener('change', loadTemplates);
        gradeSelect.addEventListener('change', loadTemplates);
        
        // Hauptaktionen
        createMaterialButton.addEventListener('click', createNewMaterial);
        saveMaterialButton.addEventListener('click', saveMaterial);
        qualityCheckButton.addEventListener('click', runQualityCheck);
        togglePreviewButton.addEventListener('click', togglePreview);
        updateMetadataButton.addEventListener('click', updateMetadata);
        fetchCurriculumButton.addEventListener('click', fetchCurriculum);
        
        // Tutorial-Steuerung
        showTutorialButton.addEventListener('click', showTutorial);
        closeTutorialButton.addEventListener('click', hideTutorial);
        prevStepButton.addEventListener('click', prevTutorialStep);
        nextStepButton.addEventListener('click', nextTutorialStep);
        
        // Qualitätsprüfungs-Dialog
        closeQualityModalButton.addEventListener('click', closeQualityModal);
        applyFixesButton.addEventListener('click', applyAutomaticFixes);
    }
    
    /**
     * Erstellt ein neues Material basierend auf dem ausgewählten Template
     */
    function createNewMaterial() {
        const type = materialTypeSelect.value;
        const subject = subjectSelect.value;
        const grade = gradeSelect.value;
        const templateId = templateSelect.value;
        
        if (!templateId) {
            showError('Bitte wählen Sie ein Template aus.');
            return;
        }
        
        setStatus('Material wird erstellt...');
        
        if (serverStatus) {
            // Template vom Server laden
            fetch(`${API_URL}/templates/${templateId}`)
                .then(response => response.text())
                .then(template => {
                    editor.setValue(template);
                    populateMetadataForm(extractMetadata(template));
                    setStatus('Neues Material erstellt');
                })
                .catch(error => {
                    console.error('Fehler beim Laden des Templates:', error);
                    loadFallbackTemplate(templateId);
                });
        } else {
            // Offline-Modus: Lokales Template laden
            loadFallbackTemplate(templateId);
        }
    }
    
    /**
     * Lädt ein lokales Fallback-Template
     */
    function loadFallbackTemplate(templateId) {
        // In einer vollständigen Implementierung würden hier lokale Templates geladen
        // Für dieses Beispiel verwenden wir ein einfaches Standard-Template
        
        let template = '';
        
        if (templateId === 'ue_wib_standard') {
            template = `---
type: unterrichtseinheit
title: "Neue Unterrichtseinheit"
subject: "WiB"
grade: "${gradeSelect.value}"
topic: "Neues Thema"
subtopic: ""
learningAreas: ["LB1"]
competencyAreas: ["Arbeit"]
processCompetencies: ["Handeln"]
duration: "90"
prerequisites: []
resources: []
author: ""
created: "${new Date().toISOString().split('T')[0]}"
modified: "${new Date().toISOString().split('T')[0]}"
version: "1.0.0"
status: "draft"
---

# Neue Unterrichtseinheit

## Basisinformationen

- **Fach:** WiB
- **Jahrgangsstufe:** ${gradeSelect.value}
- **Dauer:** 90 Minuten
- **Thema:** Neues Thema

## Lehrplanbezug

### Kompetenzerwartungen (LehrplanPLUS)
- Kompetenzerwartung 1
- Kompetenzerwartung 2

### Inhalte zu den Kompetenzen
- Inhalt 1
- Inhalt 2

## Lernziele

Die Schülerinnen und Schüler...

- **können** [Kompetenz], indem sie [Methode/Bedingungen], was daran erkennbar wird, dass [Beurteilungsmaßstab].

## Materialien und Medien

- [Liste der benötigten Materialien und Medien]

## Verlaufsplanung

| Zeit | Phase | Lehrer-Schüler-Interaktion | Sozialform/Methode | Medien/Material |
|------|-------|----------------------------|-------------------|-----------------|
| 10 Min. | Einleitung | | | |
| 30 Min. | Erarbeitung | | | |
| 15 Min. | Sicherung | | | |
| 25 Min. | Anwendung | | | |
| 10 Min. | Reflexion | | | |

## Differenzierung

### Für leistungsstärkere Schülerinnen und Schüler
- [Differenzierungsmaßnahmen nach oben]

### Für leistungsschwächere Schülerinnen und Schüler
- [Differenzierungsmaßnahmen nach unten]

## Erwartete Ergebnisse
- [Beschreibung der erwarteten Schülerergebnisse]

---

*Diese Unterrichtseinheit wurde mit ArtefaktCraft erstellt*`;
        } else {
            template = `---
type: ${type}
title: "Neues Material"
subject: "${subject}"
grade: "${grade}"
---

# Neues Material

Dieses Material wurde im Offline-Modus erstellt. Bitte füllen Sie den Inhalt aus.`;
        }
        
        editor.setValue(template);
        populateMetadataForm(extractMetadata(template));
        setStatus('Neues Material erstellt (Offline-Modus)');
    }
    
    /**
     * Extrahiert Metadaten aus einem Markdown-Text mit Frontmatter
     */
    function extractMetadata(text) {
        // Einfache Extraktion von YAML Frontmatter
        const match = text.match(/^---\s*\n([\s\S]*?)\n---\s*\n/);
        
        if (match && match[1]) {
            try {
                // In einer vollständigen Implementierung würde hier ein YAML-Parser verwendet
                // Für dieses Beispiel extrahieren wir einige grundlegende Felder manuell
                const metadata = {};
                const lines = match[1].split('\n');
                
                for (const line of lines) {
                    const keyValueMatch = line.match(/^([^:]+):\s*(.*)$/);
                    if (keyValueMatch) {
                        const key = keyValueMatch[1].trim();
                        let value = keyValueMatch[2].trim();
                        
                        // Anführungszeichen entfernen
                        if (value.startsWith('"') && value.endsWith('"')) {
                            value = value.slice(1, -1);
                        }
                        
                        // Arrays parsen
                        if (value.startsWith('[') && value.endsWith(']')) {
                            try {
                                value = JSON.parse(value.replace(/'/g, '"'));
                            } catch (e) {
                                // Fallback: Als String belassen
                            }
                        }
                        
                        metadata[key] = value;
                    }
                }
                
                return metadata;
            } catch (error) {
                console.error('Fehler beim Parsen der Metadaten:', error);
                return {};
            }
        }
        
        return {};
    }
    
    /**
     * Füllt das Metadaten-Formular mit den extrahierten Werten
     */
    function populateMetadataForm(metadata) {
        // Einfache Felder
        document.getElementById('title').value = metadata.title || '';
        document.getElementById('topic').value = metadata.topic || '';
        document.getElementById('subtopic').value = metadata.subtopic || '';
        document.getElementById('duration').value = metadata.duration || '';
        document.getElementById('author').value = metadata.author || '';
        
        // Voraussetzungen
        if (metadata.prerequisites && Array.isArray(metadata.prerequisites)) {
            document.getElementById('prerequisites').value = metadata.prerequisites.join(', ');
        } else {
            document.getElementById('prerequisites').value = '';
        }
        
        // Checkboxen für Lernbereiche
        if (metadata.learningAreas && Array.isArray(metadata.learningAreas)) {
            const checkboxes = document.querySelectorAll('#learningAreas input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = metadata.learningAreas.includes(checkbox.value);
            });
        }
        
        // Checkboxen für Gegenstandsbereiche
        if (metadata.competencyAreas && Array.isArray(metadata.competencyAreas)) {
            const checkboxes = document.querySelectorAll('#competencyAreas input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = metadata.competencyAreas.includes(checkbox.value);
            });
        }
        
        // Checkboxen für Prozessbezogene Kompetenzen
        if (metadata.processCompetencies && Array.isArray(metadata.processCompetencies)) {
            const checkboxes = document.querySelectorAll('#processCompetencies input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = metadata.processCompetencies.includes(checkbox.value);
            });
        }
    }
    
    /**
     * Sammelt Metadaten aus dem Formular
     */
    function collectMetadataFromForm() {
        const metadata = {
            type: materialTypeSelect.value,
            title: document.getElementById('title').value,
            subject: subjectSelect.value,
            grade: gradeSelect.value,
            topic: document.getElementById('topic').value,
            subtopic: document.getElementById('subtopic').value,
            duration: document.getElementById('duration').value,
            author: document.getElementById('author').value,
            created: new Date().toISOString().split('T')[0],
            modified: new Date().toISOString().split('T')[0],
            version: "1.0.0",
            status: "draft"
        };
        
        // Voraussetzungen
        const prerequisites = document.getElementById('prerequisites').value;
        if (prerequisites) {
            metadata.prerequisites = prerequisites.split(',').map(item => item.trim());
        } else {
            metadata.prerequisites = [];
        }
        
        // Lernbereiche
        metadata.learningAreas = [];
        const learningAreaCheckboxes = document.querySelectorAll('#learningAreas input[type="checkbox"]:checked');
        learningAreaCheckboxes.forEach(checkbox => {
            metadata.learningAreas.push(checkbox.value);
        });
        
        // Gegenstandsbereiche
        metadata.competencyAreas = [];
        const competencyAreaCheckboxes = document.querySelectorAll('#competencyAreas input[type="checkbox"]:checked');
        competencyAreaCheckboxes.forEach(checkbox => {
            metadata.competencyAreas.push(checkbox.value);
        });
        
        // Prozessbezogene Kompetenzen
        metadata.processCompetencies = [];
        const processCompetencyCheckboxes = document.querySelectorAll('#processCompetencies input[type="checkbox"]:checked');
        processCompetencyCheckboxes.forEach(checkbox => {
            metadata.processCompetencies.push(checkbox.value);
        });
        
        return metadata;
    }
    
    /**
     * Aktualisiert die Metadaten im Editor
     */
    function updateMetadata() {
        const content = editor.getValue();
        const metadata = collectMetadataFromForm();
        
        // Metadaten als YAML formatieren
        let yamlMetadata = '---\n';
        for (const [key, value] of Object.entries(metadata)) {
            if (Array.isArray(value)) {
                if (value.length === 0) {
                    yamlMetadata += `${key}: []\n`;
                } else {
                    yamlMetadata += `${key}: ${JSON.stringify(value)}\n`;
                }
            } else if (typeof value === 'string' && value.includes('\n')) {
                yamlMetadata += `${key}: |\n  ${value.replace(/\n/g, '\n  ')}\n`;
            } else if (typeof value === 'string') {
                yamlMetadata += `${key}: "${value}"\n`;
            } else {
                yamlMetadata += `${key}: ${value}\n`;
            }
        }
        yamlMetadata += '---\n\n';
        
        // Bestehenden Frontmatter ersetzen oder an den Anfang setzen
        const frontmatterRegex = /^---\s*\n[\s\S]*?\n---\s*\n/;
        if (frontmatterRegex.test(content)) {
            const newContent = content.replace(frontmatterRegex, yamlMetadata);
            editor.setValue(newContent);
        } else {
            editor.setValue(yamlMetadata + content);
        }
        
        setStatus('Metadaten aktualisiert');
    }
    
    /**
     * Ruft Lehrplaninhalte vom Server ab
     */
    function fetchCurriculum() {
        const metadata = collectMetadataFromForm();
        
        if (!serverStatus) {
            showWarning('Diese Funktion erfordert eine Verbindung zum mcp-Server.');
            return;
        }
        
        if (!metadata.subject || !metadata.grade || !metadata.learningAreas || metadata.learningAreas.length === 0) {
            showError('Bitte geben Sie Fach, Jahrgangsstufe und Lernbereich(e) an.');
            return;
        }
        
        setStatus('Lehrplaninhalte werden geladen...');
        
        const params = new URLSearchParams({
            subject: metadata.subject,
            grade: metadata.grade,
            learningAreas: metadata.learningAreas.join(',')
        });
        
        fetch(`${API_URL}/curriculum?${params}`)
            .then(response => response.json())
            .then(data => {
                if (!data.competencyExpectations || !data.contents) {
                    showWarning('Keine passenden Lehrplaninhalte gefunden.');
                    return;
                }
                
                // Aktuelle Inhalte des Editors abrufen
                let content = editor.getValue();
                
                // Kompetenzerwartungen und Inhalte formatieren
                let competencyExpectations = '';
                data.competencyExpectations.forEach(expectation => {
                    competencyExpectations += `- ${expectation}\n`;
                });
                
                let contents = '';
                data.contents.forEach(content => {
                    contents += `- ${content}\n`;
                });
                
                // Lehrplanbezug im Dokument ersetzen
                const competencyPattern = /### Kompetenzerwartungen \(LehrplanPLUS\)\n([\s\S]*?)(?=###|$)/;
                const contentsPattern = /### Inhalte zu den Kompetenzen\n([\s\S]*?)(?=##|$)/;
                
                if (competencyPattern.test(content)) {
                    content = content.replace(competencyPattern, `### Kompetenzerwartungen (LehrplanPLUS)\n${competencyExpectations}\n`);
                }
                
                if (contentsPattern.test(content)) {
                    content = content.replace(contentsPattern, `### Inhalte zu den Kompetenzen\n${contents}\n`);
                }
                
                // Aktualisierte Inhalte im Editor setzen
                editor.setValue(content);
                setStatus('Lehrplaninhalte eingefügt');
            })
            .catch(error => {
                console.error('Fehler beim Laden der Lehrplaninhalte:', error);
                showError('Fehler beim Laden der Lehrplaninhalte.');
            });
    }
    
    /**
     * Speichert das aktuelle Material
     */
    function saveMaterial() {
        const content = editor.getValue();
        const metadata = extractMetadata(content);
        
        if (!metadata.title) {
            showError('Bitte geben Sie einen Titel an.');
            return;
        }
        
        // In einer vollständigen Implementierung würde hier das Material gespeichert werden
        // Für dieses Beispiel simulieren wir den Speichervorgang
        
        setStatus('Material wird gespeichert...');
        
        setTimeout(() => {
            setStatus('Material erfolgreich gespeichert');
            showSuccess('Das Material wurde erfolgreich gespeichert.');
        }, 1000);
    }
    
    /**
     * Führt eine Qualitätsprüfung durch
     */
    function runQualityCheck() {
        const content = editor.getValue();
        const metadata = extractMetadata(content);
        
        if (serverStatus) {
            setStatus('Qualitätsprüfung wird durchgeführt...');
            
            // Qualitätsprüfung vom Server anfordern
            fetch(`${API_URL}/quality-check`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    content: content,
                    metadata: metadata
                })
            })
            .then(response => response.json())
            .then(results => {
                displayQualityResults(results);
            })
            .catch(error => {
                console.error('Fehler bei der Qualitätsprüfung:', error);
                simulateQualityCheck();
            });
        } else {
            // Offline-Modus: Lokale Qualitätsprüfung durchführen
            simulateQualityCheck();
        }
    }
    
    /**
     * Simuliert eine Qualitätsprüfung (für Offline-Modus)
     */
    function simulateQualityCheck() {
        setStatus('Lokale Qualitätsprüfung wird durchgeführt...');
        
        const content = editor.getValue();
        const metadata = extractMetadata(content);
        
        // Einfache Prüfungen
        const results = {
            score: 0,
            errors: 0,
            warnings: 0,
            tests: []
        };
        
        // Metadaten-Prüfung
        const metadataTest = {
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
            metadataTest.status = 'error';
            metadataTest.message = `Folgende grundlegende Metadaten fehlen: ${missingFields.join(', ')}`;
            results.errors++;
        }
        
        results.tests.push(metadataTest);
        
        // Struktur-Prüfung
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
        
        if (metadata.type === 'unterrichtseinheit') {
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
        }
        
        if (structureTest.details.length > 0 && structureTest.status === 'success') {
            structureTest.status = 'warning';
        }
        
        if (structureTest.details.length > 0) {
            structureTest.message = `${structureTest.details.length} strukturelle Probleme gefunden.`;
        }
        
        results.tests.push(structureTest);
        
        // Template-Vollständigkeit
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
        results.errors += missingFields.length;
        results.score = Math.max(0, 100 - (results.errors * 10) - (results.warnings * 5));
        
        displayQualityResults(results);
    }
    
    /**
     * Zeigt die Ergebnisse der Qualitätsprüfung an
     */
    function displayQualityResults(results) {
        // Zusammenfassung aktualisieren
        document.getElementById('quality-score').textContent = `${results.score}%`;
        document.getElementById('quality-score').className = 'metric-value ' + 
            (results.score >= 80 ? 'good' : results.score >= 50 ? 'warning' : 'bad');
            
        document.getElementById('error-count').textContent = results.errors;
        document.getElementById('error-count').className = 'metric-value ' + 
            (results.errors === 0 ? 'good' : results.errors <= 2 ? 'warning' : 'bad');
            
        document.getElementById('warning-count').textContent = results.warnings;
        document.getElementById('warning-count').className = 'metric-value ' + 
            (results.warnings === 0 ? 'good' : results.warnings <= 3 ? 'warning' : 'bad');
        
        // Details aktualisieren
        const detailsContainer = document.getElementById('quality-details');
        detailsContainer.innerHTML = '';
        
        results.tests.forEach(test => {
            const testElement = document.createElement('div');
            testElement.className = 'quality-test';
            
            const heading = document.createElement('h4');
            heading.className = test.status;
            heading.textContent = `${test.name}: ${test.message}`;
            testElement.appendChild(heading);
            
            if (test.details && test.details.length > 0) {
                const detailsElement = document.createElement('div');
                detailsElement.className = 'quality-test-details';
                
                const list = document.createElement('ul');
                test.details.forEach(detail => {
                    const item = document.createElement('li');
                    item.textContent = detail;
                    list.appendChild(item);
                });
                
                detailsElement.appendChild(list);
                testElement.appendChild(detailsElement);
            }
            
            detailsContainer.appendChild(testElement);
        });
        
        // Automatische Korrekturen aktivieren, falls Fehler gefunden wurden
        applyFixesButton.disabled = results.errors === 0;
        
        // Modal anzeigen
        qualityModal.classList.add('visible');
        setStatus('Qualitätsprüfung abgeschlossen');
    }
    
    /**
     * Wendet automatische Korrekturen auf Basis der Qualitätsprüfung an
     */
    function applyAutomaticFixes() {
        setStatus('Automatische Korrekturen werden angewendet...');
        
        let content = editor.getValue();
        const metadata = collectMetadataFromForm();
        let modified = false;
        
        // 1. Fehlende Metadaten ergänzen
        if (!content.match(/^---\s*\n[\s\S]*?\n---\s*\n/)) {
            updateMetadata();
            modified = true;
        }
        
        // 2. Fehlende Hauptüberschrift ergänzen
        if (!content.match(/^#\s+/m)) {
            const title = metadata.title || 'Neues Material';
            
            // Prüfen, ob es Frontmatter gibt
            if (content.match(/^---\s*\n[\s\S]*?\n---\s*\n/)) {
                // Nach Frontmatter einfügen
                content = content.replace(/^(---\s*\n[\s\S]*?\n---\s*\n)/, `$1\n# ${title}\n\n`);
            } else {
                // Am Anfang einfügen
                content = `# ${title}\n\n${content}`;
            }
            
            modified = true;
        }
        
        // 3. Unbearbeitete Platzhalter ersetzen
        const placeholderPattern = /\{\{([^}]+)\}\}/g;
        content = content.replace(placeholderPattern, '___');
        
        // 4. Für Unterrichtseinheiten: Fehlende Strukturelemente hinzufügen
        if (metadata.type === 'unterrichtseinheit') {
            if (!content.includes('## Lernziele') && !content.includes('## Lernziel')) {
                content += '\n\n## Lernziele\n\nDie Schülerinnen und Schüler...\n\n- **können** [Kompetenz], indem sie [Methode/Bedingungen], was daran erkennbar wird, dass [Beurteilungsmaßstab].';
                modified = true;
            }
            
            if (!content.includes('## Verlaufsplanung')) {
                content += '\n\n## Verlaufsplanung\n\n| Zeit | Phase | Lehrer-Schüler-Interaktion | Sozialform/Methode | Medien/Material |\n|------|-------|----------------------------|-------------------|------------------|\n| Min. | Einleitung | | | |\n| Min. | Erarbeitung | | | |\n| Min. | Sicherung | | | |\n| Min. | Anwendung | | | |\n| Min. | Reflexion | | | |';
                modified = true;
            }
        }
        
        if (modified) {
            editor.setValue(content);
            showSuccess('Automatische Korrekturen wurden angewendet.');
        } else {
            showInfo('Keine automatischen Korrekturen notwendig.');
        }
        
        closeQualityModal();
        setStatus('Korrekturen angewendet');
    }
    
    /**
     * Wechselt zwischen Editor und Vorschau
     */
    function togglePreview() {
        if (markdownPreview.classList.contains('hidden')) {
            updatePreview();
            markdownPreview.classList.remove('hidden');
            togglePreviewButton.textContent = 'Editor anzeigen';
        } else {
            markdownPreview.classList.add('hidden');
            togglePreviewButton.textContent = 'Vorschau anzeigen';
        }
    }
    
    /**
     * Aktualisiert die Markdown-Vorschau
     */
    function updatePreview() {
        const content = editor.getValue();
        const md = window.markdownit();
        
        // Frontmatter entfernen
        let cleanContent = content;
        const frontmatterMatch = content.match(/^---\s*\n[\s\S]*?\n---\s*\n/);
        if (frontmatterMatch) {
            cleanContent = content.replace(frontmatterMatch[0], '');
        }
        
        markdownPreview.innerHTML = md.render(cleanContent);
    }
    
    /**
     * Zeigt das Tutorial an
     */
    function showTutorial() {
        // Aktiven Schritt zurücksetzen
        const tutorialSteps = document.querySelectorAll('.tutorial-step');
        tutorialSteps.forEach(step => step.classList.remove('active'));
        document.querySelector('.tutorial-step[data-step="1"]').classList.add('active');
        
        // Navigation zurücksetzen
        prevStepButton.disabled = true;
        nextStepButton.disabled = false;
        stepIndicator.textContent = 'Schritt 1 von ' + tutorialSteps.length;
        
        // Tutorial anzeigen
        tutorialOverlay.classList.add('visible');
    }
    
    /**
     * Verbirgt das Tutorial
     */
    function hideTutorial() {
        tutorialOverlay.classList.remove('visible');
    }
    
    /**
     * Zeigt den vorherigen Tutorial-Schritt an
     */
    function prevTutorialStep() {
        const activeStep = document.querySelector('.tutorial-step.active');
        const currentStep = parseInt(activeStep.dataset.step);
        
        if (currentStep > 1) {
            activeStep.classList.remove('active');
            const prevStep = document.querySelector(`.tutorial-step[data-step="${currentStep - 1}"]`);
            prevStep.classList.add('active');
            
            // Navigation aktualisieren
            nextStepButton.disabled = false;
            prevStepButton.disabled = (currentStep - 1 === 1);
            
            const totalSteps = document.querySelectorAll('.tutorial-step').length;
            stepIndicator.textContent = `Schritt ${currentStep - 1} von ${totalSteps}`;
        }
    }
    
    /**
     * Zeigt den nächsten Tutorial-Schritt an
     */
    function nextTutorialStep() {
        const activeStep = document.querySelector('.tutorial-step.active');
        const currentStep = parseInt(activeStep.dataset.step);
        const totalSteps = document.querySelectorAll('.tutorial-step').length;
        
        if (currentStep < totalSteps) {
            activeStep.classList.remove('active');
            const nextStep = document.querySelector(`.tutorial-step[data-step="${currentStep + 1}"]`);
            nextStep.classList.add('active');
            
            // Navigation aktualisieren
            prevStepButton.disabled = false;
            nextStepButton.disabled = (currentStep + 1 === totalSteps);
            
            stepIndicator.textContent = `Schritt ${currentStep + 1} von ${totalSteps}`;
        }
    }
    
    /**
     * Schließt den Qualitätsprüfungs-Dialog
     */
    function closeQualityModal() {
        qualityModal.classList.remove('visible');
    }
    
    /**
     * Setzt den Statustext in der Fußzeile
     */
    function setStatus(message) {
        statusMessage.textContent = message;
    }
    
    /**
     * Zeigt eine Erfolgsmeldung
     */
    function showSuccess(message) {
        // In einer vollständigen Implementierung würde hier eine Toast-Nachricht angezeigt
        alert('✅ ' + message);
    }
    
    /**
     * Zeigt eine Warnmeldung
     */
    function showWarning(message) {
        // In einer vollständigen Implementierung würde hier eine Toast-Nachricht angezeigt
        alert('⚠️ ' + message);
    }
    
    /**
     * Zeigt eine Fehlermeldung
     */
    function showError(message) {
        // In einer vollständigen Implementierung würde hier eine Toast-Nachricht angezeigt
        alert('❌ ' + message);
    }
    
    /**
     * Zeigt eine Informationsmeldung
     */
    function showInfo(message) {
        // In einer vollständigen Implementierung würde hier eine Toast-Nachricht angezeigt
        alert('ℹ️ ' + message);
    }
});
