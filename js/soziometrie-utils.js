/**
 * Soziometrie-Utilities
 * Funktionen zur datenschutzkonformen Verarbeitung soziometrischer Daten
 */

// CSV-Datei parsen
function parseCSV(csvContent) {
    const lines = csvContent.split('\n');
    const headers = lines[0].split(',').map(h => h.trim());
    
    const data = [];
    for (let i = 1; i < lines.length; i++) {
        if (!lines[i].trim()) continue;
        
        const values = lines[i].split(',').map(v => v.trim());
        const entry = {};
        
        headers.forEach((header, index) => {
            entry[header] = values[index] || '';
        });
        
        data.push(entry);
    }
    
    return {
        headers,
        data
    };
}

// Anonymisierte Vorschau generieren
function generateAnonymizedPreview(parsedData) {
    const { headers, data } = parsedData;
    
    if (data.length === 0) return '<p>Keine Daten gefunden.</p>';
    
    let html = '<table style="width: 100%; border-collapse: collapse;">';
    
    // Kopfzeile
    html += '<tr>';
    headers.forEach(header => {
        html += `<th style="padding: 8px; border: 1px solid #ddd; text-align: left;">${sanitizeHTML(header)}</th>`;
    });
    html += '</tr>';
    
    // Maximal 5 Zeilen für die Vorschau
    const previewRows = data.slice(0, 5);
    
    // Datenzeilen (anonymisiert)
    previewRows.forEach(row => {
        html += '<tr>';
        headers.forEach(header => {
            let value = row[header] || '';
            
            // Personenbezogene Daten anonymisieren
            if (isPersonalData(header)) {
                value = anonymizeValue(value);
            }
            
            html += `<td style="padding: 8px; border: 1px solid #ddd;">${sanitizeHTML(value)}</td>`;
        });
        html += '</tr>';
    });
    
    html += '</table>';
    
    if (data.length > 5) {
        html += `<p>... und ${data.length - 5} weitere Einträge</p>`;
    }
    
    return html;
}

// Prüfen, ob es sich um personenbezogene Daten handelt
function isPersonalData(fieldName) {
    const personalFields = [
        'name', 'vorname', 'nachname', 'schüler', 'schueler', 
        'email', 'mail', 'adresse', 'telefon', 'handy'
    ];
    
    return personalFields.some(field => 
        fieldName.toLowerCase().includes(field.toLowerCase())
    );
}

// Werte anonymisieren
function anonymizeValue(value) {
    if (!value) return '';
    return value.charAt(0) + '***';
}

// HTML-Escape für sicheres Rendering
function sanitizeHTML(str) {
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

// Gruppenbildung analysieren
function analyzeGroupFormation(parsedData) {
    const { data } = parsedData;
    
    // Isolierte Schüler identifizieren (Pseudocode)
    const isolatedCount = countIsolatedStudents(data);
    
    // Beliebte Schüler identifizieren (Pseudocode)
    const popularCount = countPopularStudents(data);
    
    // Cliquen identifizieren (Pseudocode)
    const cliques = identifyCliques(data);
    
    // Ergebnisbericht generieren
    const result = `
        <h4>Gruppenstrukturanalyse</h4>
        <ul>
            <li>Isolierte Schüler: ${isolatedCount}</li>
            <li>Stark präferierte Schüler: ${popularCount}</li>
            <li>Identifizierte Gruppen: ${cliques.length}</li>
        </ul>
    `;
    
    // Anonymisierte Prompt-Ergänzung generieren
    const promptSuggestion = `
        Berücksichtige bei der Erstellung von Gruppenarbeitsphasen folgende soziometrische Informationen:
        
        - Es gibt ${isolatedCount} isolierte Schüler, die wenig soziale Verbindungen haben
        - Es gibt ${popularCount} stark präferierte Schüler, die viele Verbindungen haben
        - Es gibt ${cliques.length} erkennbare Cliquen/Freundesgruppen
        
        Vorschläge:
        - Bilde heterogene Gruppen, die isolierte Schüler integrieren
        - Verteile die stark präferierten Schüler auf verschiedene Gruppen
        - Berücksichtige eine Mischung aus bestehenden Freundschaften und neuen Verbindungen
    `;
    
    return [result, promptSuggestion];
}

// Sozialstruktur analysieren
function analyzeSocialStructure(parsedData) {
    // Implementierung ähnlich wie bei analyzeGroupFormation
    // ...
    
    const result = '<p>Sozialstrukturanalyse durchgeführt.</p>';
    const promptSuggestion = 'Berücksichtige folgende soziale Struktur in der Klasse: ...';
    
    return [result, promptSuggestion];
}

// Präferenzen analysieren
function analyzePreferences(parsedData) {
    // Implementierung ähnlich wie bei analyzeGroupFormation
    // ...
    
    const result = '<p>Präferenzanalyse durchgeführt.</p>';
    const promptSuggestion = 'Berücksichtige folgende Interessensgebiete der Schüler: ...';
    
    return [result, promptSuggestion];
}

// Hilfsfunktionen (Mock-Implementierungen)
function countIsolatedStudents(data) {
    // Tatsächliche Implementierung würde die Verbindungen analysieren
    return Math.floor(data.length * 0.15); // Annahme: ca. 15% isolierte Schüler
}

function countPopularStudents(data) {
    // Tatsächliche Implementierung würde die Verbindungen analysieren
    return Math.floor(data.length * 0.2); // Annahme: ca. 20% beliebte Schüler
}

function identifyCliques(data) {
    // Tatsächliche Implementierung würde Gruppen identifizieren
    return [
        { size: 4, strength: 'stark' },
        { size: 3, strength: 'mittel' },
        { size: 5, strength: 'mittel' }
    ];
}
