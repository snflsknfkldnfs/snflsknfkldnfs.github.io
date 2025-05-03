# WiB-Dokumentationsprozess: Systematische Metastruktur

## 1. Grundlagen und Zielsetzung

### 1.1 Systemische Einordnung
Der WiB-Dokumentationsprozess bildet das methodische Rahmenwerk für die systematische Erstellung, Kategorisierung und Verknüpfung aller Inhalte im Fachbereich Wirtschaft und Beruf. Er stellt die strukturelle Konsistenz, inhaltliche Kohärenz und funktionale Vernetzung aller Dokumente sicher und ermöglicht dadurch einen systematischen Zugriff auf die Wissensbasis.

### 1.2 Kernprinzipien
- **Strukturelle Kohärenz**: Einheitliche Organisation durch standardisierte Metadaten und Taxonomie
- **Funktionale Vernetzung**: Systematische Verknüpfung auf Basis definierter Beziehungstypen 
- **Prozessuale Integration**: Einbettung in definierte Arbeitsabläufe und Entwicklungsprozesse
- **Taxonomische Präzision**: Eindeutige Kategorisierung und Klassifikation aller Inhalte
- **Systemische Wachstumsfähigkeit**: Adaptives Framework für organische Weiterentwicklung

## 2. Dokumententypologie

### 2.1 Primäre Dokumenttypen
- **Konzeptdokumente**: Definieren strukturelle und inhaltliche Grundlagen (Metaebene)
- **Inhaltsdokumente**: Enthalten fachliche Inhalte gemäß Lehrplan/Kompetenzmodell
- **Prozessdokumente**: Beschreiben methodische Vorgehensweisen und Abläufe
- **Anwendungsdokumente**: Konkretisieren die praktische Implementierung
- **Indexdokumente**: Bieten Navigation und Systematisierung der Dokumentenlandschaft

### 2.2 Metadatenschema
Jedes Dokument beginnt mit einem standardisierten Metadatenblock:

```yaml
---
typ: [konzept|inhalt|prozess|anwendung|index]
fach: WiB
jahrgangsstufen: [5|6|7|8|9|10] # kann mehrere oder "alle" enthalten
lernbereiche: [1|2|3|4|5] # kann mehrere oder "alle" enthalten
gegenstandsbereiche: 
  - [Arbeit|Berufsorientierung|Wirtschaft|Technik|Recht]
prozessbezogene_kompetenzen:
  - [Handeln|Analysieren|Kommunizieren|Beurteilen]
verknüpfte_dokumente:
  - relativer/pfad/zu/dokument.md
bearbeitungsstand: [Entwurf|In Bearbeitung|Abgeschlossen|Archiviert]
letzte_aktualisierung: "YYYY-MM-DD"
autor: "Name"
version: "X.Y.Z" # Major.Minor.Patch
---
```

## 3. Dateistruktur und Benennungskonventionen

### 3.1 Verzeichnisstruktur
Die primäre Strukturierung erfolgt nach funktionalen Aspekten:

```
/notizen/wib/
  ├── meta/              # Metadokumente zur Struktur und zu Prozessen
  ├── lehrplanbezug/     # Dokumente mit direktem Lehrplanbezug
  ├── kompetenzmodell/   # Kompetenzstrukturmodell und -analysen
  ├── didaktik/          # Didaktische Grundsätze und Konzepte
  ├── methodik/          # Methodische Konzepte und Anwendungen
  │   ├── fachspezifisch/    # WiB-spezifische Methoden
  │   ├── fachtypisch/       # Übertragbare fachtypische Methoden
  │   └── projektunterricht/ # Projekt- und handlungsorientierte Methoden
  ├── sequenzplanung/    # Vorlagen und Konzepte für Sequenzplanung
  ├── unterrichtsplanung/ # Vorlagen und Konzepte für Unterrichtsplanung
  ├── beispielsequenzen/ # Konkrete Beispielsequenzen
  ├── lernziele/         # Lernzielformulierung und -analyse
  ├── materialvorlagen/  # Vorlagen für Unterrichtsmaterial
  ├── evaluation/        # Evaluationskonzepte und -instrumente
  ├── best_practices/    # Bewährte Praxisbeispiele
  └── index/             # Übersichtsdokumente und Navigation
```

### 3.2 Dateibenennungskonvention
Alle Dateien folgen einem einheitlichen Benennungsschema:

