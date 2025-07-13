#!/usr/bin/env python3
"""
DiSoAn Cross-Project Learning Engine v2.0
Emergente Optimierung durch Projekt-übergreifende Muster-Erkennung
"""

import json
import re
from collections import defaultdict, Counter
from pathlib import Path
from datetime import datetime, timedelta

class DiSoAnCrossProjectLearning:
    def __init__(self, repo_path: str):
        self.repo_path = Path(repo_path)
        self.instructions_dir = self.repo_path / "claude_desktop_instructions"
        self.patterns_dir = self.repo_path / "learning_patterns"
        self.patterns_dir.mkdir(exist_ok=True)
        
    def analyze_success_patterns(self) -> dict:
        """Analysiert erfolgreiche Muster across Projekte"""
        
        patterns = {
            'high_quality_elements': [],
            'stakeholder_patterns': defaultdict(list),
            'methodology_effectiveness': defaultdict(int),
            'content_structures': defaultdict(list),
            'version_evolution_patterns': []
        }
        
        # Alle Metadaten analysieren
        meta_files = list(self.instructions_dir.glob("*_meta.json"))
        
        for meta_file in meta_files:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
                
            # Projekt mit hoher Qualität identifizieren
            if metadata['quality_score'] >= 95:
                patterns['high_quality_elements'].append({
                    'project': metadata['project_name'],
                    'quality': metadata['quality_score'],
                    'version': metadata['version_info']['version'],
                    'update_count': metadata['version_info']['update_count']
                })
                
            # Versionsentwicklung tracken
            patterns['version_evolution_patterns'].append({
                'project': metadata['project_name'],
                'version': metadata['version_info']['version'],
                'update_count': metadata['version_info']['update_count'],
                'last_updated': metadata['version_info']['last_updated']
            })
                
        # Content-Analyse für erfolgreiche Templates
        instruction_files = list(self.instructions_dir.glob("*_claude_desktop_instructions.md"))
        
        for instruction_file in instruction_files:
            content = instruction_file.read_text(encoding='utf-8')
            project_name = instruction_file.stem.replace('_claude_desktop_instructions', '')
            
            # Stakeholder-Patterns extrahieren
            stakeholder_section = self._extract_section(content, "STAKEHOLDER")
            if stakeholder_section:
                stakeholders = re.findall(r'- ([^:]+):', stakeholder_section)
                for stakeholder in stakeholders:
                    patterns['stakeholder_patterns'][stakeholder.strip()].append(project_name)
                
            # Methodische Ansätze identifizieren
            methods_section = self._extract_section(content, "Methodische Ausrichtung")
            if methods_section:
                methods = re.findall(r'- ([^:]+):', methods_section)
                for method in methods:
                    patterns['methodology_effectiveness'][method.strip()] += 1
                    
            # Content-Strukturen analysieren
            sections = re.findall(r'## ([^#\n]+)', content)
            for section in sections:
                patterns['content_structures'][section.strip()].append(project_name)
                
        return patterns
    
    def _extract_section(self, content: str, section_name: str) -> str:
        """Extrahiert spezifischen Abschnitt aus Content"""
        
        # Verschiedene Muster für Abschnitte
        patterns = [
            rf'{section_name}[^#]*?(?=##|\Z)',
            rf'#{1,3}\s*[^#]*{section_name}[^#]*?(?=##|\Z)',
            rf'[^#]*{section_name}[^#]*?(?=##|\Z)'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, content, re.IGNORECASE | re.DOTALL)
            if match:
                return match.group(0)
        
        return ""
    
    def generate_optimization_recommendations(self, patterns: dict) -> list:
        """Generiert Optimierungsempfehlungen basierend auf Mustern"""
        
        recommendations = []
        
        # Qualitäts-Pattern-Analyse
        if patterns['high_quality_elements']:
            avg_updates = sum(elem['update_count'] for elem in patterns['high_quality_elements']) / len(patterns['high_quality_elements'])
            
            if avg_updates > 3:
                recommendations.append({
                    'type': 'template_optimization',
                    'priority': 'high',
                    'suggestion': f'Häufige Updates (⌀{avg_updates:.1f}) deuten auf Template-Schwächen hin - Template-Robustheit verbessern',
                    'action': 'review_template_stability'
                })
        
        # Stakeholder-Redundanz-Analyse
        common_stakeholders = {stakeholder: len(projects) 
                             for stakeholder, projects in patterns['stakeholder_patterns'].items() 
                             if len(projects) >= 3}
                
        if common_stakeholders:
            recommendations.append({
                'type': 'stakeholder_standardization', 
                'priority': 'medium',
                'suggestion': f'Gemeinsame Stakeholder standardisieren: {", ".join(common_stakeholders.keys())}',
                'data': common_stakeholders,
                'action': 'create_stakeholder_templates'
            })
            
        # Methodische Effektivität
        effective_methods = {method: count for method, count in patterns['methodology_effectiveness'].items() if count >= 4}
        
        if effective_methods:
            recommendations.append({
                'type': 'methodology_propagation',
                'priority': 'medium', 
                'suggestion': f'Bewährte Methoden auf alle Projekte ausweiten: {", ".join(effective_methods.keys())}',
                'data': effective_methods,
                'action': 'propagate_successful_methods'
            })
            
        # Content-Struktur-Konsistenz
        structure_inconsistencies = []
        expected_sections = ["KERNAUFTRAG", "STAKEHOLDER", "HANDLUNGSLOGIK", "SELBSTREFLEXION"]
        
        for section in expected_sections:
            projects_with_section = patterns['content_structures'].get(section, [])
            total_projects = len(patterns['high_quality_elements'])
            
            if len(projects_with_section) < total_projects * 0.8:  # Weniger als 80% haben diese Sektion
                structure_inconsistencies.append(section)
                
        if structure_inconsistencies:
            recommendations.append({
                'type': 'structure_standardization',
                'priority': 'low',
                'suggestion': f'Inkonsistente Strukturen harmonisieren: {", ".join(structure_inconsistencies)}',
                'data': structure_inconsistencies,
                'action': 'standardize_content_structure'
            })
            
        return recommendations
    
    def apply_optimizations(self, recommendations: list):
        """Wendet Optimierungen automatisch an"""
        
        applied_optimizations = []
        
        for rec in recommendations:
            if rec['type'] == 'template_optimization' and rec['priority'] == 'high':
                result = self._optimize_templates()
                applied_optimizations.append(f"Template-Optimierung: {result}")
                
            elif rec['type'] == 'stakeholder_standardization':
                result = self._standardize_stakeholders(rec.get('data', {}))
                applied_optimizations.append(f"Stakeholder-Standardisierung: {result}")
                
            elif rec['type'] == 'methodology_propagation':
                result = self._propagate_methodologies(rec.get('data', {}))
                applied_optimizations.append(f"Methodik-Propagation: {result}")
                
        return applied_optimizations
    
    def _optimize_templates(self) -> str:
        """Optimiert Templates basierend auf Erfolgsmustern"""
        
        # Analysiere Projekte mit niedrigster Update-Frequenz als stabilste Templates
        stable_templates = []
        
        meta_files = list(self.instructions_dir.glob("*_meta.json"))
        for meta_file in meta_files:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
                
            if metadata['quality_score'] == 100 and metadata['version_info']['update_count'] <= 2:
                stable_templates.append(metadata['project_name'])
                
        return f"Identifiziert {len(stable_templates)} stabile Templates als Basis-Pattern"
        
    def _standardize_stakeholders(self, common_stakeholders: dict) -> str:
        """Standardisiert gemeinsame Stakeholder"""
        
        # Erstelle Stakeholder-Template
        stakeholder_template = {
            'timestamp': datetime.now().isoformat(),
            'common_stakeholders': common_stakeholders,
            'recommendations': {}
        }
        
        for stakeholder, frequency in common_stakeholders.items():
            if frequency >= 5:  # In mindestens 5 Projekten
                stakeholder_template['recommendations'][stakeholder] = {
                    'priority': 'standard_inclusion',
                    'description': 'In alle neuen Projekte standardmäßig einbeziehen'
                }
                
        # Template speichern
        template_file = self.patterns_dir / "stakeholder_standardization_template.json"
        with open(template_file, 'w', encoding='utf-8') as f:
            json.dump(stakeholder_template, f, indent=2, ensure_ascii=False)
            
        return f"Stakeholder-Template erstellt mit {len(stakeholder_template['recommendations'])} Standard-Stakeholdern"
        
    def _propagate_methodologies(self, effective_methods: dict) -> str:
        """Propagiert bewährte Methodiken"""
        
        # Erstelle Methodologie-Template
        methodology_template = {
            'timestamp': datetime.now().isoformat(),
            'effective_methods': effective_methods,
            'propagation_plan': {}
        }
        
        for method, frequency in effective_methods.items():
            if frequency >= 6:  # In mindestens 6 Projekten erfolgreich
                methodology_template['propagation_plan'][method] = {
                    'priority': 'high',
                    'target': 'all_projects',
                    'implementation': 'next_update_cycle'
                }
                
        # Template speichern
        template_file = self.patterns_dir / "methodology_propagation_template.json"
        with open(template_file, 'w', encoding='utf-8') as f:
            json.dump(methodology_template, f, indent=2, ensure_ascii=False)
            
        return f"Methodologie-Propagation geplant für {len(methodology_template['propagation_plan'])} bewährte Ansätze"
    
    def generate_learning_report(self, patterns: dict, recommendations: list) -> str:
        """Generiert detaillierten Lernbericht"""
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'analysis_summary': {
                'total_projects_analyzed': len(patterns['high_quality_elements']),
                'high_quality_projects': len([p for p in patterns['high_quality_elements'] if p['quality'] == 100]),
                'unique_stakeholders': len(patterns['stakeholder_patterns']),
                'unique_methodologies': len(patterns['methodology_effectiveness']),
                'recommendations_generated': len(recommendations)
            },
            'patterns': patterns,
            'recommendations': recommendations
        }
        
        # Bericht speichern
        report_file = self.patterns_dir / f"cross_project_learning_report_{datetime.now().strftime('%Y%m%d_%H%M')}.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        return str(report_file)

