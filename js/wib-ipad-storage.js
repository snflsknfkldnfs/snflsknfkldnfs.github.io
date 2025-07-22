/**
 * IPAD STORAGE SYSTEM
 * Lokale Speicher- und Export-Funktionen für WiB-Materialien
 * DSGVO-konform durch LocalStorage ohne Serverübertragung
 */

class WiBiPadStorage {
    constructor() {
        this.storageKey = 'wib_kulturtechniken_data';
        this.init();
    }

    init() {
        this.setupAutoSave();
        this.setupExportFunctions();
        this.loadStoredData();
    }

    // DSGVO-konforme Datenspeicherung im Browser
    saveFormData(formId, data) {
        try {
            const stored = this.getStoredData();
            const timestamp = new Date().toISOString();
            
            stored[formId] = {
                data: data,
                timestamp: timestamp,
                formType: this.getFormType(formId)
            };
            
            localStorage.setItem(this.storageKey, JSON.stringify(stored));
            this.showSaveNotification('✅ Automatisch gespeichert');
            
            return true;
        } catch (error) {
            console.warn('Speichern fehlgeschlagen:', error);
            this.showSaveNotification('⚠️ Speichern fehlgeschlagen', 'error');
            return false;
        }
    }

    // Gespeicherte Daten laden
    loadStoredData() {
        try {
            const stored = this.getStoredData();
            
            // Auto-fill forms if data exists
            Object.keys(stored).forEach(formId => {
                this.fillForm(formId, stored[formId].data);
            });
            
            return stored;
        } catch (error) {
            console.warn('Laden fehlgeschlagen:', error);
            return {};
        }
    }

    // Formular automatisch ausfüllen
    fillForm(formId, data) {
        if (!document.getElementById(formId)) return;
        
        Object.keys(data).forEach(fieldName => {
            const field = document.querySelector(`[name="${fieldName}"], #${fieldName}`);
            if (field) {
                field.value = data[fieldName];
            }
        });
    }

    // Alle gespeicherten Daten abrufen
    getStoredData() {
        try {
            return JSON.parse(localStorage.getItem(this.storageKey) || '{}');
        } catch {
            return {};
        }
    }

    // Formular-Typ ermitteln
    getFormType(formId) {
        if (formId.includes('informieren')) return 'UE3_Informieren';
        if (formId.includes('unterhalten')) return 'UE3_Unterhalten';
        if (formId.includes('produzieren')) return 'UE3_Produzieren';
        if (formId.includes('organisieren')) return 'UE3_Organisieren';
        if (formId.includes('laufzettel')) return 'UE4_Laufzettel';
        return 'Unbekannt';
    }

    // Auto-Save für Eingabefelder einrichten
    setupAutoSave() {
        document.addEventListener('input', (e) => {
            if (e.target.matches('input, textarea, select')) {
                this.debounce(() => {
                    this.autoSaveForm(e.target.form);
                }, 1000)();
            }
        });
    }

