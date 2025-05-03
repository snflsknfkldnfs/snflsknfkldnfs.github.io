#!/bin/bash

echo "Starte Update-Prozess..."

./scripts/import_notes.sh
./scripts/index_notes.sh
./scripts/extract_metadata.sh
./scripts/convert_notes.sh
./scripts/integrate_notes.sh
./scripts/update_structure.sh  # Hinzufügen dieser Zeile
node ./scripts/generators/generate_tuv_overview.js
echo "Update abgeschlossen!"
