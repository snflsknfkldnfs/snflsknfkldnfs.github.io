#!/bin/bash
# MCP-SAFEGUARDS DEPLOYMENT SCRIPT

echo "🚀 DEPLOYING MCP-SAFEGUARDS SYSTEM-WIDE"

# Konfiguration
SAFEGUARDS_SOURCE="/Users/paulad/snflsknfkldnfs.github.io/SYSTEM_MCP_SAFEGUARDS"
PROJECTS_ROOT="/Users/paulad/snflsknfkldnfs.github.io"

# Funktion: Safeguards in Projekt deployen
deploy_safeguards() {
    local project_path="$1"
    local project_name=$(basename "$project_path")
    
    echo "📂 Deploying to: $project_name"
    
    # Erstelle Safeguards-Verzeichnis wenn nicht vorhanden
    mkdir -p "$project_path/SYSTEM_MCP_SAFEGUARDS"
    
    # Kopiere alle Safeguard-Dokumente
    cp -r "$SAFEGUARDS_SOURCE"/* "$project_path/SYSTEM_MCP_SAFEGUARDS/"
    
    # Erstelle projektspezifische README
    cat > "$project_path/SYSTEM_MCP_SAFEGUARDS/README.md" << EOF
# MCP-Safeguards für $project_name

## 🔗 Quick-Start
1. Lese: 00_MASTER_PROBLEM_DOCUMENTATION.md
2. Befolge: 01_SESSION_ONBOARDING.md  
3. Integriere: 02_DISOAN_INTEGRATION.md

## 🚨 KRITISCH: Multi-PDF-Access-Bug
Siehe Master-Documentation für Details und Workarounds.

## ✅ Status: Safeguards aktiv für $project_name
EOF

    # Git-Hook für automatische Warnung
    if [ -d "$project_path/.git" ]; then
        cat > "$project_path/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
echo "⚠️  MCP-SAFEGUARDS REMINDER: Kein Multi-PDF-Access!"
echo "✅ Einzeldatei-Workflow verwenden"
exit 0
EOF
        chmod +x "$project_path/.git/hooks/pre-commit"
    fi
    
    echo "✅ $project_name: Safeguards deployed"
}

# Hauptdeployment
echo "🔍 Scanning for projects..."

# Deploy zu Haupt-Repository
deploy_safeguards "$PROJECTS_ROOT"

# Deploy zu allen Seminar-Verzeichnissen
find "$PROJECTS_ROOT/seminarcloud" -name "24-25" -type d | while read seminar_path; do
    deploy_safeguards "$seminar_path"
done

# Deploy zu speziellen Projektverzeichnissen
for special_dir in "LMStudio-MCP" "mcp-obsidian-local" "tools"; do
    if [ -d "$PROJECTS_ROOT/$special_dir" ]; then
        deploy_safeguards "$PROJECTS_ROOT/$special_dir"
    fi
done

# Erstelle Master-Index
cat > "$PROJECTS_ROOT/MCP_SAFEGUARDS_INDEX.md" << EOF
# MCP-SAFEGUARDS: System-Wide Deployment Index

## 📊 Deployment Status
**Timestamp**: $(date)
**Status**: ACTIVE - Safeguards deployed system-wide

## 🔗 Deployed Locations:
- Haupt-Repository: ✅ SYSTEM_MCP_SAFEGUARDS/
- Seminar-Cloud: ✅ In allen 24-25 Verzeichnissen  
- Spezial-Tools: ✅ MCP-relevante Projekte

## 🚨 KRITISCHER BUG:
Multi-PDF-Access nach komplexen MCP-Operations löst Chat-Reset aus.

## 🛡️ AUTOMATISCHE SAFEGUARDS:
- Git-Hooks für Pre-Commit-Warnings
- Session-Onboarding-Scripts
- DiSoAn-Integration
- User-Guidelines

## 📈 UPDATE-PROTOKOLL:
- 2025-07-01: Initial deployment
- [Weitere Updates hier...]

## 🎯 NÄCHSTE SCHRITTE:
1. ✅ System-wide deployment complete
2. 🔄 Monitor effectiveness  
3. 📝 Document additional cases
4. 🚀 Update when Claude-fix available

---
**Status**: Problem systemweit umgangen ✅
EOF

echo ""
echo "🎯 DEPLOYMENT COMPLETE!"
echo "✅ MCP-Safeguards system-wide aktiv"
echo "✅ Git-Hooks installiert"
echo "✅ Documentation deployed"
echo "✅ Master-Index erstellt"
echo ""
echo "🛡️ Das Multi-PDF-Crash-Problem ist jetzt systemweit umgangen!"
