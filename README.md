# Unterrichtsmaterialien-Generator für das Fach GPG

Dieses Repository enthält einen Generator für Unterrichtsmaterialien im Fach Geschichte/Politik/Geographie (GPG) sowie umfangreiche Leitfäden und Vorlagen für die Unterrichtsplanung und -durchführung.

## Funktionen

- **Material-Generator**: Webbasiertes Tool zur Erstellung von Vergleichstabellen, Bildkarten und Arbeitsblättern
- **Unterrichtseinheiten**: Vorgefertigte Einheiten zu verschiedenen Themen
- **Leitfäden und Vorlagen**: Umfassende Materialien zur Unterrichtsplanung, Lernzielformulierung und Methodenauswahl
- **Miro-Integration**: Optimierte Darstellung der Materialien in Miro-Boards

## Verwendung

1. **Unterrichtsmaterialien erstellen**:
   - Öffne `generator.html` in deinem Browser
   - Wähle einen Template-Typ (Tabelle, Bildkarten, Arbeitsblatt)
   - Gib die erforderlichen Informationen ein
   - Generiere den Inhalt mit KI-Unterstützung oder manuell

2. **Neue Unterrichtseinheit erstellen**:
   - Verwende das Skript `create_ue.sh`:
./create_ue.sh einheitsname "Einheitstitel"
3. **Leitfäden und Vorlagen**:
- Unter `notizen/` findest du umfangreiche Leitfäden und Vorlagen:
- Sequenzplanung (`notizen/leitfaden/sequenzplanung/`)
- Lernzielformulierung (`notizen/leitfaden/lernziele/`)
- Classroom Management (`notizen/methodik/classroom-management/`)
- Aktivierende Methoden (`notizen/methodik/aktivierende-methoden/`)
- Visualisierungstechniken (`notizen/methodik/visualisierung/`)
- Differenzierung (`notizen/methodik/differenzierung/`)

4. **Miro-Integration**:
- Materialien können direkt in Miro eingebettet werden
- Optimierte Darstellung durch Miro-spezifisches CSS

## Struktur

- `css/`: Stylesheet-Dateien
- `js/`: JavaScript-Funktionalitäten
- `unterricht/`: Unterrichtsmaterialien nach Themen
- `notizen/`: Leitfäden und theoretische Grundlagen
- `index.html`: Hauptseite der Webplattform
- `generator.html`: Interface zur KI-gestützten Materialerstellung
- `create_ue.sh`: Shell-Skript zur Erstellung neuer Unterrichtseinheiten

## Leitfäden-Übersicht

Eine vollständige Übersicht aller verfügbaren Leitfäden findest du unter [`notizen/index/GPG_Leitfaeden_Index.md`](notizen/index/GPG_Leitfaeden_Index.md).

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe LICENSE für Details.

## Typische Materialien und deren Verwendung

### Vergleichstabellen
Für Vergleichstabellen gibt es zwei Vorlagen:
- `tabelle-template.html`: Standard-Tabelle für statische Inhalte
- `components/editable-table-template.html`: Tabelle mit editierbaren Textfeldern für den Unterrichtseinsatz

Tipps für Vergleichstabellen:
1. Platzieren Sie Kategorien in der Kopfzeile und Vergleichsobjekte in der ersten Spalte
2. Für Unterrichtspräsentationen nutzen Sie die editierbare Variante
3. Für Arbeitsblätter zum Einkleben vermeiden Sie Überschriften und überflüssige Elemente
4. Passen Sie Zellgrößen an den erwarteten Inhalt an

Beispiel-Befehl zur Erstellung:
```bash
./create_ue.sh aegypten "Leben im alten Ägypten"
# Für editierbare Tabelle ergänzen:
create_editable_table "aegypten" "Leben im alten Ägypten"
