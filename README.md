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
