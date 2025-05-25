# NT-Dokumentationsprozess: Systematische Metastruktur

## 1. Grundlagen und Zielsetzung

### 1.1 Systemische Einordnung
Der NT-Dokumentationsprozess bildet das methodische Rahmenwerk für die systematische Erstellung, Kategorisierung und Verknüpfung aller Inhalte im Fachbereich Natur und Technik. Er stellt die strukturelle Konsistenz, inhaltliche Kohärenz und funktionale Vernetzung aller Dokumente sicher und ermöglicht dadurch einen systematischen Zugriff auf die Wissensbasis.

### 1.2 Kernprinzipien
- **Naturwissenschaftliche Exaktheit**: Präzise Dokumentation experimenteller Verfahren und Beobachtungen
- **Interdisziplinäre Vernetzung**: Systematische Verknüpfung der Teilgebiete Physik, Chemie, Biologie und Informatik
- **Kompetenzorientierung**: Ausrichtung an den prozessbezogenen Kompetenzen des LehrplanPLUS
- **Experimentelle Fundierung**: Zentrale Rolle des Experiments als Erkenntnismethode
- **Sicherheitsorientierung**: Durchgängige Berücksichtigung von Sicherheitsaspekten

## 2. Dokumententypologie

### 2.1 Primäre Dokumenttypen
- **Konzeptdokumente**: Definieren strukturelle und inhaltliche Grundlagen (Metaebene)
- **Fachdokumente**: Enthalten fachliche Inhalte gemäß Lehrplan/Kompetenzmodell
- **Experimentdokumente**: Beschreiben Versuchsaufbauten, Durchführungen und Auswertungen
- **Sicherheitsdokumente**: Gefährdungsbeurteilungen und Sicherheitshinweise
- **Anwendungsdokumente**: Konkretisieren die praktische Implementierung

### 2.2 Metadatenschema
Jedes Dokument beginnt mit einem standardisierten Metadatenblock:

```yaml
---
typ: [konzept|fachinhalt|experiment|sicherheit|anwendung|index]
fach: NT
jahrgangsstufen: [5|6|7|8|9|10] # kann mehrere oder "alle" enthalten
lernbereiche: 
  - [1 Naturwissenschaftliches Arbeiten|2 Lebensgrundlage Energie|3 Materie in der Natur|4 Wechselwirkungen|5 Technik|6 Informatik]
schwerpunktkompetenzen:
  - [Erkenntnisse gewinnen|Kommunizieren|Bewerten|Anwenden]
teilgebiete:
  - [Physik|Chemie|Biologie|Informatik]
experimenttyp: [Demonstrationsexperiment|Schülerexperiment|Simulation|Modell]
gefaehrdungsbeurteilung: [erforderlich|nicht erforderlich]
verknüpfte_dokumente:
  - relativer/pfad/zu/dokument.md
bearbeitungsstand: [Entwurf|In Bearbeitung|Abgeschlossen|Archiviert]
letzte_aktualisierung: "YYYY-MM-DD"
autor: "Name"
version: "X.Y.Z"
---
```

## 3. Dateistruktur und Benennungskonventionen

### 3.1 Verzeichnisstruktur
Die primäre Strukturierung erfolgt nach funktionalen und fachlichen Aspekten:

```
/notizen/nt/
  ├── meta/                    # Metadokumente zur Struktur und zu Prozessen
  ├── lehrplanbezug/          # Dokumente mit direktem Lehrplanbezug
  ├── kompetenzmodell/        # Kompetenzstrukturmodell und -analysen
  ├── didaktik/               # Didaktische Grundsätze und Konzepte
  ├── methodik/               # Methodische Konzepte und Anwendungen
  │   ├── fachspezifisch/     # NT-spezifische Methoden
  │   ├── experimentell/      # Experimentelle Methoden
  │   └── digital/            # Digitale Werkzeuge und Simulationen
  ├── sequenzplanung/         # Vorlagen und Konzepte für Sequenzplanung
  ├── unterrichtsplanung/     # Vorlagen und Konzepte für Unterrichtsplanung
  ├── beispielsequenzen/      # Konkrete Beispielsequenzen
  ├── lernziele/              # Lernzielformulierung und -analyse
  ├── experimente/            # Experimentsammlungen nach Themen
  │   ├── physik/             # Physikalische Experimente
  │   ├── chemie/             # Chemische Experimente
  │   ├── biologie/           # Biologische Experimente
  │   └── informatik/         # Informatische Projekte
  ├── sicherheit/             # Sicherheitskonzepte und Gefährdungsbeurteilungen
  ├── materialvorlagen/       # Vorlagen für Unterrichtsmaterial
  ├── evaluation/             # Evaluationskonzepte und -instrumente
  ├── best_practices/         # Bewährte Praxisbeispiele
  └── index/                  # Übersichtsdokumente und Navigation
```