`WiB[Jahrgangsstufe]_[Bereich]_[Thema]_[Spezifikation].md`

Beispiele:
- `WiB5_Lehrplan_LB2_Detail.md`
- `WiB_Methodik_Realbegegnung_Checkliste.md`
- `WiB7_Sequenz_Wirtschaft_Marktformen.md`

Bei jahrgangsstufenübergreifenden Dokumenten entfällt die Jahrgangsstufe:
- `WiB_Dokumentationsprozess.md`
- `WiB_Kompetenzmodell_Analyse.md`

## 4. Prozessmodell für die Dokumentenerstellung

### 4.1 Entwicklungsphasen
Jedes Dokument durchläuft systematisch definierte Entwicklungsphasen:

1. **Konzeption**: Strukturelle und inhaltliche Planung
2. **Entwurf**: Initiale Erstellung mit Grundstruktur
3. **Ausarbeitung**: Detaillierte Entwicklung aller Inhalte
4. **Vernetzung**: Systematische Verknüpfung mit anderen Dokumenten
5. **Evaluation**: Überprüfung auf Konsistenz und Vollständigkeit
6. **Finalisierung**: Abschluss und Versionierung

### 4.2 Workflow für Lehrplanumsetzung
Der spezifische Workflow für die Transformation des Lehrplans umfasst:

1. **Lehrplananalyse**: Systematische Erfassung der Kompetenzerwartungen
2. **Taxonomische Klassifikation**: Einordnung in Anforderungsbereiche
3. **Didaktische Transformation**: Operationalisierung der Kompetenzerwartungen
4. **Methodische Konkretisierung**: Verknüpfung mit geeigneten Methoden
5. **Exemplarische Implementierung**: Erstellung von Anwendungsbeispielen
6. **Systematische Vernetzung**: Integration in das Gesamtsystem

### 4.3 Iterativer Verbesserungsprozess
Die kontinuierliche Optimierung erfolgt durch:

1. **Nutzungsdokumentation**: Erfassung von Anwendungserfahrungen
2. **Systematische Reflexion**: Analyse von Stärken und Schwächen
3. **Kollaborative Optimierung**: Einbeziehung verschiedener Perspektiven
4. **Versionierte Weiterentwicklung**: Transparente Dokumentation von Änderungen

## 5. Verknüpfungsmodell

### 5.1 Verknüpfungstypen
Die systematische Vernetzung erfolgt durch definierte Beziehungstypen:

- **Hierarchische Beziehungen**: Überordnung/Unterordnung (Konzept → Konkretisierung)
- **Sequenzielle Beziehungen**: Vorgänger/Nachfolger (zeitliche/logische Abfolge)
- **Konzeptuelle Beziehungen**: Inhaltliche Zusammenhänge (thematische Verbindung)
- **Implementierungsbeziehungen**: Theorie/Praxis (Konzept → Anwendung)
- **Differenzierungsbeziehungen**: Grundform/Varianten (Basiskonzept → Adaptionen)

### 5.2 Verknüpfungssyntax im Markdown
Die Verknüpfungen werden einheitlich als relative Pfade umgesetzt:

```markdown
- **Konzeptbezug**: [Dokumenttitel](../pfad/zum/dokument.md)
- **Methodischer Bezug**: [Methodenname](../methodik/methode.md)
- **Beispielimplementierung**: [Beispieltitel](../beispielsequenzen/beispiel.md)
```

Bei komplexen Bezügen mit Erläuterung:

```markdown
- **Konzeptbezug**: Die [Grundprinzipien der Handlungsorientierung](../didaktik/handlungsorientierung.md) 
  bilden die Basis für die hier dargestellte methodische Konkretisierung.
```

## 6. Qualitätssicherung und -entwicklung

### 6.1 Qualitätskriterien
Die systematische Qualitätssicherung orientiert sich an definierten Kriterien:

1. **Strukturelle Integrität**: Einhaltung der Metastruktur und Konventionen
2. **Inhaltliche Konsistenz**: Widerspruchsfreiheit zu verwandten Dokumenten
3. **Funktionale Vernetzung**: Adäquate Einbettung ins Gesamtsystem
4. **Didaktische Transformation**: Gelungene Operationalisierung von Lehrplaninhalten
5. **Praktische Anwendbarkeit**: Konkrete Umsetzbarkeit im Unterrichtskontext

