---
type: sequenzplanung
title: "{{ title }}"
subject: "{{ subject }}"
grade: "{{ grade }}"
topic: "{{ topic }}"
subtopic: "{{ subtopic }}"
learningAreas: {{ learningAreas }}
competencyAreas: {{ competencyAreas }}
processCompetencies: {{ processCompetencies }}
duration: "{{ duration }}"
lessons: {{ lessons }}
author: "{{ author }}"
created: "{{ created }}"
modified: "{{ modified }}"
version: "{{ version }}"
status: "{{ status }}"
description: "Standard-Template für WiB-Sequenzplanungen"
---

# {{ title }}

## Basisinformationen

- **Fach:** {{ subject }}
- **Jahrgangsstufe:** {{ grade }}
- **Thema:** {{ topic }}
- **Unterthema:** {{ subtopic }}
- **Zeitraum:** {{ duration }}

## Lehrplanbezug

### Kompetenzerwartungen (LehrplanPLUS)
{{ curriculum.competencyExpectations }}

### Inhalte zu den Kompetenzen
{{ curriculum.contents }}

## Bezug zum Kompetenzstrukturmodell

### Gegenstandsbereiche
- Competency Areas will be listed here

### Prozessbezogene Kompetenzen
{{#each seq_wib_standard_processCompetencies}}
- {{ item }}
{{/each}}

## Einordnung in das Schulcurriculum

- **Vorbereitende Sequenzen:** [Angabe vorheriger Sequenzen]
- **Weiterführende Sequenzen:** [Angabe nachfolgender Sequenzen]
- **Verknüpfungen mit anderen Fächern:** [Fächerübergreifende Bezüge]

## Sequenzüberblick

| Stunde | Thema | Kompetenzerwartungen | Lernziel | Methoden/Sozialformen | Materialien |
|--------|-------|----------------------|----------|----------------------|-------------|
| 1 | [Thema der ersten Stunde] | [Bezug zu Kompetenzerwartungen] | [Lernziel] | [Methoden und Sozialformen] | [Benötigte Materialien] |
| 2 | [Thema der zweiten Stunde] | [Bezug zu Kompetenzerwartungen] | [Lernziel] | [Methoden und Sozialformen] | [Benötigte Materialien] |
| 3 | [Thema der dritten Stunde] | [Bezug zu Kompetenzerwartungen] | [Lernziel] | [Methoden und Sozialformen] | [Benötigte Materialien] |
| 4 | [Thema der vierten Stunde] | [Bezug zu Kompetenzerwartungen] | [Lernziel] | [Methoden und Sozialformen] | [Benötigte Materialien] |
| 5 | [Thema der fünften Stunde] | [Bezug zu Kompetenzerwartungen] | [Lernziel] | [Methoden und Sozialformen] | [Benötigte Materialien] |

## Methodische Schwerpunkte der Sequenz

- [Beschreibung der methodischen Schwerpunkte]
- [Begründung der methodischen Entscheidungen]
- [Progression der Methoden über die Sequenz]

## Differenzierungskonzept

### Grundlegende Differenzierungsmaßnahmen

- [Beschreibung, wie Differenzierung in der gesamten Sequenz umgesetzt wird]

### Zielgruppenspezifische Maßnahmen

- **Für leistungsstärkere Schülerinnen und Schüler:** [Beschreibung der Maßnahmen]
- **Für leistungsschwächere Schülerinnen und Schüler:** [Beschreibung der Maßnahmen]

## Leistungserhebung und -bewertung

### Formative Leistungsbewertung

- [Beschreibung formativer Bewertungsinstrumente und -phasen]

### Summative Leistungsbewertung

- [Beschreibung der abschließenden Leistungserhebung]
- [Bewertungskriterien und -maßstäbe]

## Medien- und Materialeinsatz

- [Übersicht über verwendete Medien und Materialien]
- [Begründung der Medienauswahl]
- [Hinweise zur Beschaffung/Vorbereitung]

## Lernumgebung und Raumgestaltung

- [Anforderungen an die Lernumgebung]
- [Hinweise zur Raumgestaltung]
- [Besondere räumliche Voraussetzungen]

## Fächerübergreifende Bezüge

### Verknüpfungen mit anderen Fächern

- **[Fach 1]:** [Beschreibung der Verknüpfung]
- **[Fach 2]:** [Beschreibung der Verknüpfung]

### Umsetzung übergreifender Bildungs- und Erziehungsziele

- **[Ziel 1]:** [Beschreibung der Umsetzung]
- **[Ziel 2]:** [Beschreibung der Umsetzung]

## Reflexion und Evaluation der Sequenz

### Reflexionsinstrumente

- [Beschreibung der Instrumente zur Reflexion und Evaluation]

### Evaluationskriterien

- [Beschreibung der Kriterien zur Beurteilung des Sequenzerfolgs]

## Verknüpfte Ressourcen
{{ similar_resources }}

---

*Diese Sequenzplanung wurde mit ArtefaktCraft erstellt*