### 3.2 Dateibenennungskonvention
Alle Dateien folgen einem einheitlichen Benennungsschema:

`NT[Jahrgangsstufe]_[Bereich]_[Thema]_[Spezifikation].md`

Beispiele:
- `NT7_Lehrplan_LB2_Energie.md`
- `NT7_Experiment_Photosynthese_Sauerstoffnachweis.md`
- `NT7_Sicherheit_Chemikalien_Gefaehrdungsbeurteilung.md`
- `NT_Methodik_Experimentalunterricht_Leitfaden.md`

Bei jahrgangsstufenübergreifenden Dokumenten entfällt die Jahrgangsstufe:
- `NT_Dokumentationsprozess.md`
- `NT_Kompetenzmodell_Analyse.md`

## 4. Prozessmodell für die Dokumentenerstellung

### 4.1 Entwicklungsphasen
Jedes Dokument durchläuft systematisch definierte Entwicklungsphasen:

1. **Konzeption**: Strukturelle und inhaltliche Planung
2. **Fachliche Prüfung**: Sicherstellung der wissenschaftlichen Korrektheit
3. **Didaktische Aufbereitung**: Transformation für die Zielgruppe
4. **Sicherheitsanalyse**: Prüfung auf Gefährdungspotenziale (bei Experimenten)
5. **Vernetzung**: Systematische Verknüpfung mit anderen Dokumenten
6. **Evaluation**: Überprüfung auf Konsistenz und Vollständigkeit
7. **Finalisierung**: Abschluss und Versionierung

### 4.2 Workflow für Experimentdokumentation
Der spezifische Workflow für die Dokumentation von Experimenten umfasst:

1. **Experimentplanung**: Definition von Ziel und Hypothese
2. **Gefährdungsbeurteilung**: Systematische Risikoanalyse
3. **Materialliste**: Vollständige Auflistung aller benötigten Materialien
4. **Versuchsaufbau**: Präzise Beschreibung mit Skizzen/Fotos
5. **Durchführung**: Schrittweise Anleitung
6. **Beobachtung und Auswertung**: Erwartete Ergebnisse und Deutung
7. **Didaktische Einbettung**: Integration in Unterrichtskontext
8. **Differenzierung**: Anpassungsmöglichkeiten für verschiedene Leistungsniveaus

### 4.3 Qualitätssicherung bei Experimenten
- **Reproduzierbarkeit**: Alle Experimente müssen reproduzierbar beschrieben sein
- **Sicherheit**: Vollständige Gefährdungsbeurteilung ist Pflicht
- **Praktikabilität**: Experimente müssen im Schulkontext durchführbar sein
- **Lehrplanbezug**: Klare Verknüpfung mit Kompetenzerwartungen

## 5. Verknüpfungsmodell

### 5.1 Verknüpfungstypen
Die systematische Vernetzung erfolgt durch definierte Beziehungstypen:

- **Fachliche Beziehungen**: Verknüpfung zwischen Teilgebieten (Physik ↔ Chemie)
- **Hierarchische Beziehungen**: Überordnung/Unterordnung (Konzept → Konkretisierung)
- **Experimentelle Beziehungen**: Grundversuch → Variation → Erweiterung
- **Sicherheitsbeziehungen**: Experiment → Gefährdungsbeurteilung
- **Kompetenzbeziehungen**: Inhalt → Kompetenzerwartung → Bewertung

### 5.2 Verknüpfungssyntax im Markdown
Die Verknüpfungen werden einheitlich als relative Pfade umgesetzt:

```markdown
- **Theoretische Grundlage**: [Energieerhaltungssatz](../fachinhalte/physik/energieerhaltung.md)
- **Experiment**: [Energieumwandlung am Pendel](../experimente/physik/pendel_energie.md)
- **Sicherheitshinweise**: [Umgang mit elektrischen Geräten](../sicherheit/elektrizitaet.md)
- **Kompetenzerwartung**: [NT7 LB 2.1](../lehrplanbezug/NT7_LB2_Energie.md#kompetenzerwartungen)
```

## 6. Spezifische Dokumentationsanforderungen für NT

### 6.1 Experimentdokumentation
Jedes Experiment muss folgende Struktur aufweisen:

