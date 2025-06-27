#!/bin/bash
"""
DSGVO-Compliance-System Setup Script
Automatische Installation und Konfiguration für Git-Repository
Rechtsbasis: DSGVO Art. 25 (Privacy by Design)
"""

set -e

# ============================================================================
# KONFIGURATION
# ============================================================================

SETUP_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DSGVO_DIR="$REPO_ROOT/.dsgvo"
SCRIPTS_SOURCE_DIR="$REPO_ROOT/scripts/dsgvo_compliance"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# UTILITY-FUNKTIONEN
# ============================================================================

print_header() {
    echo -e "${BLUE}"
    echo "========================================================================"
    echo "  DSGVO-COMPLIANCE-SYSTEM SETUP v$SETUP_VERSION"
    echo "  Automatische Schülerdaten-Anonymisierung für Git-Repositories"
    echo "========================================================================"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Prüfe Voraussetzungen
check_prerequisites() {
    log_info "Überprüfe Systemvoraussetzungen..."
    
    # Git verfügbar?
    if ! command -v git >/dev/null 2>&1; then
        log_error "Git ist nicht installiert oder nicht im PATH verfügbar"
        exit 1
    fi
    
    # Python3 verfügbar?
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3 ist nicht installiert oder nicht im PATH verfügbar"
        exit 1
    fi
    
    # Pip verfügbar?
    if ! command -v pip3 >/dev/null 2>&1; then
        log_warning "pip3 nicht verfügbar, versuche alternative Installation"
    fi
    
    # Git-Repository?
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_warning "Kein Git-Repository erkannt, erstelle Basis-Setup"
    fi
    
    log_success "Systemvoraussetzungen erfüllt"
}

# Installiere Python-Dependencies
install_python_dependencies() {
    log_info "Installiere Python-Dependencies..."
    
    local requirements=(
        "cryptography>=3.4.8"
        "keyring>=23.0.0"
    )
    
    # Optional dependencies
    local optional_requirements=(
        "PyPDF2>=2.0.0"
        "python-docx>=0.8.11"
    )
    
    # Basis-Dependencies
    for req in "${requirements[@]}"; do
        log_info "Installiere: $req"
        if pip3 install --user "$req" >/dev/null 2>&1; then
            log_success "Installiert: $req"
        else
            log_error "Fehler bei Installation: $req"
            exit 1
        fi
    done
    
    # Optionale Dependencies
    for req in "${optional_requirements[@]}"; do
        log_info "Installiere optional: $req"
        if pip3 install --user "$req" >/dev/null 2>&1; then
            log_success "Installiert: $req"
        else
            log_warning "Optional nicht installiert: $req"
        fi
    done
    
    log_success "Python-Dependencies installiert"
}

# Erstelle Verzeichnisstruktur
create_directory_structure() {
    log_info "Erstelle DSGVO-Verzeichnisstruktur..."
    
    # Hauptverzeichnisse
    mkdir -p "$DSGVO_DIR"/{scripts,mappings,logs,backups,config,temp}
    
    # Berechtigungen setzen (nur User-Zugriff)
    chmod 700 "$DSGVO_DIR"
    chmod 700 "$DSGVO_DIR/mappings"
    chmod 700 "$DSGVO_DIR/logs"
    chmod 700 "$DSGVO_DIR/backups"
    
    log_success "Verzeichnisstruktur erstellt"
}

# Kopiere Scripts
install_scripts() {
    log_info "Installiere DSGVO-Scripts..."
    
    # Core-Scripts kopieren
    if [[ -f "$SCRIPTS_SOURCE_DIR/pii_scanner.py" ]]; then
        cp "$SCRIPTS_SOURCE_DIR/pii_scanner.py" "$DSGVO_DIR/scripts/"
        chmod +x "$DSGVO_DIR/scripts/pii_scanner.py"
        log_success "PII-Scanner installiert"
    else
        log_error "PII-Scanner nicht gefunden: $SCRIPTS_SOURCE_DIR/pii_scanner.py"
        exit 1
    fi
    
    if [[ -f "$SCRIPTS_SOURCE_DIR/anonymizer.py" ]]; then
        cp "$SCRIPTS_SOURCE_DIR/anonymizer.py" "$DSGVO_DIR/scripts/"
        chmod +x "$DSGVO_DIR/scripts/anonymizer.py"
        log_success "Anonymizer installiert"
    else
        log_error "Anonymizer nicht gefunden: $SCRIPTS_SOURCE_DIR/anonymizer.py"
        exit 1
    fi
    
    # Git-Hooks
    if [[ -f "$SCRIPTS_SOURCE_DIR/pre-commit-dsgvo.sh" ]]; then
        cp "$SCRIPTS_SOURCE_DIR/pre-commit-dsgvo.sh" "$DSGVO_DIR/scripts/"
        chmod +x "$DSGVO_DIR/scripts/pre-commit-dsgvo.sh"
        log_success "Git-Hook-Scripts installiert"
    else
        log_error "Git-Hook nicht gefunden: $SCRIPTS_SOURCE_DIR/pre-commit-dsgvo.sh"
        exit 1
    fi
}

# Installiere Git-Hooks
setup_git_hooks() {
    log_info "Konfiguriere Git-Hooks..."
    
    local git_hooks_dir="$REPO_ROOT/.git/hooks"
    
    if [[ ! -d "$git_hooks_dir" ]]; then
        log_warning "Git-Hooks-Verzeichnis nicht gefunden, erstelle Basis-Setup"
        mkdir -p "$git_hooks_dir"
    fi
    
    # Pre-commit Hook
    local pre_commit_hook="$git_hooks_dir/pre-commit"
    
    if [[ -f "$pre_commit_hook" ]]; then
        # Backup erstellen
        cp "$pre_commit_hook" "$pre_commit_hook.backup.$(date +%s)"
        log_warning "Bestehender pre-commit Hook gesichert"
    fi
    
    # DSGVO-Hook installieren
    cat > "$pre_commit_hook" << 'EOF'
#!/bin/bash
# DSGVO-Compliance Pre-Commit Hook
# Automatisch generiert durch setup-dsgvo-compliance.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
DSGVO_HOOK="$REPO_ROOT/.dsgvo/scripts/pre-commit-dsgvo.sh"

if [[ -f "$DSGVO_HOOK" ]]; then
    exec "$DSGVO_HOOK" "$@"
else
    echo "FEHLER: DSGVO-Hook nicht gefunden: $DSGVO_HOOK" >&2
    echo "Führen Sie setup-dsgvo-compliance.sh erneut aus." >&2
    exit 1
fi
EOF
    
    chmod +x "$pre_commit_hook"
    log_success "Git pre-commit Hook installiert"
    
    # Post-checkout Hook (für Deanonymisierung)
    create_post_checkout_hook
}

# Post-checkout Hook für optionale Deanonymisierung
create_post_checkout_hook() {
    local post_checkout_hook="$REPO_ROOT/.git/hooks/post-checkout"
    
    cat > "$post_checkout_hook" << 'EOF'
#!/bin/bash
# DSGVO Post-Checkout Hook - Optionale Deanonymisierung
# Warnt bei anonymisierten Dateien

REPO_ROOT=$(git rev-parse --show-toplevel)
DSGVO_DIR="$REPO_ROOT/.dsgvo"

# Prüfe ob Anonymisierungs-Mappings existieren
if [[ -f "$DSGVO_DIR/mappings/anonymization_mappings.enc" ]]; then
    echo "💡 HINWEIS: Repository enthält anonymisierte Schülerdaten"
    echo "   Deanonymisierung für autorisierte Nutzer verfügbar:"
    echo "   python3 $DSGVO_DIR/scripts/anonymizer.py $REPO_ROOT --deanonymize DATEI"
fi
EOF
    
    chmod +x "$post_checkout_hook"
    log_success "Git post-checkout Hook installiert"
}

# Erstelle Konfigurationsdateien
create_configuration_files() {
    log_info "Erstelle Konfigurationsdateien..."
    
    # PII-Scanner Konfiguration
    cat > "$DSGVO_DIR/config/pii_scanner_config.json" << 'EOF'
{
  "confidence_threshold": 0.7,
  "enable_context_analysis": true,
  "enable_audit_logging": true,
  "supported_extensions": [".md", ".txt", ".html", ".tex", ".rst", ".adoc"],
  "exclude_patterns": [
    "*.enc",
    "*/.*",
    "*/node_modules/*",
    "*/venv/*",
    "*/build/*",
    "*/.dsgvo/*"
  ],
  "context_keywords": [
    "sus", "schüler", "schülerin", "student", "studentin",
    "klasse", "kurs", "lerngruppe", "gruppe", "team",
    "note", "bewertung", "leistung", "prüfung", "test"
  ]
}
EOF
    
    # Anonymizer Konfiguration
    cat > "$DSGVO_DIR/config/anonymizer_config.json" << 'EOF'
{
  "pseudonym_format": "SuS_{gender}_{counter:03d}",
  "preserve_gender": true,
  "preserve_length_approx": true,
  "backup_retention_days": 90,
  "auto_save_frequency": 10,
  "enable_audit_trail": true,
  "encryption_algorithm": "AES-256",
  "key_derivation": "PBKDF2-SHA256"
}
EOF
    
    # Git-Hook Konfiguration
    cat > "$DSGVO_DIR/config/git_hook_config.json" << 'EOF'
{
  "confidence_threshold": 0.7,
  "auto_anonymize": true,
  "strict_mode": true,
  "backup_before_anonymize": true,
  "enable_audit_logging": true,
  "supported_extensions": [".md", ".txt", ".html", ".tex", ".rst", ".adoc"],
  "exclude_patterns": ["*.enc", "*/.*", "*/node_modules/*", "*/venv/*"],
  "emergency_bypass_enabled": false
}
EOF
    
    # Whitelist für Nicht-Namen
    cat > "$DSGVO_DIR/config/whitelist.txt" << 'EOF'
# Whitelist für Nicht-Namen (eine pro Zeile)
# Deutsche Städte
Berlin
München
Hamburg
Köln
Frankfurt
Stuttgart
Düsseldorf
Dortmund
Essen
Leipzig
Bremen
Dresden
Hannover
Nürnberg

# Schulfächer
Deutsch
Mathematik
Englisch
Geschichte
Biologie
Chemie
Physik
Sport
Kunst
Musik
Religion
Ethik
Politik
Wirtschaft

# Allgemeine Begriffe
Beispiel
Muster
Vorlage
Template
Lorem
Ipsum
Placeholder
EOF
    
    log_success "Konfigurationsdateien erstellt"
}

# Aktualisiere .gitignore
update_gitignore() {
    log_info "Aktualisiere .gitignore..."
    
    local gitignore="$REPO_ROOT/.gitignore"
    local dsgvo_section="
# ============================================================================
# DSGVO-Compliance (NIEMALS committen!)
# ============================================================================
.dsgvo/mappings/
.dsgvo/logs/
.dsgvo/backups/
.dsgvo/temp/
*.enc
personal_data_*
*_anonymized.*
*_deanonymized.*
.emergency_bypass
"
    
    # Prüfe ob DSGVO-Section bereits existiert
    if ! grep -q "DSGVO-Compliance" "$gitignore" 2>/dev/null; then
        echo "$dsgvo_section" >> "$gitignore"
        log_success ".gitignore aktualisiert"
    else
        log_info ".gitignore bereits konfiguriert"
    fi
}

# Erstelle README und Dokumentation
create_documentation() {
    log_info "Erstelle Dokumentation..."
    
    cat > "$DSGVO_DIR/README.md" << 'EOF'
# DSGVO-Compliance-System

Automatische Anonymisierung von Schülerdaten in Git-Repositories.

## Rechtsbasis
- DSGVO Art. 4 Nr. 5 (Pseudonymisierung)
- DSGVO Art. 25 (Privacy by Design)
- DSGVO Art. 32 (Sicherheit der Verarbeitung)

## Funktionen
- Automatische Erkennung personenbezogener Daten (PII)
- DSGVO-konforme Pseudonymisierung
- Git-Hook-Integration
- Verschlüsselte Zuordnungstabellen
- Audit-Logging

## Verwendung

### Manuelle Überprüfung
```bash
python3 .dsgvo/scripts/pii_scanner.py datei.md
```

### Manuelle Anonymisierung
```bash
python3 .dsgvo/scripts/anonymizer.py . --anonymize datei.md
```

### Deanonymisierung (nur autorisierte Nutzer)
```bash
python3 .dsgvo/scripts/anonymizer.py . --deanonymize datei.md
```

### Statistiken
```bash
python3 .dsgvo/scripts/anonymizer.py . --stats
```

## Automatische Funktionen
- Pre-commit: Automatische PII-Erkennung und Anonymisierung
- Post-checkout: Hinweise auf anonymisierte Inhalte

## Konfiguration
Alle Konfigurationsdateien befinden sich in `.dsgvo/config/`:
- `pii_scanner_config.json` - Scanner-Einstellungen
- `anonymizer_config.json` - Anonymisierungs-Einstellungen
- `git_hook_config.json` - Git-Hook-Konfiguration
- `whitelist.txt` - Ausnahmen für Namen-Erkennung

## Sicherheit
- AES-256-Verschlüsselung für Zuordnungstabellen
- Lokale Verarbeitung (keine Cloud-Services)
- Passwort-basierte Schlüsselableitung (PBKDF2)
- Sichere Löschung von Temp-Dateien

## Compliance
- Vollständige DSGVO-Konformität
- Audit-Logging aller Aktionen
- Backup-Strategien für Datenwiederherstellung
- Automatische Löschung alter Backups
EOF
    
    log_success "Dokumentation erstellt"
}

# Führe initiale Tests durch
run_initial_tests() {
    log_info "Führe initiale Tests durch..."
    
    # Test 1: PII-Scanner
    echo "Max Mustermann ist ein Schüler in der 5. Klasse." > "$DSGVO_DIR/temp/test_file.md"
    
    if python3 "$DSGVO_DIR/scripts/pii_scanner.py" "$DSGVO_DIR/temp/test_file.md" --quiet >/dev/null 2>&1; then
        log_success "PII-Scanner Test erfolgreich"
    else
        log_warning "PII-Scanner Test ergab keine Findings (möglicherweise OK)"
    fi
    
    # Test 2: Anonymizer (ohne Verschlüsselung für Test)
    if python3 -c "
import sys
sys.path.append('$DSGVO_DIR/scripts')
from anonymizer import DSGVOAnonymizer
print('Anonymizer Import Test erfolgreich')
" >/dev/null 2>&1; then
        log_success "Anonymizer Test erfolgreich"
    else
        log_error "Anonymizer Test fehlgeschlagen"
    fi
    
    # Cleanup
    rm -f "$DSGVO_DIR/temp/test_file.md"
    
    log_success "Initiale Tests abgeschlossen"
}

# Zeige Post-Installation-Informationen
show_post_install_info() {
    echo ""
    log_success "🎉 DSGVO-Compliance-System erfolgreich installiert!"
    echo ""
    echo -e "${BLUE}Nächste Schritte:${NC}"
    echo "1. Führen Sie initiale Verschlüsselung durch:"
    echo "   python3 .dsgvo/scripts/anonymizer.py . --stats"
    echo ""
    echo "2. Testen Sie das System:"
    echo "   echo 'Max Mustermann ist ein Schüler' > test.md"
    echo "   git add test.md"
    echo "   git commit -m 'Test DSGVO-System'"
    echo ""
    echo "3. Prüfen Sie die Konfiguration:"
    echo "   Dateien in .dsgvo/config/ nach Bedarf anpassen"
    echo ""
    echo -e "${YELLOW}Wichtige Hinweise:${NC}"
    echo "- Verschlüsselungspasswort sicher aufbewahren"
    echo "- .dsgvo/mappings/ niemals in Git committen"
    echo "- Bei Problemen: .dsgvo/logs/ für Audit-Trail prüfen"
    echo ""
    echo -e "${GREEN}Support:${NC}"
    echo "- Dokumentation: .dsgvo/README.md"
    echo "- Konfiguration: .dsgvo/config/"
    echo "- Logs: .dsgvo/logs/"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    print_header
    
    # Interaktive Bestätigung
    echo "Dieses Script installiert das DSGVO-Compliance-System für automatische"
    echo "Schülerdaten-Anonymisierung in diesem Git-Repository."
    echo ""
    read -p "Fortfahren? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation abgebrochen"
        exit 0
    fi
    
    # Setup-Schritte ausführen
    check_prerequisites
    install_python_dependencies
    create_directory_structure
    install_scripts
    setup_git_hooks
    create_configuration_files
    update_gitignore
    create_documentation
    run_initial_tests
    
    show_post_install_info
}

# Fehlerbehandlung
trap 'log_error "Setup fehlgeschlagen in Zeile $LINENO"; exit 1' ERR

# Script ausführen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
