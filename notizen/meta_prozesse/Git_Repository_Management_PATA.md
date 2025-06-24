# Git-Repository-Management PATA-Standard

---
typ: meta_prozess_kritisch
anwendungsbereich: Kontinuierliche Verzeichnispflege
priorität: HÖCHSTE
bearbeitungsstand: Sofort produktiv
letzte_aktualisierung: "2025-06-24"
autor: "System-Optimierung"
version: "1.0.0"
---

## GRUNDPRINZIP: Nur aktuelle, versionierte Realität im Repository

### ⚠️ ZWANGS-REGELN für Git-Management:

1. **Eine Wahrheit-Regel**: Nur eine aktuelle Version je Dokument im Hauptverzeichnis
2. **Versionierung statt Duplikate**: `_v1`, `_alt`, `_backup` → Git-History nutzen
3. **Realitäts-Anpassung**: Kontinuierliche Updates statt parallele Versionen
4. **Intelligente Commits**: Aussagekräftige Commit-Messages mit Kontext

### 🔄 WORKFLOW-INTEGRATION:

#### Bei Dokumenterstellung:
```
1. Neue Datei erstellen
2. Sofort Git-Add + Commit mit Context
3. Bei Änderungen: Edit + Commit (keine neuen Dateien)
4. Alte Versionen aus Verzeichnis entfernen
```

#### Bei Überarbeitungen:
```
1. Bestehende Datei editieren (nicht kopieren)
2. Substantielle Änderungen: Git-Tag setzen
3. Meta-Daten aktualisieren (version, letzte_aktualisierung)
4. Commit mit Änderungsprotokoll
```

#### Bei Realitäts-Anpassungen:
```
1. Sofortige Anpassung der betroffenen Dokumente
2. Verknüpfte Dokumente automatisch mitbedenken
3. Konsistenz-Check über alle verbundenen Dateien
4. Batch-Commit aller zusammenhängenden Änderungen
```

### 🛠️ PRAKTISCHE UMSETZUNG:

#### Datei-Lifecycle:
- **Entwurf**: Erstdokumentation mit Git-Init
- **Bearbeitung**: Kontinuierliche Commits bei Änderungen
- **Finalisierung**: Version-Tag + final commit
- **Anpassung**: Edit statt neue Datei + beschreibender Commit

#### Verzeichnis-Hygiene:
- **Keine Duplikate**: `_alt`, `_neu`, `_überarbeitet` eliminieren
- **Konsistente Namen**: Einheitliche Benennungskonvention
- **Metadaten-Aktualität**: Automatisches Update bei Änderungen
- **Link-Pflege**: Verknüpfungen bei Umbenennungen aktualisieren

## AUTO-INTEGRATION in alle Arbeitsprozesse:

### Bei jeder Dateierstellung:
```
1. Prüfung: Existiert ähnliche/alte Version?
2. Entscheidung: Neue Datei oder Überarbeitung?
3. Git-Management: Sofortiger Commit oder Edit
4. Metadaten: Version und Update-Datum setzen
```

### Bei jeder Sequenz-/UE-Planung:
```
1. Jahresplan-Check: Aktuelle Version?
2. Sequenzplan-Update: Edit statt Neuerstellung
3. UE-Integration: Verknüpfung statt Isolation
4. Konsistenz-Commit: Alle Änderungen zusammen
```

---

**PATA-IMPLEMENTIERT: Dieser Standard läuft ab sofort automatisch!**