    // Formulardaten automatisch speichern
    autoSaveForm(form) {
        if (!form) return;
        
        const formId = form.id || this.generateFormId(form);
        const formData = new FormData(form);
        const data = {};
        
        for (let [key, value] of formData.entries()) {
            data[key] = value;
        }
        
        // Zusätzlich alle Eingabefelder erfassen
        const inputs = form.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
            if (input.name || input.id) {
                const key = input.name || input.id;
                data[key] = input.value;
            }
        });
        
        this.saveFormData(formId, data);
    }

    // Form-ID generieren falls nicht vorhanden
    generateFormId(form) {
        const url = window.location.pathname;
        if (url.includes('INFORMIEREN')) return 'form_informieren';
        if (url.includes('UNTERHALTEN')) return 'form_unterhalten';
        if (url.includes('PRODUZIEREN')) return 'form_produzieren';
        if (url.includes('Laufzettel')) return 'form_laufzettel';
        return 'form_' + Date.now();
    }

    // Export-Funktionen einrichten
    setupExportFunctions() {
        // Export-Button hinzufügen falls nicht vorhanden
        this.addExportButton();
    }

    // Export-Button zum DOM hinzufügen
    addExportButton() {
        const container = document.querySelector('.forschungsbogen, .laufzettel, body');
        if (!container || document.getElementById('wib-export-btn')) return;
        
        const exportDiv = document.createElement('div');
        exportDiv.id = 'wib-export-controls';
        exportDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border: 1px solid #e2e8f0;
        `;
        
        exportDiv.innerHTML = `
            <div style="font-weight: bold; margin-bottom: 0.5rem; color: #2d3748;">📱 iPad-Tools</div>
            <button id="wib-export-btn" style="
                background: #3182ce;
                color: white;
                border: none;
                padding: 0.5rem 1rem;
                border-radius: 6px;
                cursor: pointer;
                margin-right: 0.5rem;
                font-size: 0.9rem;
            ">💾 Export</button>
            <button id="wib-clear-btn" style="
                background: #e53e3e;
                color: white;
                border: none;
                padding: 0.5rem 1rem;
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.9rem;
            ">🗑️ Leeren</button>
            <div id="wib-status" style="font-size: 0.8rem; color: #718096; margin-top: 0.5rem;"></div>
        `;
        
        container.appendChild(exportDiv);
        
        // Event-Listener hinzufügen
        document.getElementById('wib-export-btn').onclick = () => this.exportAllData();
        document.getElementById('wib-clear-btn').onclick = () => this.clearAllData();
    }

    // Alle Daten exportieren
    exportAllData() {
        const stored = this.getStoredData();
        const exportData = {
            timestamp: new Date().toISOString(),
            project: 'WiB 5b Kulturtechniken',
            class: '5b',
            data: stored
        };
        
        // Als JSON-Datei herunterladen
        const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `WiB_Kulturtechniken_${new Date().toISOString().split('T')[0]}.json`;
        a.click();
        URL.revokeObjectURL(url);
        
        this.showSaveNotification('📥 Daten exportiert');
    }

    // Alle Daten löschen
    clearAllData() {
        if (confirm('Alle gespeicherten Daten löschen? Diese Aktion kann nicht rückgängig gemacht werden.')) {
            localStorage.removeItem(this.storageKey);
            location.reload();
        }
    }

    // Speicher-Benachrichtigung anzeigen
    showSaveNotification(message, type = 'success') {
        const status = document.getElementById('wib-status');
        if (status) {
            status.textContent = message;
            status.style.color = type === 'error' ? '#e53e3e' : '#38a169';
            
            setTimeout(() => {
                status.textContent = '';
            }, 3000);
        }
    }

    // Debounce-Funktion für Performance
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // QR-Code für aktuelles Formular generieren
    generateQRForCurrentForm() {
        const currentUrl = window.location.href;
        const title = document.title;
        
        const qrUrl = `/qr-generator.html?url=${encodeURIComponent(currentUrl)}&title=${encodeURIComponent(title)}`;
        window.open(qrUrl, '_blank');
    }

    // Statistiken anzeigen
    getStorageStats() {
        const stored = this.getStoredData();
        const stats = {
            totalForms: Object.keys(stored).length,
            totalDataSize: JSON.stringify(stored).length,
            lastUpdate: null
        };
        
        // Neueste Aktualisierung finden
        Object.values(stored).forEach(item => {
            if (!stats.lastUpdate || item.timestamp > stats.lastUpdate) {
                stats.lastUpdate = item.timestamp;
            }
        });
        
        return stats;
    }
}

// Automatische Initialisierung
let wibStorage;
document.addEventListener('DOMContentLoaded', () => {
    wibStorage = new WiBiPadStorage();
    console.log('WiB iPad Storage System initialisiert');
    
    // Statistiken in Konsole ausgeben
    const stats = wibStorage.getStorageStats();
    console.log('Storage Stats:', stats);
});

// Global verfügbar machen
window.wibStorage = wibStorage;