#!/bin/bash

TEMPLATE_DIR="unterricht/template"
NOTES_DIR="notizen"

function add_context_to_template() {
    TEMPLATE_FILE=$1
    CATEGORY=$2
    
    if grep -q "kontext-dropdown" "$TEMPLATE_FILE"; then
        echo "Kontext-Dropdown existiert bereits in $TEMPLATE_FILE"
        return
    fi
    
    POSITION=$(grep -n "</body>" "$TEMPLATE_FILE" | cut -d':' -f1)
    POSITION=$((POSITION - 1))
    
    DROPDOWN="<div class=\"kontext-dropdown\">\n"
    DROPDOWN+="  <h3>Kontext und Notizen</h3>\n"
    DROPDOWN+="  <select id=\"context-select\" onchange=\"showContext(this.value)\">\n"
    DROPDOWN+="    <option value=\"\">-- Kontext auswählen --</option>\n"
    
    find "$NOTES_DIR/$CATEGORY" -name "*.md" -type f | sort | while read FILE; do
        TITLE=$(head -n 1 "$FILE" | sed 's/^# //')
        REL_PATH=${FILE#*/}
        DROPDOWN+="    <option value=\"$REL_PATH\">$TITLE</option>\n"
    done
    
    DROPDOWN+="  </select>\n"
    DROPDOWN+="  <div id=\"context-content\"></div>\n"
    DROPDOWN+="</div>\n\n"
    DROPDOWN+="<script>\n"
    DROPDOWN+="function showContext(path) {\n"
    DROPDOWN+="  if (!path) {\n"
    DROPDOWN+="    document.getElementById('context-content').innerHTML = '';\n"
    DROPDOWN+="    return;\n"
    DROPDOWN+="  }\n"
    DROPDOWN+="  fetch('/' + path)\n"
    DROPDOWN+="    .then(response => response.text())\n"
    DROPDOWN+="    .then(text => {\n"
    DROPDOWN+="      const converter = new showdown.Converter();\n"
    DROPDOWN+="      document.getElementById('context-content').innerHTML = converter.makeHtml(text);\n"
    DROPDOWN+="    });\n"
    DROPDOWN+="}\n"
    DROPDOWN+="</script>\n"
    
    sed -i "${POSITION}i${DROPDOWN}" "$TEMPLATE_FILE"
    
    echo "Kontext-Dropdown hinzugefügt zu $TEMPLATE_FILE"
}

for TEMPLATE in $(find "$TEMPLATE_DIR" -name "*-template.html"); do
    add_context_to_template "$TEMPLATE" "gpg"
done

echo "Notizen wurden in die Templates integriert."
