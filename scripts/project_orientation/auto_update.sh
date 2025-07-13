#!/bin/bash
# DiSoAn Projekt-Orientierung Automatisierung

set -e

REPO_PATH="/Users/paulad/snflsknfkldnfs.github.io"
SCRIPTS_DIR="$REPO_PATH/scripts/project_orientation"

echo "🚀 DiSoAn Projekt-Orientierung Auto-Update"

# Verzeichnisse erstellen
mkdir -p "$REPO_PATH/project_descriptions"
mkdir -p "$REPO_PATH/monitoring_reports"

# Projekte definieren
projects=("GPG5" "GPG6" "WiB5" "WiB6" "M5" "M6" "E5" "E6")

# Projektbeschreibungen generieren
echo "🔄 Generiere Projektbeschreibungen..."
for project in "${projects[@]}"; do
    echo "  Bearbeite $project..."
    python3 "$SCRIPTS_DIR/generate_descriptions.py" "$project"
done

# Monitoring ausführen
echo "📊 Erstelle Monitoring-Berichte..."
python3 "$SCRIPTS_DIR/monitor.py" dashboard
python3 "$SCRIPTS_DIR/monitor.py" report

echo "✅ Update abgeschlossen!"
echo "📋 Projektbeschreibungen verfügbar in: $REPO_PATH/project_descriptions/"
echo "📊 Dashboard verfügbar: $REPO_PATH/monitoring_reports/current_dashboard.html"
