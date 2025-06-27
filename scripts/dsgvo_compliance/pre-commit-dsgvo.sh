#!/bin/bash
"""
DSGVO-Git-Hook: Pre-Commit-Check für automatische Schülerdaten-Anonymisierung
Verhindert Commits mit unverschlüsselten personenbezogenen Daten
Rechtsbasis: DSGVO Art. 25 (Privacy by Design)
"""

set -e

# ============================================================================
# KONFIGURATION
# ============================================================================

HOOK_VERSION="1.0.0"
REPO_ROOT=$(git rev-parse --show-toplevel)
DSGVO_DIR="$REPO_ROOT/.dsgvo"
SCRIPTS_DIR="$REPO_ROOT/scripts/dsgvo_compliance"
LOGS_DIR="$DSGVO_DIR/logs"

# Scripts-Pfade
PII_SCANNER="$SCRIPTS_DIR/pii_scanner.py"
ANONYMIZER="$SCRIPTS_DIR/anonymizer.py"

# Konfiguration
CONFIDENCE_THRESHOLD=0.7
AUTO_ANONYMIZE=true
STRICT_MODE=true
BACKUP_BEFORE_ANONYMIZE=true

# ============================================================================
# UTILITY-FUNKTIONEN
# ============================================================================

log_info() {
    echo "🔒 [DSGVO-Hook] $1"
}

log_warning() {
    echo "⚠️ [DSGVO-Hook] $1" >&2
}

log_error() {
    echo "❌ [DSGVO-Hook] $1" >&2
}

log_success() {
    echo "✅ [DSGVO-Hook] $1"
}

# Audit-Logging
audit_log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    mkdir -p "$LOGS_DIR"
    echo "[$timestamp] $message" >> "$LOGS_DIR/git_hook_audit.log"
}

# Prüfe ob Python verfügbar ist
check_python() {
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3 ist nicht verfügbar. DSGVO-Compliance kann nicht sichergestellt werden."
        exit 1
    fi
}

# Prüfe ob DSGVO-Scripts verfügbar sind
check_dsgvo_scripts() {
    if [[ ! -f "$PII_SCANNER" ]]; then
        log_error "PII-Scanner nicht gefunden: $PII_SCANNER"
        log_error "Installieren Sie das DSGVO-Compliance-System:"
        log_error "  bash $REPO_ROOT/scripts/setup-dsgvo-compliance.sh"
        exit 1
    fi
    
    if [[ ! -f "$ANONYMIZER" ]]; then
        log_error "Anonymizer nicht gefunden: $ANONYMIZER"
        log_error "Installieren Sie das DSGVO-Compliance-System:"
        log_error "  bash $REPO_ROOT/scripts/setup-dsgvo-compliance.sh"
        exit 1
    fi
}

# Prüfe ob Python-Dependencies verfügbar sind
check_python_deps() {
    local missing_deps=()
    
    if ! python3 -c "import cryptography" >/dev/null 2>&1; then
        missing_deps+=("cryptography")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Fehlende Python-Dependencies: ${missing_deps[*]}"
        log_error "Installation: pip3 install ${missing_deps[*]}"
        exit 1
    fi
}

# ============================================================================
# DSGVO-COMPLIANCE-FUNKTIONEN
# ============================================================================

# Hole alle staged Dateien
get_staged_files() {
    git diff --cached --name-only --diff-filter=ACM | \
    grep -E '\.(md|txt|html|tex|rst|adoc)$' | \
    grep -v -E '(\.enc$|/\.|node_modules/|venv/|\.git/)' || true
}

# Scanne Datei nach PII
scan_file_for_pii() {
    local file="$1"
    local findings_file="$DSGVO_DIR/temp_findings_$$.json"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # PII-Scan durchführen
    python3 "$PII_SCANNER" "$file" \
        --threshold "$CONFIDENCE_THRESHOLD" \
        --quiet \
        --report "$findings_file" >/dev/null 2>&1
    
    # Exit-Code prüfen (1 = PII gefunden, 0 = sauber)
    local exit_code=$?
    
    if [[ $exit_code -eq 1 && -f "$findings_file" ]]; then
        echo "$findings_file"
        return 1
    else
        [[ -f "$findings_file" ]] && rm -f "$findings_file"
        return 0
    fi
}

