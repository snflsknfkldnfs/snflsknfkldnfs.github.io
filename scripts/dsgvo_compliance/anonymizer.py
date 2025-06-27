#!/usr/bin/env python3
"""
DSGVO-konforme Anonymisierungs-Engine für Schülerdaten
Pseudonymisiert automatisch erkannte personenbezogene Daten
Rechtsbasis: DSGVO Art. 4 Nr. 5 (Pseudonymisierung)
"""

import json
import hashlib
import getpass
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import argparse
import logging
from datetime import datetime, timedelta
import base64
import secrets

# Kryptographie-Imports
try:
    from cryptography.fernet import Fernet
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    CRYPTO_AVAILABLE = True
except ImportError:
    print("FEHLER: cryptography-Paket nicht installiert.", file=sys.stderr)
    print("Installation: pip install cryptography", file=sys.stderr)
    CRYPTO_AVAILABLE = False


class DSGVOAnonymizer:
    """DSGVO-konforme Anonymisierungs-Engine"""
    
    def __init__(self, repository_path: Path, password: Optional[str] = None):
        self.repository_path = Path(repository_path)
        self.dsgvo_dir = self.repository_path / '.dsgvo'
        self.mappings_dir = self.dsgvo_dir / 'mappings'
        self.logs_dir = self.dsgvo_dir / 'logs'
        
        # Verzeichnisse erstellen
        self.mappings_dir.mkdir(parents=True, exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        
        # Verschlüsselung initialisieren
        self.encryption_key = None
        self.fernet = None
        self._init_encryption(password)
        
        # Anonymisierungs-State
        self.mappings = {}  # Original -> Pseudonym
        self.reverse_mappings = {}  # Pseudonym -> Original
        self.gender_counters = {'M': 1, 'W': 1, 'X': 1}
        
        # Konfiguration
        self.config = self._load_config()
        
        # Logging
        self.setup_logging()
        
        # Mappings laden
        self._load_mappings()
    
    def _init_encryption(self, password: Optional[str] = None):
        """Initialisiert DSGVO-konforme Verschlüsselung"""
        if not CRYPTO_AVAILABLE:
            raise RuntimeError("Verschlüsselung nicht verfügbar. Installieren Sie: pip install cryptography")
        
        # Passwort-basierte Schlüsselableitung
        if password is None:
            password = getpass.getpass("DSGVO-Verschlüsselungspasswort: ")
        
        # Repository-spezifischer Salt
        salt_file = self.dsgvo_dir / 'salt.key'
        if salt_file.exists():
            with open(salt_file, 'rb') as f:
                salt = f.read()
        else:
            salt = secrets.token_bytes(32)
            with open(salt_file, 'wb') as f:
                f.write(salt)
            # Berechtigung auf User-only setzen
            salt_file.chmod(0o600)
        
        # Schlüsselableitung (PBKDF2)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,  # NIST-Empfehlung
        )
        
        self.encryption_key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        self.fernet = Fernet(self.encryption_key)
    
    def _load_config(self) -> Dict:
        """Lädt Anonymisierungs-Konfiguration"""
        config_file = self.dsgvo_dir / 'anonymizer_config.json'
        
        default_config = {
            'pseudonym_format': 'SuS_{gender}_{counter:03d}',
            'preserve_gender': True,
            'preserve_length_approx': True,
            'backup_retention_days': 90,
            'auto_save_frequency': 10,  # Nach X Anonymisierungen automatisch speichern
            'enable_audit_trail': True
        }
        
        if config_file.exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                default_config.update(user_config)
            except Exception as e:
                print(f"Warnung: Konfiguration konnte nicht geladen werden: {e}")
        else:
            # Default-Konfiguration speichern
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=2, ensure_ascii=False)
        
        return default_config
    
    def setup_logging(self):
        """Richtet DSGVO-konformes Audit-Logging ein"""
        if not self.config.get('enable_audit_trail', True):
            self.logger = logging.getLogger('dsgvo_anonymizer_silent')
            self.logger.addHandler(logging.NullHandler())
            return
        
        log_file = self.logs_dir / f'anonymizer_{datetime.now().strftime("%Y%m%d")}.log'
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - DSGVO-Anonymizer - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger('dsgvo_anonymizer')
        self.logger.info("DSGVO-Anonymizer gestartet")
    
    def _load_mappings(self):
        """Lädt verschlüsselte Anonymisierungs-Mappings"""
        mappings_file = self.mappings_dir / 'anonymization_mappings.enc'
        
        if not mappings_file.exists():
            self.logger.info("Keine bestehenden Mappings gefunden. Starte mit leeren Mappings.")
            return
        
        try:
            with open(mappings_file, 'rb') as f:
                encrypted_data = f.read()
            
            decrypted_data = self.fernet.decrypt(encrypted_data)
            mappings_data = json.loads(decrypted_data.decode('utf-8'))
            
            self.mappings = mappings_data.get('mappings', {})
            self.reverse_mappings = mappings_data.get('reverse_mappings', {})
            self.gender_counters = mappings_data.get('gender_counters', {'M': 1, 'W': 1, 'X': 1})
            
            self.logger.info(f"Mappings geladen: {len(self.mappings)} Einträge")
            
        except Exception as e:
            self.logger.error(f"Fehler beim Laden der Mappings: {e}")
            self.logger.warning("Starte mit leeren Mappings")
    
    def _save_mappings(self):
        """Speichert verschlüsselte Anonymisierungs-Mappings"""
        mappings_data = {
            'mappings': self.mappings,
            'reverse_mappings': self.reverse_mappings,
            'gender_counters': self.gender_counters,
            'last_updated': datetime.now().isoformat(),
            'version': '1.0.0'
        }
        
        try:
            # JSON serialisieren
            json_data = json.dumps(mappings_data, ensure_ascii=False, indent=2)
            
            # Verschlüsseln
            encrypted_data = self.fernet.encrypt(json_data.encode('utf-8'))
            
            # Atomisches Schreiben
            mappings_file = self.mappings_dir / 'anonymization_mappings.enc'
            temp_file = mappings_file.with_suffix('.tmp')
            
            with open(temp_file, 'wb') as f:
                f.write(encrypted_data)
            
            # Atomic move
            temp_file.replace(mappings_file)
            
            # Berechtigung auf User-only setzen
            mappings_file.chmod(0o600)
            
            self.logger.info(f"Mappings gespeichert: {len(self.mappings)} Einträge")
            
        except Exception as e:
            self.logger.error(f"Fehler beim Speichern der Mappings: {e}")
            raise
    
    def detect_gender(self, name: str, context: str = "") -> str:
        """
        Erkennt Geschlecht für konsistente Pseudonymisierung
        Rückgabe: 'M' (männlich), 'W' (weiblich), 'X' (unbestimmt)
        """
        # Explizite Angaben im Kontext
        context_lower = context.lower()
        
        if any(marker in context_lower for marker in ['(m)', 'schüler ', '♂', 'junge']):
            return 'M'
        elif any(marker in context_lower for marker in ['(w)', 'schülerin', '♀', 'mädchen']):
            return 'W'
        
        # Heuristische Geschlechtserkennung (deutschsprachig)
        if not name:
            return 'X'
        
        first_name = name.split()[0].lower()
        
        # Typisch weibliche Endungen
        female_endings = ['a', 'e', 'in', 'ine', 'ette', 'chen', 'lein']
        if any(first_name.endswith(ending) for ending in female_endings):
            # Ausnahmen prüfen
            male_exceptions = ['ole', 'arne', 'rene', 'andre']
            if not any(exception in first_name for exception in male_exceptions):
                return 'W'
        
        # Typisch männliche Endungen
        male_endings = ['er', 'el', 'en', 'an', 'on', 'us', 'as', 'o']
        if any(first_name.endswith(ending) for ending in male_endings):
            return 'M'
        
        # Bekannte Namen-Listen (Basis-Set)
        known_male_names = {
            'max', 'tim', 'tom', 'jan', 'ben', 'leo', 'paul', 'leon', 'felix',
            'david', 'noah', 'alex', 'finn', 'luca', 'erik', 'jonas', 'lars'
        }
        
        known_female_names = {
            'anna', 'lea', 'emma', 'mia', 'sara', 'maja', 'lisa', 'lena', 'nina',
            'julia', 'laura', 'marie', 'sophie', 'clara', 'nele', 'greta'
        }
        
        if first_name in known_male_names:
            return 'M'
        elif first_name in known_female_names:
            return 'W'
        
        return 'X'  # Unbestimmt
    
    def generate_pseudonym(self, original_name: str, context: str = "") -> str:
        """Generiert konsistentes Pseudonym für Namen"""
        # Bereits anonymisiert?
        if original_name in self.mappings:
            return self.mappings[original_name]
        
        # Geschlecht erkennen
        gender = self.detect_gender(original_name, context)
        
        # Pseudonym generieren
        pseudonym = self.config['pseudonym_format'].format(
            gender=gender,
            counter=self.gender_counters[gender]
        )
        
        # Counter erhöhen
        self.gender_counters[gender] += 1
        
        # Mappings aktualisieren
        self.mappings[original_name] = pseudonym
        self.reverse_mappings[pseudonym] = original_name
        
        # Audit-Log
        self.logger.info(f"Neues Pseudonym: '{original_name}' -> '{pseudonym}' (Geschlecht: {gender})")
        
        return pseudonym
    
    def anonymize_text(self, text: str, pii_findings: List[Dict]) -> Tuple[str, int]:
        """
        Anonymisiert Text basierend auf PII-Findings
        Rückgabe: (anonymisierter_text, anzahl_ersetzungen)
        """
        if not pii_findings:
            return text, 0
        
        anonymized_text = text
        replacements_count = 0
        
        # Nach Position sortieren (rückwärts für korrekte String-Indizes)
        sorted_findings = sorted(pii_findings, key=lambda x: x.get('position', 0), reverse=True)
        
        # Text-basierte Ersetzung wenn keine Positionen verfügbar
        if not any('position' in finding for finding in pii_findings):
            # Namen nach Länge sortieren (längste zuerst für korrekte Ersetzung)
            names_by_length = sorted(
                set(finding['name'] for finding in pii_findings),
                key=len, reverse=True
            )
            
            for name in names_by_length:
                # Pseudonym generieren
                relevant_findings = [f for f in pii_findings if f['name'] == name]
                context = relevant_findings[0].get('context', '') if relevant_findings else ''
                
                pseudonym = self.generate_pseudonym(name, context)
                
                # Ersetzungen durchführen (Wort-Grenzen beachten)
                import re
                pattern = r'\b' + re.escape(name) + r'\b'
                matches = list(re.finditer(pattern, anonymized_text, re.IGNORECASE))
                
                if matches:
                    for match in reversed(matches):  # Rückwärts für korrekte Indizes
                        start, end = match.span()
                        anonymized_text = anonymized_text[:start] + pseudonym + anonymized_text[end:]
                        replacements_count += 1
        
        else:
            # Positions-basierte Ersetzung
            for finding in sorted_findings:
                if 'position' in finding:
                    start, end = finding['position']
                    name = finding['name']
                    context = finding.get('context', '')
                    
                    pseudonym = self.generate_pseudonym(name, context)
                    
                    anonymized_text = anonymized_text[:start] + pseudonym + anonymized_text[end:]
                    replacements_count += 1
        
        return anonymized_text, replacements_count
    
    def anonymize_file(self, file_path: Path, pii_findings: List[Dict], 
                      backup: bool = True) -> bool:
        """
        Anonymisiert einzelne Datei
        Rückgabe: True bei Erfolg, False bei Fehler
        """
        try:
            # Nur relevante Findings für diese Datei
            file_findings = [f for f in pii_findings if f.get('file') == str(file_path)]
            
            if not file_findings:
                self.logger.info(f"Keine PII-Findings für {file_path}")
                return True
            
            # Original-Inhalt lesen
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # Backup erstellen
            if backup:
                backup_dir = self.dsgvo_dir / 'backups'
                backup_dir.mkdir(exist_ok=True)
                
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_file = backup_dir / f"{file_path.name}_{timestamp}.backup"
                
                with open(backup_file, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                self.logger.info(f"Backup erstellt: {backup_file}")
            
            # Anonymisierung durchführen
            anonymized_content, replacements = self.anonymize_text(original_content, file_findings)
            
            if replacements == 0:
                self.logger.warning(f"Keine Ersetzungen in {file_path} durchgeführt")
                return True
            
            # Anonymisierten Inhalt schreiben
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(anonymized_content)
            
            self.logger.info(f"Datei anonymisiert: {file_path} ({replacements} Ersetzungen)")
            
            # Mappings speichern
            self._save_mappings()
            
            return True
            
        except Exception as e:
            self.logger.error(f"Fehler beim Anonymisieren von {file_path}: {e}")
            return False
    
    def deanonymize_file(self, file_path: Path, output_path: Optional[Path] = None) -> bool:
        """
        Stellt Original-Namen in Datei wieder her (für autorisierte Nutzer)
        ACHTUNG: Nur für berechtigte Personen!
        """
        try:
            if not self.reverse_mappings:
                self.logger.warning("Keine Reverse-Mappings verfügbar für Deanonymisierung")
                return False
            
            # Datei lesen
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Deanonymisierung
            deanonymized_content = content
            replacements = 0
            
            # Pseudonyme nach Länge sortieren (längste zuerst)
            pseudonyms = sorted(self.reverse_mappings.keys(), key=len, reverse=True)
            
            for pseudonym in pseudonyms:
                original_name = self.reverse_mappings[pseudonym]
                
                # Wort-Grenzen-sichere Ersetzung
                import re
                pattern = r'\b' + re.escape(pseudonym) + r'\b'
                matches = len(re.findall(pattern, deanonymized_content))
                
                if matches > 0:
                    deanonymized_content = re.sub(pattern, original_name, deanonymized_content)
                    replacements += matches
            
            # Ausgabe
            output_file = output_path or file_path.with_suffix('.deanonymized' + file_path.suffix)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(deanonymized_content)
            
            self.logger.info(f"Deanonymisierung abgeschlossen: {output_file} ({replacements} Ersetzungen)")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Fehler bei Deanonymisierung von {file_path}: {e}")
            return False
    
    def get_anonymization_stats(self) -> Dict:
        """Liefert Statistiken über Anonymisierungen"""
        return {
            'total_mappings': len(self.mappings),
            'gender_distribution': {
                'male': self.gender_counters['M'] - 1,
                'female': self.gender_counters['W'] - 1,
                'unspecified': self.gender_counters['X'] - 1
            },
            'last_updated': datetime.now().isoformat(),
            'repository': str(self.repository_path)
        }
    
    def cleanup_old_backups(self, retention_days: Optional[int] = None):
        """Löscht alte Backup-Dateien gemäß Retention-Policy"""
        retention_days = retention_days or self.config.get('backup_retention_days', 90)
        cutoff_date = datetime.now() - timedelta(days=retention_days)
        
        backup_dir = self.dsgvo_dir / 'backups'
        if not backup_dir.exists():
            return
        
        deleted_count = 0
        for backup_file in backup_dir.glob('*.backup'):
            try:
                file_mtime = datetime.fromtimestamp(backup_file.stat().st_mtime)
                if file_mtime < cutoff_date:
                    backup_file.unlink()
                    deleted_count += 1
            except Exception as e:
                self.logger.warning(f"Fehler beim Löschen von Backup {backup_file}: {e}")
        
        if deleted_count > 0:
            self.logger.info(f"Alte Backups gelöscht: {deleted_count} Dateien")


def main():
    """Hauptfunktion für CLI-Nutzung"""
    parser = argparse.ArgumentParser(
        description='DSGVO-konforme Anonymisierungs-Engine für Schülerdaten',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Beispiele:
  python anonymizer.py /path/to/repo --anonymize datei.md       # Datei anonymisieren
  python anonymizer.py /path/to/repo --deanonymize datei.md     # Datei deanonymisieren
  python anonymizer.py /path/to/repo --stats                    # Statistiken anzeigen
  python anonymizer.py /path/to/repo --cleanup                  # Alte Backups löschen
        """
    )
    
    parser.add_argument('repository', type=Path, help='Pfad zum Repository')
    parser.add_argument('--anonymize', type=Path, help='Datei anonymisieren')
    parser.add_argument('--deanonymize', type=Path, help='Datei deanonymisieren')
    parser.add_argument('--output', type=Path, help='Ausgabedatei für Deanonymisierung')
    parser.add_argument('--pii-findings', type=Path, help='JSON-Datei mit PII-Findings')
    parser.add_argument('--stats', action='store_true', help='Anonymisierungs-Statistiken anzeigen')
    parser.add_argument('--cleanup', action='store_true', help='Alte Backups löschen')
    parser.add_argument('--no-backup', action='store_true', help='Kein Backup vor Anonymisierung')
    parser.add_argument('--password', help='Verschlüsselungspasswort (UNSICHER, nur für Tests)')
    
    args = parser.parse_args()
    
    # Repository validieren
    if not args.repository.exists():
        print(f"Fehler: Repository '{args.repository}' existiert nicht.", file=sys.stderr)
        return 1
    
    try:
        # Anonymizer initialisieren
        anonymizer = DSGVOAnonymizer(args.repository, password=args.password)
        
        # Aktionen durchführen
        if args.anonymize:
            # PII-Findings laden
            pii_findings = []
            if args.pii_findings and args.pii_findings.exists():
                with open(args.pii_findings, 'r', encoding='utf-8') as f:
                    findings_data = json.load(f)
                    pii_findings = findings_data.get('findings', [])
            
            success = anonymizer.anonymize_file(
                args.anonymize, 
                pii_findings, 
                backup=not args.no_backup
            )
            
            if success:
                print(f"✅ Datei erfolgreich anonymisiert: {args.anonymize}")
                return 0
            else:
                print(f"❌ Fehler bei Anonymisierung: {args.anonymize}", file=sys.stderr)
                return 1
        
        elif args.deanonymize:
            success = anonymizer.deanonymize_file(args.deanonymize, args.output)
            
            if success:
                output_file = args.output or args.deanonymize.with_suffix('.deanonymized' + args.deanonymize.suffix)
                print(f"✅ Datei erfolgreich deanonymisiert: {output_file}")
                return 0
            else:
                print(f"❌ Fehler bei Deanonymisierung: {args.deanonymize}", file=sys.stderr)
                return 1
        
        elif args.stats:
            stats = anonymizer.get_anonymization_stats()
            print("📊 DSGVO-Anonymisierungs-Statistiken:")
            print(f"   Gesamt-Mappings: {stats['total_mappings']}")
            print(f"   Männliche Namen: {stats['gender_distribution']['male']}")
            print(f"   Weibliche Namen: {stats['gender_distribution']['female']}")
            print(f"   Unbestimmte Namen: {stats['gender_distribution']['unspecified']}")
            print(f"   Repository: {stats['repository']}")
            return 0
        
        elif args.cleanup:
            anonymizer.cleanup_old_backups()
            print("✅ Backup-Cleanup abgeschlossen")
            return 0
        
        else:
            parser.print_help()
            return 1
            
    except Exception as e:
        print(f"Kritischer Fehler: {e}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
