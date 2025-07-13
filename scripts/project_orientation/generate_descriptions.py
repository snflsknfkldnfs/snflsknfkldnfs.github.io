#!/usr/bin/env python3
"""
DiSoAn Projekt-Orientierung Generator
Generiert intelligente Projektbeschreibungen für Claude-Desktop-Projekte
"""

import os
import re
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any

class DiSoAnProjectOrientationGenerator:
    def __init__(self, repo_path: str = "/Users/paulad/snflsknfkldnfs.github.io"):
        self.repo_path = Path(repo_path)
        self.project_descriptions_dir = self.repo_path / "project_descriptions"
        self.project_descriptions_dir.mkdir(exist_ok=True)
        
        # Fach-spezifische Konfiguration
        self.fach_config = {
            'GPG': {
                'name': 'Geschichte/Politik/Geographie',
                'icon': '🌍',
                'schwerpunkte': ['Demokratie', 'Gesellschaft', 'Raum', 'Zeit'],
                'methoden': ['Rollespiele', 'Projektarbeit', 'Exkursionen'],
                'stakeholder': ['Museen', 'Historische Vereine', 'Kommunalpolitik']
            },
            'WIB': {
                'name': 'Wirtschaft und Beruf',
                'icon': '💼', 
                'schwerpunkte': ['Projektmethodik', 'Berufsorientierung', 'Wirtschaftsverständnis'],
                'methoden': ['Schülerfirma', 'Betriebserkundung', 'Expertengespräche'],
                'stakeholder': ['Betriebe', 'IHK/HWK', 'Berufsberatung', 'Eltern']
            },
            'M': {
                'name': 'Mathematik',
                'icon': '🔢',
                'schwerpunkte': ['Grundrechenarten', 'Geometrie', 'Größen', 'Daten'],
                'methoden': ['Handlungsorientierung', 'Differenzierung', 'Digitale Tools'],
                'stakeholder': ['Eltern', 'Nachhilfe', 'Förderlehrer']
            },
            'E': {
                'name': 'English',
                'icon': '🇬🇧',
                'schwerpunkte': ['Communication', 'Intercultural Competence', 'Language Awareness'],
                'methoden': ['Task-Based Learning', 'Content Integration', 'Authentic Materials'],
                'stakeholder': ['Native Speakers', 'Kulturvereine', 'Austauschprogramme']
            }
        }
        
        # Jahrgangsstufen-spezifische Entwicklungsphasen
        self.jahrgangsstufen_config = {
            5: {'phase': 'Übergang Grundschule', 'schwerpunkt': 'Orientierung', 'besonderheiten': 'Neue Lernumgebung'},
            6: {'phase': 'Konsolidierung', 'schwerpunkt': 'Grundlagen', 'besonderheiten': 'Routine entwickeln'},
            7: {'phase': 'Differenzierung', 'schwerpunkt': 'Vertiefung', 'besonderheiten': 'Pubertät beginnt'},
            8: {'phase': 'Berufsorientierung', 'schwerpunkt': 'Anwendung', 'besonderheiten': 'Praktika möglich'},
            9: {'phase': 'Abschlussorientierung', 'schwerpunkt': 'Prüfungsvorbereitung', 'besonderheiten': 'QA-Fokus'},
            10: {'phase': 'Übergang Beruf', 'schwerpunkt': 'Spezialisierung', 'besonderheiten': 'M10-Abschluss'}
        }

    def generate_project_description(self, project_name: str) -> bool:
        """Generiert Projektbeschreibung für gegebenes Projekt"""
        
        try:
            # Projekt parsen
            fach, jahrgangsstufe = self.parse_project_name(project_name)
            
            # Repository-Status analysieren
            project_state = self.analyze_project_state(fach, jahrgangsstufe)
            
            # Beschreibung generieren
            description = self.create_description(fach, jahrgangsstufe, project_state)
            
            # Qualität validieren
            quality_score = self.validate_quality(description)
            
            if quality_score >= 80:
                # Speichern
                self.save_description(project_name, description, quality_score)
                print(f"✅ {project_name}: Beschreibung erfolgreich generiert (Qualität: {quality_score}%)")
                return True
            else:
                print(f"⚠️ {project_name}: Qualität zu niedrig ({quality_score}%)")
                return False
                
        except Exception as e:
            print(f"❌ Fehler bei {project_name}: {str(e)}")
            return False

    def parse_project_name(self, project_name: str) -> tuple:
        """Extrahiert Fach und Jahrgangsstufe aus Projektname"""
        
        match = re.match(r'([A-Z]+)(\d+)', project_name.upper())
        if not match:
            raise ValueError(f"Ungültiger Projektname: {project_name}")
            
        fach = match.group(1)
        jahrgangsstufe = int(match.group(2))
        
        if fach not in self.fach_config:
            raise ValueError(f"Unbekanntes Fach: {fach}")
            
        if jahrgangsstufe not in self.jahrgangsstufen_config:
            raise ValueError(f"Ungültige Jahrgangsstufe: {jahrgangsstufe}")
            
        return fach, jahrgangsstufe

    def analyze_project_state(self, fach: str, jahrgangsstufe: int) -> Dict[str, Any]:
        """Analysiert aktuellen Zustand des Projekts im Repository"""
        
        # Relevante Pfade scannen
        unterricht_paths = list(self.repo_path.glob(f"unterricht/*{fach}{jahrgangsstufe}*"))
        notizen_paths = list(self.repo_path.glob(f"notizen/{fach}/*"))
        
        # Materialien kategorisieren
        materialien = self.categorize_materials(unterricht_paths + notizen_paths)
        
        # Aktuelle Sequenzen identifizieren
        sequenzen = self.identify_sequences(materialien)
        
        # Digitale Ressourcen finden
        digitale_resources = self.find_digital_resources_from_materials(materialien)
        
        return {
            'timestamp': datetime.now().isoformat(),
            'materialien_count': len(materialien),
            'sequenzen': sequenzen,
            'digitale_resources': digitale_resources,
            'letzte_aktivität': self.get_last_activity(unterricht_paths + notizen_paths),
            'verfügbare_tools': self.detect_available_tools(materialien)
        }

    def find_digital_resources_from_materials(self, materialien: Dict[str, List[str]]) -> List[str]:
        """Findet digitale Ressourcen aus kategorisierten Materialien"""
        digital_resources = []
        
        # Aus digitale_medien Kategorie
        for resource in materialien.get('digitale_medien', []):
            if 'miro' in resource.lower():
                digital_resources.append('Miro-Boards')
            elif '.html' in resource:
                digital_resources.append('Interaktive Web-Tools')
            elif '.mp4' in resource or 'video' in resource.lower():
                digital_resources.append('Video-Materialien')
                
        # Standard-Ausstattung immer verfügbar
        digital_resources.extend(['iPad-Integration', 'Beamer', 'Dokumentenkamera'])
        
        return list(set(digital_resources))  # Duplikate entfernen

    def categorize_materials(self, paths: List[Path]) -> Dict[str, List[str]]:
        """Kategorisiert gefundene Materialien"""
        
        categories = {
            'unterrichtseinheiten': [],
            'arbeitsblätter': [],
            'bewertungsbögen': [],
            'sequenzplanungen': [],
            'digitale_medien': [],
            'projekte': []
        }
        
        for path in paths:
            name_lower = path.name.lower()
            
            if 'sequenz' in name_lower or 'planung' in name_lower:
                categories['sequenzplanungen'].append(str(path.relative_to(self.repo_path)))
            elif 'arbeitsblatt' in name_lower or 'ab_' in name_lower:
                categories['arbeitsblätter'].append(str(path.relative_to(self.repo_path)))
            elif 'bewertung' in name_lower or 'leistung' in name_lower:
                categories['bewertungsbögen'].append(str(path.relative_to(self.repo_path)))
            elif path.suffix in ['.html', '.js', '.mp4', '.pdf']:
                categories['digitale_medien'].append(str(path.relative_to(self.repo_path)))
            elif 'projekt' in name_lower:
                categories['projekte'].append(str(path.relative_to(self.repo_path)))
            else:
                categories['unterrichtseinheiten'].append(str(path.relative_to(self.repo_path)))
                
        return categories

    def create_description(self, fach: str, jahrgangsstufe: int, project_state: Dict[str, Any]) -> str:
        """Erstellt die eigentliche Projektbeschreibung"""
        
        fach_info = self.fach_config[fach]
        stufe_info = self.jahrgangsstufen_config[jahrgangsstufe]
        
        # Template basierend auf Fach auswählen
        if fach == 'GPG':
            return self.create_gpg_description(fach_info, stufe_info, jahrgangsstufe, project_state)
        elif fach == 'WIB':
            return self.create_wib_description(fach_info, stufe_info, jahrgangsstufe, project_state)
        elif fach == 'M':
            return self.create_math_description(fach_info, stufe_info, jahrgangsstufe, project_state)
        elif fach == 'E':
            return self.create_english_description(fach_info, stufe_info, jahrgangsstufe, project_state)
        else:
            return self.create_generic_description(fach_info, stufe_info, jahrgangsstufe, project_state)

    def create_gpg_description(self, fach_info: Dict, stufe_info: Dict, jahrgangsstufe: int, state: Dict) -> str:
        """Erstellt GPG-spezifische Beschreibung"""
        
        return f"""# {fach_info['icon']} GPG{jahrgangsstufe} - Systemtheoretische Projekt-Orientierung

## 📍 **CLAUDE-CHAT-ORIENTIERUNG** (Auto-Update: {state['timestamp'][:19]})

Sie arbeiten mit **{fach_info['name']} Jahrgangsstufe {jahrgangsstufe}** an der Auen Mittelschule Schweinfurt.

### **DiSoAn-Standards aktiviert:**
✅ Systemtheoretische Perspektive nach Luhmann  
✅ Teilrationalitäten-Balance: Pädagogisch-Rechtlich-Wissenschaftlich-Technisch
✅ Stakeholder-Integration: Mittelschul-Digitalisierung 2025
✅ Selbstlernende Optimierung und PATA-Protokoll

### **Entwicklungsphase:**
**{stufe_info['phase']}** - Schwerpunkt: {stufe_info['schwerpunkt']}
- Besonderheiten: {stufe_info['besonderheiten']}
- Methodische Ausrichtung: {', '.join(fach_info['methoden'])}

### **Verfügbare Ressourcen:** (Stand: {state['timestamp'][:10]})
- **Materialien gesamt**: {state['materialien_count']} Einheiten
- **Aktuelle Sequenzen**: {len(state['sequenzen'])} verfügbar
- **Digitale Tools**: {', '.join(state['verfügbare_tools'])}
- **Letzte Aktivität**: {state['letzte_aktivität']}

### **Klassen-Kontext:**
- 22 Schüler:innen, hohe Heterogenität (Migrationshintergrund, Leistungsspektrum)
- Verfügbar: 15 iPads, Beamer, Dokumentenkamera
- Raum: Klassenzimmer + Differenzierungsraum

### **Stakeholder-Netzwerk:**
{self.format_stakeholders(fach_info['stakeholder'])}

### **Systemtheoretische Reflexion:**
- **Rückkopplungseffekte**: Engagement ↔ Methodenvielfalt ↔ Lernerfolg
- **Blinde Flecken**: Kulturelle Geschichtsverständnis-Unterschiede
- **Emergente Eigenschaften**: Spontane politische Diskussionen
- **Autopoiesis**: Selbstständige Weiterverfolgung historischer Interessen

**🚀 Bereit für optimale systemtheoretische GPG{jahrgangsstufe}-Unterstützung!**

---
*Auto-generiert durch DiSoAn-Orientierungssystem v2.0 - {datetime.now().strftime('%Y-%m-%d %H:%M')}*"""

    def create_wib_description(self, fach_info: Dict, stufe_info: Dict, jahrgangsstufe: int, state: Dict) -> str:
        """Erstellt WiB-spezifische Beschreibung"""
        
        return f"""# {fach_info['icon']} WiB{jahrgangsstufe} - Projektökonomische Orientierung

## 📊 **CLAUDE-CHAT-WIRTSCHAFTSKONTEXT** (Live-Update: {state['timestamp'][:19]})

Sie arbeiten mit **{fach_info['name']} Jahrgangsstufe {jahrgangsstufe}** an der Auen Mittelschule Schweinfurt.

### **DiSoAn-Wirtschaftsdidaktik aktiviert:**
✅ Projektmethodik als WiB-Kernelement
✅ Berufsorientierung und Lebensweltbezug
✅ Systemtheoretische Wirtschaftsbetrachtung
✅ Stakeholder-Integration: Betriebe, Berufsberatung, Eltern

### **Entwicklungsfokus:**
**{stufe_info['phase']}** - Schwerpunkt: {stufe_info['schwerpunkt']}
- {stufe_info['besonderheiten']}
- Wirtschaftsdidaktische Methoden: {', '.join(fach_info['methoden'])}

### **Verfügbare WiB-Ressourcen:**
- **Projektvorlagen**: {state['materialien_count']} Einheiten verfügbar
- **Aktuelle Zyklen**: {len(state['sequenzen'])} Projektphasen
- **Kooperationspartner**: Schweinfurter Industriestandort
- **Letzte Projektaktivität**: {state['letzte_aktivität']}

### **Berufsorientierungs-Fokus:**
- **Industrie**: SKF, ZF, Schaeffler (Schweinfurt)
- **Handel**: Lokale Geschäfte und Dienstleister
- **Soziales**: Gesundheit, Pflege, Bildung
- **Digital**: IT-Kompetenzen für alle Berufswege

### **Stakeholder-Ökonomie:**
{self.format_stakeholders(fach_info['stakeholder'])}

### **Projektmethodische Reflexion:**
- **Systemlogik**: Wirtschaft als komplexes Netzwerk
- **Lebensweltbezug**: Schülererfahrungen als Ausgangspunkt
- **Handlungsorientierung**: Learning by Doing
- **Differenzierung**: Verschiedene Zugänge für verschiedene Talente

**💡 Bereit für praxisorientierte WiB{jahrgangsstufe}-Projektunterstützung!**

---
*Auto-generiert durch DiSoAn-WiB-System v2.0 - {datetime.now().strftime('%Y-%m-%d %H:%M')}*"""

    def create_math_description(self, fach_info: Dict, stufe_info: Dict, jahrgangsstufe: int, state: Dict) -> str:
        """Erstellt Mathematik-spezifische Beschreibung"""
        
        return f"""# {fach_info['icon']} M{jahrgangsstufe} - Systemtheoretische Mathematik-Orientierung

## 📐 **CLAUDE-CHAT-MATHEMATIKKONTEXT** (Precision-Update: {state['timestamp'][:19]})

Sie arbeiten mit **{fach_info['name']} Jahrgangsstufe {jahrgangsstufe}** an der Auen Mittelschule Schweinfurt.

### **DiSoAn-Mathematikdidaktik aktiviert:**
✅ Strukturierte Heterogenitäts-Bewältigung
✅ Sprachsensible Mathematikdidaktik  
✅ Digitale Tools für Differenzierung
✅ Kompetenzorientierte Leistungsanalyse

### **Entwicklungsphase:**
**{stufe_info['phase']}** - Schwerpunkt: {stufe_info['schwerpunkt']}
- {stufe_info['besonderheiten']}
- Mathematikdidaktische Methoden: {', '.join(fach_info['methoden'])}

### **Verfügbare Mathe-Ressourcen:**
- **Materialien**: {state['materialien_count']} mathematische Einheiten
- **Aktuelle Sequenzen**: {len(state['sequenzen'])} verfügbar
- **Digitale Tools**: {', '.join(state['verfügbare_tools'])}
- **Letzte Aktivität**: {state['letzte_aktivität']}

### **Klassen-Spezifika M{jahrgangsstufe}:**
- **Heterogenität**: Von fundamentalen Defiziten bis überdurchschnittliche Leistungen
- **Sprachbarrieren**: Diskrepanz Alltags-/Fachsprache bei Migrationshintergrund
- **Motivation**: Niedriges Frustrationsniveau, strukturierte Erfolgs-Erlebnisse nötig
- **Differenzierung**: 3-Ebenen-System (Grundlagen-Sicherung-Herausforderung)

### **Stakeholder-Netzwerk:**
{self.format_stakeholders(fach_info['stakeholder'])}

### **Systemtheoretische Mathematik-Reflexion:**
- **Rückkopplung**: Erfolg → Motivation → Engagement → weiterer Erfolg
- **Komplexitätsreduktion**: Schrittweise Erschließung großer Zahlenräume
- **Emergenz**: Mathematisches Verständnis durch Mustererkennung
- **Autopoiesis**: Selbstständiges Weiterlernen als Ziel

**🎯 Bereit für strukturierte, differenzierte M{jahrgangsstufe}-Mathematikunterstützung!**

---
*Auto-generiert durch DiSoAn-Math-System v2.0 - {datetime.now().strftime('%Y-%m-%d %H:%M')}*"""

    def create_english_description(self, fach_info: Dict, stufe_info: Dict, jahrgangsstufe: int, state: Dict) -> str:
        """Erstellt English-spezifische Beschreibung"""
        
        return f"""# {fach_info['icon']} E{jahrgangsstufe} - Communicative Language Learning Orientation

## 🗣️ **CLAUDE-CHAT-ENGLISH-CONTEXT** (Language-Update: {state['timestamp'][:19]})

You're working with **{fach_info['name']} Year {jahrgangsstufe}** at Auen Mittelschule Schweinfurt.

### **DiSoAn-Language-Didactics activated:**
✅ Communicative approach with real-world contexts
✅ Multilingual awareness and intercultural competence
✅ Digital media integration for authentic language input
✅ Differentiated assessment and competence development

### **Development Phase:**
**{stufe_info['phase']}** - Focus: {stufe_info['schwerpunkt']}
- Characteristics: {stufe_info['besonderheiten']}
- Communicative Methods: {', '.join(fach_info['methoden'])}

### **Available English Resources:**
- **Materials**: {state['materialien_count']} language learning units
- **Current Sequences**: {len(state['sequenzen'])} active
- **Digital Tools**: {', '.join(state['verfügbare_tools'])}
- **Last Activity**: {state['letzte_aktivität']}

### **Class-Specific E{jahrgangsstufe} Context:**
- **Language Levels**: Mixed proficiency from beginner to intermediate
- **Multilingual Learners**: Leverage existing language competencies (German + heritage languages)
- **Motivation**: High interest in authentic English media and communication
- **Communication Focus**: Speaking confidence and intercultural understanding

### **Stakeholder Network:**
{self.format_stakeholders(fach_info['stakeholder'])}

### **Systemic Language Learning Reflection:**
- **Input-Processing-Output**: Comprehensive language acquisition model
- **Intercultural Competence**: Language as cultural bridge
- **Autonomy Development**: Self-directed learning strategies
- **Error as Learning**: Mistakes as natural part of acquisition process

**🌟 Ready for communicative, competence-oriented E{jahrgangsstufe} English support!**

---
*Auto-generated by DiSoAn-English-System v2.0 - {datetime.now().strftime('%Y-%m-%d %H:%M')}*"""

    def create_generic_description(self, fach_info: Dict, stufe_info: Dict, jahrgangsstufe: int, state: Dict) -> str:
        """Erstellt generische Beschreibung für andere Fächer"""
        
        return f"""# {fach_info['icon']} {fach_info['name']}{jahrgangsstufe} - DiSoAn-Projekt-Orientierung

## 📍 **CLAUDE-CHAT-ORIENTIERUNG** (Auto-Update: {state['timestamp'][:19]})

Sie arbeiten mit **{fach_info['name']} Jahrgangsstufe {jahrgangsstufe}** an der Auen Mittelschule Schweinfurt.

### **DiSoAn-Standards aktiviert:**
✅ Systemtheoretische Perspektive nach Luhmann  
✅ Teilrationalitäten-Balance: Pädagogisch-Rechtlich-Wissenschaftlich-Technisch
✅ Stakeholder-Integration: Mittelschul-Digitalisierung 2025
✅ Selbstlernende Optimierung und PATA-Protokoll

### **Entwicklungsphase:**
**{stufe_info['phase']}** - Schwerpunkt: {stufe_info['schwerpunkt']}
- Besonderheiten: {stufe_info['besonderheiten']}
- Fachspezifische Methoden: {', '.join(fach_info['methoden'])}

### **Verfügbare Ressourcen:**
- **Materialien**: {state['materialien_count']} Einheiten verfügbar
- **Aktuelle Sequenzen**: {len(state['sequenzen'])} aktive Bereiche
- **Digitale Integration**: {', '.join(state['verfügbare_tools'])}
- **Letzte Aktivität**: {state['letzte_aktivität']}

### **Stakeholder-Netzwerk:**
{self.format_stakeholders(fach_info['stakeholder'])}

**🚀 Bereit für optimale fachspezifische Unterstützung!**

---
*Auto-generiert durch DiSoAn-System v2.0 - {datetime.now().strftime('%Y-%m-%d %H:%M')}*"""

    def format_stakeholders(self, stakeholders: List[str]) -> str:
        """Formatiert Stakeholder-Liste"""
        return '\n'.join([f"- **{stakeholder}**: Relevante Akteure für Projektunterstützung" for stakeholder in stakeholders])

    def get_last_activity(self, paths: List[Path]) -> str:
        """Ermittelt letzte Aktivität in den Projektdateien"""
        if not paths:
            return "Keine Aktivität gefunden"
            
        latest_time = max([p.stat().st_mtime for p in paths if p.exists()])
        latest_date = datetime.fromtimestamp(latest_time)
        
        days_ago = (datetime.now() - latest_date).days
        
        if days_ago == 0:
            return "Heute"
        elif days_ago == 1:
            return "Gestern"
        elif days_ago < 7:
            return f"Vor {days_ago} Tagen"
        else:
            return latest_date.strftime("%d.%m.%Y")

    def detect_available_tools(self, materialien: Dict[str, List[str]]) -> List[str]:
        """Erkennt verfügbare digitale Tools aus Materialien"""
        tools = set()
        
        for category, files in materialien.items():
            for file_path in files:
                if 'miro' in file_path.lower():
                    tools.add('Miro-Boards')
                if 'ipad' in file_path.lower() or 'tablet' in file_path.lower():
                    tools.add('iPad-Integration')
                if '.html' in file_path:
                    tools.add('Interaktive Webtools')
                if 'video' in file_path.lower() or '.mp4' in file_path:
                    tools.add('Video-Materialien')
                    
        return list(tools) if tools else ['Standard-Ausstattung']

    def identify_sequences(self, materialien: Dict[str, List[str]]) -> List[str]:
        """Identifiziert aktuelle Unterrichtssequenzen"""
        sequences = []
        
        for seq_path in materialien.get('sequenzplanungen', []):
            seq_name = Path(seq_path).stem
            sequences.append(seq_name.replace('_', ' ').title())
            
        return sequences[:3]  # Maximal 3 aktuelle Sequenzen

    def validate_quality(self, description: str) -> int:
        """Validiert Qualität der generierten Beschreibung"""
        score = 0
        
        # Mindestlänge
        if len(description) > 800:
            score += 25
        elif len(description) > 500:
            score += 15
            
        # Pflicht-Komponenten
        required_elements = [
            'DiSoAn-Standards aktiviert',
            'Systemtheoretische',
            'Verfügbare',
            'Stakeholder',
            'Auto-generiert'
        ]
        
        for element in required_elements:
            if element in description:
                score += 12
                
        # Fach-spezifische Inhalte
        if any(term in description.lower() for term in ['jahrgangsstufe', 'schüler', 'unterricht']):
            score += 15
            
        return min(score, 100)

    def save_description(self, project_name: str, description: str, quality_score: int):
        """Speichert Beschreibung mit Metadaten"""
        
        # Hauptbeschreibung speichern
        desc_file = self.project_descriptions_dir / f"{project_name}_description.md"
        with open(desc_file, 'w', encoding='utf-8') as f:
            f.write(description)
            
        # Metadaten speichern
        meta_file = self.project_descriptions_dir / f"{project_name}_meta.json"
        metadata = {
            'project_name': project_name,
            'generated_at': datetime.now().isoformat(),
            'quality_score': quality_score,
            'version': '2.0',
            'generator': 'DiSoAn-Orientierungssystem'
        }
        
        with open(meta_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)

def main():
    """Hauptfunktion für CLI-Verwendung"""
    import sys
    
    generator = DiSoAnProjectOrientationGenerator()
    
    if len(sys.argv) > 1:
        # Einzelnes Projekt
        project_name = sys.argv[1].upper()
        success = generator.generate_project_description(project_name)
        sys.exit(0 if success else 1)
    else:
        # Alle Standard-Projekte
        projects = ['GPG5', 'GPG6', 'WiB5', 'WiB6', 'M5', 'M6', 'E5', 'E6']
        
        print("🚀 Generiere DiSoAn-Projektbeschreibungen...")
        print("=" * 50)
        
        successful = 0
        for project in projects:
            if generator.generate_project_description(project):
                successful += 1
                
        print("=" * 50)
        print(f"✅ {successful}/{len(projects)} Projekte erfolgreich generiert")
        
        if successful == len(projects):
            print("🎯 Alle Projektbeschreibungen sind bereit für Claude Desktop!")
        else:
            print("⚠️ Einige Projekte benötigen manuelle Nachbearbeitung")

if __name__ == "__main__":
    main()
