# Standardisierte Prompt-Templates für WiB-Unterrichtsentwicklung

---
typ: meta_prozess
bereich: prompt_engineering
priorität: hoch
anwendung: claude_desktop
status: aktiv
letzte_aktualisierung: "2025-06-24"
version: "1.0.0"
---

## 🎯 **TEMPLATE-ÜBERSICHT**

### 1. Nahtlose Chat-Fortsetzung
**Einsatz:** Bei Context-Window-Limits oder Chat-Wechseln
**Ziel:** Verlustfreie Übertragung von Arbeitsstand und Kontext

### 2. Neue Sequenzplanung
**Einsatz:** Entwicklung neuer Unterrichtssequenzen
**Ziel:** Systematische, lehrplanbasierte Sequenzentwicklung

### 3. Unterrichtseinheit-Ausarbeitung
**Einsatz:** Detailplanung einzelner Unterrichtsstunden
**Ziel:** Vollständige, seminarleitertaugliche UE-Dokumentation

### 4. Nachdokumentation gehaltener Stunden
**Einsatz:** Aufarbeitung bereits durchgeführter Unterrichtsstunden
**Ziel:** Strukturierte Dokumentation für Repository-Integration

### 5. Repository-Strukturoptimierung
**Einsatz:** Aufräumung und Strukturverbesserung
**Ziel:** Saubere, navigierbare Dateienorganisation

### 6. Meta-Prozess-Entwicklung
**Einsatz:** Entwicklung neuer PATA-Standards
**Ziel:** Kontinuierliche Verbesserung der Arbeitsabläufe

## 📋 **TEMPLATE 1: NAHTLOSE CHAT-FORTSETZUNG**

### Anwendung
- Bei Token-Limits in umfangreichen Projekten
- Bei geplanten Arbeitspausen mit Fortsetzung
- Bei Chat-Session-Wechseln zur Fehlervermeidung

### Template-Struktur
```markdown
# Nahtlose Fortsetzung: [PROJEKT_NAME] (Session [N])

Du bist Claude und führst die Arbeit an [PROJEKT_NAME] aus Chat-Session [N-1] nahtlos fort.

## SOFORTIGE ORIENTIERUNG:
Lies vollständigen Status: `[PFAD_ZU_STATUS_MD]`

## AKTIVE PATA-STANDARDS (automatisch übernommen):
- **Git-Repository-Management**: Saubere Versionierung, keine "_NEU"-Suffixe
- **PATA-PATA-Selbstüberwachung**: Automatische Kontrolle aller eigenen Aktionen
- **Planungshierarchie-Zwangscheck**: Jahresplan→Sequenz→UE-Reihenfolge zwingend
- **Nachdokumentation-Standard**: 5-Stufen-Prozess für bereits gehaltene UE
- **User-Kommunikations-Präferenzen**: Kompakt, intelligent, kontextsensibel

## USER-KONTEXT (beibehalten):
- **Arbeitsweise**: [SPEZIFISCHE_ARBEITSWEISE]
- **Standards**: WiB-Dokumentationsstandards + Git-Repository-Management
- **Prioritäten**: [AKTUELLE_PRIORITÄTEN]
- **Kommunikation**: Zwischen den Zeilen lesen, intelligent mitdenken
- **Qualität**: Seminarleitertauglich, selbstlernend optimierend

## PROJEKT-STATUS (aus Session [N-1]):
✅ **Abgeschlossen**: [ABGESCHLOSSENE_PUNKTE]
🎯 **Innovation**: [ERREICHTE_INNOVATIONEN]
⏰ **Zeitkontext**: [AKTUELLER_ZEITKONTEXT]

## UNMITTELBAR ABZUARBEITENDER USER-PROMPT:
[SPEZIFISCHER_ARBEITSAUFTRAG]

## ERFOLGS-KRITERIEN:
- **Nahtlose Fortsetzung**: Keine Rückfragen zu bereits geklärten Punkten
- **Vollständige Abarbeitung**: Alle User-Aufgaben systematisch lösen
- **PATA-Standards aktiv**: Alle Meta-Prozesse laufen automatisch weiter
- **Qualitäts-Excellence**: Seminarleitertauglich, zukunftssicher, selbstlernend

**Beginne sofort mit systematischer Abarbeitung. Nutze PATA-PATA-Selbstüberwachung für fehlerfreie Execution.**
```

