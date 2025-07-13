# DiSoAn-Projekt-Orientierungssystem: Intelligente Claude-Project-Artefakte

---
typ: projekt_orientierung_framework
priorität: CRITICAL_AUTOMATION
anwendung: claude_desktop_projects
basis: disoän_standards + stakeholder_integration + selbstlernende_systeme
status: framework_entwicklung
luhmann_perspektive: projekt_beobachtung_2_ordnung
letzte_aktualisierung: "2025-07-08"
version: "1.0.0"
---

## 🎯 **SYSTEMTHEORETISCHE EINORDNUNG NACH LUHMANN**

### **Projekt-Beobachtung als System-Operation**
```yaml
BEOBACHTUNG_1_ORDNUNG: "Direkter Projektinhalt (Fach, Jahrgangsstufe, Materialien)"
BEOBACHTUNG_2_ORDNUNG: "Wie beobachtet das Projekt sich selbst?"
BEOBACHTUNG_3_ORDNUNG: "Wie beobachte ich die Projekt-Selbstbeobachtung?"

AUTOPOIESIS_PROJEKT: "Projekte reproduzieren sich durch kontinuierliche Orientierungs-Updates"
PROJEKT_UMWELT: "Repository, Chat-Verläufe, aktuelle Unterrichtsmaterialien"
STRUKTURELLE_KOPPLUNG: "Projekt ↔ Repository ↔ DiSoAn-Standards ↔ Stakeholder-System"
```

### **Teilrationalitäten in Projekt-Orientierung**
```yaml
PÄDAGOGISCHE_RATIONALITÄT: "Optimale Lehr-Lern-Unterstützung durch perfekte Orientierung"
TECHNISCHE_RATIONALITÄT: "Effiziente Automatisierung und nahtlose Integration"
WISSENSCHAFTLICHE_RATIONALITÄT: "Evidenzbasierte Projekt-Beschreibungs-Optimierung"
RECHTLICH_ADMINISTRATIVE_RATIONALITÄT: "DSGVO-konforme Datenverarbeitung und Versionierung"
```

## 🏗️ **SYSTEM-ARCHITEKTUR: INTELLIGENTE PROJEKT-ORIENTIERUNG**

### **Kern-Komponenten des Orientierungssystems**
```python
class DiSoAnProjectOrientationSystem:
    def __init__(self):
        self.fach_templates = {
            'GPG': GeographyPoliticsHistoryTemplate(),
            'WiB': BusinessEconomicsTemplate(), 
            'M': MathematicsTemplate(),
            'E': EnglishTemplate(),
            'NT': ScienceTemplate(),
            'D': GermanTemplate(),
            'Sport': PhysicalEducationTemplate()
        }
        
        self.jahrgangsstufen_config = {
            5: {'entwicklung': 'Übergang_Grundschule', 'schwerpunkt': 'Orientierung'},
            6: {'entwicklung': 'Konsolidierung', 'schwerpunkt': 'Grundlagen'},
            7: {'entwicklung': 'Differenzierung', 'schwerpunkt': 'Vertiefung'},
            8: {'entwicklung': 'Berufsorientierung', 'schwerpunkt': 'Anwendung'},
            9: {'entwicklung': 'Abschlussorientierung', 'schwerpunkt': 'Prüfungsvorbereitung'},
            10: {'entwicklung': 'Übergang_Beruf', 'schwerpunkt': 'Spezialisierung'}
        }
        
    def generate_project_description(self, project_name):
        fach, jahrgangsstufe = self.parse_project_name(project_name)
        
        # Repository-Analyse für aktuellen Projektstand
        current_state = self.analyze_repository_state(fach, jahrgangsstufe)
        
        # Stakeholder-Kontext für Fach/Jahrgangsstufe
        stakeholder_context = self.get_stakeholder_context(fach, jahrgangsstufe)
        
        # DiSoAn-konforme Orientierung generieren
        orientation_artifact = self.create_orientation_artifact(
            fach, jahrgangsstufe, current_state, stakeholder_context
        )
        
        return orientation_artifact
```