### 6.2 Versionierungskonzept
Die systematische Dokumentation von Entwicklungsständen erfolgt durch:

- **Semantische Versionierung**: MAJOR.MINOR.PATCH
  - MAJOR: Grundlegende konzeptionelle Änderungen
  - MINOR: Inhaltliche Erweiterungen/Ergänzungen
  - PATCH: Korrekturen und kleinere Optimierungen
- **Änderungsprotokoll**: Dokumentation aller substantiellen Änderungen
- **Entwicklungsstand-Markierung**: Explizite Kennzeichnung des Bearbeitungsstatus

## 7. Implementierungsschritte

### 7.1 Initial-Setup
1. Erstellung der Meta-Dokumentationsstruktur
2. Definition der grundlegenden Taxonomie
3. Implementierung der Verzeichnisstruktur
4. Erstellung von Template-Dokumenten für jeden Dokumenttyp

### 7.2 Inhaltsintegration
1. Systematische Erfassung des Lehrplans nach Jahrgangsstufen
2. Entwicklung des Kompetenzstrukturmodells und seiner Operationalisierung
3. Integration vorhandener Materialien in die neue Struktur
4. Identifikation und Schließung inhaltlicher Lücken

### 7.3 Prozessimplementierung
1. Etablierung des Dokumentationsprozesses für neue Inhalte
2. Implementierung regelmäßiger Qualitätschecks
3. Training zur Anwendung der Metastruktur
4. Entwicklung von Automatisierungsmöglichkeiten für wiederkehrende Aufgaben

## 8. Integration mit dem DiSoAn-Ansatz

Die WiB-Metastruktur adaptiert zentrale Elemente des DiSoAn-Ansatzes:

1. **Systemtheoretische Fundierung**: Betrachtung des Dokumentationsystems als autopoietisches System
2. **Prozessuale Perspektive**: Fokus auf definierte Abläufe statt statischer Strukturen
3. **Differenzierte Taxonomie**: Präzise kategoreale Einordnung aller Entitäten
4. **Funktionale Metadaten**: Systematische Erschließung durch strukturierte Metainformationen
5. **Versionierte Entwicklung**: Transparente Dokumentation der Systemevolution

## 9. Glossar der Schlüsselbegriffe

- **Dokumenttyp**: Primäre Klassifikation von Dokumenten nach ihrer Funktion
- **Gegenstandsbereich**: Inhaltliche Dimension des WiB-Kompetenzstrukturmodells
- **Prozessbezogene Kompetenz**: Methodische Dimension des WiB-Kompetenzstrukturmodells
- **Lernbereich**: Struktureinheit des Lehrplans (LB 1-5)
- **Verknüpfungstyp**: Art der inhaltlichen oder strukturellen Beziehung zwischen Dokumenten
- **Taxonomie**: Hierarchisches Klassifikationssystem für die inhaltliche Einordnung
- **Metadaten**: Strukturierte Informationen über ein Dokument (nicht Teil des Inhalts)
- **Versionierung**: Systematische Kennzeichnung von Entwicklungsständen

## 10. Anhang: Template-Beispiele

### 10.1 Konzeptdokument-Template

```markdown
# [Titel des Konzepts]

---
typ: konzept
fach: WiB
jahrgangsstufen: [relevant für welche Jahrgangsstufen]
lernbereiche: [relevante Lernbereiche]
gegenstandsbereiche: 
  - [relevante Gegenstandsbereiche]
prozessbezogene_kompetenzen:
  - [relevante prozessbezogene Kompetenzen]
verknüpfte_dokumente:
  - [relevante verknüpfte Dokumente]
bearbeitungsstand: Entwurf
letzte_aktualisierung: "YYYY-MM-DD"
autor: "Name"
version: "0.1.0"
---

## 1. Grundlagen und Zielsetzung

### 1.1 Systemische Einordnung
[Beschreibung der Positionierung im Gesamtsystem]

### 1.2 Kernprinzipien
- [Prinzip 1]
- [Prinzip 2]
- [...]

## 2. Konzeptionelle Struktur

### 2.1 [Strukturelement 1]
[Beschreibung]

### 2.2 [Strukturelement 2]
[Beschreibung]

## 3. Anwendungsperspektiven

### 3.1 [Anwendungskontext 1]
[Beschreibung]

### 3.2 [Anwendungskontext 2]
[Beschreibung]

## 4. Verknüpfungen im Gesamtsystem

- **[Verknüpfungstyp 1]**: [Verknüpfung 1]
- **[Verknüpfungstyp 2]**: [Verknüpfung 2]
- [...]

## 5. Implementierungshinweise

### 5.1 [Implementierungsaspekt 1]
[Beschreibung]

### 5.2 [Implementierungsaspekt 2]
[Beschreibung]
```