## 📋 **TEMPLATE 2: NEUE SEQUENZPLANUNG**

### Anwendung
- Entwicklung neuer Unterrichtssequenzen
- Anpassung bestehender Sequenzen an veränderte Rahmenbedingungen
- Lehrplankonforma Sequenzentwicklung

### Template-Struktur
```markdown
# Neue WiB-Sequenz entwickeln: [SEQUENZ_THEMA]

## PROJEKT-PARAMETER:
- **Fach**: Wirtschaft und Beruf (WiB)
- **Jahrgangsstufe**: [JAHRGANGSSTUFE]
- **Lernbereich**: [LB_NUMMER] - [LB_BEZEICHNUNG]
- **Zeitrahmen**: [UMFANG] UE + [GLNW_STATUS]
- **Klassen-Kontext**: [KLASSENSPEZIFIKA]

## LEHRPLAN-ORIENTIERUNG ZWINGEND:
1. **LehrplanPLUS-Analyse**: Kompetenzerwartungen und Inhalte aus LB [LB_NUMMER]
2. **Kompetenzmodell-Integration**: Gegenstandsbereiche + prozessbezogene Kompetenzen
3. **Jahresplan-Kongruenz**: Einbettung in bestehende Jahresplanung unter [JAHRESPLAN_PFAD]

## ERWARTETER WORKFLOW:
1. **Planungshierarchie-Check**: Jahresplan → Sequenz → UE-Struktur
2. **Sequenzplan-Entwicklung**: Nach WiB-Dokumentationsstandards
3. **UE-Grobplanung**: Progression und methodische Schwerpunkte
4. **Material-Konzeption**: Bedarfsermittlung und erste Ansätze
5. **Repository-Integration**: Saubere Strukturierung + Git-Management

## QUALITÄTS-STANDARDS:
- **Seminarleitertauglich**: Vollständig ausgearbeitete, reproduzierbare Materialien
- **Realitätsorientiert**: Angepasst an tatsächliche Rahmenbedingungen
- **Innovations-orientiert**: Neue methodische Ansätze wo sinnvoll
- **PATA-compliant**: Alle Meta-Prozesse automatisch integriert

## SPEZIELLE ANFORDERUNGEN:
[BESONDERE_ANFORDERUNGEN_DER_SEQUENZ]

**Beginne mit vollständiger LehrplanPLUS-Analyse und entwickle systematisch die gesamte Sequenz.**
```

## 📋 **TEMPLATE 3: UNTERRICHTSEINHEIT AUSARBEITEN**

### Template-Struktur
```markdown
# UE-Vollausarbeitung: [UE_TITEL]

## UE-KONTEXT:
- **Sequenz**: [SEQUENZ_NAME]
- **Position**: UE [NUMMER] von [GESAMT]
- **Zeitrahmen**: [MINUTEN] Minuten
- **Termin**: [DATUM_UHRZEIT]
- **Besonderheiten**: [SPEZIELLE_UMSTÄNDE]

## PFLICHT-REFERENZEN:
- **Sequenzplan**: [PFAD_ZU_SEQUENZPLAN]
- **Jahresplan**: [PFAD_ZU_JAHRESPLAN] 
- **Vorherige UE**: [PFAD_ZU_VORHERIGER_UE]
- **LehrplanPLUS**: [SPEZIFISCHE_KOMPETENZERWARTUNGEN]

## ERWARTETE AUSARBEITUNG:
1. **Vollständiger Verlaufsplan**: Mit Zeittiming, Lehrersprache, Materialangaben
2. **Alle Materialien**: Arbeitsblätter, Hilfekarten, digitale Inhalte
3. **Differenzierungsmaßnahmen**: Für heterogene Lerngruppe
4. **Checkliste für Durchführung**: Praktische Vorbereitung
5. **Nachbereitung-Template**: Für spätere Reflexion

## METHODISCHE SCHWERPUNKTE:
- **Handlungsorientierung**: Konkrete Schüleraktivitäten
- **Kompetenzorientierung**: Messbare Lernziele nach Mager-Schema
- **WiB-spezifische Methoden**: [SPEZIELLE_METHODEN]
- **Medienintegration**: Sinnvoller Einsatz digitaler Tools

## QUALITÄTS-KRITERIEN:
- **Sofort unterrichtbar**: Ohne weitere Vorbereitung einsetzbar
- **Materialvollständigkeit**: Alle Komponenten vorhanden
- **Realitätsorientiert**: Angepasst an tatsächliche Bedingungen
- **Reflexionsfähig**: Nachbereitungsoptionen integriert

**Entwickle eine vollständig ausgearbeitete, sofort einsetzbare Unterrichtseinheit.**
```

