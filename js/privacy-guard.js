/**
 * Enhanced Privacy Guard
 * Funktionen zum Schutz personenbezogener Daten mit Lehrerzugriff
 */

// Pseudonymisierung mit Entschlüsselungsmöglichkeit für den Lehrer
function pseudonymizeDataWithMapping(data, nameField) {
    const pseudonyms = {};
    const reverseMapping = {};
    
    // Erstelle eindeutige Vornamen mit Initialen bei Duplikaten
    const processedData = data.map(row => {
        const newRow = {...row};
        
        if (newRow[nameField]) {
            const fullName = newRow[nameField];
            let displayName = createDisplayName(fullName);
            
            // Erstelle eindeutige Anzeigenamen
            if (!pseudonyms[displayName]) {
                pseudonyms[displayName] = fullName;
            } else {
                // Wenn der Name bereits existiert, füge Initial hinzu
                const initial = getLastNameInitial(fullName);
                displayName = `${getFirstName(fullName)} ${initial}.`;
                pseudonyms[displayName] = fullName;
            }
            
            // Speichere Zuordnung in beide Richtungen
            reverseMapping[fullName] = displayName;
            newRow[nameField] = displayName;
        }
        
        return newRow;
    });
    
    return {
        processedData,
        mappings: {
            original: pseudonyms,     // Von Anzeigename zu Originalname
            display: reverseMapping   // Von Originalname zu Anzeigename
        }
    };
}

// Extrahiert Vornamen
function getFirstName(fullName) {
    return fullName.split(' ')[0];
}

// Extrahiert Initial des Nachnamens
function getLastNameInitial(fullName) {
    const parts = fullName.split(' ');
    return parts.length > 1 ? parts[parts.length - 1].charAt(0) : '';
}

// Erstellt Anzeigenamen (Vorname oder Vorname + Initial)
function createDisplayName(fullName) {
    const firstName = getFirstName(fullName);
    return firstName;
}

// Entschlüsselt Pseudonyme für den Lehrer
function deanonymizeForTeacher(data, mappings, nameField) {
    return data.map(item => {
        const newItem = {...item};
        
        if (newItem[nameField] && mappings.original[newItem[nameField]]) {
            newItem[`${nameField}_original`] = mappings.original[newItem[nameField]];
        }
        
        return newItem;
    });
}

// Gruppen erstellen mit lesbaren Namen
function createGroups(data, nameField, groupSize, preferenceField = null) {
    // Kopie der Daten erstellen
    let studentsToAssign = [...data];
    
    // Wenn Präferenzen vorhanden sind, diese berücksichtigen
    if (preferenceField) {
        studentsToAssign = considerPreferences(studentsToAssign, preferenceField);
    }
    
    // Isolierte Schüler identifizieren
    const isolatedStudents = identifyIsolatedStudents(studentsToAssign);
    
    // Beliebte Schüler identifizieren
    const popularStudents = identifyPopularStudents(studentsToAssign);
    
    // Gruppen erstellen
    const groups = [];
    let currentGroup = [];
    
    // Abwechselnd isolierte und beliebte Schüler auf Gruppen verteilen
    while (isolatedStudents.length > 0 && popularStudents.length > 0) {
        if (currentGroup.length === 0 || currentGroup.length === 2) {
            currentGroup.push(isolatedStudents.shift());
        } else {
            currentGroup.push(popularStudents.shift());
        }
        
        if (currentGroup.length === groupSize) {
            groups.push([...currentGroup]);
            currentGroup = [];
        }
    }
    
    // Restliche Schüler zu den Gruppen hinzufügen
    const remainingStudents = [...isolatedStudents, ...popularStudents, 
                               ...studentsToAssign.filter(s => 
                                  !isolatedStudents.includes(s) && !popularStudents.includes(s))];
    
    for (const student of remainingStudents) {
        currentGroup.push(student);
        
        if (currentGroup.length === groupSize) {
            groups.push([...currentGroup]);
            currentGroup = [];
        }
    }
    
    // Falls noch eine unvollständige Gruppe übrig ist
    if (currentGroup.length > 0) {
        groups.push([...currentGroup]);
    }
    
    // Gruppen in lesbares Format umwandeln
    return groups.map((group, index) => ({
        gruppenNr: index + 1,
        mitglieder: group.map(student => student[nameField]).join(', '),
        mitgliederObjekte: group
    }));
}

// Mock-Implementierungen für Demonstrations- und Testzwecke
function considerPreferences(students, preferenceField) {
    // In einer realen Implementierung würde hier die Präferenzlogik stehen
    return students;
}

function identifyIsolatedStudents(students) {
    // In einer realen Implementierung würde hier die Identifikationslogik stehen
    return students.filter((_, index) => index % 5 === 0); // Beispiel: jeder 5. Schüler
}

function identifyPopularStudents(students) {
    // In einer realen Implementierung würde hier die Identifikationslogik stehen
    return students.filter((_, index) => index % 7 === 0); // Beispiel: jeder 7. Schüler
}

// Lokale sichere Speicherung mit Lehrerpasswort
function secureStoreForTeacher(data, password) {
    const serialized = JSON.stringify(data);
    
    // In einer produktiven Anwendung würde hier eine sichere Verschlüsselung stehen
    // Diese einfache Implementierung dient nur zur Demonstration
    const encrypted = btoa(serialized); // Base64-Kodierung
    
    return encrypted;
}

// Abrufen der gesicherten Lehrerdaten
function retrieveTeacherData(encryptedData, password) {
    try {
        // In einer produktiven Anwendung würde hier eine sichere Entschlüsselung stehen
        const decrypted = atob(encryptedData); // Base64-Dekodierung
        return JSON.parse(decrypted);
    } catch (e) {
        console.error('Fehler beim Abrufen der Lehrerdaten:', e);
        return null;
    }
}

// Exportfunktion für Lehreransicht
function exportForTeacherView(groups, mappings) {
    let html = '<h3>Gruppenübersicht für den Lehrer</h3>';
    html += '<table style="width: 100%; border-collapse: collapse;">';
    html += '<tr><th style="border: 1px solid #ddd; padding: 8px;">Gruppe</th><th style="border: 1px solid #ddd; padding: 8px;">Teilnehmer</th></tr>';
    
    groups.forEach(group => {
        html += `<tr>
            <td style="border: 1px solid #ddd; padding: 8px;">Gruppe ${group.gruppenNr}</td>
            <td style="border: 1px solid #ddd; padding: 8px;">
                ${group.mitgliederObjekte.map(student => {
                    const displayName = student.name;
                    const originalName = mappings.original[displayName] || displayName;
                    return `<div>${originalName}</div>`;
                }).join('')}
            </td>
        </tr>`;
    });
    
    html += '</table>';
    return html;
}

// Exportfunktion für KI-Prompt (anonymisiert)
function exportForAIPrompt(groups) {
    return `
        Für diese Unterrichtsplanung wurden ${groups.length} Gruppen mit folgender Zusammensetzung gebildet:
        
        ${groups.map(group => `Gruppe ${group.gruppenNr}: ${group.mitglieder}`).join('\n        ')}
        
        Bitte berücksichtige diese Gruppeneinteilung bei der Erstellung der Unterrichtsmaterialien.
        Generiere passende Aufgaben für kooperatives Lernen in diesen Gruppen.
    `;
}