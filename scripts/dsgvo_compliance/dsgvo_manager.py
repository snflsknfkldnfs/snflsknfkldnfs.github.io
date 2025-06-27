#!/usr/bin/env python3
"""
DSGVO-Management-Tool: Zentrale Steuerung für Schülerdaten-Anonymisierung
Vereinfacht die Bedienung des DSGVO-Compliance-Systems
Rechtsbasis: DSGVO Art. 25 (Privacy by Design)
"""

import sys
import os
import json
import argparse
from pathlib import Path
from typing import Dict, List, Optional
import subprocess
from datetime import datetime
import logging

class DSGVOManager:
    """Zentrale Management-Klasse für DSGVO-Compliance"""
    
    def __init__(self, repository_path: Path):
        self.repository_path = Path(repository_path)
        self.dsgvo_dir = self.repository_path / '.dsgvo'
        self.scripts_dir = self.dsgvo_dir / 'scripts'
        self.config_dir = self.dsgvo_dir / 'config'
        self.logs_dir = self.dsgvo_dir / 'logs'
        
        # Scripts-Pfade
        self.pii_scanner = self.scripts_dir / 'pii_scanner.py'
        self.anonymizer = self.scripts_dir / 'anonymizer.py'
        
        # Logging
        self.setup_logging()
        
        # Validierung
        self.validate_installation()
    
    def setup_logging(self):
        """Richtet Logging für Manager ein"""
        log_file = self.logs_dir / f'dsgvo_manager_{datetime.now().strftime("%Y%m%d")}.log'
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - DSGVO-Manager - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger('dsgvo_manager')
    
    def validate_installation(self):
        """Validiert DSGVO-System-Installation"""
        missing_components = []
        
        if not self.dsgvo_dir.exists():
            missing_components.append('.dsgvo directory')
        
        if not self.pii_scanner.exists():
            missing_components.append('PII-Scanner')
        
        if not self.anonymizer.exists():
            missing_components.append('Anonymizer')
        
        if missing_components:
            print(f"❌ DSGVO-System unvollständig: {', '.join(missing_components)}")
            print(f"Führen Sie setup-dsgvo-compliance.sh aus.")
            sys.exit(1)
    
    def run_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Führt Shell-Kommando aus"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                cwd=self.repository_path
            )
            return result
        except Exception as e:
            self.logger.error(f"Kommando fehlgeschlagen: {' '.join(command)} - {e}")
            raise
    
    def scan_repository(self, recursive: bool = True, threshold: float = 0.7) -> Dict:
        """Scannt gesamtes Repository nach PII"""
        print("🔍 Scanne Repository nach personenbezogenen Daten...")
        
        command = [
            'python3', str(self.pii_scanner),
            str(self.repository_path),
            '--threshold', str(threshold),
            '--report', str(self.dsgvo_dir / 'temp' / 'scan_results.json')
        ]
        
        if recursive:
            command.append('--recursive')
        
        result = self.run_command(command)
        
        if result.returncode == 0:
            print("✅ Repository ist sauber - keine PII gefunden")
            return {'status': 'clean', 'findings': []}
        elif result.returncode == 1:
            print("⚠️ Personenbezogene Daten gefunden")
            
            # Ergebnisse laden
            results_file = self.dsgvo_dir / 'temp' / 'scan_results.json'
            if results_file.exists():
                with open(results_file, 'r', encoding='utf-8') as f:
                    findings = json.load(f)
                return {'status': 'pii_found', 'findings': findings}
            
        return {'status': 'error', 'findings': []}
    
    def anonymize_repository(self, auto_mode: bool = True, backup: bool = True) -> bool:
        """Anonymisiert alle gefundenen PII im Repository"""
        print("🔄 Starte Repository-Anonymisierung...")
        
        # Zuerst scannen
        scan_results = self.scan_repository()
        
        if scan_results['status'] == 'clean':
            print("✅ Keine Anonymisierung notwendig")
            return True
        
        if scan_results['status'] == 'error':
            print("❌ Fehler beim Scannen")
            return False
        
        findings = scan_results['findings']
        affected_files = set()
        
        # Betroffene Dateien sammeln
        for finding in findings.get('findings', []):
            affected_files.add(finding['file'])
        
        print(f"📁 Betroffene Dateien: {len(affected_files)}")
        
        # Jede Datei anonymisieren
        success_count = 0
        for file_path in affected_files:
            file_path_obj = Path(file_path)
            
            if not file_path_obj.exists():
                continue
            
            print(f"   Anonymisiere: {file_path}")
            
            command = [
                'python3', str(self.anonymizer),
                str(self.repository_path),
                '--anonymize', str(file_path)
            ]
            
            if not backup:
                command.append('--no-backup')
            
            result = self.run_command(command)
            
            if result.returncode == 0:
                success_count += 1
            else:
                print(f"❌ Fehler bei: {file_path}")
        
        print(f"✅ Anonymisierung abgeschlossen: {success_count}/{len(affected_files)} Dateien")
        
        # Git-Status prüfen
        if self.is_git_repository():
            print("💡 Hinweis: Anonymisierte Dateien wurden geändert.")
            print("   Führen Sie 'git add .' und 'git commit' aus.")
        
        return success_count > 0
    
    def deanonymize_file(self, file_path: Path, output_path: Optional[Path] = None) -> bool:
        """Deanonymisiert einzelne Datei"""
        print(f"🔓 Deanonymisiere: {file_path}")
        
        command = [
            'python3', str(self.anonymizer),
            str(self.repository_path),
            '--deanonymize', str(file_path)
        ]
        
        if output_path:
            command.extend(['--output', str(output_path)])
        
        result = self.run_command(command)
        
        if result.returncode == 0:
            output_file = output_path or file_path.with_suffix('.deanonymized' + file_path.suffix)
            print(f"✅ Deanonymisiert: {output_file}")
            return True
        else:
            print(f"❌ Deanonymisierung fehlgeschlagen")
            return False
    
    def show_statistics(self) -> Dict:
        """Zeigt Anonymisierungs-Statistiken"""
        print("📊 DSGVO-Anonymisierungs-Statistiken")
        print("=" * 50)
        
        command = [
            'python3', str(self.anonymizer),
            str(self.repository_path),
            '--stats'
        ]
        
        result = self.run_command(command, capture_output=False)
        
        return {'success': result.returncode == 0}
    
    def cleanup_old_data(self, retention_days: int = 90) -> bool:
        """Löscht alte Backups und Logs"""
        print(f"🧹 Lösche Daten älter als {retention_days} Tage...")
        
        command = [
            'python3', str(self.anonymizer),
            str(self.repository_path),
            '--cleanup'
        ]
        
        result = self.run_command(command)
        
        if result.returncode == 0:
            print("✅ Cleanup abgeschlossen")
            return True
        else:
            print("❌ Cleanup fehlgeschlagen")
            return False
    
    def validate_compliance(self) -> Dict:
        """Validiert DSGVO-Compliance des Repositories"""
        print("🔍 Validiere DSGVO-Compliance...")
        
        compliance_report = {
            'timestamp': datetime.now().isoformat(),
            'repository': str(self.repository_path),
            'checks': {},
            'overall_status': 'unknown'
        }
        
        # Check 1: PII-Scan
        scan_results = self.scan_repository()
        compliance_report['checks']['pii_scan'] = {
            'status': scan_results['status'],
            'findings_count': len(scan_results.get('findings', {}).get('findings', []))
        }
        
        # Check 2: Verschlüsselung
        mappings_file = self.dsgvo_dir / 'mappings' / 'anonymization_mappings.enc'
        compliance_report['checks']['encryption'] = {
            'status': 'encrypted' if mappings_file.exists() else 'no_mappings',
            'file_exists': mappings_file.exists()
        }
        
        # Check 3: Git-Hooks
        pre_commit_hook = self.repository_path / '.git' / 'hooks' / 'pre-commit'
        compliance_report['checks']['git_hooks'] = {
            'status': 'installed' if pre_commit_hook.exists() else 'missing',
            'hook_exists': pre_commit_hook.exists()
        }
        
        # Check 4: .gitignore
        gitignore = self.repository_path / '.gitignore'
        gitignore_ok = False
        if gitignore.exists():
            with open(gitignore, 'r', encoding='utf-8') as f:
                content = f.read()
                gitignore_ok = '.dsgvo/mappings/' in content
        
        compliance_report['checks']['gitignore'] = {
            'status': 'configured' if gitignore_ok else 'missing',
            'properly_configured': gitignore_ok
        }
        
        # Overall Status
        critical_issues = []
        if scan_results['status'] == 'pii_found':
            critical_issues.append('Unverschlüsselte PII gefunden')
        if not pre_commit_hook.exists():
            critical_issues.append('Git-Hook fehlt')
        if not gitignore_ok:
            critical_issues.append('.gitignore unvollständig')
        
        if critical_issues:
            compliance_report['overall_status'] = 'non_compliant'
            compliance_report['critical_issues'] = critical_issues
        else:
            compliance_report['overall_status'] = 'compliant'
        
        # Ausgabe
        print(f"📋 Compliance-Status: {compliance_report['overall_status'].upper()}")
        
        if critical_issues:
            print("❌ Kritische Probleme:")
            for issue in critical_issues:
                print(f"   - {issue}")
        else:
            print("✅ Alle Compliance-Checks bestanden")
        
        return compliance_report
    
    def emergency_bypass(self, reason: str, enable: bool = True) -> bool:
        """Aktiviert/Deaktiviert Notfall-Bypass"""
        bypass_file = self.dsgvo_dir / '.emergency_bypass'
        
        if enable:
            with open(bypass_file, 'w', encoding='utf-8') as f:
                f.write(f"{reason}\nActivated: {datetime.now().isoformat()}")
            print(f"⚠️ Notfall-Bypass aktiviert: {reason}")
            print(f"   Deaktivierung: dsgvo-manager emergency-bypass --disable")
            return True
        else:
            if bypass_file.exists():
                bypass_file.unlink()
                print("✅ Notfall-Bypass deaktiviert")
                return True
            else:
                print("ℹ️ Notfall-Bypass war nicht aktiv")
                return False
    
    def is_git_repository(self) -> bool:
        """Prüft ob Repository ein Git-Repository ist"""
        return (self.repository_path / '.git').exists()
    
    def get_system_status(self) -> Dict:
        """Liefert vollständigen System-Status"""
        status = {
            'installation': 'complete',
            'git_repository': self.is_git_repository(),
            'components': {
                'pii_scanner': self.pii_scanner.exists(),
                'anonymizer': self.anonymizer.exists(),
                'git_hooks': (self.repository_path / '.git' / 'hooks' / 'pre-commit').exists() if self.is_git_repository() else False
            },
            'emergency_bypass': (self.dsgvo_dir / '.emergency_bypass').exists()
        }
        
        return status


