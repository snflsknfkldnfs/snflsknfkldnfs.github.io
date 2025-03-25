#!/bin/bash

# Überprüfe, ob die notwendigen Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    echo "Verwendung: $0 KATEGORIE \"TITEL\""
    echo "Kategorien: prozesse, workflows, tools"
    exit 1
fi

KATEGORIE=$1
TITEL=$2
DATUM=$(date +%Y-%m-%d)
DATEINAME="${TITEL// /_}.md"
ZIELORDNER="notizen/anleitungen/${KATEGORIE}"

# Überprüfe, ob die Kategorie gültig ist
if [[ ! "$KATEGORIE" =~ ^(prozesse|workflows|tools)$ ]]; then
    echo "Fehler: Ungültige Kategorie. Verwende 'prozesse', 'workflows' oder 'tools'."
    exit 1
fi

# Erstelle den Zielordner, falls nicht vorhanden
mkdir -p "${ZIELORDNER}"

# Kopiere das Template und ersetze Platzhalter
cp notizen/skripte/anleitung-template.md "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{TITEL}}/${TITEL}/g" "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{KATEGORIE}}/${KATEGORIE}/g" "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{DATUM}}/${DATUM}/g" "${ZIELORDNER}/${DATEINAME}"

# Platzhalter für die manuelle Bearbeitung belassen
echo "Anleitungsdatei erstellt: ${ZIELORDNER}/${DATEINAME}"
echo "Bitte öffne die Datei und fülle die verbleibenden Platzhalter aus."

# Git-Aktionen, falls Git verfügbar ist
if command -v git &> /dev/null && [ -d ".git" ]; then
    git add "${ZIELORDNER}/${DATEINAME}"
    git commit -m "Neue Anleitung: ${TITEL}"
    echo "Änderungen wurden dem Git-Repository hinzugefügt."
fi
