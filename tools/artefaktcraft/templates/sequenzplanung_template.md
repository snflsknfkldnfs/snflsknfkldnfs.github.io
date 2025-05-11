# Sequenzplanung für {{ fach }} (LehrplanPLUS)

## Basisinformationen
- **Jahrgangsstufe:** {{ jahrgangsstufe }}
- **Thema der Sequenz:** {{ title }}
- **Zeitraum:** {{ zeitraum if zeitraum else "Nicht angegeben" }}
- **Umfang:** {{ umfang }} Unterrichtsstunden
- **Erstellt am:** {{ now | format_date }}

## Lehrplanbezug

{{ mcp_link("lehrplan", fach + jahrgangsstufe + "_Lehrplan_Ueberblick") }}

**Kompetenzerwartungen (LehrplanPLUS):**
- {{ lernbereich }}
{% if lehrplan and lehrplan.kompetenzerwartungen %}
{% for kompetenz in lehrplan.kompetenzerwartungen %}
- {{ kompetenz }}
{% endfor %}
{% else %}
- Weitere Kompetenzerwartungen zu definieren
{% endif %}

**Inhalte zu den Kompetenzen:**
{% if lehrplan and lehrplan.inhalte %}
{% for inhalt in lehrplan.inhalte %}
- {{ inhalt }}
{% endfor %}
{% else %}
- Zu definieren
{% endif %}

## Bezug zu Gegenstandsbereichen und prozessbezogenen Kompetenzen

{{ mcp_link("kompetenzmodell", fach + "_Kompetenzmodell_Detailanalyse") }}

| Gegenstandsbereich | Prozessbezogene Kompetenzen |
|-------------------|----------------------------|
| □ Arbeit           | □ Handeln                   |
| □ Berufsorientierung | □ Analysieren              |
| □ Wirtschaft       | □ Kommunizieren             |
| □ Technik          | □ Beurteilen                |
| □ Recht            |                            |

## Methodische Zugänge

{{ mcp_link("methodik", fach + "_Methodenmatrix_Kompetenzorientiert") }}

## Einbindung in die übergreifenden Bildungs- und Erziehungsziele
- Zu definieren

## Sequenzüberblick

| Stunde | Thema/Inhalt | Kompetenzerwartungen | Methoden/Sozialformen | Materialien/Medien | Lernziele |
|--------|-------------|---------------------|----------------------|-------------------|-----------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

## Differenzierungsaspekte
- Zu definieren

## Lernprodukte und Leistungserhebung
- Zu definieren

## Verknüpfung mit anderen Fächern
- Zu definieren

## Reflexion und Evaluation
- Zu definieren

## QS-Checkliste
- [ ] Vollständiger Lehrplanbezug
- [ ] Kompetenzorientierte Lernziele nach Mager-Schema
- [ ] Methodische Vielfalt
- [ ] Differenzierungsmaßnahmen eingebaut
- [ ] Angemessene Medienintegration
- [ ] Konsistente Lernziel-Methoden-Relation
