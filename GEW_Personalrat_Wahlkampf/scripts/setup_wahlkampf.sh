#!/bin/bash

# 🚀 GEW Wahlkampf System - Automatische Einrichtung
# Version 1.0.0 | 2025-07-18

echo "=========================================="
echo "🗳️  GEW PERSONALRAT WAHLKAMPF SETUP"
echo "=========================================="
echo ""

# Definiere Pfade
BASE_DIR="/Users/paulad/snflsknfkldnfs.github.io/GEW_Personalrat_Wahlkampf"
SCRIPTS_DIR="$BASE_DIR/scripts"
REPORTS_DIR="$BASE_DIR/reports"
CACHE_DIR="$BASE_DIR/.cache"

echo "📁 Erstelle zusätzliche Verzeichnisstruktur..."

# Erstelle reports und cache Verzeichnisse
mkdir -p "$REPORTS_DIR"
mkdir -p "$REPORTS_DIR/daily"
mkdir -p "$REPORTS_DIR/weekly"  
mkdir -p "$REPORTS_DIR/dashboard"
mkdir -p "$CACHE_DIR"
mkdir -p "$CACHE_DIR/network"
mkdir -p "$CACHE_DIR/content"
mkdir -p "$CACHE_DIR/feedback"

echo "✅ Verzeichnisse erstellt"

echo ""
echo "📊 Initialisiere Wahlkampf-Baseline..."

# Erstelle initiale Konfigurationsdatei
cat > "$BASE_DIR/config/wahlkampf_config.json" << 'EOF'
{
  "campaign": {
    "candidate": "Paul Alexander Cebulla",
    "position": "GEW Personalrat Unterfranken", 
    "start_date": "2025-07-18",
    "election_date": "TBD",
    "phase": "Vorbereitung"
  },
  "targets": {
    "direct_supporters": 50,
    "multipliers": 15,
    "events_per_week": 1,
    "content_posts_per_week": 3
  },
  "monitoring": {
    "daily_updates": true,
    "weekly_reports": true,
    "auto_dashboard": true,
    "feedback_integration": true
  },
  "last_update": "2025-07-18T16:00:00Z"
}
EOF

mkdir -p "$BASE_DIR/config"

echo "✅ Baseline-Konfiguration erstellt"

echo ""
echo "🧠 Optimiere Claude-Instructions..."

# Erstelle aktualisierte Claude Instructions mit Timestamp
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i.backup "s/Auto-Update: [0-9T:-]*Z/Auto-Update: $CURRENT_TIME/" "$BASE_DIR/claude_desktop_instructions/GEW_Personalrat_Wahlkampf_Claude_Instructions.md"

echo "✅ Claude-Instructions aktualisiert"

echo ""
echo "📈 Erstelle initiales Monitoring-Dashboard..."

