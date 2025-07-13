#!/bin/bash
# DiSoAn Claude Desktop Projektanweisungen Auto-Update v3.0
# Systemtheoretisch fundierte Automatisierung für verlässliche Claude-Orientierung

set -e

REPO_PATH="/Users/paulad/snflsknfkldnfs.github.io"
SCRIPTS_DIR="$REPO_PATH/scripts/project_orientation"
INSTRUCTIONS_DIR="$REPO_PATH/claude_desktop_instructions"

echo "🚀 DiSoAn Claude Desktop Projektanweisungen Auto-Update v3.0"
echo "🎯 Systemtheoretisch fundierte Claude-Orientierung für alle Projekte"
echo "=" * 70

# Verzeichnisse erstellen
mkdir -p "$INSTRUCTIONS_DIR"
mkdir -p "$REPO_PATH/monitoring_reports"

# Alle verfügbaren Projekte definieren
projects=("Seminar" "GPG5" "GPG6" "WiB5" "WiB6" "M5" "M6" "E5" "E6")

echo "📋 Verfügbare Projekte: ${projects[@]}"
echo ""

# Claude Desktop Projektanweisungen generieren
echo "🔄 Generiere Claude Desktop Projektanweisungen..."
successful=0
total=${#projects[@]}

for project in "${projects[@]}"; do
    echo "  📝 Bearbeite $project..."
    
    if python3 "$SCRIPTS_DIR/claude_desktop_generator_v3.py" "$project" >/dev/null 2>&1; then
        echo "  ✅ $project: Claude Desktop Anweisungen erfolgreich generiert"
        ((successful++))
    else
        echo "  ❌ $project: Fehler bei Generierung"
    fi
done

echo ""
echo "📊 Generierungs-Ergebnis: $successful/$total Projekte erfolgreich"

# Qualitäts-Monitoring ausführen
echo ""
echo "📈 Erstelle Qualitäts-Monitoring..."

# Erweiterte Monitoring-Funktion für Claude Desktop
cat > "$SCRIPTS_DIR/claude_desktop_monitor.py" << 'EOF'
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
EOF

# Monitoring ausführen
python3 "$SCRIPTS_DIR/claude_desktop_monitor.py"

echo ""
echo "🎯 Claude Desktop Integration bereit!"
echo "📁 Anweisungen verfügbar in: $INSTRUCTIONS_DIR/"
echo "📊 Monitoring-Berichte: $REPO_PATH/monitoring_reports/"
echo ""
echo "💡 Verwendung:"
echo "   1. Generator ausführen: python3 claude_desktop_generator_v3.py [PROJEKT]"
echo "   2. Output kopieren in Claude Desktop 'Projektanweisungen festlegen'"
echo "   3. Sofort optimierte Claude-Orientierung verfügbar"
echo ""
echo "✅ DiSoAn Claude Desktop Standardisierung erfolgreich implementiert!"