### **Intelligente Repository-Analyse**
```python
class IntelligentRepositoryAnalyzer:
    def analyze_project_state(self, fach, jahrgangsstufe):
        analysis = {
            'unterrichtsmaterialien': self.scan_teaching_materials(fach, jahrgangsstufe),
            'sequenzplanungen': self.find_sequence_plans(fach, jahrgangsstufe),
            'bewertungsbögen': self.locate_assessment_tools(fach, jahrgangsstufe),
            'digitale_medien': self.identify_digital_resources(fach, jahrgangsstufe),
            'stakeholder_verbindungen': self.map_stakeholder_connections(fach),
            'letzte_änderungen': self.track_recent_changes(fach, jahrgangsstufe),
            'pata_status': self.assess_pata_compliance(fach, jahrgangsstufe)
        }
        
        # Systemtheoretische Reflexion
        analysis['rückkopplungseffekte'] = self.identify_feedback_loops(analysis)
        analysis['blinde_flecken'] = self.detect_blind_spots(analysis)
        analysis['emergente_eigenschaften'] = self.recognize_emergent_properties(analysis)
        
        return analysis
```

## 📋 **FACH-SPEZIFISCHE TEMPLATE-SYSTEM**

### **Template für GPG (Geschichte/Politik/Geographie)**
```markdown
# 🌍 GPG{jahrgangsstufe} - Systemtheoretische Projekt-Orientierung

## 📍 **AKTUELLER PROJEKTSTATUS** (Auto-Update: {last_update})

### **Systemkonfiguration**
```yaml
DiSoAn_Standards: ✅ Vollständig aktiviert
Stakeholder_Integration: ✅ GPG-spezifische Akteure kartiert  
Teilrationalitäten_Balance: ✅ Pädagogisch-wissenschaftlich-technisch-rechtlich
Selbstlernend: ✅ Kontinuierliche Repository-Integration
```

### **Fachspezifische Orientierung**
- **Kernbereich**: Geschichte/Politik/Geographie interdisziplinär
- **Jahrgangsstufe {jahrgangsstufe}**: {entwicklungsphase} mit Schwerpunkt {schwerpunkt}
- **Lehrplan-Fokus**: {aktuelle_lernbereiche}
- **Digitalisierung**: {digital_integration_status}

### **Verfügbare Ressourcen** 
{materialien_übersicht}

### **Aktuelle Unterrichtssequenzen**
{sequenzen_status}

### **Stakeholder-Netzwerk**
{stakeholder_connections}

### **Systemtheoretische Reflexion**
- **Rückkopplungseffekte**: {feedback_loops}
- **Blinde Flecken**: {blind_spots}  
- **Emergente Eigenschaften**: {emergent_properties}

---
*Auto-generiert durch DiSoAn-Orientierungssystem v{version}*
```

### **Template für WiB (Wirtschaft und Beruf)**
```markdown
# 💼 WiB{jahrgangsstufe} - Projektökonomische Orientierung

## 📊 **WIRTSCHAFTSDIDAKTISCHER PROJEKTSTATUS** (Live-Update: {timestamp})

### **Ökonomische Systemkonfiguration**
```yaml
Projektmethodik: ✅ WiB-Kernkompetenzen optimiert
Berufsorientierung: ✅ {berufsfeld_schwerpunkte}
Wirtschaftsverständnis: ✅ Jahrgangsstufe-{jahrgangsstufe}-konform
Digitale_Kompetenz: ✅ {digital_skills_level}
```

### **Praxisorientierte Projektausrichtung**
- **Lernfeld-Fokus**: {aktuelle_lernfelder}
- **Berufsorientierung**: {berufliche_schwerpunkte}
- **Projektzyklen**: {projekt_status}
- **Wirtschaftspartner**: {externe_kooperationen}

### **Verfügbare WiB-Ressourcen**
{wib_materialien}

### **Aktive Projektphasen**
{projektphasen_übersicht}

### **Stakeholder-Ökonomie**
{wirtschaftliche_akteure}

---
*DiSoAn-WiB-Optimierungssystem v{version}*
```

## 🔄 **SELBSTLERNENDE UPDATE-MECHANISMEN**