def main():
    """Hauptfunktion für CLI-Interface"""
    parser = argparse.ArgumentParser(
        description='DSGVO-Management-Tool für Schülerdaten-Anonymisierung',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Kommandos:
  scan                 Scanne Repository nach personenbezogenen Daten
  anonymize           Anonymisiere gefundene PII automatisch
  deanonymize FILE    Deanonymisiere spezifische Datei
  stats               Zeige Anonymisierungs-Statistiken
  compliance          Validiere DSGVO-Compliance
  cleanup             Lösche alte Backups und Logs
  status              Zeige System-Status
  emergency-bypass    Aktiviere/Deaktiviere Notfall-Bypass

Beispiele:
  dsgvo-manager scan                              # Repository scannen
  dsgvo-manager anonymize                         # Automatische Anonymisierung
  dsgvo-manager deanonymize unterricht.md         # Datei deanonymisieren
  dsgvo-manager emergency-bypass --reason "Test"  # Notfall-Bypass
        """
    )
    
    parser.add_argument('command', choices=[
        'scan', 'anonymize', 'deanonymize', 'stats', 
        'compliance', 'cleanup', 'status', 'emergency-bypass'
    ], help='Auszuführendes Kommando')
    
    parser.add_argument('file', nargs='?', type=Path, 
                        help='Datei für deanonymize-Kommando')
    parser.add_argument('--repository', type=Path, default=Path.cwd(),
                        help='Repository-Pfad (Standard: aktuelles Verzeichnis)')
    parser.add_argument('--threshold', type=float, default=0.7,
                        help='Konfidenz-Schwellwert für PII-Erkennung')
    parser.add_argument('--no-backup', action='store_true',
                        help='Keine Backups vor Anonymisierung')
    parser.add_argument('--output', type=Path,
                        help='Ausgabedatei für Deanonymisierung')
    parser.add_argument('--reason', type=str,
                        help='Grund für Emergency-Bypass')
    parser.add_argument('--disable', action='store_true',
                        help='Emergency-Bypass deaktivieren')
    
    args = parser.parse_args()
    
    # Repository validieren
    if not args.repository.exists():
        print(f"❌ Repository nicht gefunden: {args.repository}")
        return 1
    
    try:
        # Manager initialisieren
        manager = DSGVOManager(args.repository)
        
        # Kommando ausführen
        if args.command == 'scan':
            results = manager.scan_repository(threshold=args.threshold)
            return 0 if results['status'] != 'error' else 1
        
        elif args.command == 'anonymize':
            success = manager.anonymize_repository(backup=not args.no_backup)
            return 0 if success else 1
        
        elif args.command == 'deanonymize':
            if not args.file:
                print("❌ Datei-Argument erforderlich für deanonymize")
                return 1
            success = manager.deanonymize_file(args.file, args.output)
            return 0 if success else 1
        
        elif args.command == 'stats':
            results = manager.show_statistics()
            return 0 if results['success'] else 1
        
        elif args.command == 'compliance':
            report = manager.validate_compliance()
            return 0 if report['overall_status'] == 'compliant' else 1
        
        elif args.command == 'cleanup':
            success = manager.cleanup_old_data()
            return 0 if success else 1
        
        elif args.command == 'status':
            status = manager.get_system_status()
            print("🔧 DSGVO-System Status:")
            print(f"   Installation: {status['installation']}")
            print(f"   Git-Repository: {status['git_repository']}")
            print(f"   PII-Scanner: {'✅' if status['components']['pii_scanner'] else '❌'}")
            print(f"   Anonymizer: {'✅' if status['components']['anonymizer'] else '❌'}")
            print(f"   Git-Hooks: {'✅' if status['components']['git_hooks'] else '❌'}")
            print(f"   Emergency-Bypass: {'⚠️ AKTIV' if status['emergency_bypass'] else '✅ Inaktiv'}")
            return 0
        
        elif args.command == 'emergency-bypass':
            if args.disable:
                success = manager.emergency_bypass("", enable=False)
            else:
                if not args.reason:
                    print("❌ --reason erforderlich für Emergency-Bypass")
                    return 1
                success = manager.emergency_bypass(args.reason, enable=True)
            return 0 if success else 1
        
        else:
            parser.print_help()
            return 1
            
    except Exception as e:
        print(f"❌ Fehler: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
