# 🔒 DSGVO-Automatische Schülerdaten-Anonymisierung

Vollständiges Compliance-System für automatische, rechtskonforme Anonymisierung von Schülerdaten in Git-Repositories.

## 📋 **Rechtliche Grundlage**

- **DSGVO Art. 4 Nr. 5**: Pseudonymisierung personenbezogener Daten
- **DSGVO Art. 25**: Privacy by Design (eingebauter Datenschutz)
- **DSGVO Art. 32**: Sicherheit der Verarbeitung
- **Schulgesetze der Länder**: Verschwiegenheitspflicht bei Schülerdaten

## 🎯 **Funktionen**

### ✅ **Automatische PII-Erkennung**
- Erkennt deutsche Namen in verschiedenen Kontexten
- Kontextuelle Analyse (Schüler, SuS, Klasse, etc.)
- Konfigurierbare Konfidenz-Schwellwerte
- Whitelist für Nicht-Namen (Städte, Fächer, etc.)

### ✅ **DSGVO-konforme Pseudonymisierung**
- Konsistente Zuordnung: "Max Mustermann" → "SuS_M_001"
- Geschlechts-/Längenerhalten für pädagogischen Kontext
- AES-256-Verschlüsselung der Zuordnungstabellen
- Reversible Anonymisierung für autorisierte Nutzer

### ✅ **Git-Integration**
- Pre-commit Hook: Automatische PII-Checks vor Commits
- Post-checkout Hook: Hinweise auf anonymisierte Inhalte
- .gitignore-Integration für sensible Daten
- Notfall-Bypass für kritische Situationen

### ✅ **Sicherheit & Compliance**
- Lokale Verarbeitung (keine Cloud-Services)
- Passwort-basierte Schlüsselableitung (PBKDF2)
- Audit-Logging aller Aktionen
- Automatische Backup-Retention

## 🚀 **Installation**

### Schnell-Installation
```bash
# Repository klonen oder öffnen
cd /path/to/your/repository

# DSGVO-System installieren
bash scripts/setup-dsgvo-compliance.sh
```

### Manuelle Installation
```bash
# 1. Python-Dependencies installieren
pip3 install cryptography keyring

# 2. Scripts kopieren
cp -r scripts/dsgvo_compliance .dsgvo/scripts/

# 3. Git-Hooks einrichten
cp .dsgvo/scripts/pre-commit-dsgvo.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 4. .gitignore erweitern
echo -e "\n.dsgvo/mappings/\n*.enc\npersonal_data_*" >> .gitignore
```

## 🎛️ **Verwendung**

### DSGVO-Manager (Empfohlen)
```bash
# Repository scannen
python3 scripts/dsgvo_compliance/dsgvo_manager.py scan

# Automatische Anonymisierung
python3 scripts/dsgvo_compliance/dsgvo_manager.py anonymize

# System-Status prüfen
python3 scripts/dsgvo_compliance/dsgvo_manager.py status

# Compliance validieren
python3 scripts/dsgvo_compliance/dsgvo_manager.py compliance

# Statistiken anzeigen
python3 scripts/dsgvo_compliance/dsgvo_manager.py stats
```

### Einzelne Tools
```bash
# PII-Scanner
python3 scripts/dsgvo_compliance/pii_scanner.py datei.md

# Anonymisierung
python3 scripts/dsgvo_compliance/anonymizer.py . --anonymize datei.md

# Deanonymisierung (nur autorisierte Nutzer)
python3 scripts/dsgvo_compliance/anonymizer.py . --deanonymize datei.md
```

### Automatische Funktionen
```bash
# Git-Workflow (automatisch durch Hooks)
git add unterricht.md    # Automatischer PII-Check
git commit -m "Update"   # PII wird automatisch anonymisiert
```

## ⚙️ **Konfiguration**

### Konfidenz-Schwellwert anpassen
```bash
# .dsgvo/config/pii_scanner_config.json
{
  "confidence_threshold": 0.7,  # 0.5 = weniger streng, 0.9 = sehr streng
  "enable_context_analysis": true
}
```

### Pseudonym-Format ändern
```bash
# .dsgvo/config/anonymizer_config.json
{
  "pseudonym_format": "SuS_{gender}_{counter:03d}",  # SuS_M_001, SuS_W_002
  "preserve_gender": true
}
```

### Automatische Anonymisierung deaktivieren
```bash
# .dsgvo/config/git_hook_config.json
{
  "auto_anonymize": false,  # Manuelle Bestätigung erforderlich
  "strict_mode": true
}
```

## 🔧 **Erweiterte Funktionen**

### Notfall-Bypass
```bash
# Bei kritischen Problemen
echo "Systemausfall - Deadline" > .dsgvo/.emergency_bypass

# Deaktivieren
rm .dsgvo/.emergency_bypass
```

### Backup-Management
```bash
# Alte Backups löschen (>90 Tage)
python3 scripts/dsgvo_compliance/dsgvo_manager.py cleanup

# Backup-Aufbewahrungszeit ändern
# .dsgvo/config/anonymizer_config.json
{
  "backup_retention_days": 30
}
```

### Whitelist erweitern
```bash
# .dsgvo/config/whitelist.txt
Musterstadt
Beispielschule
Testklasse
```

## 🧪 **Testing & Validierung**

