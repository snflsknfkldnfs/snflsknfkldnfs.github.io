# ArtefaktCraft - Benutzerhandbuch

## Einführung

ArtefaktCraft ist ein spezialisiertes Werkzeug zur standardisierten Erstellung hochwertiger Unterrichtsmaterialien für die Fächer Wirtschaft und Beruf (WiB) sowie Geschichte/Politik/Geographie (GPG). Es unterstützt Sie bei der effizienten Erstellung konsistenter, lehrplankonformer Materialien und sorgt für eine gleichbleibend hohe Qualität.

### Für wen ist ArtefaktCraft gedacht?

- **Lehrkräfte**, die effizient standardisierte Unterrichtsmaterialien erstellen möchten
- **Referendare**, die Unterstützung bei der korrekten Erstellung von Unterrichtsentwürfen benötigen
- **Fachschaften**, die einen einheitlichen Materialpool aufbauen wollen
- **Bildungsinstitutionen**, die Qualitätsstandards in der Materialerstellung sicherstellen möchten

## Schnellstart

### Installation

1. **ArtefaktCraft herunterladen und entpacken**
2. **Installation starten**:
   - Windows: Doppelklick auf `setup.exe`
   - macOS/Linux: Terminal öffnen und `./install.sh` ausführen
3. **Folgen Sie den Anweisungen auf dem Bildschirm**

### Erster Start

1. **ArtefaktCraft starten**:
   - Windows: Doppelklick auf das Desktop-Symbol oder im Startmenü öffnen
   - macOS/Linux: Terminal öffnen und `./start-artefaktcraft.sh` ausführen oder Desktop-Icon verwenden
2. **Web-Interface öffnet sich** automatisch in Ihrem Standard-Browser unter `http://localhost:3000/webapp/`
3. **Tutorial folgen**, das beim ersten Start automatisch angezeigt wird

### Erstes Material erstellen

1. **Materialtyp auswählen** (z.B. Unterrichtseinheit)
2. **Fach und Jahrgangsstufe** wählen
3. **Template** auswählen
4. **Auf "Erstellen" klicken**
5. **Metadaten vervollständigen** (Titel, Thema, Lernbereiche, etc.)
6. **Inhalt bearbeiten** und anpassen
7. **"Speichern" klicken**, um das Material zu speichern

## Benutzeroberfläche im Detail

### Hauptbereiche der Benutzeroberfläche

![Benutzeroberfläche ArtefaktCraft](images/ui_overview.png)

1. **Kopfzeile**: Logo und Server-Status
2. **Seitenleiste**: Grundlegende Einstellungen und Aktionen
3. **Metadaten-Bereich**: Verwaltung der Metadaten des Materials
4. **Editor-Bereich**: Bearbeitung des Inhalts mit Vorschau-Option
5. **Ressourcen-Bereich**: Verknüpfung mit anderen Materialien
6. **Fußzeile**: Speichern, Exportieren und Statusmeldungen

### Seitenleiste

Die Seitenleiste enthält alle grundlegenden Einstellungen und Aktionen:

- **Materialtyp**: Wählen Sie zwischen Unterrichtseinheit, Sequenzplanung, Tafelbild, etc.
- **Fach**: Wählen Sie das Unterrichtsfach (WiB, GPG)
- **Jahrgangsstufe**: Wählen Sie die passende Jahrgangsstufe (5-10)
- **Template**: Wählen Sie aus verfügbaren Vorlagen
- **Aktionen**: Buttons zum Erstellen, Laden und Prüfen von Materialien
- **Hilfe**: Zugriff auf Tutorial, Dokumentation und Support

### Metadaten-Bereich

Der Metadaten-Bereich ermöglicht die Eingabe und Verwaltung aller strukturellen Informationen:

- **Titel**: Der Haupttitel des Materials
- **Thema/Unterthema**: Inhaltliche Kategorisierung
- **Lernbereiche**: Auswahl der relevanten Lernbereiche gemäß Lehrplan
- **Gegenstandsbereiche**: Auswahl der Gegenstandsbereiche gemäß Kompetenzmodell
- **Prozessbezogene Kompetenzen**: Auswahl der zu fördernden Kompetenzen
- **Dauer**: Zeitlicher Umfang in Minuten
- **Voraussetzungen**: Notwendige Vorkenntnisse
- **Autor**: Name des Erstellers