```markdown
# [Experimenttitel]

## Metadaten
[Metadatenblock]

## Ziel und Kontext
- Lehrplanbezug
- Zu entwickelnde Kompetenzen
- Einordnung in die Unterrichtssequenz

## Gefährdungsbeurteilung
- Gefahrstoffe (falls vorhanden)
- Gefährdungen
- Schutzmaßnahmen
- Entsorgung

## Material und Aufbau
- Detaillierte Materialliste
- Aufbauskizze/Foto
- Vorbereitung

## Durchführung
1. Schrittweise Anleitung
2. Sicherheitshinweise während der Durchführung
3. Zeitangaben

## Beobachtung
- Erwartete Beobachtungen
- Mögliche Fehlerquellen
- Dokumentationshinweise

## Auswertung
- Erklärung der Phänomene
- Bezug zur Theorie
- Transfermöglichkeiten

## Differenzierung
- Vereinfachungen
- Erweiterungen
- Alternative Durchführungen

## Digitale Ergänzungen
- Simulationen
- Videos
- Messwerterfassung
```

### 6.2 Sicherheitsdokumentation
Gefährdungsbeurteilungen folgen dem standardisierten Format:

```markdown
# Gefährdungsbeurteilung: [Experiment/Tätigkeit]

## Tätigkeitsbeschreibung
[Kurze Beschreibung]

## Gefährdungen
| Gefährdung | Risiko | Maßnahmen |
|------------|--------|-----------|
| [Gefährdung 1] | [hoch/mittel/gering] | [Schutzmaßnahme] |

## Erste Hilfe
[Spezifische Erste-Hilfe-Maßnahmen]

## Entsorgung
[Entsorgungshinweise]

## Substitutionsprüfung
[Mögliche ungefährlichere Alternativen]
```

## 7. Integration der Schwerpunktkompetenzen

### 7.1 Erkenntnisse gewinnen
- Beobachten, Vergleichen, Ordnen
- Experimentieren
- Modelle nutzen
- Arbeitstechniken anwenden

### 7.2 Kommunizieren
- Informationen erschließen
- Informationen austauschen
- Fachsprache verwenden
- Dokumentieren und Präsentieren

### 7.3 Bewerten
- Sachverhalte bewerten
- Handlungsoptionen erkennen
- Nachhaltig handeln
- Technikfolgen abschätzen

### 7.4 Anwenden
- Konzepte übertragen
- Problemlösen
- Kreativ gestalten
- Im Alltag umsetzen

## 8. Qualitätskriterien für NT-Dokumente

### 8.1 Fachliche Qualität
- Wissenschaftliche Korrektheit
- Altersgemäße Darstellung
- Aktualität der Inhalte
- Berücksichtigung von Fehlvorstellungen

### 8.2 Didaktische Qualität
- Klarer Kompetenzbezug
- Schülerorientierung
- Differenzierungsmöglichkeiten
- Alltagsbezug

### 8.3 Sicherheitsqualität
- Vollständige Gefährdungsbeurteilung
- Klare Sicherheitshinweise
- Aktuelle Rechtslage
- Praktikable Schutzmaßnahmen

## 9. Digitale Integration

### 9.1 Digitale Werkzeuge
- Messwerterfassungssysteme
- Simulationssoftware
- Modellierungswerkzeuge
- Dokumentationssysteme

### 9.2 Medienintegration
- Videos von Experimenten
- Interaktive Simulationen
- AR/VR-Anwendungen
- Digitale Messdatenauswertung

## 10. Implementierung und kontinuierliche Verbesserung

### 10.1 Implementierungsschritte
1. Etablierung der Grundstruktur
2. Migration bestehender Materialien
3. Systematische Lückenanalyse
4. Schrittweise Vervollständigung
5. Qualitätssicherung
6. Vernetzung optimieren

### 10.2 Evaluationszyklus
- Halbjährliche Überprüfung der Struktur
- Feedback von Nutzern einbeziehen
- Aktualität der Inhalte prüfen
- Neue Entwicklungen integrieren
- Best Practices dokumentieren

## 11. Schnittstellen zu anderen Fächern

### 11.1 Fächerverbindende Aspekte
- Mathematik: Berechnungen und Modellierung
- Informatik: Algorithmisches Denken
- Geographie: Umweltsysteme
- Wirtschaft: Technikfolgen und Nachhaltigkeit

### 11.2 Dokumentation von Verknüpfungen
```markdown
**Fächerverbindung**: Dieses Experiment verbindet sich mit:
- **Mathematik**: [Proportionale Zuordnungen](../../../mathematik/funktionen/proportionalitaet.md)
- **Geographie**: [Treibhauseffekt](../../../gpg/klimawandel/treibhauseffekt.md)
```

Diese Metastruktur bildet das Fundament für eine systematische, sichere und didaktisch hochwertige Dokumentation des NT-Unterrichts, die den besonderen Anforderungen des naturwissenschaftlichen Arbeitens gerecht wird.
