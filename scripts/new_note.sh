#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Verwendung: $0 <kategorie> <titel>"
    echo "Beispiel: $0 gpg 'Der Nil als Lebensader Ägyptens'"
    exit 1
fi

CATEGORY=$1
TITLE=$2
DATE=$(date +"%Y-%m-%d")
FILENAME=$(echo "$TITLE" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
TARGET_DIR="notizen/$CATEGORY"
TARGET_FILE="$TARGET_DIR/$FILENAME.md"

mkdir -p "$TARGET_DIR"

cat > "$TARGET_FILE" << EOF
# $TITLE

**Datum:** $DATE  
**Kategorie:** $CATEGORY  
**Tags:** 

## Zusammenfassung

Kurze Zusammenfassung hier einfügen.

## Inhalt

Hauptinhalt hier einfügen.

## Verweise

- [Link zu verwandten Notizen oder Quellen](#)

EOF

echo "Neue Notiz erstellt: $TARGET_FILE"
echo "Sie können die Datei jetzt bearbeiten."

if command -v code &> /dev/null; then
    code "$TARGET_FILE"
elif command -v nano &> /dev/null; then
    nano "$TARGET_FILE"
elif command -v vi &> /dev/null; then
    vi "$TARGET_FILE"
fi
