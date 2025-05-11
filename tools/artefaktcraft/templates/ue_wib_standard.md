---
type: unterrichtseinheit
title: "{{ title }}"
subject: "{{ subject }}"
grade: "{{ grade }}"
topic: "{{ topic }}"
subtopic: "{{ subtopic }}"
learningAreas: {{ learningAreas }}
competencyAreas: {{ competencyAreas }}
processCompetencies: {{ processCompetencies }}
duration: "{{ duration }}"
prerequisites: {{ prerequisites }}
resources: {{ resources }}
author: "{{ author }}"
created: "{{ created }}"
modified: "{{ modified }}"
version: "{{ version }}"
status: "{{ status }}"
description: "Standard-Template für WiB-Unterrichtseinheiten"
---

# {{ title }}

## Basisinformationen

- **Fach:** {{ subject }}
- **Jahrgangsstufe:** {{ grade }}
- **Dauer:** {{ duration }} Minuten
- **Thema:** {{ topic }}
- **Unterthema:** {{ subtopic }}

## Lehrplanbezug

### Kompetenzerwartungen (LehrplanPLUS)
{{ curriculum.competencyExpectations }}

### Inhalte zu den Kompetenzen
{{ curriculum.contents }}

### Bezug zum Kompetenzstrukturmodell

- **Gegenstandsbereiche:** 
{{#each competencyAreas}}
  - {{ item }}
{{/each}}

- **Prozessbezogene Kompetenzen:**
{{#each processCompetencies}}
  - {{ item }}
{{/each}}

## Lernziele

Die Schülerinnen und Schüler...

- **können** [Kompetenz], indem sie [Methode/Bedingungen], was daran erkennbar wird, dass [Beurteilungsmaßstab].
- **[Operator]** [Inhalt], indem sie [Methode/Bedingungen], was daran erkennbar wird, dass [Beurteilungsmaßstab].

## Voraussetzungen und Vorwissen

{{#each prerequisites}}
- {{ item }}
{{/each}}

## Materialien und Medien

- [Liste der benötigten Materialien und Medien]
- [Verweis auf Arbeitsblätter]
- [Verweis auf Tafelbilder]

## Verlaufsplanung

| Zeit | Phase | Lehrer-Schüler-Interaktion | Sozialform/Methode | Medien/Material |
|------|-------|----------------------------|-------------------|-----------------|
| Min. | Einleitung | [Beschreibung des Lehrerverhaltens und der Schüleraktivitäten] | [Sozialform] | [Verwendete Medien] |
| Min. | Erarbeitung | [Beschreibung] | [Sozialform] | [Verwendete Medien] |
| Min. | Sicherung | [Beschreibung] | [Sozialform] | [Verwendete Medien] |
| Min. | Anwendung | [Beschreibung] | [Sozialform] | [Verwendete Medien] |
| Min. | Reflexion | [Beschreibung] | [Sozialform] | [Verwendete Medien] |

## Differenzierung

### Für leistungsstärkere Schülerinnen und Schüler
- [Differenzierungsmaßnahmen nach oben]

### Für leistungsschwächere Schülerinnen und Schüler
- [Differenzierungsmaßnahmen nach unten]

## Erwartete Ergebnisse
- [Beschreibung der erwarteten Schülerergebnisse]
- [Mögliche Lösungen]

## Verknüpfte Materialien
{{#each resources}}
- {{ item }}
{{/each}}

## Verknüpfte Ressourcen
{{ similar_resources }}

## Reflexionsfragen
- Wurden die Lernziele erreicht?
- Welche Phasen haben besonders gut funktioniert?
- Wo gab es Schwierigkeiten?
- Welche Anpassungen würden das nächste Mal helfen?

---

*Diese Unterrichtseinheit wurde mit ArtefaktCraft erstellt*