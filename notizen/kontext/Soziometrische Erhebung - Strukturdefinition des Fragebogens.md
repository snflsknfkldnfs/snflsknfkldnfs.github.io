# Soziometrische Erhebung - Strukturdefinition des Fragebogens

## Metadaten
- survey_id: "soziometrie_[klassenname]_[datum]"
- response_type: "matrix_multiple"
- scale_type: "nominal" & "ordinal"

## Einleitung
[Standardtext wie im vorherigen Fragebogen]

## Dimensionen und Operationalisierung

### 1. Sympathie-Dimension
#### 1.1 Direkte Arbeitsbeziehungen [SYM_ARB]
"Mit wem arbeitest du im Unterricht gerne zusammen?"
- Typ: Multiple Choice (3 Wahlen)
- Ranking: 1-3 (Priorität)
- Variable: sym_arb_[1-3]
- Zusatzskala: Intensität der Präferenz (1-5)

#### 1.2 Soziale Beziehungen [SYM_SOZ]
"Mit wem verbringst du in den Pausen gerne Zeit?"
- Typ: Multiple Choice (3 Wahlen)
- Ranking: 1-3 (Priorität)
- Variable: sym_soz_[1-3]
- Zusatzskala: Häufigkeit (1-5)

### 2. Experten-Dimension
#### 2.1 Fachliche Unterstützung [EXP_FACH]
"Wen würdest du bei Fachfragen um Hilfe bitten?"
- Typ: Matrix-Frage
- Fächer: Deutsch, Mathe, Englisch
- Ranking: 1-3 pro Fach
- Variable: exp_fach_[fach]_[1-3]

#### 2.2 Organisatorische Kompetenz [EXP_ORG]
"Wer kann gut..."
- Typ: Matrix-Frage
- Items:
  - "...eine Gruppenarbeit organisieren?"
  - "...schwierige Aufgaben erklären?"
  - "...bei Konflikten vermitteln?"
- Ranking: 1-3 pro Item
- Variable: exp_org_[item]_[1-3]

### 3. Arbeitsverhalten-Dimension [ARB_STIL]
"Wie arbeitest du am liebsten?"
- Typ: Likert-Skala (1-5)
- Items:
  - "Ich arbeite gerne in der Gruppe"
  - "Ich erkläre anderen gerne etwas"
  - "Ich lerne am besten alleine"
  - "Ich helfe anderen gerne"
- Variable: arb_stil_[item]

## Technische Spezifikationen für LimeSurvey

### Fragengruppen
1. Einleitung und Demographie
2. Sympathie-Matrix
3. Experten-Matrix
4. Arbeitsstil-Skalen

### Antwortcodierung
- Nominale Wahlen: [schüler_id]
- Ordinale Skalen: 1-5
- Rankings: 1-3
- Fehlende Werte: -99

### Exportformat
- CSV mit Semikolon-Trennung
- UTF-8 Kodierung
- Vollständige Variablenlabels
- Zeitstempel

### Datenvalidierung
- Pflichtfelder: Mindestens eine Wahl pro Dimension
- Plausibilitätschecks: Keine Selbstwahl
- Konsistenzprüfung: Unterschiedliche Namen pro Ranking

## Visualisierungsanforderungen

### Netzwerkanalyse
- Gerichtete Kanten für Wahlen
- Gewichtung durch Ranking
- Farbcodierung nach Dimensionen
- Filter nach Beziehungstypen

### Metriken
- Zentralitätsmaße
- Reziprozität von Wahlen
- Cluster-Koeffizienten
- Dichte des Netzwerks

### Interaktive Features
- Dimensionsfilter
- Teilgruppen-Analyse
- Zeitliche Entwicklung
- Individuelle Profile

## Datenschutz
- Pseudonymisierung durch ID-Mapping
- Verschlüsselte Speicherung
- Zugriffsprotokollierung
- Löschkonzept