## 📋 **TEMPLATE 4: NACHDOKUMENTATION**

### Template-Struktur
```markdown
# Nachdokumentation: [UE_TITEL] (bereits gehalten)

## RAHMEN-INFORMATION:
- **Durchgeführt**: [DATUM] um [UHRZEIT]
- **Klasse**: [KLASSE]
- **Thema**: [THEMA]
- **Ungefährer Verlauf**: [GROBER_VERLAUF]
- **Besonderheiten**: [BESONDERHEITEN]

## NACHDOKUMENTATION-STANDARD (5-Stufen):
1. **Rekonstruktion**: Stundenverlauf aus Erinnerung/Notizen
2. **Lehrplanbezug**: Kompetenzerwartungen zuordnen
3. **Methodische Einordnung**: Verwendete Methoden systematisieren
4. **Material-Sammlung**: Verwendete Materialien dokumentieren
5. **Repository-Integration**: Saubere Strukturierung + Versionierung

## VERFÜGBARE INFORMATIONEN:
- **Notizen**: [VERFÜGBARE_NOTIZEN]
- **Materialien**: [VORHANDENE_MATERIALIEN]
- **Schüler-Rückmeldungen**: [FEEDBACK]
- **Eigene Reflexion**: [ERSTE_EINSCHÄTZUNG]

## ERWARTETES ERGEBNIS:
- **Vollständige UE-Dokumentation**: Nach WiB-Standards
- **Material-Integration**: Alle verwendeten Inhalte strukturiert
- **Reflexions-Dokumentation**: Was funktionierte, was nicht
- **Repository-Einbettung**: Saubere Verzeichnisstruktur

## BESONDERE HERAUSFORDERUNGEN:
[SPEZIELLE_ASPEKTE_DER_NACHDOKUMENTATION]

**Rekonstruiere systematisch die gehaltene Stunde und integriere sie vollständig ins Repository.**
```

## 📋 **TEMPLATE 5: REPOSITORY-STRUKTUROPTIMIERUNG**

### Template-Struktur
```markdown
# Repository-Strukturoptimierung: [BEREICH]

## AKTUELLER ZUSTAND:
- **Betroffener Bereich**: [BEREICH]
- **Problembeschreibung**: [KONKRETE_PROBLEME]
- **Verfügbare Dateien**: [DATEIEN_LISTE]
- **Gewünschte Struktur**: [ZIEL_STRUKTUR]

## OPTIMIERUNGS-ZIELE:
1. **Saubere Navigation**: Intuitive Ordnerstruktur
2. **Eindeutige Benennung**: Konsistente Dateinamen-Konventionen
3. **Duplikat-Elimination**: Keine redundanten Dateien
4. **Verknüpfung-Optimierung**: Korrekte interne Links
5. **Git-Compliance**: Saubere Versionierung

## PATA-STANDARDS ANWENDEN:
- **Git-Repository-Management**: Keine "_NEU"-Suffixe, saubere Commits
- **PATA-PATA-Selbstüberwachung**: Vor jeder Aktion prüfen
- **Dokumentations-Standards**: Metadaten vollständig
- **Verlustfreie Reorganisation**: Backup vor größeren Änderungen

## WORKFLOW:
1. **Ist-Analyse**: Aktuelle Struktur vollständig erfassen
2. **Soll-Konzept**: Optimale Struktur definieren
3. **Migration-Plan**: Schrittweise Transformation
4. **Ausführung**: Mit Git-Tracking und Backups
5. **Validation**: Funktionalität und Links prüfen

## ERFOLGS-KRITERIEN:
- **Verbesserte Navigation**: Schnellerer Zugang zu Inhalten
- **Keine Datenverluste**: Alle Inhalte erhalten und verknüpft
- **Zukunftssicherheit**: Struktur für weiteres Wachstum geeignet
- **Standard-Compliance**: Alle PATA-Standards erfüllt

**Optimiere systematisch die Repository-Struktur nach definierten Standards.**
```

