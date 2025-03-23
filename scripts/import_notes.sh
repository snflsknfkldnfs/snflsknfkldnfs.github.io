#!/bin/bash

NOTIZEN_PATH="$HOME/snflsknfkldnfs.github.io/notizen/anleitungen"
TARGET_PATH="notizen"

mkdir -p "$TARGET_PATH/gpg/5"
mkdir -p "$TARGET_PATH/gpg/6"
mkdir -p "$TARGET_PATH/gpg/7"

find "$NOTIZEN_PATH/01_GPG" -name "*.md" -type f | while read FILE; do
    FILENAME=$(basename "$FILE")
    
    if [[ "$FILENAME" == *"GPG5"* ]]; then
        cp "$FILE" "$TARGET_PATH/gpg/5/"
    elif [[ "$FILENAME" == *"GPG6"* ]]; then
        cp "$FILE" "$TARGET_PATH/gpg/6/"
    elif [[ "$FILENAME" == *"GPG7"* ]]; then
        cp "$FILE" "$TARGET_PATH/gpg/7/"
    else
        cp "$FILE" "$TARGET_PATH/gpg/"
    fi
done

mkdir -p "$TARGET_PATH/methodik"
find "$NOTIZEN_PATH/06_Methoden" -name "*.md" -type f -exec cp {} "$TARGET_PATH/methodik/" \;

mkdir -p "$TARGET_PATH/didaktik"
find "$NOTIZEN_PATH/07_Bausteinskripte" -name "*.md" -type f -exec cp {} "$TARGET_PATH/didaktik/" \;

mkdir -p "$TARGET_PATH/leitfaden"
find "$NOTIZEN_PATH/BUV_Leitfäden" -name "*.md" -type f -exec cp {} "$TARGET_PATH/leitfaden/" \;

echo "Notizen wurden importiert. Indexiere..."

./scripts/index_notes.sh

echo "Import abgeschlossen!"
