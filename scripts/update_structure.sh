#!/bin/bash

# Pfad zum Hauptverzeichnis
BASE_DIR=$(pwd)
STRUCTURE_FILE="$BASE_DIR/ordnerstruktur.txt"

# Aktualisiere ordnerstruktur.txt
find "$BASE_DIR" -type d | sort > "$STRUCTURE_FILE"
echo "Ordnerstruktur wurde aktualisiert in: $STRUCTURE_FILE"

# Erstelle eine Dateiliste (optional)
FILE_LIST="$BASE_DIR/dateiliste.txt"
find "$BASE_DIR" -type f -name "*.md" | sort > "$FILE_LIST"
echo "Dateiliste wurde aktualisiert in: $FILE_LIST"

# Füge einen Zeitstempel hinzu
echo "Letzte Aktualisierung: $(date)" >> "$STRUCTURE_FILE"
echo "Letzte Aktualisierung: $(date)" >> "$FILE_LIST"