# Anonymisiere Datei automatisch
anonymize_file_auto() {
    local file="$1"
    local findings_file="$2"
    
    log_info "Automatische Anonymisierung: $file"
    
    # Anonymisierung durchführen
    if python3 "$ANONYMIZER" "$REPO_ROOT" \
        --anonymize "$file" \
        --pii-findings "$findings_file" \
        $([ "$BACKUP_BEFORE_ANONYMIZE" = "true" ] || echo "--no-backup") \
        >/dev/null 2>&1; then
        
        # Datei erneut zu Git hinzufügen
        git add "$file"
        
        log_success "Datei anonymisiert und re-staged: $file"
        audit_log "AUTO_ANONYMIZE: $file"
        return 0
    else
        log_error "Anonymisierung fehlgeschlagen: $file"
        return 1
    fi
}

# Interaktive PII-Behandlung
handle_pii_interactive() {
    local file="$1"
    local findings_file="$2"
    
    log_warning "Personenbezogene Daten gefunden in: $file"
    
    # Findings anzeigen
    if [[ -f "$findings_file" ]]; then
        echo ""
        echo "Gefundene personenbezogene Daten:"
        echo "=================================="
        cat "$findings_file"
        echo ""
    fi
    
    echo "Optionen:"
    echo "  a) Automatisch anonymisieren"
    echo "  s) Datei von Commit ausschließen (git reset)"
    echo "  i) Ignorieren (NICHT EMPFOHLEN)"
    echo "  c) Commit abbrechen"
    
    read -p "Ihre Wahl [a/s/i/c]: " choice
    
    case "$choice" in
        a|A)
            anonymize_file_auto "$file" "$findings_file"
            return $?
            ;;
        s|S)
            git reset HEAD "$file"
            log_info "Datei aus Commit entfernt: $file"
            return 0
            ;;
        i|I)
            log_warning "⚠️ DSGVO-RISIKO: Datei mit PII wird committet: $file"
            audit_log "PII_IGNORED: $file (User override)"
            return 0
            ;;
        c|C|*)
            log_info "Commit abgebrochen durch User"
            return 1
            ;;
    esac
}