def run_cross_project_learning():
    """Führt Cross-Project-Learning aus"""
    
    learning_engine = DiSoAnCrossProjectLearning("/Users/paulad/snflsknfkldnfs.github.io")
    
    print("🧠 Starte Cross-Project-Learning-Analyse...")
    patterns = learning_engine.analyze_success_patterns()
    
    print("📊 Generiere Optimierungsempfehlungen...")
    recommendations = learning_engine.generate_optimization_recommendations(patterns)
    
    print(f"🎯 Cross-Project-Learning: {len(recommendations)} Optimierungen identifiziert")
    
    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec['priority'].upper()}: {rec['suggestion']}")
    
    # Automatische Anwendung für high-priority Empfehlungen
    high_priority = [rec for rec in recommendations if rec['priority'] == 'high']
    if high_priority:
        print("⚡ Wende High-Priority-Optimierungen an...")
        applied = learning_engine.apply_optimizations(high_priority)
        for optimization in applied:
            print(f"  ✅ {optimization}")
    
    # Lernbericht generieren
    report_file = learning_engine.generate_learning_report(patterns, recommendations)
    print(f"📋 Detailbericht gespeichert: {report_file}")

def main():
    """Hauptfunktion für Cross-Project-Learning"""
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == 'analyze':
            run_cross_project_learning()
        elif command == 'patterns':
            # Nur Pattern-Analyse ohne Optimierung
            learning_engine = DiSoAnCrossProjectLearning("/Users/paulad/snflsknfkldnfs.github.io")
            patterns = learning_engine.analyze_success_patterns()
            print(json.dumps(patterns, indent=2, ensure_ascii=False))
        else:
            print("Verwendung: python3 cross_project_learning.py [analyze|patterns]")
    else:
        # Standard: Vollständige Analyse
        run_cross_project_learning()

if __name__ == "__main__":
    main()
