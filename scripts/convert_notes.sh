#!/bin/bash

NOTES_DIR="notizen"
OUTPUT_DIR="_site/notizen"

mkdir -p $OUTPUT_DIR

find $NOTES_DIR -name "*.md" -type f | while read FILE; do
    REL_PATH=${FILE#*/}
    DIR_PATH=$(dirname "$OUTPUT_DIR/$REL_PATH")
    OUTPUT_FILE="${OUTPUT_DIR}/${REL_PATH%.md}.html"
    
    mkdir -p "$DIR_PATH"
    
    pandoc "$FILE" \
        --standalone \
        --template=_layouts/note.html \
        --metadata title="$(head -n 1 "$FILE" | sed 's/^# //')" \
        --metadata date="$(date -r "$FILE" +"%Y-%m-%d")" \
        -o "$OUTPUT_FILE"
        
    echo "Konvertiert: $FILE -> $OUTPUT_FILE"
done
