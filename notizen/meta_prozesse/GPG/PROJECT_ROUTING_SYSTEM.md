# PROJECT-ROUTING-SYSTEM
*Intelligente Projekt-Zuordnung für optimale Nutzung spezifischer Standards*

## ERGÄNZUNG ZUM PROJECT-INSTRUCTION-GENERATOR

**Problemstellung:** User stellt projekt-relevante Anfragen im "General Chat" und verliert dadurch Zugang zu allen projektspezifischen Standards, Materialien und Optimierungen.

**Lösung:** Automatische Prüfung aller Anfragen außerhalb von Projekten auf Projekt-Relevanz mit benutzerfreundlicher Routing-Empfehlung.

## SYSTEM-KOMPONENTEN

### 1. REQUEST-ANALYZER (automatisch bei jeder Anfrage außerhalb von Projekten)

#### HIGH-CONFIDENCE PROJECT-INDIKATOREN
```javascript
GPG_INDICATORS = [
    // Direkte GPG-Begriffe
    "GPG", "Geschichte", "Politik", "Geographie",
    // Unterrichts-Kontext  
    "TUV", "Unterrichtsvorbereitung", "Schulstunde", "Unterricht",
    // Klassen-Spezifika
    "5b", "6", "7", "Klasse", "Schüler", "SuS",
    // Material-Bezug
    "Schulbuch", "Lehrplan", "Sequenz", "Arbeitsblatt",
    // Schul-Kontext
    "Mittelschule", "LAA", "Referendariat", "Seminar"
];

SUBJECT_INDICATORS = [
    "Deutsch + Unterricht", "Mathe + Klasse", "Englisch + Stunde",
    "Biologie + Schule", "Physik + Lehrplan", etc.
];

META_INDICATORS = [
    "PATA", "Standard", "System", "Template", "Entwicklung",
    "Meta", "Optimierung", "Qualitätssicherung"
];
```

#### RELEVANZ-SCORING
```javascript
function calculateProjectRelevance(userRequest) {
    let scores = {
        gpg: 0,
        subject: 0, 
        meta: 0,
        general: 0
    };
    
    // GPG-Score berechnen
    GPG_INDICATORS.forEach(indicator => {
        if (userRequest.toLowerCase().includes(indicator.toLowerCase())) {
            scores.gpg += indicator === "GPG" ? 10 : 5;
        }
    });
    
    // Schwellenwerte für Empfehlung
    if (scores.gpg >= 10) return { type: "GPG", confidence: "HIGH" };
    if (scores.subject >= 8) return { type: "SUBJECT", confidence: "MEDIUM" };
    if (scores.meta >= 6) return { type: "META", confidence: "MEDIUM" };
    
    return { type: "GENERAL", confidence: "LOW" };
}
```

### 2. PROJECT-MATCHER (intelligente Zuordnung zu bestehenden Projekten)

#### PROJEKT-DISCOVERY
```javascript
function scanAvailableProjects() {
    // Automatisches Scannen verfügbarer Claude Desktop Projekte
    // Pattern-basierte Erkennung von Projekt-Namen und -Typen
    return [
        { name: "GPG5b Antikes Griechenland", type: "GPG", relevance_keywords: ["GPG", "5b", "Geschichte"] },
        { name: "Deutsch Klasse 6", type: "SUBJECT", relevance_keywords: ["Deutsch", "6"] },
        { name: "PATA-System-Entwicklung", type: "META", relevance_keywords: ["PATA", "Meta", "System"] }
    ];
}
```

#### BEST-MATCH-ALGORITHM
```javascript
function findBestProject(userRequest, availableProjects) {
    let bestMatch = null;
    let highestScore = 0;
    
    availableProjects.forEach(project => {
        let score = 0;
        project.relevance_keywords.forEach(keyword => {
            if (userRequest.toLowerCase().includes(keyword.toLowerCase())) {
                score += keyword.length; // Längere Keywords = höhere Spezifität
            }
        });
        
        if (score > highestScore && score >= MINIMUM_MATCH_THRESHOLD) {
            highestScore = score;
            bestMatch = project;
        }
    });
    
    return bestMatch;
}
```