Der Button "Lehrplan laden" ermöglicht die automatische Integration passender Lehrplaninhalte aus dem mcp-Server.

### Editor-Bereich

Der Editor-Bereich ist das Herzstück der Anwendung:

- **Markdown-Editor**: Bearbeiten Sie den Inhalt mit Syntax-Hervorhebung
- **Vorschau-Modus**: Betrachten Sie das formatierte Dokument
- **Wechsel zwischen Editor und Vorschau**: Mit einem Klick auf "Vorschau anzeigen"/"Editor anzeigen"

### Ressourcen-Bereich

Der Ressourcen-Bereich ermöglicht die Verknüpfung mit anderen Materialien:

- **Ressourcen-Suche**: Finden Sie relevante Materialien
- **Verknüpfte Ressourcen**: Sehen und verwalten Sie bestehende Verknüpfungen
- **Dynamische Verlinkung**: Erhalten Sie Vorschläge für passende Materialien

## Arbeiten mit Materialtypen

### Unterrichtseinheiten

Unterrichtseinheiten sind detaillierte Planungen für einzelne Unterrichtsstunden:

1. **Metadaten** vollständig ausfüllen, besonders Kompetenzbereiche und Lernbereiche
2. **Lehrplaninhalte laden** mit dem Button "Lehrplan laden"
3. **Lernziele formulieren** nach dem Mager-Schema:
   "Die Schülerinnen und Schüler **[Kompetenz]**, indem sie **[Methode/Bedingungen]**, was daran erkennbar wird, dass **[Beurteilungsmaßstab]**."
4. **Verlaufsplanung** in der Tabelle detaillieren
5. **Differenzierungsaspekte** für verschiedene Leistungsniveaus angeben
6. **Materialien und Medien** auflisten
7. **Erwartete Ergebnisse** beschreiben
8. **Qualitätsprüfung** durchführen mit dem Button "Qualitätsprüfung"

### Sequenzplanungen

Sequenzplanungen bieten einen Überblick über mehrere zusammenhängende Unterrichtsstunden:

1. **Metadaten** vollständig ausfüllen, besonders den Zeitraum und die Kompetenzerwartungen
2. **Lehrplaninhalte laden** für die gesamte Sequenz
3. **Sequenzüberblick** in der Tabelle detaillieren mit allen Stunden
4. **Verknüpfungen zu anderen Fächern** herstellen
5. **Differenzierungskonzept** für die gesamte Sequenz entwickeln
6. **Leistungserhebungen** planen
7. **Qualitätsprüfung** durchführen mit dem Button "Qualitätsprüfung"

### Tafelbilder

Tafelbilder visualisieren zentrale Inhalte für den Unterricht:

1. **Metadaten** ausfüllen, besonders Bezug zum Thema und zur Unterrichtseinheit
2. **Skizze** des Tafelbilds erstellen
3. **Erläuterungen** zur Entwicklung des Tafelbilds hinzufügen
4. **Didaktische Hinweise** zur Verwendung geben
5. **Mit Unterrichtseinheiten verknüpfen** im Ressourcen-Bereich
6. **Qualitätsprüfung** durchführen mit dem Button "Qualitätsprüfung"

## Funktionen im Detail

### Lehrplaninhalte automatisch laden

ArtefaktCraft kann automatisch passende Lehrplaninhalte in Ihre Materialien integrieren:

1. **Fach, Jahrgangsstufe und Lernbereiche** auswählen
2. **"Lehrplan laden" klicken**
3. **Kompetenzerwartungen und Inhalte** werden automatisch eingefügt
4. **Bei Bedarf anpassen**

### Qualitätsprüfung durchführen

Die Qualitätsprüfung hilft Ihnen, hohe Standards einzuhalten:

1. **"Qualitätsprüfung" klicken**
2. **Ergebnisse der Prüfung** werden angezeigt:
   - Grundlegende Metadaten: Vollständigkeit der Basisdaten
   - Strukturelle Integrität: Korrekte Gliederung des Dokuments
   - Template-Vollständigkeit: Keine unersetzten Platzhalter
   - Fachspezifische Standards: Einhaltung didaktischer Grundsätze