### **Automatische Repository-Synchronisation**
```python
class AutoUpdateEngine:
    def __init__(self):
        self.watch_patterns = {
            'unterricht/': 'Neue Unterrichtsmaterialien',
            'seminarcloud/': 'Seminar-Updates',  
            'notizen/': 'Konzeptuelle Entwicklungen',
            'tools/': 'Technische Verbesserungen'
        }
        
    def detect_relevant_changes(self, project_name):
        fach, jahrgangsstufe = parse_project_name(project_name)
        
        relevant_changes = []
        for path_pattern in self.watch_patterns:
            if self.is_relevant_for_project(path_pattern, fach, jahrgangsstufe):
                changes = self.git_diff_since_last_update(path_pattern)
                relevant_changes.extend(changes)
                
        return self.categorize_changes(relevant_changes)
        
    def trigger_description_update(self, project_name, changes):
        # Systemtheoretische Bewertung der Änderungsrelevanz
        impact_assessment = self.assess_system_impact(changes)
        
        if impact_assessment['significance'] > self.update_threshold:
            new_description = self.generate_updated_description(
                project_name, changes, impact_assessment
            )
            self.version_and_commit_update(project_name, new_description)
            
        return impact_assessment
```

### **Intelligente Versionierung**
```bash
# Automatische Git-Integration
function update_project_description() {
    local project_name=$1
    local changes_detected=$2
    
    # Semantic Versioning für Projektbeschreibungen
    if [[ $changes_detected == "major" ]]; then
        version_increment="major"  # Fundamentale Änderungen
    elif [[ $changes_detected == "minor" ]]; then
        version_increment="minor"  # Neue Materialien/Sequenzen
    else
        version_increment="patch"  # Kleine Updates/Korrekturen
    fi
    
    # DiSoAn-konforme Commit-Messages
    git add "project_descriptions/${project_name}_description.md"
    git commit -m "feat(${project_name}): auto-update project orientation [${version_increment}]"
    git tag "v${new_version}-${project_name}"
}
```

## 📊 **PROJEKT-MONITORING UND QUALITÄTSSICHERUNG**

### **Key Performance Indicators für Orientierungsqualität**
```yaml
ORIENTIERUNG_QUALITY_METRICS:
  Accuracy: "Übereinstimmung mit tatsächlichem Repository-Zustand"
  Completeness: "Vollständigkeit aller relevanten Projektaspekte"  
  Timeliness: "Aktualität der Informationen"
  Usability: "Praktische Nutzbarkeit für Chat-Orientierung"
  
SELBSTLERN_METRIKEN:
  Update_Frequency: "Häufigkeit automatischer Aktualisierungen"
  Change_Detection_Accuracy: "Genauigkeit der Relevanz-Erkennung"
  User_Satisfaction: "Feedback zur Orientierungsqualität"
  System_Evolution: "Verbesserung der Beschreibungsqualität über Zeit"
```

### **Continuous Quality Improvement**
```python
def quality_assurance_loop():
    for project in active_projects:
        # Orientierungsqualität messen
        quality_metrics = assess_orientation_quality(project)
        
        # Verbesserungspotentiale identifizieren
        improvement_areas = identify_optimization_opportunities(quality_metrics)
        
        # Template-Evolution implementieren
        evolve_project_templates(improvement_areas)
        
        # System-Learning dokumentieren
        document_quality_evolution(project, quality_metrics, improvement_areas)
        
        # Repository-Integration
        commit_quality_improvements(project)
```

## 🎪 **PRAKTISCHE IMPLEMENTIERUNG**

### **Schritt 1: Projekt-Analyse-Engine**
```python
# Repository-Scanning für aktuellen Projektstand
def analyze_project_GPG5():
    return {
        'materialien': scan_directory('/Users/paulad/snflsknfkldnfs.github.io/unterricht/GPG5*'),
        'sequenzen': find_files('sequenz*', 'GPG5'),
        'bewertung': locate_assessment_files('GPG5'),
        'digital': identify_digital_resources('GPG5'),
        'stakeholder': get_stakeholder_connections('GPG'),
        'letzte_updates': git_log('--since=1.week.ago', 'unterricht/GPG5*')
    }
```