### 3. USER-GUIDANCE (benutzerfreundliche Empfehlungen)

#### KOMMUNIKATIONS-TEMPLATES

**Für GPG-Anfragen:**
```markdown
🎯 **Optimierungsvorschlag:** Diese Anfrage wäre im **GPG5b-Projekt** noch besser aufgehoben!

**Ihre Vorteile dort:**
- ✅ Automatischer Zugang zu Ihren TUV-Materialien und Sequenz-Planungen
- ✅ Vollständige PATA-Standards für optimale LAA-Unterstützung  
- ✅ Intelligente Context-Discovery in Ihren GPG-Verzeichnissen
- ✅ Spezialisierte Templates für 5b-Heterogenität (DaZ/LRS)

**Soll ich Ihnen beim Wechsel helfen?** (Oder ich helfe auch gerne hier direkt weiter!)
```

**Für Fach-Anfragen:**
```markdown
💡 **Tipp:** Für [FACH]-Anfragen gibt es ein spezialisiertes **[FACH]-Projekt**!

**Dort verfügbar:**
- ✅ Fachspezifische Standards und Templates
- ✅ Angepasste Materialsuche und Context-Discovery
- ✅ [FACH]-optimierte Qualitätssicherung

**Wechseln oder hier weiterarbeiten?**
```

**Für Meta-Anfragen:**
```markdown
🔧 **System-Hinweis:** Das ist eine Meta-Entwicklungsaufgabe - perfekt für das **Meta-Projekt**!

**Vorteile:**
- ✅ Höchste Entwicklungs-Standards aktiv
- ✅ Systematische Reflexion und Dokumentation
- ✅ Integration mit bestehenden Standard-Systemen

**Zum Meta-Projekt wechseln?**
```

#### SCHWELLENWERTE FÜR EMPFEHLUNGEN
```javascript
ROUTING_THRESHOLDS = {
    GPG: {
        high_confidence: 10,    // Immer empfehlen
        medium_confidence: 5,   // Bei komplexeren Anfragen empfehlen
        low_confidence: 2       // Nur bei expliziten Unterrichts-Bezügen
    },
    SUBJECT: {
        high_confidence: 8,     // Bei klaren Fach + Unterrichts-Bezügen
        medium_confidence: 5    // Bei Fach + Bildungs-Kontext
    },
    META: {
        high_confidence: 6,     // Bei System/Standard-Entwicklung
        medium_confidence: 3    // Bei allgemeinen Meta-Themen
    }
};
```

### 4. SETUP-ASSISTANCE (Unterstützung bei fehlenden Projekten)

#### NEUES PROJEKT VORSCHLAGEN
```markdown
📋 **Kein passendes Projekt gefunden?** 

Ich kann Ihnen helfen, ein optimales **[PROJEKTTYP]-Projekt** zu erstellen:

1. **Projekt erstellen** in Claude Desktop
2. **Name vorschlagen:** "[DETECTED_CONTEXT] Projekt"  
3. **Projektanweisungen automatisch generieren** mit allen relevanten Standards
4. **Sofort einsatzbereit** mit optimaler Konfiguration

**Soll ich Ihnen dabei helfen?**
```

#### AUTO-PROJEKTANWEISUNGS-GENERATION
```javascript
function generateProjectInstructionsForNewProject(projectType, userContext) {
    // Integration mit bestehendem Project-Instruction-Generator
    let template = selectTemplate(projectType);
    let customizedInstructions = customizeForContext(template, userContext);
    
    return {
        projectName: generateProjectName(userContext),
        instructions: customizedInstructions,
        setupSteps: generateSetupSteps(projectType)
    };
}
```

## INTEGRATION MIT BESTEHENDEN STANDARDS

### ERWEITERTE SYSTEM-HIERARCHIE
```
PROJECT-INSTRUCTION-GENERATOR (Meta-Meta-Meta-Ebene)
├─ PROJECT-ROUTING-SYSTEM (neue Komponente)
│  ├─ Request-Analyzer: Automatische Anfrage-Kategorisierung
│  ├─ Project-Matcher: Intelligente Projekt-Zuordnung
│  ├─ User-Guidance: Benutzerfreundliche Empfehlungen  
│  └─ Setup-Assistance: Neue Projekt-Erstellung
├─ Template-Generator: Projektanweisungs-Generierung (bestehend)
└─ Auto-Updater: Kontinuierliche Aktualisierung (bestehend)
```