### 10.2 Lehrplandetail-Template

```markdown
# WiB [Jahrgangsstufe] - Lernbereich [Nummer]: [Titel]

---
typ: inhalt
fach: WiB
jahrgangsstufen: [Jahrgangsstufe]
lernbereiche: [Lernbereich]
gegenstandsbereiche: 
  - [relevante Gegenstandsbereiche]
prozessbezogene_kompetenzen:
  - [relevante prozessbezogene Kompetenzen]
verknüpfte_dokumente:
  - [relevante verknüpfte Dokumente]
bearbeitungsstand: Entwurf
letzte_aktualisierung: "YYYY-MM-DD"
autor: "Name"
version: "0.1.0"
---

## 1. Lehrplanreferenz

### 1.1 Kompetenzerwartungen
Die Schülerinnen und Schüler...
- [Kompetenzerwartung 1]
- [Kompetenzerwartung 2]
- [...]

### 1.2 Inhalte zu den Kompetenzen
- [Inhalt 1]
- [Inhalt 2]
- [...]

## 2. Kompetenzstrukturmodell-Bezug

### 2.1 Primärer Gegenstandsbereich
- **[Gegenstandsbereich]**: [Beschreibung des Bezugs]

### 2.2 Prozessbezogene Kompetenzen
- **[Prozessbezogene Kompetenz 1]**: [Beschreibung des Schwerpunkts]
- **[Prozessbezogene Kompetenz 2]**: [Beschreibung des Schwerpunkts]

### 2.3 Taxonomische Einordnung
- **Anforderungsbereich I**: [zugehörige Kompetenzaspekte]
- **Anforderungsbereich II**: [zugehörige Kompetenzaspekte]
- **Anforderungsbereich III**: [zugehörige Kompetenzaspekte]

## 3. Curriculare Einordnung

### 3.1 Vertikale Progression
- **Voraussetzungen aus [vorherige Stufe]**: [Beschreibung]
- **Weiterführung in [nachfolgende Stufe]**: [Beschreibung]

### 3.2 Horizontale Vernetzung
- **[Fach 1]**: [Beschreibung der Verknüpfung]
- **[Fach 2]**: [Beschreibung der Verknüpfung]

[weitere Abschnitte nach Bedarf...]
```

### 10.3 Sequenzplanungs-Template

```markdown
# Sequenzplanung: [Titel der Sequenz]

---
typ: anwendung
fach: WiB
jahrgangsstufen: [Jahrgangsstufe]
lernbereiche: [relevante Lernbereiche]
gegenstandsbereiche: 
  - [relevante Gegenstandsbereiche]
prozessbezogene_kompetenzen:
  - [relevante prozessbezogene Kompetenzen]
verknüpfte_dokumente:
  - [relevante verknüpfte Dokumente]
zeitraum: [Zeitraum]
umfang: [Anzahl Stunden]
bearbeitungsstand: Entwurf
letzte_aktualisierung: "YYYY-MM-DD"
autor: "Name"
version: "0.1.0"
---

## 1. Basisinformationen
- **Thema der Sequenz:** [Titel]
- **Zeitraum:** [Zeitraum] ([Anzahl] Unterrichtsstunden)
- **Jahrgangsstufe:** [Jahrgangsstufe]
- **Verknüpfte Lernbereiche:** [Lernbereiche]

## 2. Lehrplanbezug

### 2.1 Kompetenzerwartungen (LehrplanPLUS)
[Liste der Kompetenzerwartungen nach Lernbereichen]

### 2.2 Inhalte zu den Kompetenzen
[Liste der Inhalte zu den Kompetenzen]

[weitere Abschnitte nach Bedarf...]
```

## Ausblick: Kontinuierliche Weiterentwicklung

Die WiB-Metastruktur ist als lernendes System konzipiert, das durch praktische Anwendung kontinuierlich optimiert wird. Regelmäßige Reflexionszyklen, systematisches Feedback und die Integration neuer Erkenntnisse sichern die nachhaltige Qualitätsentwicklung.