3. **"Automatische Korrekturen anwenden"** für schnelle Fehlerbehebung
4. **Manuelle Nachbesserungen** bei Bedarf vornehmen

### Materialien mit anderen Ressourcen verknüpfen

Die Vernetzung von Materialien verbessert den Unterrichtskontext:

1. **Im Ressourcen-Bereich nach ähnlichen Materialien suchen**
2. **Relevante Ressourcen auswählen** durch Klick
3. **Verknüpfte Ressourcen** werden im Dokument als dynamische Links eingefügt
4. **Dynamische Vorschläge** werden automatisch basierend auf Ihren Metadaten angeboten

### Exportieren und Teilen

Ihre fertigen Materialien können Sie auf verschiedene Weise nutzen:

1. **"Exportieren" klicken** in der Fußzeile
2. **Format wählen**:
   - Markdown: Für die Weiterbearbeitung
   - PDF: Für den Druck und die finale Verwendung
   - HTML: Für die Online-Nutzung
3. **Speicherort auswählen**
4. **Mit Kollegen teilen** über Ihr Repository oder andere Plattformen

## Erweiterte Funktionen

### Offline-Modus

ArtefaktCraft kann auch ohne aktive Internetverbindung genutzt werden:

1. **Lokale Templates werden verwendet**
2. **Basisvalidierung** wird direkt durchgeführt
3. **Synchronisierung** erfolgt, sobald die Verbindung wiederhergestellt ist

### Integration mit Git-Repository

Für eine optimale Versionskontrolle:

1. **In den Einstellungen das Git-Repository konfigurieren**
2. **Beim Speichern werden Änderungen automatisch committet**
3. **Versionsverlauf** kann eingesehen werden
4. **Gemeinsame Arbeit an Materialien** wird ermöglicht

### Template-Anpassung

Erstellen und passen Sie Templates an Ihre Bedürfnisse an:

1. **"Templates verwalten" im Einstellungsmenü öffnen**
2. **Bestehendes Template klonen oder neues erstellen**
3. **Anpassungen vornehmen** mit dem Template-Editor
4. **Template veröffentlichen** für andere Nutzer

## Häufige Fragen und Problembehebung

### Der mcp-Server startet nicht

**Problem**: ArtefaktCraft meldet "Server offline" oder startet nicht.

**Lösungen**:
1. Prüfen Sie, ob bereits eine andere Anwendung Port 3000 nutzt
2. Starten Sie ArtefaktCraft mit Administrator-/Root-Rechten
3. Überprüfen Sie die Log-Datei unter `logs/mcp-server.log`
4. Starten Sie Ihren Computer neu und versuchen Sie es erneut

### Änderungen werden nicht gespeichert

**Problem**: Speichern von Materialien scheint zu funktionieren, aber Änderungen sind nicht sichtbar.

**Lösungen**:
1. Überprüfen Sie die Berechtigungen im Repository-Verzeichnis
2. Prüfen Sie den Speicherort unter "Einstellungen > Dateipfade"
3. Stellen Sie sicher, dass der mcp-Server Schreibzugriff hat

### Lehrplaninhalte können nicht geladen werden

**Problem**: Die Funktion "Lehrplan laden" zeigt keine Ergebnisse.

**Lösungen**:
1. Stellen Sie sicher, dass der mcp-Server online ist
2. Prüfen Sie, ob die ausgewählten Lernbereiche korrekt sind
3. Aktualisieren Sie die Lehrplan-Datenbank unter "Einstellungen > Datenbanken"

### Die Qualitätsprüfung zeigt zu viele Fehler

**Problem**: Die Qualitätsprüfung markiert korrekte Inhalte als fehlerhaft.

**Lösungen**:
1. Prüfen Sie, ob Sie das richtige Template für Ihren Materialtyp verwenden
2. Lesen Sie die detaillierten Fehlerbeschreibungen sorgfältig
3. Nutzen Sie "Automatische Korrekturen" für Standardprobleme
4. Passen Sie die Qualitätsstandards unter "Einstellungen > Prüfoptionen" an

