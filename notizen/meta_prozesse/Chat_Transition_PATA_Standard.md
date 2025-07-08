# Chat-Transition-Prozess PATA-Standard

---
typ: meta_prozess
anwendungsbereich: Nahtlose Fortsetzung zwischen Chat-Sessions
priorität: HOCH
bearbeitungsstand: Produktiv
letzte_aktualisierung: "2025-06-24"
autor: "System-Kontinuität"
version: "1.0.0"
---

## AUTOMATISCHER CHAT-TRANSITION-WORKFLOW

### ⚠️ TRIGGER: Chat nähert sich Längenlimit

#### Automatische Aktionen (letzte 10% der verfügbaren Tokens):
1. **Status-Export erstellen**: Vollständiger Projekt-Status
2. **Transition-Verzeichnis anlegen**: `/chat_transitions/` im Projektordner
3. **Nahtlos-Prompt generieren**: Für nächste Chat-Instanz
4. **Offene Aufgaben dokumentieren**: Aus aktueller Session
5. **Kontext-Transfer sicherstellen**: Alle relevanten Informationen

### 📁 STANDARD-VERZEICHNISSTRUKTUR:

```
/projekt_hauptordner/
├── chat_transitions/
│   ├── session_X_status.md ← Vollständiger Status-Export
│   ├── session_X_to_Y_prompt.md ← Prompt für nächste Session
│   └── offene_aufgaben.md ← User-Prompt für Fortsetzung
```

### 📋 INHALT DES STATUS-EXPORTS:

#### Pflicht-Sektionen:
- **Abgeschlossene Aufgaben**: Was wurde erfolgreich erledigt
- **Implementierte Meta-Prozesse**: PATA-Standards, Workflows
- **Kern-Innovationen**: Wichtige Entwicklungen/Erkenntnisse
- **Zeitlicher Kontext**: Datum, Deadlines, Termine
- **Offene Aufgaben**: Aus aktuellem User-Prompt
- **Dateienstruktur**: Aktuelle Organisation
- **Wichtige Kontext-Infos**: Lerngruppe, Methoden, Besonderheiten

#### Meta-Informationen:
- **PATA-Status**: Welche Standards sind aktiv
- **Git-Status**: Repository-Zustand
- **Workflow-Status**: Welche Prozesse laufen
- **User-Präferenzen**: Extrahierte Kommunikationsmuster

### 🎯 NAHTLOS-PROMPT-TEMPLATE (OPTIMIERT):

```markdown
Du bist Claude und führst die Arbeit an [PROJEKT] aus Chat-Session [X] nahtlos fort.

SOFORTIGE ORIENTIERUNG:
Lies vollständigen Kontext: [PFAD]/chat_transitions/session_[X]_to_[X+1]_[kontext].md

AKTIVE PATA-STANDARDS:
- Git-Repository-Management mit automatischer Selbstkontrolle
- Chat-Transition-Automatisierung (nahtlose Sessions)
- [weitere aktive Standards basierend auf Projekt]

USER-KONTEXT:
- Arbeitsweise: [Präzise/fachlich fundiert/PATA-konform]
- Standards: [DiSoAn-Dokumentationsstandards/Marc Kunz BUV/etc.]
- Prioritäten: [Inhaltliche Stringenz über technische Machbarkeit]
- Repository: [REPOSITORY-PFAD]

UNMITTELBARER AUFTRAG:
"[EXAKTER USER-PROMPT AUS VORHERIGER SESSION]"

VERFÜGBARE ASSETS:
✅ [KONKRETE LISTE DER VERFÜGBAREN DATEIEN UND RESSOURCEN]
✅ [PROJEKTSPEZIFISCHE KOMPONENTEN]
✅ [PATA-KONFORME REPOSITORY-STRUKTUR]

ERFOLGSKRITERIEN:
- [SPEZIFISCHE ERFOLGSKRITERIEN FÜR DAS PROJEKT]
- Nahtlose Fortsetzung ohne Informationsverlust
- Alle PATA-Standards bleiben aktiv
- [PROJEKTSPEZIFISCHE QUALITÄTSZIELE]

STARTAKTION:
[KONKRETE ERSTE HANDLUNG FÜR SOFORTIGEN ARBEITSBEGINN]
```

### 🔄 SELBSTLERNENDE TEMPLATE-OPTIMIERUNG:

**Implementiertes Learning (2025-07-07):**
- **Copy-Paste-Ready Format**: Direkter Prompt ohne zusätzliche Formatierung
- **Konkrete Assets-Liste**: Verfügbare Ressourcen explizit aufführen
- **Spezifische Startaktion**: Klare erste Handlung statt allgemeiner Anweisung
- **Repository-Pfad**: Absoluter Pfad für sofortige Orientierung

### 🔄 KONTINUITÄTS-CHECKS:

#### Vor Chat-Transition:
- [ ] Status-Export vollständig?
- [ ] Alle offenen Aufgaben dokumentiert?
- [ ] Transition-Verzeichnis angelegt?
- [ ] Nahtlos-Prompt generiert?
- [ ] Keine Informationsverluste?

#### Nach Chat-Transition (neue Session):
- [ ] Status-Dokument gelesen?
- [ ] PATA-Standards aktiviert?
- [ ] User-Kontext verstanden?
- [ ] User-Prompt verstanden?
- [ ] Nahtlose Fortsetzung gewährleistet?

### 📊 QUALITÄTS-STANDARDS:

#### Exzellente Transition:
- Neue Session arbeitet sofort effektiv weiter
- Keine Rückfragen zu bereits geklärten Punkten
- Alle Meta-Prozesse laufen automatisch weiter
- User merkt keinen Qualitäts-/Kontinuitätsverlust

#### Automatische Verbesserung:
- Jede Transition wird analysiert
- Häufige Probleme führen zu Prozess-Updates
- User-Feedback fließt in Template-Optimierung
- Template werden kontextsensibel angepasst

---

**PATA-IMPLEMENTIERT: Dieser Standard ist ab sofort bei jedem Chat-Limit aktiv!**