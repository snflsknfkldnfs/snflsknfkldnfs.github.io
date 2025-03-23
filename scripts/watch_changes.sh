#!/bin/bash

# Installiere fswatch falls nötig
if ! command -v fswatch &> /dev/null; then
    echo "fswatch ist nicht installiert. Installiere es mit 'brew install fswatch'"
    exit 1
fi

echo "Starte Überwachung des Verzeichnisses..."
fswatch -0 -r $(pwd) | while read -d "" event
do
    ./scripts/update_structure.sh
    echo "Änderung erkannt - Struktur aktualisiert"
done
