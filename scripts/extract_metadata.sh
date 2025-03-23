#!/bin/bash

NOTES_DIR="notizen"
METADATA_FILE="notizen/metadata.json"

echo "[" > $METADATA_FILE

find $NOTES_DIR -name "*.md" -type f | sort | while read FILE; do
    TITLE=$(head -n 1 "$FILE" | sed 's/^# //')
    CATEGORY=$(echo $FILE | cut -d'/' -f2)
    TAGS=$(grep -i "tags:" "$FILE" | sed 's/tags://' | tr -d '[:space:]' | tr ',' ' ')
    DATE=$(grep -i "datum:" "$FILE" | sed 's/datum://' | tr -d '[:space:]')
    
    if [ -z "$DATE" ]; then
        DATE=$(date -r "$FILE" +"%Y-%m-%d")
    fi
    
    echo "  {" >> $METADATA_FILE
    echo "    \"path\": \"$FILE\"," >> $METADATA_FILE
    echo "    \"title\": \"$TITLE\"," >> $METADATA_FILE
    echo "    \"category\": \"$CATEGORY\"," >> $METADATA_FILE
    echo "    \"tags\": \"$TAGS\"," >> $METADATA_FILE
    echo "    \"date\": \"$DATE\"" >> $METADATA_FILE
    echo "  }," >> $METADATA_FILE
done

sed -i '$ s/,$//' $METADATA_FILE

echo "]" >> $METADATA_FILE

echo "Metadaten wurden extrahiert: $METADATA_FILE"
