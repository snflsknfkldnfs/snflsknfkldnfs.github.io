# {{ title }}

## Basisinformationen
- **Jahrgangsstufe:** {{ jahrgangsstufe }}
- **Fach:** {{ fach }}
- **Lernbereich:** {{ lernbereich }}
- **Dauer:** {{ dauer }} Unterrichtsstunde(n)
- **Erstellt am:** {{ now | format_date }}

## Lehrplanbezug

{{ mcp_link("lehrplan", fach + jahrgangsstufe + "_Lehrplan_LB" + lernbereich[0] + "_Detail") if lernbereich and lernbereich[0].isdigit() else "" }}

**Kompetenzerwartungen (LehrplanPLUS):**
{% if lehrplan and lehrplan.kompetenzerwartungen %}
{% for kompetenz in lehrplan.kompetenzerwartungen %}
- {{ kompetenz }}
{% endfor %}
{% else %}
- Zu definieren
{% endif %}

**Inhalte zu den Kompetenzen:**
{% if lehrplan and lehrplan.inhalte %}
{% for inhalt in lehrplan.inhalte %}
- {{ inhalt }}
{% endfor %}
{% else %}
- Zu definieren
{% endif %}

## Lernziel
Die Schülerinnen und Schüler **[Operator + Inhalt]**, indem sie **[Methode und Rahmenbedingungen]**, was daran erkennbar wird, dass **[konkretes, beobachtbares Ergebnis]**.

## Bezug zum Kompetenzstrukturmodell

{{ mcp_link("kompetenzmodell", fach + "_Kompetenzmodell_Detailanalyse") }}

## Voraussetzungen
- Zu definieren

## Verlaufsplanung

| Zeit | Phase | Lehrer-Schüler-Interaktion | Sozialform/Methode | Medien/Material |
|------|-------|----------------------------|-------------------|-----------------|
| | Einstieg | | | |
| | Erarbeitung | | | |
| | Sicherung | | | |
| | Anwendung | | | |
| | Abschluss | | | |

## Materialien
- Zu definieren

## Differenzierung
- Zu definieren

## Methodische Hinweise
{{ mcp_link("methodik", fach + "_Methodenfinder_Kompetenzorientiert") }}

## Reflexion
- Zu definieren

## QS-Checkliste
- [ ] Lernziel nach Mager-Schema
- [ ] Bezug zu Kompetenzerwartungen des LehrplanPLUS hergestellt
- [ ] Angemessene Methodenwahl für Lernziel
- [ ] Differenzierung berücksichtigt
- [ ] Vollständige Verlaufsplanung mit realistischer Zeiteinteilung
- [ ] Material- und Medieneinsatz reflektiert