# Prüfe DSGVO-Compliance für alle staged Dateien
check_dsgvo_compliance() {
    local staged_files
    staged_files=($(get_staged_files))
    
    if [[ ${#staged_files[@]} -eq 0 ]]; then
        log_info "Keine relevanten Dateien für DSGVO-Check gefunden"
        return 0
    fi
    
    log_info "DSGVO-Compliance-Check für ${#staged_files[@]} Datei(en)..."
    
    local pii_found=false
    local failed_files=()
    
    for file in "${staged_files[@]}"; do
        log_info "Überprüfe: $file"
        
        # PII-Scan
        local findings_file
        if findings_file=$(scan_file_for_pii "$file"); then
            # Keine PII gefunden
            continue
        else
            # PII gefunden
            pii_found=true
            
            if [[ "$AUTO_ANONYMIZE" = "true" ]]; then
                # Automatische Anonymisierung
                if ! anonymize_file_auto "$file" "$findings_file"; then
                    failed_files+=("$file")
                fi
            else
                # Interaktive Behandlung
                if ! handle_pii_interactive "$file" "$findings_file"; then
                    failed_files+=("$file")
                fi
            fi
            
            # Cleanup
            [[ -f "$findings_file" ]] && rm -f "$findings_file"
        fi
    done
    
    # Ergebnis bewerten
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log_error "DSGVO-Compliance-Fehler in folgenden Dateien:"
        printf '  %s\n' "${failed_files[@]}"
        audit_log "COMPLIANCE_FAILED: ${failed_files[*]}"
        return 1
    fi
    
    if [[ "$pii_found" = "true" ]]; then
        log_success "DSGVO-Compliance durch Anonymisierung sichergestellt"
        audit_log "COMPLIANCE_SUCCESS: Auto-anonymization completed"
    else
        log_success "DSGVO-Compliance bestätigt - keine PII gefunden"
        audit_log "COMPLIANCE_SUCCESS: No PII detected"
    fi
    
    return 0
}

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

# Lade Hook-Konfiguration
load_hook_config() {
    local config_file="$DSGVO_DIR/git_hook_config.json"
    
    if [[ -f "$config_file" ]]; then
        # JSON-Parsing mit Python (einfach und robust)
        eval $(python3 -c "
import json
import sys
try:
    with open('$config_file', 'r') as f:
        config = json.load(f)
    
    print(f'CONFIDENCE_THRESHOLD={config.get(\"confidence_threshold\", 0.7)}')
    print(f'AUTO_ANONYMIZE={\"true\" if config.get(\"auto_anonymize\", True) else \"false\"}')
    print(f'STRICT_MODE={\"true\" if config.get(\"strict_mode\", True) else \"false\"}')
    print(f'BACKUP_BEFORE_ANONYMIZE={\"true\" if config.get(\"backup_before_anonymize\", True) else \"false\"}')
except Exception as e:
    print(f'# Config load failed: {e}', file=sys.stderr)
" 2>/dev/null || true)
    fi
}

# Erstelle Default-Konfiguration
create_default_config() {
    local config_file="$DSGVO_DIR/git_hook_config.json"
    
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$DSGVO_DIR"
        cat > "$config_file" << EOF
{
  "confidence_threshold": 0.7,
  "auto_anonymize": true,
  "strict_mode": true,
  "backup_before_anonymize": true,
  "enable_audit_logging": true,
  "supported_extensions": [".md", ".txt", ".html", ".tex", ".rst", ".adoc"],
  "exclude_patterns": ["*.enc", "*/.*", "*/node_modules/*", "*/venv/*"],
  "version": "$HOOK_VERSION"
}
EOF
        log_info "Default-Konfiguration erstellt: $config_file"
    fi
}

# ============================================================================
# EMERGENCY FUNCTIONS
# ============================================================================

# Notfall-Bypass (nur bei kritischen Problemen)
emergency_bypass() {
    local bypass_file="$DSGVO_DIR/.emergency_bypass"
    
    if [[ -f "$bypass_file" ]]; then
        local bypass_reason
        bypass_reason=$(cat "$bypass_file" 2>/dev/null || echo "Unknown")
        
        log_warning "⚠️ NOTFALL-BYPASS AKTIVIERT: $bypass_reason"
        log_warning "⚠️ DSGVO-COMPLIANCE WIRD NICHT ÜBERPRÜFT!"
        audit_log "EMERGENCY_BYPASS: $bypass_reason"
        
        return 0
    fi
    
    return 1
}

# Erstelle Notfall-Bypass
create_emergency_bypass() {
    local reason="$1"
    local bypass_file="$DSGVO_DIR/.emergency_bypass"
    
    echo "$reason" > "$bypass_file"
    log_warning "Notfall-Bypass erstellt. Entfernen mit: rm $bypass_file"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Header
    log_info "DSGVO-Git-Hook v$HOOK_VERSION gestartet"
    audit_log "HOOK_START: Pre-commit DSGVO check"
    
    # Notfall-Bypass prüfen
    if emergency_bypass; then
        return 0
    fi
    
    # Voraussetzungen prüfen
    check_python
    check_dsgvo_scripts
    check_python_deps
    
    # Konfiguration laden
    create_default_config
    load_hook_config
    
    # DSGVO-Compliance-Check durchführen
    if check_dsgvo_compliance; then
        log_success "🛡️ DSGVO-Compliance bestätigt - Commit wird fortgesetzt"
        audit_log "HOOK_SUCCESS: Commit approved"
        return 0
    else
        log_error "🚫 DSGVO-Compliance-Verletzung - Commit blockiert"
        log_error ""
        log_error "Optionen zur Behebung:"
        log_error "  1. Anonymisierung akzeptieren und erneut committen"
        log_error "  2. Betroffene Dateien manuell bearbeiten"
        log_error "  3. Notfall-Bypass: echo 'Reason' > $DSGVO_DIR/.emergency_bypass"
        audit_log "HOOK_BLOCKED: DSGVO compliance violation"
        return 1
    fi
}

# Exception Handling
trap 'log_error "Unerwarteter Fehler in DSGVO-Hook (Zeile $LINENO)"; exit 1' ERR

# Hook ausführen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
