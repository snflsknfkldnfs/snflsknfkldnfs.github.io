#!/bin/bash

# TUV-Übersicht Workflow Integration
# Dieses Script installiert alles Nötige und erweitert den bestehenden Workflow

# Farbcodes für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}TUV-Übersicht Integrationsscript${NC}"
echo "===================="

# Prüfe Voraussetzungen
if ! command -v node &> /dev/null
then
    echo -e "${RED}Node.js ist nicht installiert. Bitte installiere Node.js (Version 14+)${NC}"
    exit 1
fi

# Installiere notwendige Abhängigkeiten, falls nicht vorhanden
echo -e "${YELLOW}Installiere notwendige Abhängigkeiten...${NC}"
npm list gray-matter &> /dev/null || npm install --save gray-matter
echo -e "${GREEN}Abhängigkeiten wurden installiert.${NC}"

# Erstelle Verzeichnis für den Generator, falls nicht vorhanden
SCRIPT_DIR="./scripts/generators"
if [ ! -d "$SCRIPT_DIR" ]; then
    echo -e "${YELLOW}Erstelle Verzeichnis für Generatoren...${NC}"
    mkdir -p "$SCRIPT_DIR"
fi

# Kopiere TUV-Generator in das Script-Verzeichnis
echo -e "${YELLOW}Installiere den TUV-Generator...${NC}"
cp ./tuv-overview-generator.js "$SCRIPT_DIR/generate_tuv_overview.js"
chmod +x "$SCRIPT_DIR/generate_tuv_overview.js"
echo -e "${GREEN}Generator wurde installiert.${NC}"

# Erstelle ein ausführbares Skript zum direkten Ausführen
echo -e "${YELLOW}Erstelle ausführbares Skript...${NC}"
cat > ./scripts/generate_tuv_overview.sh << 'EOF'
#!/bin/bash
# Ausführbares Skript zum Generieren der TUV-Übersicht
node ./scripts/generators/generate_tuv_overview.js
EOF
chmod +x ./scripts/generate_tuv_overview.sh
echo -e "${GREEN}Ausführbares Skript erstellt.${NC}"

# Aktualisiere update_all.sh, falls vorhanden
UPDATE_SCRIPT="./scripts/update_all.sh"
if [ -f "$UPDATE_SCRIPT" ]; then
    echo -e "${YELLOW}Füge Generator zum update_all.sh Script hinzu...${NC}"
    
    # Prüfe, ob der Generator bereits in der Datei ist
    if grep -q "generate_tuv_overview.sh" "$UPDATE_SCRIPT"; then
        echo -e "${GREEN}Generator ist bereits in update_all.sh enthalten.${NC}"
    else
        # Finde die letzte Zeile vor "Update abgeschlossen" und füge neue Zeile ein
        line_num=$(grep -n "Update abgeschlossen" "$UPDATE_SCRIPT" | cut -d: -f1)
        if [ -n "$line_num" ]; then
            line_num=$((line_num - 1))
            sed -i "${line_num}a ./scripts/generate_tuv_overview.sh  # Generiere TUV-Übersicht" "$UPDATE_SCRIPT"
            echo -e "${GREEN}Generator wurde zu update_all.sh hinzugefügt.${NC}"
        else
            # Wenn "Update abgeschlossen" nicht gefunden wurde, füge am Ende hinzu
            echo "./scripts/generate_tuv_overview.sh  # Generiere TUV-Übersicht" >> "$UPDATE_SCRIPT"
            echo -e "${GREEN}Generator wurde am Ende von update_all.sh hinzugefügt.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Die Datei update_all.sh wurde nicht gefunden. Der Generator muss manuell ausgeführt werden.${NC}"
fi

# Git Pre-Commit Hook einrichten (optional)
GIT_DIR="./.git"
HOOKS_DIR="$GIT_DIR/hooks"
if [ -d "$HOOKS_DIR" ]; then
    echo -e "${YELLOW}Möchtest du den Generator als Git Pre-Commit Hook einrichten? (j/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([jJ][aA]|[jJ])$ ]]; then
        echo -e "${YELLOW}Richte Git Pre-Commit Hook ein...${NC}"
        
        # Erstelle oder aktualisiere den Pre-Commit Hook
        cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-Commit Hook für die automatische Generierung der TUV-Übersicht
# Alle TUV-Dateien werden geprüft und die Übersicht bei Änderungen aktualisiert

# Prüfe, ob TUV-Dateien geändert wurden
if git diff --cached --name-only | grep -E '.*_UE_.*\.md|.*_TB_.*\.md|.*_TUV_.*\.md'; then
    echo "TUV-Dateien wurden geändert. Aktualisiere TUV-Übersicht..."
    ./scripts/generate_tuv_overview.sh
    git add ./notizen/index/TUV_Uebersicht.md
fi
EOF
        chmod +x "$HOOKS_DIR/pre-commit"
        echo -e "${GREEN}Git Pre-Commit Hook wurde eingerichtet.${NC}"
    else
        echo -e "${YELLOW}Git Pre-Commit Hook wurde nicht eingerichtet.${NC}"
    fi
else
    echo -e "${YELLOW}Git-Repository nicht gefunden. Pre-Commit Hook kann nicht eingerichtet werden.${NC}"
fi

echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "Du kannst die TUV-Übersicht nun auf folgende Weisen generieren:"
echo "1. Automatisch bei jedem Update mit update_all.sh"
echo "2. Manuell mit ./scripts/generate_tuv_overview.sh"
if [ -d "$HOOKS_DIR" ] && [[ "$response" =~ ^([jJ][aA]|[jJ])$ ]]; then
    echo "3. Automatisch vor jedem Commit (wenn TUV-Dateien geändert wurden)"
fi

echo ""
echo -e "${YELLOW}Soll die TUV-Übersicht jetzt generiert werden? (j/n)${NC}"
read -r generate_now
if [[ "$generate_now" =~ ^([jJ][aA]|[jJ])$ ]]; then
    echo -e "${YELLOW}Generiere TUV-Übersicht...${NC}"
    node "$SCRIPT_DIR/generate_tuv_overview.js"
    echo -e "${GREEN}TUV-Übersicht wurde generiert.${NC}"
fi