## 📋 **TEMPLATE 6: META-PROZESS-ENTWICKLUNG**

### Template-Struktur
```markdown
# Neuer PATA-Standard: [PROZESS_NAME]

## PROBLEM-IDENTIFIKATION:
- **Aktueller Schmerzpunkt**: [PROBLEMBESCHREIBUNG]
- **Häufigkeit**: [WIE_OFT_TRITT_AUF]
- **Auswirkungen**: [KONKRETE_PROBLEME]
- **Bisherige Workarounds**: [AKTUELLE_LÖSUNGEN]

## STANDARD-ENTWICKLUNG:
1. **Prozess-Analyse**: Systematische Erfassung des Workflows
2. **Best-Practice-Definition**: Optimaler Ablauf definieren
3. **Automatisierung-Potenzial**: Welche Schritte automatisierbar
4. **Integration-Konzept**: Einbindung in bestehende PATA-Standards
5. **Dokumentation**: Vollständige Prozess-Beschreibung

## QUALITÄTS-KRITERIEN:
- **Selbstlernend**: Kontinuierliche Verbesserung möglich
- **Fehlerresistent**: Robuste Ausführung auch bei Problemen
- **Token-effizient**: Minimaler Aufwand bei maximaler Wirkung
- **Skalierbar**: Auf verschiedene Situationen anwendbar

## PATA-INTEGRATION:
- **PATA-PATA-Ebene**: Selbstüberwachung des neuen Standards
- **Chat-Transition**: Integration in Übergangsprozesse
- **Repository-Standards**: Kompatibilität mit Git-Management
- **User-Präferenzen**: Berücksichtigung der Arbeitsweise

## IMPLEMENTIERUNG:
1. **Dokumentation erstellen**: Nach PATA-Meta-Struktur
2. **Test-Anwendung**: In konkretem Anwendungsfall
3. **Optimierung**: Basierend auf ersten Erfahrungen
4. **Vollständige Integration**: In alle relevanten Workflows

**Entwickle einen robusten, selbstlernenden Meta-Prozess für nachhaltigen Workflow-Optimierung.**
```

## 🔧 **ANWENDUNGS-LEITFADEN**

### Template-Auswahl-Checkliste

| Template | Verwendung wenn... | Erwartete Dauer |
|----------|-------------------|-----------------|
| **Chat-Fortsetzung** | Context-Window-Limit erreicht | Sofort |
| **Neue Sequenz** | Neue Unterrichtssequenz geplant | 60-90 Min |
| **UE ausarbeiten** | Einzelne Stunde vollständig planen | 45-60 Min |
| **Nachdokumentation** | Gehaltene Stunde dokumentieren | 30-45 Min |
| **Struktur-Optimierung** | Repository aufräumen | 20-40 Min |
| **Meta-Prozess** | Workflow-Problem lösen | 30-60 Min |

### Token-Effizienz-Optimierung

**Kontextsensible Anpassungen:**
- **Bekannte Projekte**: Template-Teile reduzieren
- **Neue Bereiche**: Vollständigen Template verwenden
- **Routine-Aufgaben**: Auf Kern-Workflow fokussieren
- **Komplexe Projekte**: Alle Orientierungshilfen nutzen

### Erfolgs-Monitoring

**Selbstlernende Optimierung:**
- **Template-Wirksamkeit**: Wurde Ziel erreicht?
- **Effizienz-Bewertung**: Zeit-zu-Ergebnis-Verhältnis
- **Fehlerrate**: Häufigkeit von Nachkorrekturen
- **User-Zufriedenheit**: Entspricht Erwartungen

---

**IMPLEMENTIERUNGS-STATUS**: Sofort verfügbar für alle WiB-Entwicklungsaufgaben  
**SELBSTLERNEND**: Templates optimieren sich durch Anwendungserfahrung  
**ZUKUNFTSSICHER**: Adaptiv für neue Anforderungen und Workflow-Entwicklungen