### Vollständige System-Validierung
```bash
python3 scripts/dsgvo_compliance/test_dsgvo_system.py
```

### Manuelle Tests
```bash
# Test-Datei erstellen
echo "Max Mustermann ist Schüler der 5a" > test.md

# PII-Erkennung testen
python3 scripts/dsgvo_compliance/pii_scanner.py test.md

# Anonymisierung testen
python3 scripts/dsgvo_compliance/anonymizer.py . --anonymize test.md
```

## 📊 **Monitoring & Audit**

### Logs einsehen
```bash
# DSGVO-Manager Logs
cat .dsgvo/logs/dsgvo_manager_$(date +%Y%m%d).log

# PII-Scanner Logs
cat .dsgvo/logs/pii_scanner_$(date +%Y%m%d).log

# Git-Hook Audit
cat .dsgvo/logs/git_hook_audit.log
```

### Compliance-Bericht
```bash
python3 scripts/dsgvo_compliance/dsgvo_manager.py compliance > compliance_report.txt
```

## 🚨 **Troubleshooting**

### Häufige Probleme

#### "Cryptography nicht installiert"
```bash
pip3 install --user cryptography keyring
```

#### "Git-Hook wird nicht ausgeführt"
```bash
chmod +x .git/hooks/pre-commit
cat .git/hooks/pre-commit  # Inhalt prüfen
```

#### "Verschlüsselung fehlgeschlagen"
```bash
# Passwort zurücksetzen
rm .dsgvo/salt.key .dsgvo/mappings/anonymization_mappings.enc
# Beim nächsten Anonymisierungs-Aufruf neues Passwort setzen
```

#### "PII wird nicht erkannt"
```bash
# Konfidenz-Schwellwert senken
python3 scripts/dsgvo_compliance/pii_scanner.py datei.md --threshold 0.5
```

### Support-Informationen sammeln
```bash
# System-Status
python3 scripts/dsgvo_compliance/dsgvo_manager.py status

# Git-Status
git status
git log --oneline -5

# Python-Environment
python3 --version
pip3 list | grep -E "(cryptography|keyring)"
```

## 📁 **Datei-Struktur**

```
.dsgvo/
├── scripts/
│   ├── pii_scanner.py           # PII-Erkennung
│   ├── anonymizer.py            # Anonymisierung/Deanonymisierung
│   ├── pre-commit-dsgvo.sh      # Git-Hook
│   └── dsgvo_manager.py         # Management-Tool
├── config/
│   ├── pii_scanner_config.json  # Scanner-Einstellungen
│   ├── anonymizer_config.json   # Anonymisierungs-Einstellungen
│   ├── git_hook_config.json     # Git-Hook-Konfiguration
│   └── whitelist.txt            # Ausnahmen für Namen
├── mappings/                    # 🔒 NIEMALS COMMITTEN!
│   └── anonymization_mappings.enc  # Verschlüsselte Zuordnungen
├── logs/                        # Audit-Logs
├── backups/                     # Automatische Backups
└── README.md                    # Diese Dokumentation
```

## ⚖️ **Rechtliche Hinweise**

### Verarbeitungsverzeichnis (Art. 30 DSGVO)
- **Zweck**: Pseudonymisierung von Schülerdaten für Unterrichtsdokumentation
- **Rechtsgrundlage**: Art. 6 Abs. 1 lit. e DSGVO (öffentliche Aufgabe)
- **Kategorien**: Namen, ggf. Alter/Geschlecht
- **Empfänger**: Keine (lokale Verarbeitung)
- **Übermittlung**: Keine
- **Löschfristen**: Nach Zweckerfüllung (Standard: 90 Tage)
- **Sicherheit**: AES-256-Verschlüsselung, lokale Verarbeitung

### Technische und organisatorische Maßnahmen (Art. 32 DSGVO)
- **Vertraulichkeit**: AES-256-Verschlüsselung, Passwort-basierte Schlüssel
- **Integrität**: Hash-basierte Integritätsprüfung, Git-Versionierung
- **Verfügbarkeit**: Lokale Backups, sichere Wiederherstellung
- **Belastbarkeit**: Offline-Verarbeitung, keine Cloud-Dependencies
- **Testing**: Regelmäßige Penetrationstests, Compliance-Audits
- **Wiederherstellung**: Dokumentierte Recovery-Procedures

## 🤝 **Support & Weiterentwicklung**

### Bug Reports
- Logs sammeln: `.dsgvo/logs/`
- System-Status: `dsgvo_manager.py status`
- Git-Repository-Status bereitstellen

### Feature Requests
- DSGVO-Compliance hat Priorität
- Sicherheit vor Komfort
- Rechtskonforme Implementierung erforderlich

### Beiträge
- Alle Änderungen müssen DSGVO-konform sein
- Sicherheits-Review erforderlich
- Tests für neue Features obligatorisch

---

**🛡️ DSGVO-Garantie**: Vollständige Compliance nach Art. 4, 25, 32  
**🔒 Sicherheit**: AES-256-Verschlüsselung + lokale Verarbeitung  
**⚡ Automatisierung**: Transparente Git-Integration ohne Workflow-Unterbrechung  
**📚 Rechtssicherheit**: Vollständige Dokumentation für Datenschutzbeauftragte  
**🔄 Zukunftssicher**: Adaptive Anpassung bei Rechtsänderungen