## Tipps für effizientes Arbeiten

1. **Tutorial vollständig durcharbeiten** beim ersten Start
2. **Tastenkombinationen nutzen**:
   - `Strg+S`: Speichern
   - `Strg+P`: Vorschau umschalten
   - `Strg+Q`: Qualitätsprüfung
   - `Strg+L`: Lehrplan laden
3. **Templates für wiederkehrende Materialtypen anpassen**
4. **Materialien konsequent verknüpfen** für bessere Konsistenz
5. **Regelmäßige Qualitätsprüfungen** durchführen, nicht erst am Ende
6. **Repository-Integration nutzen** für Versionskontrolle
7. **Metadaten sorgfältig pflegen** für bessere Auffindbarkeit
8. **Nach ähnlichen Materialien suchen**, bevor Sie neue erstellen

## Glossar

- **ArtefaktCraft**: Das Gesamtsystem zur standardisierten Erstellung von Unterrichtsmaterialien
- **mcp-Server**: Die Middleware-Komponente, die für dynamische Funktionen und Datenverwaltung zuständig ist
- **Template**: Eine Vorlage für verschiedene Materialtypen mit vordefinierten Strukturen
- **Metadata**: Strukturierte Informationen über ein Material (Fach, Jahrgangsstufe, Thema, etc.)
- **Lernbereich**: Kategorisierung von Lehrplaninhalten (z.B. LB1-LB5 in WiB)
- **Gegenstandsbereich**: Inhaltliche Dimension des Kompetenzstrukturmodells (z.B. Arbeit, Wirtschaft)
- **Prozessbezogene Kompetenz**: Methodische Dimension des Kompetenzstrukturmodells (z.B. Handeln, Analysieren)
- **Qualitätsprüfung**: Automatisierte Überprüfung der Materialqualität nach definierten Standards
- **Dynamische Verlinkung**: System zur intelligenten Verknüpfung zusammengehöriger Materialien

## Anhang

### Unterstützte Markdown-Syntax

ArtefaktCraft verwendet standardisiertes Markdown mit einigen Erweiterungen:

| Element | Syntax | Beispiel |
|---------|--------|----------|
| Überschrift | `# Überschrift` | # Hauptüberschrift |
| Unterüberschrift | `## Unterüberschrift` | ## Abschnitt |
| Fett | `**Text**` | **wichtig** |
| Kursiv | `*Text*` | *betont* |
| Liste | `- Element` | - Punkt 1 |
| Nummerierte Liste | `1. Element` | 1. Schritt 1 |
| Tabelle | `\|Spalte 1\|Spalte 2\|` | |Kopf1|Kopf2| |
| Link | `[Text](URL)` | [Link](https://example.com) |
| Bild | `![Alt-Text](URL)` | ![Bild](bild.jpg) |

### Tastenkombinationen

| Kombination | Funktion |
|-------------|----------|
| Strg+S | Speichern |
| Strg+P | Vorschau umschalten |
| Strg+Q | Qualitätsprüfung |
| Strg+L | Lehrplan laden |
| Strg+F | Suchen im Dokument |
| Strg+Space | Autovervollständigung |
| Strg+Z | Rückgängig |
| Strg+Shift+Z | Wiederherstellen |
| Strg+B | Fett formatieren |
| Strg+I | Kursiv formatieren |

### Unterstützte Materialtypen

| Typ | Beschreibung | Hauptelemente |
|-----|-------------|---------------|
| Unterrichtseinheit | Detaillierte Planung einer Unterrichtsstunde | Lernziele, Verlaufsplanung, Differenzierung |
| Sequenzplanung | Überblick über mehrere zusammenhängende Stunden | Kompetenzerwartungen, Stundenübersicht |
| Tafelbild | Visualisierung für den Unterricht | Skizze, Erläuterungen |
| Arbeitsblatt | Aufgaben für Schülerinnen und Schüler | Aufgabenstellungen, Materialien |
| Projekt | Projektplanung mit Leittextmethode | Projektphasen, Materialien |
| Lernzielkontrolle | Überprüfung des Lernerfolgs | Aufgaben, Erwartungshorizont |

---

Erstellt mit ArtefaktCraft v1.0