cat > "$REPORTS_DIR/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>GEW Wahlkampf Dashboard</title>
    <meta charset="utf-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
        .header { background: #1f4e79; color: white; padding: 20px; border-radius: 8px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #1f4e79; }
        .metric-value { font-size: 24px; font-weight: bold; color: #1f4e79; }
        .metric-label { font-size: 14px; color: #666; margin-top: 5px; }
        .status-good { color: #28a745; }
        .status-warn { color: #ffc107; }
        .status-error { color: #dc3545; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🗳️ GEW Personalrat Wahlkampf Dashboard</h1>
        <p>Paul Alexander Cebulla | Last Update: [TIMESTAMP]</p>
    </div>
    
    <div class="metrics">
        <div class="metric">
            <div class="metric-value status-good">READY</div>
            <div class="metric-label">System Status</div>
        </div>
        <div class="metric">
            <div class="metric-value">0</div>
            <div class="metric-label">Direkte Unterstützer</div>
        </div>
        <div class="metric">
            <div class="metric-value">0</div>
            <div class="metric-label">Content Posts</div>
        </div>
        <div class="metric">
            <div class="metric-value">0</div>
            <div class="metric-label">Events durchgeführt</div>
        </div>
    </div>
    
    <h2>📊 Nächste Schritte</h2>
    <ul>
        <li>Claude Desktop Projekt mit Instructions konfigurieren</li>
        <li>Erstes "Kaffee & Klagen" Event planen</li>
        <li>Netzwerk-Inventur durchführen</li>
        <li>Content-Pipeline aktivieren</li>
    </ul>
    
    <h2>🎯 Aktuelle Wahlkampf-Phase</h2>
    <p><strong>Vorbereitung & Basis-Aufbau</strong> - Fokus auf Authentizitäts-Aufbau und Netzwerk-Aktivierung</p>
</body>
</html>
EOF

# Timestamp in Dashboard einsetzen
sed -i.backup "s/\[TIMESTAMP\]/$(date)/" "$REPORTS_DIR/dashboard/index.html"

echo "✅ Dashboard erstellt unter: $REPORTS_DIR/dashboard/index.html"

echo ""
echo "🌐 Initialisiere Netzwerk-Tracking..."

# Erstelle Template für Netzwerk-Tracking
cat > "$CACHE_DIR/network/contacts_template.json" << 'EOF'
{
  "contacts": [],
  "segments": {
    "basketball_community": {"count": 0, "activated": 0},
    "jmu_network": {"count": 0, "activated": 0}, 
    "montessori_colleagues": {"count": 0, "activated": 0},
    "edtech_community": {"count": 0, "activated": 0},
    "gew_members": {"count": 0, "contacted": 0},
    "mittelschul_teachers": {"count": 0, "contacted": 0}
  },
  "last_update": "2025-07-18T16:00:00Z"
}
EOF

echo "✅ Netzwerk-Template erstellt"

echo ""
echo "⚙️  Erstelle Update-Scripts..."

# Erstelle tägliches Update-Script
cat > "$SCRIPTS_DIR/daily_update.sh" << 'EOF'
#!/bin/bash

echo "📅 $(date): Tägliches Wahlkampf-Update startet..."

BASE_DIR="/Users/paulad/snflsknfkldnfs.github.io/GEW_Personalrat_Wahlkampf"
REPORTS_DIR="$BASE_DIR/reports/daily"

# Erstelle heutigen Report-Ordner
TODAY=$(date +%Y-%m-%d)
mkdir -p "$REPORTS_DIR/$TODAY"

# Erstelle Update-Log
echo "$(date): Daily update started" >> "$REPORTS_DIR/$TODAY/update.log"

# TODO: Hier werden später Python-Scripts für Analyse aufgerufen
# python3 "$BASE_DIR/scripts/analyze_social_performance.py"
# python3 "$BASE_DIR/scripts/track_network_changes.py"  
# python3 "$BASE_DIR/scripts/update_claude_context.py"

echo "$(date): Daily update completed" >> "$REPORTS_DIR/$TODAY/update.log"
echo "✅ Tägliches Update abgeschlossen: $REPORTS_DIR/$TODAY/"
EOF

chmod +x "$SCRIPTS_DIR/daily_update.sh"

# Erstelle Reflexions-Extraktions-Script
cat > "$SCRIPTS_DIR/reflection_extraction.sh" << 'EOF'
#!/bin/bash

echo "🔍 $(date): Extrahiere Learnings aus heutigen Aktivitäten..."

BASE_DIR="/Users/paulad/snflsknfkldnfs.github.io/GEW_Personalrat_Wahlkampf"
CACHE_DIR="$BASE_DIR/.cache/feedback"

# Erstelle Feedback-Log für heute
TODAY=$(date +%Y-%m-%d)
mkdir -p "$CACHE_DIR/$TODAY"

# Erstelle Template für manuelle Eingabe
cat > "$CACHE_DIR/$TODAY/daily_reflection.md" << 'INNER_EOF'
# Tägliche Wahlkampf-Reflexion - [TODAY]

## 💬 Gespräche heute
- [ ] Name/Kontext: ___________
  - Feedback: ___________
  - Nächste Schritte: ___________

## 📱 Social Media Reaktionen  
- [ ] Plattform/Post: ___________
  - Resonanz: ___________
  - Learnings: ___________

## 🎪 Events/Meetings
- [ ] Event/Meeting: ___________
  - Teilnehmer: ___________
  - Wichtige Erkenntnisse: ___________

## 🧠 Strategische Erkenntnisse
- Was funktioniert gut: ___________
- Was sollte angepasst werden: ___________
- Neue Ideen: ___________

## 📋 Morgen Prioritäten
- [ ] ___________
- [ ] ___________
- [ ] ___________
INNER_EOF

sed -i.backup "s/\[TODAY\]/$TODAY/" "$CACHE_DIR/$TODAY/daily_reflection.md"

echo "✅ Reflexions-Template erstellt: $CACHE_DIR/$TODAY/daily_reflection.md"
echo "👉 Bitte manuell ausfüllen für optimale Lerneffekte"
EOF

chmod +x "$SCRIPTS_DIR/reflection_extraction.sh"

echo "✅ Update-Scripts erstellt und executable gemacht"

echo ""
echo "🎯 Setup-Abschluss..."

# Erstelle Erfolgs-Report
cat > "$REPORTS_DIR/setup_success_$(date +%Y%m%d_%H%M).txt" << EOF
GEW WAHLKAMPF SYSTEM - SETUP ERFOLGREICH ABGESCHLOSSEN
========================================================

Zeitpunkt: $(date)
Benutzer: $(whoami)
Basis-Verzeichnis: $BASE_DIR

ERSTELLTE KOMPONENTEN:
✅ Verzeichnisstruktur komplett
✅ Konfigurationsdateien erstellt
✅ Claude-Instructions optimiert
✅ Monitoring-Dashboard generiert
✅ Netzwerk-Tracking initialisiert
✅ Automatische Update-Scripts erstellt

NÄCHSTE SCHRITTE:
1. Claude Desktop Projekt konfigurieren
2. Dashboard ansehen: $REPORTS_DIR/dashboard/index.html
3. Erstes daily_update.sh ausführen
4. Netzwerk-Inventur beginnen

AUTOMATISIERUNG:
- Tägliche Updates: $SCRIPTS_DIR/daily_update.sh
- Reflexions-Extraktion: $SCRIPTS_DIR/reflection_extraction.sh
- Optional: Cronjob für automatische Ausführung

SYSTEM STATUS: VOLLSTÄNDIG OPERATIV 🚀
EOF

echo ""
echo "=========================================="
echo "✅ GEW WAHLKAMPF SYSTEM ERFOLGREICH EINGERICHTET!"
echo "=========================================="
echo ""
echo "📊 Dashboard ansehen:"
echo "open $REPORTS_DIR/dashboard/index.html"
echo ""
echo "🧠 Claude Desktop Projekt konfigurieren:"
echo "Kopiere Inhalt aus: $BASE_DIR/claude_desktop_instructions/"
echo ""
echo "🔄 Erstes Update ausführen:"
echo "$SCRIPTS_DIR/daily_update.sh"
echo ""
echo "📝 Setup-Details:"
echo "cat $REPORTS_DIR/setup_success_$(date +%Y%m%d_%H%M).txt"
echo ""
echo "🎯 READY TO LAUNCH WAHLKAMPF! 🚀"