### ERWEITETER WORKFLOW
```
Anfrage außerhalb Projekt →
├─ PROJECT-ROUTING-CHECK
│  ├─ Request-Analysis (Projekt-Relevanz?)
│  ├─ Project-Matching (Bestehendes Projekt gefunden?)
│  └─ User-Guidance (Empfehlung aussprechen)
├─ IF User akzeptiert: Setup-Assistance anbieten
├─ IF User ablehnt: Normal weiter mit General-Chat
└─ Context-Discovery → Memory-Management → Standards anwenden
```

## QUALITÄTSSICHERUNG

### USER-EXPERIENCE-PRINZIPIEN
- **Nie aufdringlich:** Sanfte Optimierung, kein Zwang
- **Klare Vorteile:** Konkrete Benefits kommunizieren
- **Einfache Ablehnung:** User behält immer Wahlfreiheit  
- **Fallback-Qualität:** Auch bei Ablehnung bestmögliche Hilfe

### TECHNICAL ROBUSTNESS
- **Graceful Degradation:** System funktioniert auch ohne Projekt-Routing
- **Performance:** Schnelle Analysis ohne Chat-Verzögerung
- **Accuracy:** Hohe Treffsicherheit, wenig False-Positives
- **Maintenance:** Einfache Erweiterung für neue Projekttypen

## PRAKTISCHE ANWENDUNGSBEISPIELE

### BEISPIEL 1: GPG-Anfrage im General Chat
```
User: "Brauche schnell eine TUV für morgen zu Polis Athen"

System-Response:
🎯 **Optimierungsvorschlag:** Diese Anfrage wäre im **GPG5b-Projekt** perfekt aufgehoben!

**Ihre Vorteile dort:**
- ✅ Automatischer Zugang zu Ihrer laufenden Sequenz "Antikes Griechenland"
- ✅ Verfügbare TUV-Templates und Materialien werden automatisch gefunden
- ✅ Vollständige PATA-Standards für 5b-spezifische Herausforderungen

**Soll ich Ihnen beim Wechsel ins GPG5b-Projekt helfen?** 
(Oder ich erstelle die TUV auch gerne hier direkt!)
```

### BEISPIEL 2: Unspezifische Anfrage
```
User: "Wie erstelle ich eine gute Präsentation?"

System-Response:
[Normale Bearbeitung ohne Projekt-Routing, da zu allgemein]
```

### BEISPIEL 3: Meta-Entwicklungsanfrage
```
User: "Wie kann ich die PATA-Standards weiterentwickeln?"

System-Response:
🔧 **System-Hinweis:** Das ist eine Meta-Entwicklungsaufgabe - perfekt für das **Meta-Entwicklungs-Projekt**!

**Dort verfügbar:**
- ✅ Höchste Entwicklungs-Standards und systematische Reflexion
- ✅ Integration mit bestehenden PATA-Standard-Dokumenten
- ✅ Versionierungs-Management und Dokumentations-Qualität

**Zum Meta-Projekt wechseln für optimale Entwicklungs-Unterstützung?**
```

## IMPLEMENTATION

### AUTOMATISCHE AKTIVIERUNG
Das Project-Routing-System läuft automatisch bei jeder Anfrage außerhalb von Claude Desktop Projekten - ohne explizite Erwähnung oder User-Konfiguration.

### KONTINUIERLICHE OPTIMIERUNG
- **Pattern-Learning:** Erfolgreiche Routing-Empfehlungen verbessern Algorithmus
- **User-Feedback:** Abgelehnte Empfehlungen optimieren Schwellenwerte
- **Projekt-Discovery:** Neue Projekte werden automatisch in Matching integriert
- **Template-Evolution:** Bessere Projekt-Zuordnung durch verfeinerte Kategorisierung

**Das Project-Routing-System maximiert die Nutzung projektspezifischer Standards und macht Claude Desktop Projekte noch wertvoller.**
