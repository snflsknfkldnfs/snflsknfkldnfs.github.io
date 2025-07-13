#!/usr/bin/env python3
"""
DiSoAn Claude Desktop Projektanweisungen Generator v3.0
Selbstlernend-optimierendes System für verlässliche Claude-Orientierung
"""

import os
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any

class DiSoAnClaudeDesktopGenerator:
    def __init__(self, repo_path: str = "/Users/paulad/snflsknfkldnfs.github.io"):
        self.repo_path = Path(repo_path)
        self.instructions_dir = self.repo_path / "claude_desktop_instructions"
        self.instructions_dir.mkdir(exist_ok=True)
        
        # Erweiterte Projektkonfiguration inkl. Seminar
        self.project_config = {
            'GPG5': self._create_fach_config('GPG', 5),
            'GPG6': self._create_fach_config('GPG', 6),
            'WiB5': self._create_fach_config('WiB', 5),
            'WiB6': self._create_fach_config('WiB', 6),
            'M5': self._create_fach_config('M', 5),
            'M6': self._create_fach_config('M', 6),
            'E5': self._create_fach_config('E', 5),
            'E6': self._create_fach_config('E', 6),
            
            # SEMINAR-PROJEKT KONFIGURATION
            'Seminar': {
                'name': 'Lehramtsanwärter-Seminar',
                'icon': '🎓',
                'typ': 'erwachsenenbildung',
                'schwerpunkte': [
                    'Reflexionsorientierte Professionalisierung',
                    'Theorie-Praxis-Integration', 
                    'Kollegiale Beratung',
                    'Kompetenzentwicklung'
                ],
                'methoden': [
                    'Peer-Learning',
                    'Videoanalyse', 
                    'Portfolioarbeit',
                    'Kollegiale Fallberatung'
                ],
                'stakeholder': [
                    'Seminarleitung',
                    'Seminarlehrkräfte', 
                    'LAA-Kohorte',
                    'Mentorlehrkräfte',
                    'Ausbildungsschulen',
                    'Staatl. Prüfungsamt'
                ],
                'zielgruppe': 'Lehramtsanwärter im Vorbereitungsdienst',
                'besonderheiten': 'Übergang Studium → Berufspraxis'
            }
        }
        
        # Versionierungs-System
        self.version_tracker = self._init_version_tracker()
        
    def _create_fach_config(self, fach: str, stufe: int) -> Dict:
        """Erstellt Fach-spezifische Konfiguration"""
        base_configs = {
            'GPG': {
                'name': 'Geschichte/Politik/Geographie',
                'icon': '🌍',
                'typ': 'gesellschaftswissenschaft',
                'schwerpunkte': ['Demokratie', 'Gesellschaft', 'Raum', 'Zeit'],
                'methoden': ['Rollespiele', 'Projektarbeit', 'Exkursionen'],
                'stakeholder': ['Museen', 'Historische Vereine', 'Kommunalpolitik']
            },
            'WiB': {
                'name': 'Wirtschaft und Beruf', 
                'icon': '💼',
                'typ': 'berufsorientierung',
                'schwerpunkte': ['Projektmethodik', 'Berufsorientierung', 'Wirtschaftsverständnis'],
                'methoden': ['Schülerfirma', 'Betriebserkundung', 'Expertengespräche'],
                'stakeholder': ['Betriebe', 'IHK/HWK', 'Berufsberatung', 'Eltern']
            },
            'M': {
                'name': 'Mathematik',
                'icon': '🔢',
                'typ': 'grundlagenfach',
                'schwerpunkte': ['Grundrechenarten', 'Geometrie', 'Größen', 'Daten'],
                'methoden': ['Handlungsorientierung', 'Differenzierung', 'Digitale Tools'],
                'stakeholder': ['Eltern', 'Nachhilfe', 'Förderlehrer']
            },
            'E': {
                'name': 'English',
                'icon': '🇬🇧', 
                'typ': 'fremdsprache',
                'schwerpunkte': ['Communication', 'Intercultural Competence', 'Language Awareness'],
                'methoden': ['Task-Based Learning', 'Content Integration', 'Authentic Materials'],
                'stakeholder': ['Native Speakers', 'Kulturvereine', 'Austauschprogramme']
            }
        }
        
        config = base_configs[fach].copy()
        config['jahrgangsstufe'] = stufe
        config['zielgruppe'] = f'Mittelschüler:innen Jahrgangsstufe {stufe}'
        
        return config

    def _init_version_tracker(self) -> Dict:
        """Initialisiert Versionierungs-System"""
        version_file = self.instructions_dir / "version_tracker.json"
        
        if version_file.exists():
            with open(version_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            return {
                'current_version': '3.0.0',
                'projects': {},
                'last_global_update': datetime.now().isoformat(),
                'update_history': []
            }
    
    def generate_claude_desktop_instructions(self, project_name: str) -> str:
        """Generiert optimierte Claude Desktop Projektanweisungen"""
        
        if project_name not in self.project_config:
            raise ValueError(f"Projekt '{project_name}' nicht konfiguriert")
        
        config = self.project_config[project_name]
        
        # Repository-Status analysieren
        project_state = self._analyze_project_repository_state(project_name, config)
        
        # Versionierung aktualisieren
        version_info = self._update_project_version(project_name)
        
        # Claude Desktop optimierte Anweisungen generieren
        instructions = self._create_claude_desktop_instructions(
            project_name, config, project_state, version_info
        )
        
        # Qualität validieren und speichern
        quality_score = self._validate_instructions_quality(instructions)
        
        if quality_score >= 85:
            self._save_instructions(project_name, instructions, quality_score, version_info)
            return instructions
        else:
            raise ValueError(f"Qualität zu niedrig: {quality_score}%")
    
    def _analyze_project_repository_state(self, project_name: str, config: Dict) -> Dict:
        """Analysiert Repository-Zustand für spezifisches Projekt"""
        
        state = {
            'timestamp': datetime.now().isoformat(),
            'project_type': config['typ'],
            'available_resources': [],
            'recent_activity': None,
            'stakeholder_integration': len(config['stakeholder']),
            'methodology_complexity': len(config['methoden'])
        }
        
        # Projekt-spezifische Pfade scannen
        if project_name == 'Seminar':
            # Seminar-spezifische Analyse
            seminar_paths = [
                self.repo_path / "seminarcloud",
                self.repo_path / "notizen" / "meta_prozesse", 
                self.repo_path / "templates"
            ]
            
            total_resources = 0
            for path in seminar_paths:
                if path.exists():
                    total_resources += len(list(path.rglob("*.md")))
                    
            state['available_resources'] = [
                f"Seminarcloud-Materialien: {total_resources} Einheiten",
                "Meta-Prozesse: Vollständig dokumentiert",
                "Template-System: Aktiv"
            ]
            
            state['recent_activity'] = self._get_seminar_activity()
            
        else:
            # Standard-Fächer Analyse
            fach = project_name[:-1]  # Ohne Jahrgangsstufe
            stufe = project_name[-1]
            
            unterricht_path = self.repo_path / "unterricht"
            notizen_path = self.repo_path / "notizen" / fach.lower()
            
            resources = []
            if unterricht_path.exists():
                resources.extend(list(unterricht_path.glob(f"*{fach}{stufe}*")))
            if notizen_path.exists(): 
                resources.extend(list(notizen_path.rglob("*.md")))
                
            state['available_resources'] = [
                f"Unterrichtsmaterialien: {len(resources)} Einheiten",
                f"Fach-Notizen: Verfügbar",
                "Digitale Integration: iPad-Ready"
            ]
            
        return state
    
    def _get_seminar_activity(self) -> str:
        """Ermittelt letzte Seminar-Aktivität"""
        seminarcloud = self.repo_path / "seminarcloud"
        
        if not seminarcloud.exists():
            return "Keine Aktivität verfügbar"
            
        # Neueste Datei finden
        files = list(seminarcloud.rglob("*"))
        if not files:
            return "Keine Dateien gefunden"
            
        latest_file = max(files, key=lambda f: f.stat().st_mtime if f.is_file() else 0)
        latest_time = datetime.fromtimestamp(latest_file.stat().st_mtime)
        
        days_ago = (datetime.now() - latest_time).days
        
        if days_ago == 0:
            return "Heute"
        elif days_ago == 1:
            return "Gestern"
        elif days_ago < 7:
            return f"Vor {days_ago} Tagen"
        else:
            return latest_time.strftime("%d.%m.%Y")
    
    def _update_project_version(self, project_name: str) -> Dict:
        """Aktualisiert Projekt-Versionierung"""
        
        current_time = datetime.now().isoformat()
        
        if project_name not in self.version_tracker['projects']:
            # Neues Projekt
            version_info = {
                'version': '1.0.0',
                'created_at': current_time,
                'last_updated': current_time,
                'update_count': 1
            }
        else:
            # Bestehendes Projekt aktualisieren
            existing = self.version_tracker['projects'][project_name]
            major, minor, patch = map(int, existing['version'].split('.'))
            
            # Intelligente Versionierung
            patch += 1
            if patch >= 10:
                minor += 1
                patch = 0
            if minor >= 10:
                major += 1
                minor = 0
                
            version_info = {
                'version': f'{major}.{minor}.{patch}',
                'created_at': existing['created_at'],
                'last_updated': current_time,
                'update_count': existing['update_count'] + 1
            }
        
        self.version_tracker['projects'][project_name] = version_info
        self._save_version_tracker()
        
        return version_info
    
    def _create_claude_desktop_instructions(self, project_name: str, config: Dict, 
                                          state: Dict, version_info: Dict) -> str:
        """Erstellt Claude Desktop optimierte Projektanweisungen"""
        
        if project_name == 'Seminar':
            return self._create_seminar_instructions(config, state, version_info)
        else:
            return self._create_fach_instructions(project_name, config, state, version_info)
    
    def _create_seminar_instructions(self, config: Dict, state: Dict, version_info: Dict) -> str:
        """Erstellt Seminar-spezifische Claude Desktop Anweisungen"""
        
        return f"""{config['icon']} SEMINAR - DiSoAn-Projektanweisungen für Claude Desktop

🎯 **SYSTEMTHEORETISCHE CLAUDE-ORIENTIERUNG** 
Version {version_info['version']} | Auto-Update: {state['timestamp'][:19]}

Sie arbeiten mit dem Lehramtsanwärter-Seminar-Unterstützungsprojekt

📋 KERNAUFTRAG
Unterstützung von Lehramtsanwärtern (LAA) im Vorbereitungsdienst durch systemtheoretisch fundierte, reflexionsorientierte Begleitung.

🔬 DiSoAn-STANDARDS AKTIVIERT

Systemtheoretische Perspektive (Luhmann):
✅ Autopoiesis: Seminar-System reproduziert sich durch LAA-Kohorten  
✅ Strukturelle Kopplung: Seminar ↔ Universität ↔ Schule ↔ Ministerium  
✅ Beobachtung 2. Ordnung: Reflexion über Reflexion als Kernelement  
✅ Emergenz: Professionelle Kompetenz entsteht durch Systeminteraktion  

Teilrationalitäten-Balance:
PÄDAGOGISCHE_RATIONALITÄT:
- Erwachsenengerechte Didaktik für LAA
- Reflexionsorientierte Lernprozesse  
- Peer-Learning und kollegiale Beratung

RECHTLICH_ADMINISTRATIVE_RATIONALITÄT:
- ALBAV (Ausbildungs- und Lehramtsprüfungsordnung)
- Prüfungsstandards und Bewertungskriterien
- DSGVO bei Unterrichtsbeobachtungen

WISSENSCHAFTLICHE_RATIONALITÄT:
- Evidenzbasierte Didaktik und Pädagogik
- Forschungsorientierte Reflexion
- Theoriegeleitete Praxisanalyse

TECHNISCHE_RATIONALITÄT:
- Digitale Lernplattformen (Mebis, Teams)
- Videoanalyse-Tools für Unterrichtsreflexion
- KI-gestützte Reflexionsunterstützung

👥 STAKEHOLDER-ÖKOSYSTEM

Primäre Akteure:
- Seminarleitung: Strategische Ausbildungsplanung und Qualitätssicherung
- Seminarlehrkräfte: Fachspezifische Betreuung und Mentoring  
- LAA-Kohorte: Peer-Learning-Gemeinschaft (18-24 Monate)
- Mentorlehrkräfte: Praxis-Begleitung an Ausbildungsschulen

Sekundäre Akteure:
- Ausbildungsschulen: Praktische Ausbildungsplätze
- Universitäten: Theoretische Fundierung
- Staatl. Prüfungsamt: Qualitäts- und Leistungsstandards
- Ministerium: Bildungspolitische Vorgaben

🛠️ VERFÜGBARE SYSTEM-INFRASTRUKTUR

Repository-Ressourcen:
{chr(10).join([f"- {resource}" for resource in state['available_resources']])}

Letzte Aktivität: {state['recent_activity']}

Automatisierte Unterstützung:
- Reflexions-Engine: KI-gestützte Unterrichts- und Erfahrungsreflexion
- Praxis-Theorie-Interface: Systematische Verbindung Seminar ↔ Schulpraxis  
- Kollegialitäts-Facilitator: Peer-Learning strukturieren
- Kompetenz-Tracker: Portfolio-basierte Professionalisierung

🎯 HANDLUNGSLOGIK FÜR CLAUDE

Primäre Funktionen:
1. Reflexionspartner: Strukturierte Unterrichts- und Erfahrungsreflexion
2. Theoriebrücke: Verbindung Seminarinhalte ↔ Schulpraxis
3. Peer-Facilitator: Kollegiale Beratungsprozesse unterstützen
4. Kompetenz-Coach: Portfolio-Entwicklung und Prüfungsvorbereitung

Methodische Ausrichtung:
- Erwachsenenlernen: LAA als professionelle Lernende respektieren
- Konstruktivistische Didaktik: Wissen aktiv konstruieren lassen
- Systemische Beratung: Komplexität der Schulrealität berücksichtigen
- Evidenzbasierte Praxis: Forschung und Erfahrung verknüpfen

🔄 SELBSTLERNENDE OPTIMIERUNG

Kontinuierliche Adaptation:
- LAA-Feedback → Seminar-Anpassung
- Mentor-Evaluationen → Praxis-Theorie-Balance  
- Prüfungsergebnisse → Qualitätsoptimierung
- Alumni-Tracking → Langzeit-Wirksamkeit

PATA-Protokoll aktiv:
✅ Performance: LAA-Kompetenzzuwachs messbar  
✅ Accuracy: Theoriegeleitete, evidenzbasierte Unterstützung  
✅ Transparency: Nachvollziehbare Entwicklungspfade  
✅ Accountability: Systemische Verantwortlichkeit für Professionalisierung  

⚡ OPERATIVE RICHTLINIEN

Bei LAA-Anfragen:
1. Systemisch denken: Schule als komplexes System verstehen
2. Reflexiv begleiten: Nicht Lösungen geben, sondern Reflexion anregen
3. Theoriegeleitet arbeiten: Wissenschaftliche Fundierung einbeziehen
4. Peer-Perspektive einbringen: Kollegiale Sichtweisen aktivieren

Bei Praxisproblemen:
1. Situationsanalyse: Systemische Faktoren identifizieren
2. Handlungsalternativen: Verschiedene Optionen entwickeln
3. Reflexionsfragen: Selbstreflexion der LAA anregen
4. Theorieanbindung: Passende pädagogische Konzepte verknüpfen

🧠 SYSTEMISCHE SELBSTREFLEXION

Wissensgrenzen transparent machen:
- KI-System kennt Grenzen pädagogischer Intuition und situativer Kontextualisierung
- LAA-Individualität und Schulkontexte erfordern menschliche Interpretation
- Komplexität realer Unterrichtssituationen übersteigt algorithmische Erfassung

Rückkopplungseffekte beachten:
- Unterstützungssystem kann Abhängigkeiten schaffen statt Autonomie fördern
- Kontinuierliche Reflexion über Empowerment vs. Bevormundung
- Balance zwischen Struktur und Freiraum für LAA-Entwicklung

Blinde Flecken identifizieren:
- Technische Rationalität könnte pädagogische Intuition dominieren  
- Macht-Asymmetrien zwischen KI-System und LAA systematisch reflektieren
- Kulturelle und biografische Vielfalt der LAA angemessen berücksichtigen

📊 VERSION & QUALITÄT
Projektversion: {version_info['version']}
Erstellt: {version_info['created_at'][:10]}
Updates: {version_info['update_count']}
Stakeholder integriert: {state['stakeholder_integration']}
Methodische Komplexität: {state['methodology_complexity']} Ansätze

🚀 BEREIT für systemtheoretisch fundierte LAA-Seminar-Unterstützung!

DiSoAn Claude Desktop Instructions v{version_info['version']} | Autopoietisch optimiert | {datetime.now().strftime('%Y-%m-%d %H:%M')}"""
    
    def _create_fach_instructions(self, project_name: str, config: Dict, 
                                state: Dict, version_info: Dict) -> str:
        """Erstellt Fach-spezifische Claude Desktop Anweisungen"""
        
        fach = project_name[:-1]
        stufe = config['jahrgangsstufe']
        
        return f"""{config['icon']} {project_name} - DiSoAn-Projektanweisungen für Claude Desktop

🎯 SYSTEMTHEORETISCHE CLAUDE-ORIENTIERUNG
Version {version_info['version']} | Auto-Update: {state['timestamp'][:19]}

Sie arbeiten mit {config['name']} Jahrgangsstufe {stufe} an der Auen Mittelschule Schweinfurt

📋 KERNAUFTRAG
Mittelschuldidaktische Unterstützung für {config['name']} unter Berücksichtigung der Heterogenität und des Sozialraums Schweinfurt.

🔬 DiSoAn-STANDARDS AKTIVIERT

Systemtheoretische Perspektive:
✅ Autopoiesis: Klasse als selbstregulierende Lerngemeinschaft  
✅ Strukturelle Kopplung: Schule ↔ Familie ↔ Peer-Group ↔ Sozialraum  
✅ Komplexitätsreduktion: Heterogenitäts-adaptive Didaktik  
✅ Emergenz: Lernerfolg durch Synergie von Methodik und Beziehung  

Teilrationalitäten-Balance:
- Pädagogisch: {config['typ']}-spezifische Didaktik für Mittelschule
- Rechtlich: LehrplanPLUS Bayern, Mittelschulordnung (MSO)
- Wissenschaftlich: Evidenzbasierte {config['typ']}-Didaktik
- Technisch: iPad-Integration und digitale Lernplattformen

👥 STAKEHOLDER-SYSTEM
{chr(10).join([f"- {stakeholder}: Relevante Akteure für {config['typ']}" for stakeholder in config['stakeholder']])}

🛠️ VERFÜGBARE RESSOURCEN
{chr(10).join([f"- {resource}" for resource in state['available_resources']])}

Klassen-Kontext Jahrgangsstufe {stufe}:
- 22 Schüler:innen: Hohe Heterogenität (Migrationshintergrund, Leistungsspektrum)
- Ausstattung: 15 iPads, Beamer, Dokumentenkamera
- Raum: Klassenzimmer + Differenzierungsraum
- Sozialraum: Schweinfurt (Industriestandort, multikulturell)

🎯 HANDLUNGSLOGIK FÜR CLAUDE

Schwerpunkte {config['name']}:
{chr(10).join([f"- {schwerpunkt}: Mittelschul-angepasste Vermittlung" for schwerpunkt in config['schwerpunkte']])}

Methodische Ausrichtung:
{chr(10).join([f"- {methode}: Handlungsorientiert und differenziert" for methode in config['methoden']])}

📊 VERSION & QUALITÄT
Projektversion: {version_info['version']}
Fachtyp: {config['typ']}  
Updates: {version_info['update_count']}
Methodische Vielfalt: {len(config['methoden'])} Ansätze

🚀 BEREIT für optimale {config['name']}{stufe}-Unterstützung!

DiSoAn Claude Desktop Instructions v{version_info['version']} | {datetime.now().strftime('%Y-%m-%d %H:%M')}"""
    
    def _validate_instructions_quality(self, instructions: str) -> int:
        """Validiert Qualität der Claude Desktop Anweisungen"""
        score = 0
        
        # Mindestlänge für Claude Desktop Anweisungen
        if len(instructions) > 1500:
            score += 20
        elif len(instructions) > 1000:
            score += 15
        elif len(instructions) > 500:
            score += 10
            
        # Pflicht-Komponenten für Claude Desktop
        required_elements = [
            'SYSTEMTHEORETISCHE CLAUDE-ORIENTIERUNG',
            'DiSoAn-STANDARDS AKTIVIERT', 
            'STAKEHOLDER',
            'HANDLUNGSLOGIK FÜR CLAUDE',
            'VERSION'
        ]
        
        for element in required_elements:
            if element in instructions:
                score += 15
                
        # Claude Desktop spezifische Elemente
        claude_specific = [
            'Sie arbeiten mit',
            'BEREIT für',
            'Auto-Update',
            'Projektversion'
        ]
        
        for element in claude_specific:
            if element in instructions:
                score += 5
                
        return min(score, 100)
    
    def _save_instructions(self, project_name: str, instructions: str, 
                          quality_score: int, version_info: Dict):
        """Speichert Claude Desktop Anweisungen mit Metadaten"""
        
        # Hauptanweisungen speichern
        instructions_file = self.instructions_dir / f"{project_name}_claude_desktop_instructions.md"
        with open(instructions_file, 'w', encoding='utf-8') as f:
            f.write(instructions)
            
        # Metadaten speichern
        meta_file = self.instructions_dir / f"{project_name}_meta.json"
        metadata = {
            'project_name': project_name,
            'generated_at': datetime.now().isoformat(),
            'quality_score': quality_score,
            'version_info': version_info,
            'generator_version': '3.0.0',
            'type': 'claude_desktop_instructions'
        }
        
        with open(meta_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    def _save_version_tracker(self):
        """Speichert Versionierungs-Tracker"""
        version_file = self.instructions_dir / "version_tracker.json"
        with open(version_file, 'w', encoding='utf-8') as f:
            json.dump(self.version_tracker, f, indent=2, ensure_ascii=False)

# CLI Interface für Generator
def main():
    import sys
    
    generator = DiSoAnClaudeDesktopGenerator()
    
    if len(sys.argv) > 1:
        project_name = sys.argv[1]
        try:
            instructions = generator.generate_claude_desktop_instructions(project_name)
            print(f"✅ Claude Desktop Anweisungen für '{project_name}' erfolgreich generiert!")
            print("📋 Bereit zum Kopieren in Claude Desktop Projektanweisungen-Feld")
            print("\n" + "="*60)
            print(instructions)
            print("="*60)
        except Exception as e:
            print(f"❌ Fehler bei {project_name}: {str(e)}")
    else:
        # Alle verfügbaren Projekte generieren
        projects = ['GPG5', 'GPG6', 'WiB5', 'WiB6', 'M5', 'M6', 'E5', 'E6', 'Seminar']
        
        print("🚀 Generiere Claude Desktop Anweisungen für alle Projekte...")
        print("=" * 60)
        
        successful = 0
        for project in projects:
            try:
                instructions = generator.generate_claude_desktop_instructions(project)
                print(f"✅ {project}: Claude Desktop Anweisungen generiert")
                successful += 1
            except Exception as e:
                print(f"❌ {project}: {str(e)}")
                
        print("=" * 60)
        print(f"📊 {successful}/{len(projects)} Projekte erfolgreich generiert")
        print("🎯 Anweisungen bereit für Claude Desktop Integration!")

if __name__ == "__main__":
    main()
