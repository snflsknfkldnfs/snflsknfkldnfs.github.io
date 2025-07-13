#!/usr/bin/env python3
"""
DiSoAn Claude Desktop Monitoring v3.0
Qualitätssicherung für Claude Desktop Projektanweisungen
"""

import json
import os
from datetime import datetime
from pathlib import Path

def monitor_claude_desktop_instructions():
    """Überwacht Claude Desktop Anweisungen Qualität"""
    
    repo_path = Path("/Users/paulad/snflsknfkldnfs.github.io")
    instructions_dir = repo_path / "claude_desktop_instructions"
    reports_dir = repo_path / "monitoring_reports"
    
    if not instructions_dir.exists():
        print("❌ Keine Claude Desktop Anweisungen gefunden")
        return
    
    # Alle Meta-Dateien finden
    meta_files = list(instructions_dir.glob("*_meta.json"))
    
    if not meta_files:
        print("❌ Keine Metadaten gefunden")
        return
    
    # Bericht generieren
    report = {
        'timestamp': datetime.now().isoformat(),
        'total_projects': len(meta_files),
        'quality_scores': {},
        'versions': {},
        'recommendations': []
    }
    
    quality_scores = []
    
    for meta_file in meta_files:
        with open(meta_file, 'r', encoding='utf-8') as f:
            metadata = json.load(f)
        
        project_name = metadata['project_name']
        quality = metadata['quality_score']
        version = metadata['version_info']['version']
        
        report['quality_scores'][project_name] = quality
        report['versions'][project_name] = version
        quality_scores.append(quality)
    
    # Durchschnitt berechnen
    if quality_scores:
        avg_quality = sum(quality_scores) / len(quality_scores)
        report['average_quality'] = avg_quality
        
        print(f"📊 Claude Desktop Anweisungen Status:")
        print(f"   Projekte: {len(meta_files)}")
        print(f"   Durchschnittsqualität: {avg_quality:.1f}%")
        
        # Empfehlungen
        if avg_quality >= 95:
            report['recommendations'].append("✅ Exzellente Qualität - System optimal")
        elif avg_quality >= 85:
            report['recommendations'].append("✅ Gute Qualität - Kleinere Optimierungen möglich")
        else:
            report['recommendations'].append("⚠️ Qualität unter Standard - Überprüfung erforderlich")
        
        # Projekte unter 90% identifizieren
        low_quality = [name for name, score in report['quality_scores'].items() if score < 90]
        if low_quality:
            report['recommendations'].append(f"🔍 Überprüfung erforderlich: {', '.join(low_quality)}")
    
    # Bericht speichern
    report_file = reports_dir / f"claude_desktop_quality_report_{datetime.now().strftime('%Y%m%d_%H%M')}.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"📋 Bericht gespeichert: {report_file}")
    
    # Empfehlungen ausgeben
    for rec in report['recommendations']:
        print(f"   {rec}")

if __name__ == "__main__":
    monitor_claude_desktop_instructions()
