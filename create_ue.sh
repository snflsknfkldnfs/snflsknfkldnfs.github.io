#!/bin/bash

if [ -z "$1" ]; then
  echo "Verwendung: ./create_ue.sh UE_NAME UE_TITEL"
  echo "Beispiel: ./create_ue.sh roemisches_reich \"Das Römische Reich\""
  exit 1
fi

if [ -z "$2" ]; then
  echo "Bitte gib einen Titel für die UE an."
  echo "Beispiel: ./create_ue.sh roemisches_reich \"Das Römische Reich\""
  exit 1
fi

UE_NAME=$1
UE_TITEL=$2

mkdir -p "unterricht/$UE_NAME"

cp unterricht/template/tabelle-template.html "unterricht/$UE_NAME/tabelle.html"
cp unterricht/template/bildkarten-template.html "unterricht/$UE_NAME/bildkarten.html"
cp unterricht/template/arbeitsblatt-template.html "unterricht/$UE_NAME/arbeitsblatt.html"

sed -i "s/{{THEMA}}/$UE_TITEL/g" "unterricht/$UE_NAME/tabelle.html"
sed -i "s/{{THEMA}}/$UE_TITEL/g" "unterricht/$UE_NAME/bildkarten.html"
sed -i "s/{{THEMA}}/$UE_TITEL/g" "unterricht/$UE_NAME/arbeitsblatt.html"

cat > "unterricht/$UE_NAME/index.html" << EOL
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$UE_TITEL - Materialien</title>
    <link rel="stylesheet" href="../../css/style.css">
</head>
<body>
    <div class="container">
        <h1>$UE_TITEL</h1>
        
        <div class="instructions">
            <h2>Verfügbare Materialien</h2>
            <p>Hier findest du alle Materialien zum Thema "$UE_TITEL".</p>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>Vergleichstabelle</h3>
                <p>Tabelle mit Informationen zum Thema</p>
                <a href="tabelle.html" target="_blank">Öffnen</a>
            </div>
            
            <div class="card">
                <h3>Bildkarten</h3>
                <p>Bildkarten zu den verschiedenen Aspekten</p>
                <a href="bildkarten.html" target="_blank">Öffnen</a>
            </div>
            
            <div class="card">
                <h3>Arbeitsblatt</h3>
                <p>Interaktives Arbeitsblatt zum Ausfüllen</p>
                <a href="arbeitsblatt.html" target="_blank">Öffnen</a>
            </div>
        </div>
        
        <p><a href="../../index.html">Zurück zur Hauptseite</a></p>
    </div>
</body>
</html>
EOL

CARD_ENTRY="            <div class=\"card\">
                <h3>$UE_TITEL</h3>
                <p>Materialien zum Thema</p>
                <ul>
                    <li><a href=\"unterricht/$UE_NAME/tabelle.html\" target=\"_blank\">Vergleichstabelle</a></li>
                    <li><a href=\"unterricht/$UE_NAME/bildkarten.html\" target=\"_blank\">Bildkarten</a></li>
                    <li><a href=\"unterricht/$UE_NAME/arbeitsblatt.html\" target=\"_blank\">Arbeitsblatt</a></li>
                </ul>
            </div>"

sed -i "s/            <!-- Weitere UEs hier hinzufügen -->/$CARD_ENTRY\n            <!-- Weitere UEs hier hinzufügen -->/" index.html

echo "UE \"$UE_TITEL\" ($UE_NAME) wurde erfolgreich erstellt."
echo "Dateien wurden unter unterricht/$UE_NAME/ abgelegt."
echo "Die Hauptindex-Datei wurde aktualisiert."
