#!/bin/bash

# Überprüfe, ob die notwendigen Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    echo "Verwendung: $0 UE_ORDNER \"REFLEXIONSTITEL\""
    exit 1
fi

UE_ORDNER=$1
THEMA=$2
DATUM=$(date +%Y-%m-%d)
DATEINAME="reflexion_${DATUM// /_}.md"
ZIELORDNER="notizen/reflexionen/unterrichtseinheiten/${UE_ORDNER}"

# Überprüfe, ob der Unterrichtsordner existiert
if [ ! -d "unterricht/${UE_ORDNER}" ]; then
    echo "Fehler: Unterrichtsordner 'unterricht/${UE_ORDNER}' existiert nicht."
    exit 1
fi

# Erstelle den Zielordner, falls nicht vorhanden
mkdir -p "${ZIELORDNER}"

# Kopiere das Template und ersetze Platzhalter
cp notizen/skripte/reflexion-template.md "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{THEMA}}/${THEMA}/g" "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{DATUM}}/${DATUM}/g" "${ZIELORDNER}/${DATEINAME}"
sed -i "" "s/{{UE_ORDNER}}/${UE_ORDNER}/g" "${ZIELORDNER}/${DATEINAME}"

# Platzhalter für die manuelle Bearbeitung belassen
echo "Reflexionsdatei erstellt: ${ZIELORDNER}/${DATEINAME}"
echo "Bitte öffne die Datei und fülle die verbleibenden Platzhalter aus."

# Git-Aktionen, falls Git verfügbar ist
if command -v git &> /dev/null && [ -d ".git" ]; then
    git add "${ZIELORDNER}/${DATEINAME}"
    git commit -m "Neue Reflexion für ${UE_ORDNER}: ${THEMA}"
    echo "Änderungen wurden dem Git-Repository hinzugefügt."
fi
