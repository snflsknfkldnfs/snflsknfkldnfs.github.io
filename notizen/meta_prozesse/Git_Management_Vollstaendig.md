# Git-Management Vollständig - PATA-Standard

---
typ: meta_prozess
bereich: git_management
priorität: kritisch
status: aktiv
letzte_aktualisierung: "2025-06-24"
version: "1.0.0"
---

## KERN-FUNKTIONALITÄTEN

### 1. Repository-Status prüfen
**Zweck:** Vor jeder Aktion aktuellen Git-Zustand erfassen
**Anwendung:** Automatisch vor größeren Änderungen

```bash
# Standard-Check
git status --porcelain
git branch --show-current
git log --oneline -5
```

### 2. Intelligente Commit-Strategien
**Zweck:** Semantisch sinnvolle, nachvollziehbare Commits
**Kategorien:**
- `feat:` Neue Funktionalitäten/Inhalte
- `fix:` Korrekturen/Bugfixes  
- `docs:` Dokumentation
- `refactor:` Strukturoptimierungen
- `meta:` PATA-Prozess-Updates

### 3. Automatisierte Commit-Zyklen
**Trigger:**
- Nach Abschluss einer UE-Ausarbeitung
- Nach Implementierung neuer PATA-Standards
- Nach größeren Strukturänderungen
- Nach Chat-Transition-Abschluss

### 4. Branch-Management
**Master-Branch:** Stabile, getestete Versionen
**Feature-Branches:** Für größere Entwicklungen
**Chat-Branches:** Für experimentelle Chat-Sessions (optional)

## IMPLEMENTIERTE KOMMANDOS

### Git-Status-Check (automatisch)
**Funktion:** `git_status_check()`
**Execution:** Vor jeder Dateioperation >3 Dateien

### Intelligent Commit
**Funktion:** `intelligent_commit(message, type="feat")`
**Auto-Staging:** Ja, mit Ausnahmen (.DS_Store, temp-files)

### Push-Workflow
**Funktion:** `git_push_workflow()`
**Sicherheit:** Status-Check → Commit → Push → Verification

### Rollback-Sicherung
**Funktion:** `git_rollback_point(description)`
**Zweck:** Sicherungspunkte vor kritischen Änderungen

## INTEGRATION IN CHAT-WORKFLOW

### Bei Chat-Start:
1. Git-Status prüfen
2. Aktuellen Branch bestätigen
3. Letzte Commits anzeigen

### Während Chat:
1. Nach jeder größeren Änderung: Automatic staging
2. Bei 5+ geänderten Dateien: Commit-Empfehlung
3. Bei kritischen Änderungen: Rollback-Point setzen

### Bei Chat-Ende:
1. Alle Änderungen committen
2. Transition-Status dokumentieren  
3. Push to remote (wenn gewünscht)
4. Next-Session-Branch vorbereiten (optional)

## FEHLER-PRÄVENTIONS-SYSTEM

### Verbotene Aktionen:
- Commits ohne Nachricht
- Force-Push ohne Warnung
- Löschung ohne Backup
- Push von temp/debug-Dateien

### Validierung vor Commit:
- Markdown-Syntax-Check
- Metadaten-Vollständigkeit
- Link-Validation (internal)
- PATA-Standard-Compliance

## AUTOMATISIERTE GIT-KOMMANDOS

Diese werden bei Bedarf automatisch ausgeführt:

```bash
# Basis-Setup für neue Session
git_session_start() {
    git status
    git branch --show-current
    echo "Last 3 commits:"
    git log --oneline -3
}

# Intelligenter Commit mit Auto-Message
git_smart_commit() {
    local file_count=$(git diff --name-only --cached | wc -l)
    local modified_areas=$(git diff --name-only --cached | cut -d'/' -f1-2 | sort -u)
    
    if [ $file_count -gt 0 ]; then
        local message="Auto: Updated $file_count files in $modified_areas"
        git commit -m "$message"
        echo "Committed: $message"
    fi
}

# Sicherer Push-Workflow
git_safe_push() {
    git status --porcelain
    if [ $? -eq 0 ]; then
        git push origin $(git branch --show-current)
        echo "Successfully pushed to remote"
    else
        echo "Warning: Uncommitted changes detected"
    fi
}

# Rollback-Point setzen
git_savepoint() {
    local description="$1"
    git tag "savepoint-$(date +%Y%m%d-%H%M%S)-$description"
    echo "Savepoint created: $description"
}
```

## SELBSTÜBERWACHUNG

### Pre-Commit-Validierung:
- [x] Syntaxcheck für .md-Dateien
- [x] Metadaten-Validation
- [x] PATA-Standards-Compliance
- [x] Token-Efficiency-Check

### Post-Commit-Verification:
- [x] Repository-Integrität
- [x] Remote-Sync-Status
- [x] Dokumentations-Vollständigkeit

## NOTFALL-PROTOKOLLE

### Bei Git-Konflikten:
1. Status dokumentieren
2. Manuelle Intervention anfordern
3. Niemals automatisch überschreiben

### Bei Repository-Korruption:
1. Backup-Status prüfen
2. Remote-Sync bestätigen
3. Local-Recovery-Protokoll

## PERFORMANCE-OPTIMIERUNG

### Staging-Intelligenz:
- Automatisches `git add` für finale Dateien
- Automatisches `git reset` für temp-Dateien
- Intelligente .gitignore-Aktualisierung

### Commit-Batching:
- Sammlung verwandter Änderungen
- Semantisch sinnvolle Batch-Commits
- Timing-optimierte Push-Zyklen

---

**AKTIVIERUNG:** Alle Git-Kommandos sind in Chat-Session automatisch verfügbar
**ÜBERWACHUNG:** PATA-PATA-System überwacht Git-Compliance kontinuierlich
**ESKALATION:** Bei kritischen Git-Problemen → Manuelle Intervention anfordern