### **Schritt 2: Template-Instanziierung**
```python
def generate_GPG5_description():
    project_data = analyze_project_GPG5()
    
    template = load_template('GPG_template.md')
    
    description = template.format(
        jahrgangsstufe=5,
        entwicklungsphase=get_development_phase(5),
        schwerpunkt=get_focus_area(5),
        aktuelle_lernbereiche=project_data['lernbereiche'],
        materialien_übersicht=format_materials(project_data['materialien']),
        sequenzen_status=format_sequences(project_data['sequenzen']),
        stakeholder_connections=format_stakeholders(project_data['stakeholder']),
        feedback_loops=analyze_feedback_loops(project_data),
        blind_spots=identify_blind_spots(project_data),
        emergent_properties=recognize_emergence(project_data),
        last_update=datetime.now().isoformat(),
        version=get_current_version()
    )
    
    return description
```

### **Schritt 3: Claude-Desktop-Integration**
```markdown
# Automatische Claude-Project-Beschreibung für GPG5

📍 **SOFORTIGE ORIENTIERUNG FÜR CLAUDE-CHAT**

Sie arbeiten mit **GPG Jahrgangsstufe 5** an der Auen Mittelschule Schweinfurt.

## 🎯 **AKTUELLER KONTEXT** (Auto-Update: 2025-07-08T14:30:00)

### **DiSoAn-Standards aktiviert:**
✅ Systemtheoretische Perspektive (Luhmann)  
✅ Teilrationalitäten-Balance (Pädagogisch-Rechtlich-Wissenschaftlich-Technisch)
✅ Stakeholder-Integration (Erweiterte Mittelschul-Digitalisierung)
✅ Selbstlernende Optimierung aktiv

### **Verfügbare Ressourcen:**
- **Aktuelle Unterrichtssequenz**: Antikes Griechenland (LB4.2)
- **Digitale Integration**: iPads verfügbar, Miro-Boards, interaktive Materialien
- **Bewertungssystem**: Kompetenzorientierte Leistungsanalyse nach DiSoAn-Standards
- **Stakeholder**: Schulleitung, Eltern, externe Partner (Museen, etc.)

### **Systemtheoretische Reflexion:**
- **Rückkopplungseffekte**: Schülerengagement → Methodenwahl → Lernerfolg
- **Blinde Flecken**: Möglicherweise unterschätzte Heterogenität in Lerngruppe
- **Emergente Eigenschaften**: Fächerübergreifende Projektarbeit entwickelt sich

**🚀 Bereit für optimale systemtheoretische GPG5-Unterstützung!**
```

## 🔧 **AUTOMATISIERUNGS-WORKFLOW**

### **Implementation-Pipeline**
```bash
#!/bin/bash
# DiSoAn Projekt-Orientierung Auto-Update

# 1. Repository-Änderungen detektieren
git fetch origin
changes=$(git diff HEAD origin/main --name-only)

# 2. Projektrelevante Änderungen filtern
for project in GPG5 GPG6 WiB5 WiB6 M5 M6 E5 E6; do
    relevant_changes=$(echo "$changes" | grep -E "(unterricht/${project}|notizen/${project:0:3})")
    
    if [[ -n "$relevant_changes" ]]; then
        echo "Updating orientation for $project due to changes: $relevant_changes"
        
        # 3. Neue Projektbeschreibung generieren
        python3 scripts/generate_project_description.py "$project"
        
        # 4. Qualität validieren
        quality_score=$(python3 scripts/validate_description_quality.py "$project")
        
        if [[ $quality_score -gt 80 ]]; then
            # 5. Versionieren und committen
            git add "project_descriptions/${project}_description.md"
            git commit -m "feat($project): auto-update project orientation v$(date +%Y%m%d%H%M)"
            
            echo "✅ $project orientation updated successfully"
        else
            echo "⚠️ $project orientation quality below threshold ($quality_score)"
        fi
    fi
done

# 6. System-Learning dokumentieren
python3 scripts/document_system_evolution.py
```

---

**🎯 STATUS**: Framework für intelligente Projekt-Orientierung vollständig konzipiert  
**🔄 SELBSTLERNEND**: Automatische Updates basierend auf Repository-Entwicklung  
**🏗️ SYSTEMTHEORETISCH**: Luhmannsche Beobachtung 2. Ordnung integriert  
**⚡ READY-TO-IMPLEMENT**: Sofort umsetzbare Automatisierungs-Pipeline
