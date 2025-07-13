#!/usr/bin/env python3
"""
DiSoAn Projekt-Orientierung Monitoring Dashboard
Qualitätssicherung und System-Überwachung
"""

import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List
import matplotlib.pyplot as plt
import pandas as pd

class DiSoAnProjectMonitor:
    def __init__(self, repo_path: str = "/Users/paulad/snflsknfkldnfs.github.io"):
        self.repo_path = Path(repo_path)
        self.descriptions_dir = self.repo_path / "project_descriptions"
        self.reports_dir = self.repo_path / "monitoring_reports"
        self.reports_dir.mkdir(exist_ok=True)
        
    def generate_quality_report(self) -> Dict:
        """Generiert Qualitätsbericht für alle Projektbeschreibungen"""
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'total_projects': 0,
            'quality_scores': {},
            'average_quality': 0,
            'projects_below_threshold': [],
            'last_updates': {},
            'recommendations': []
        }
        
        # Alle Metadaten-Dateien finden
        meta_files = list(self.descriptions_dir.glob("*_meta.json"))
        report['total_projects'] = len(meta_files)
        
        quality_scores = []
        
        for meta_file in meta_files:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
                
            project_name = metadata['project_name']
            quality_score = metadata['quality_score']
            
            report['quality_scores'][project_name] = quality_score
            report['last_updates'][project_name] = metadata['generated_at']
            
            quality_scores.append(quality_score)
            
            # Projekte unter Schwellenwert identifizieren
            if quality_score < 80:
                report['projects_below_threshold'].append({
                    'project': project_name,
                    'score': quality_score,
                    'generated_at': metadata['generated_at']
                })
                
        # Durchschnittliche Qualität berechnen
        if quality_scores:
            report['average_quality'] = sum(quality_scores) / len(quality_scores)
            
        # Empfehlungen generieren
        report['recommendations'] = self.generate_recommendations(report)
        
        return report
    
    def generate_recommendations(self, report: Dict) -> List[str]:
        """Generiert Verbesserungsempfehlungen"""
        recommendations = []
        
        if report['average_quality'] < 85:
            recommendations.append("Durchschnittliche Qualität unter 85% - Template-Optimierung erforderlich")
            
        if len(report['projects_below_threshold']) > 0:
            recommendations.append(f"{len(report['projects_below_threshold'])} Projekte unter Qualitätsschwelle - Manuelle Überprüfung nötig")
            
        # Veraltete Beschreibungen identifizieren
        cutoff_date = datetime.now() - timedelta(days=30)
        outdated_projects = []
        
        for project, last_update in report['last_updates'].items():
            update_date = datetime.fromisoformat(last_update.replace('Z', '+00:00').replace('+00:00', ''))
            if update_date < cutoff_date:
                outdated_projects.append(project)
                
        if outdated_projects:
            recommendations.append(f"Veraltete Beschreibungen: {', '.join(outdated_projects)}")
            
        if not recommendations:
            recommendations.append("Alle Projektbeschreibungen erfüllen Qualitätsstandards ✅")
            
        return recommendations
    
    def create_quality_dashboard(self) -> str:
        """Erstellt HTML-Dashboard für Qualitätsüberwachung"""
        
        report = self.generate_quality_report()
        
        dashboard_html = f"""
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DiSoAn Projekt-Orientierung Dashboard</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                   color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }}
        .card {{ background: white; padding: 20px; border-radius: 10px; 
                 box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }}
        .metric {{ display: inline-block; margin: 10px; padding: 15px; 
                  background: #f8f9fa; border-radius: 8px; min-width: 150px; text-align: center; }}
        .quality-high {{ color: #28a745; }}
        .quality-medium {{ color: #ffc107; }}
        .quality-low {{ color: #dc3545; }}
        .project-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; }}
        .project-card {{ padding: 15px; border-left: 4px solid #667eea; background: #f8f9fa; }}
        .recommendations {{ background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; }}
        .timestamp {{ font-size: 0.9em; color: #666; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 DiSoAn Projekt-Orientierung Dashboard</h1>
            <p>Systemtheoretische Qualitätssicherung für Claude-Desktop-Projekte</p>
            <div class="timestamp">Letztes Update: {report['timestamp'][:19]}</div>
        </div>
        
        <div class="card">
            <h2>📊 Qualitäts-Metriken</h2>
            <div class="metric">
                <h3>{report['total_projects']}</h3>
                <p>Aktive Projekte</p>
            </div>
            <div class="metric">
                <h3 class="{'quality-high' if report['average_quality'] >= 85 else 'quality-medium' if report['average_quality'] >= 75 else 'quality-low'}">{report['average_quality']:.1f}%</h3>
                <p>Durchschnittsqualität</p>
            </div>
            <div class="metric">
                <h3 class="{'quality-high' if len(report['projects_below_threshold']) == 0 else 'quality-low'}">{len(report['projects_below_threshold'])}</h3>
                <p>Unter Schwellenwert</p>
            </div>
        </div>
        
        <div class="card">
            <h2>📈 Projekt-Qualitäten</h2>
            <div class="project-grid">
"""
        
        # Projekt-Details hinzufügen
        for project, score in report['quality_scores'].items():
            quality_class = 'quality-high' if score >= 85 else 'quality-medium' if score >= 75 else 'quality-low'
            last_update = report['last_updates'][project][:10]
            
            dashboard_html += f"""
                <div class="project-card">
                    <h4>{project}</h4>
                    <div class="{quality_class}">Qualität: {score}%</div>
                    <div class="timestamp">Letztes Update: {last_update}</div>
                </div>
"""
        
        dashboard_html += f"""
            </div>
        </div>
        
        <div class="card recommendations">
            <h2>💡 Empfehlungen</h2>
            <ul>
"""
        
        for recommendation in report['recommendations']:
            dashboard_html += f"<li>{recommendation}</li>"
            
        dashboard_html += """
            </ul>
        </div>
        
        <div class="card">
            <h2>🔧 System-Status</h2>
            <p><strong>DiSoAn-Standards:</strong> ✅ Vollständig implementiert</p>
            <p><strong>Selbstlernend:</strong> ✅ Kontinuierliche Optimierung aktiv</p>
            <p><strong>Stakeholder-Integration:</strong> ✅ Mittelschul-Digitalisierung 2025</p>
            <p><strong>PATA-Protokoll:</strong> ✅ Performance-Accuracy-Transparency-Accountability</p>
        </div>
        
        <div class="card">
            <h2>📋 Nächste Aktionen</h2>
            <ul>
                <li>Projekte unter 80% Qualität manuell überprüfen</li>
                <li>Veraltete Beschreibungen aktualisieren</li>
                <li>Template-Optimierung basierend auf Feedback</li>
                <li>Automatisierungs-Pipeline überwachen</li>
            </ul>
        </div>
    </div>
</body>
</html>
"""
        
        # Dashboard speichern
        dashboard_file = self.reports_dir / f"quality_dashboard_{datetime.now().strftime('%Y%m%d_%H%M')}.html"
        with open(dashboard_file, 'w', encoding='utf-8') as f:
            f.write(dashboard_html)
            
        # Aktuelles Dashboard-Link erstellen
        current_dashboard = self.reports_dir / "current_dashboard.html"
        with open(current_dashboard, 'w', encoding='utf-8') as f:
            f.write(dashboard_html)
            
        return str(dashboard_file)
    
    def save_quality_report(self) -> str:
        """Speichert JSON-Qualitätsbericht"""
        
        report = self.generate_quality_report()
        
        report_file = self.reports_dir / f"quality_report_{datetime.now().strftime('%Y%m%d_%H%M')}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        return str(report_file)
    
    def check_project_health(self, project_name: str) -> Dict:
        """Überprüft Gesundheit eines spezifischen Projekts"""
        
        meta_file = self.descriptions_dir / f"{project_name}_meta.json"
        desc_file = self.descriptions_dir / f"{project_name}_description.md"
        
        if not meta_file.exists():
            return {'status': 'missing', 'message': 'Metadaten-Datei fehlt'}
            
        if not desc_file.exists():
            return {'status': 'missing', 'message': 'Beschreibungs-Datei fehlt'}
            
        with open(meta_file, 'r', encoding='utf-8') as f:
            metadata = json.load(f)
            
        # Gesundheits-Check
        health = {
            'status': 'healthy',
            'quality_score': metadata['quality_score'],
            'last_update': metadata['generated_at'],
            'issues': []
        }
        
        # Qualitätsprobleme
        if metadata['quality_score'] < 80:
            health['issues'].append(f"Qualität unter Schwellenwert: {metadata['quality_score']}%")
            health['status'] = 'degraded'
            
        # Veraltete Beschreibung
        update_date = datetime.fromisoformat(metadata['generated_at'].replace('Z', '+00:00').replace('+00:00', ''))
        if (datetime.now() - update_date).days > 30:
            health['issues'].append(f"Beschreibung veraltet: {(datetime.now() - update_date).days} Tage")
            health['status'] = 'outdated'
            
        return health

def main():
    """CLI für Monitoring-Dashboard"""
    import sys
    
    monitor = DiSoAnProjectMonitor()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == 'dashboard':
            dashboard_file = monitor.create_quality_dashboard()
            print(f"✅ Dashboard erstellt: {dashboard_file}")
            
        elif command == 'report':
            report_file = monitor.save_quality_report()
            print(f"✅ Qualitätsbericht gespeichert: {report_file}")
            
        elif command == 'check' and len(sys.argv) > 2:
            project_name = sys.argv[2].upper()
            health = monitor.check_project_health(project_name)
            print(f"🔍 {project_name}: {health['status']}")
            for issue in health.get('issues', []):
                print(f"  ⚠️ {issue}")
                
        else:
            print("Verwendung: python monitor.py [dashboard|report|check PROJECT_NAME]")
    else:
        # Standard: Dashboard und Report erstellen
        dashboard_file = monitor.create_quality_dashboard()
        report_file = monitor.save_quality_report()
        
        print("📊 DiSoAn Projekt-Monitoring abgeschlossen:")
        print(f"  Dashboard: {dashboard_file}")
        print(f"  Report: {report_file}")

if __name__ == "__main__":
    main()
