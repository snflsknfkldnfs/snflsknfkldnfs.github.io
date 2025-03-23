#!/bin/bash

NOTES_DIR="notizen"
INDEX_FILE="notizen/index.md"

echo "# Notizen-Übersicht" > $INDEX_FILE
echo "" >> $INDEX_FILE
echo "Letzte Aktualisierung: $(date +"%d.%m.%Y %H:%M")" >> $INDEX_FILE
echo "" >> $INDEX_FILE

for CATEGORY in $(ls $NOTES_DIR); do
    if [ -d "$NOTES_DIR/$CATEGORY" ]; then
        echo "## $CATEGORY" >> $INDEX_FILE
        echo "" >> $INDEX_FILE
        
        for FILE in $(find "$NOTES_DIR/$CATEGORY" -name "*.md" -type f | sort); do
            TITLE=$(head -n 1 "$FILE" | sed 's/^# //')
            REL_PATH=${FILE#*/}
            echo "- [$TITLE]($REL_PATH)" >> $INDEX_FILE
        done
        
        echo "" >> $INDEX_FILE
    fi
done

echo "Notizen-Index wurde aktualisiert: $INDEX_FILE"
