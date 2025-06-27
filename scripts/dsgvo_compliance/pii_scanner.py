#!/usr/bin/env python3
"""
DSGVO-konformer PII-Scanner für Schülerdaten
Erkennt automatisch personenbezogene Daten in Unterrichtsmaterialien
Rechtsbasis: DSGVO Art. 4, 25, 32
"""

import re
import json
import os
import sys
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import argparse
import logging
from datetime import datetime

class DSGVOPIIScanner:
    """DSGVO-konformer Scanner für personenbezogene Daten"""
    
    def __init__(self, config_path: Optional[Path] = None):
        # DSGVO-konforme Konfiguration
        self.config = self._load_config(config_path)
        self.setup_logging()
        
        # Deutsche Namen-Pattern (DSGVO Art. 4 konform)
        self.name_patterns = [
            # Vollständige Namen
            r'\b[A-ZÄÖÜ][a-zäöüß]{2,15}\s+[A-ZÄÖÜ][a-zäöüß]{2,20}\b',
            # Kontext-basierte Erkennung
            r'\b(?:SuS|Schüler|Schülerin|Student|Studentin)\s+([A-ZÄÖÜ][a-zäöüß]{2,15})\b',
            # Namen mit Geschlechts-/Altersangabe
            r'\b([A-ZÄÖÜ][a-zäöüß]{2,15})\s*\(\s*\d{1,2}\s*[mwx]?\s*\)\b',
            # Listen-Format
            r'^\s*[-•*]\s*([A-ZÄÖÜ][a-zäöüß]{2,15}(?:\s+[A-ZÄÖÜ][a-zäöüß]{2,20})?)\s*$',
            # Tabellen-Format
            r'\|\s*([A-ZÄÖÜ][a-zäöüß]{2,15}(?:\s+[A-ZÄÖÜ][a-zäöüß]{2,20})?)\s*\|'
        ]
        
        # Whitelist für Nicht-Namen (DSGVO-konform)
        self.whitelist = self._load_whitelist()
        
        # Kontext-Keywords für erhöhte Konfidenz
        self.context_keywords = [
            'sus', 'schüler', 'schülerin', 'student', 'studentin',
            'klasse', 'kurs', 'lerngruppe', 'gruppe', 'team',
            'note', 'bewertung', 'leistung', 'prüfung', 'test'
        ]
    
    def _load_config(self, config_path: Optional[Path]) -> Dict:
        """Lädt DSGVO-konforme Konfiguration"""
        default_config = {
            'confidence_threshold': 0.7,
            'enable_context_analysis': True,
            'enable_audit_logging': True,
            'supported_extensions': ['.md', '.txt', '.pdf', '.docx', '.html'],
            'exclude_patterns': ['*.enc', '*/.*', '*/node_modules/*', '*/venv/*']
        }
        
        if config_path and config_path.exists():
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                default_config.update(user_config)
            except Exception as e:
                print(f"Warnung: Konfiguration konnte nicht geladen werden: {e}")
        
        return default_config
    
    def _load_whitelist(self) -> set:
        """Lädt Whitelist für Nicht-Namen"""
        whitelist = {
            # Deutsche Städte
            'Berlin', 'München', 'Hamburg', 'Köln', 'Frankfurt', 'Stuttgart',
            'Düsseldorf', 'Dortmund', 'Essen', 'Leipzig', 'Bremen', 'Dresden',
            'Hannover', 'Nürnberg', 'Duisburg', 'Bochum', 'Wuppertal', 'Bielefeld',
            
            # Wochentage
            'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag',
            
            # Monate
            'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
            'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
            
            # Schulfächer
            'Deutsch', 'Mathematik', 'Englisch', 'Geschichte', 'Biologie', 'Chemie',
            'Physik', 'Sport', 'Kunst', 'Musik', 'Religion', 'Ethik', 'Politik',
            
            # Häufige Begriffe
            'Aufgabe', 'Übung', 'Beispiel', 'Lösung', 'Methode', 'Gruppe', 'Team',
            'Projekt', 'Thema', 'Inhalt', 'Material', 'Medium', 'Computer', 'Internet'
        }
        
        # Erweiterte Whitelist aus Datei laden (falls vorhanden)
        whitelist_file = Path(__file__).parent / 'whitelist.txt'
        if whitelist_file.exists():
            try:
                with open(whitelist_file, 'r', encoding='utf-8') as f:
                    additional_words = {line.strip() for line in f if line.strip()}
                whitelist.update(additional_words)
            except Exception as e:
                self.logger.warning(f"Whitelist-Datei konnte nicht geladen werden: {e}")
        
        return whitelist
    
    def setup_logging(self):
        """Richtet DSGVO-konformes Audit-Logging ein"""
        if not self.config.get('enable_audit_logging', True):
            self.logger = logging.getLogger('dsgvo_scanner_silent')
            self.logger.addHandler(logging.NullHandler())
            return
        
        # Audit-Log Setup
        log_dir = Path.home() / '.dsgvo_logs'
        log_dir.mkdir(exist_ok=True)
        
        log_file = log_dir / f'pii_scanner_{datetime.now().strftime("%Y%m%d")}.log'
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - DSGVO-Scanner - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger('dsgvo_scanner')
        self.logger.info("DSGVO-PII-Scanner gestartet")
    
    def scan_file(self, file_path: Path) -> List[Dict]:
        """
        Scannt einzelne Datei nach personenbezogenen Daten
        Rückgabe: Liste mit PII-Findings (DSGVO-konform)
        """
        pii_findings = []
        
        try:
            # Datei-Extension prüfen
            if file_path.suffix.lower() not in self.config['supported_extensions']:
                return pii_findings
            
            # Ausschluss-Pattern prüfen
            if self._is_excluded(file_path):
                return pii_findings
            
            # Datei-Inhalt lesen
            content = self._read_file_content(file_path)
            if not content:
                return pii_findings
            
            # PII-Analyse durchführen
            pii_findings = self._analyze_content(file_path, content)
            
            # Audit-Logging
            if pii_findings:
                self.logger.warning(f"PII gefunden in {file_path}: {len(pii_findings)} Items")
            else:
                self.logger.info(f"Datei sauber: {file_path}")
                
        except Exception as e:
            self.logger.error(f"Fehler beim Scannen von {file_path}: {e}")
        
        return pii_findings
    
    def _read_file_content(self, file_path: Path) -> Optional[str]:
        """Liest Datei-Inhalt (verschiedene Formate)"""
        try:
            # Markdown/Text-Dateien
            if file_path.suffix.lower() in ['.md', '.txt', '.html']:
                with open(file_path, 'r', encoding='utf-8') as f:
                    return f.read()
            
            # PDF-Dateien (falls PyPDF2 verfügbar)
            elif file_path.suffix.lower() == '.pdf':
                try:
                    import PyPDF2
                    with open(file_path, 'rb') as f:
                        reader = PyPDF2.PdfReader(f)
                        text = ""
                        for page in reader.pages:
                            text += page.extract_text() + "\n"
                        return text
                except ImportError:
                    self.logger.warning(f"PyPDF2 nicht verfügbar für {file_path}")
                    return None
            
            # Word-Dokumente (falls python-docx verfügbar)
            elif file_path.suffix.lower() == '.docx':
                try:
                    import docx
                    doc = docx.Document(file_path)
                    text = ""
                    for paragraph in doc.paragraphs:
                        text += paragraph.text + "\n"
                    return text
                except ImportError:
                    self.logger.warning(f"python-docx nicht verfügbar für {file_path}")
                    return None
            
        except Exception as e:
            self.logger.error(f"Fehler beim Lesen von {file_path}: {e}")
        
        return None
    
    def _is_excluded(self, file_path: Path) -> bool:
        """Prüft ob Datei von Scan ausgeschlossen werden soll"""
        import fnmatch
        
        file_str = str(file_path)
        for pattern in self.config['exclude_patterns']:
            if fnmatch.fnmatch(file_str, pattern):
                return True
        return False
    
    def _analyze_content(self, file_path: Path, content: str) -> List[Dict]:
        """Analysiert Datei-Inhalt auf PII"""
        findings = []
        
        for line_num, line in enumerate(content.split('\n'), 1):
            line_findings = self._analyze_line(file_path, line_num, line)
            findings.extend(line_findings)
        
        # Duplikate entfernen und nach Konfidenz sortieren
        unique_findings = self._deduplicate_findings(findings)
        return sorted(unique_findings, key=lambda x: x['confidence'], reverse=True)
    
    def _analyze_line(self, file_path: Path, line_num: int, line: str) -> List[Dict]:
        """Analysiert einzelne Zeile auf PII"""
        findings = []
        
        for pattern_idx, pattern in enumerate(self.name_patterns):
            matches = re.finditer(pattern, line, re.IGNORECASE)
            
            for match in matches:
                # Namen extrahieren
                if match.groups():
                    name = match.group(1).strip()
                else:
                    name = match.group(0).strip()
                
                # Whitelist-Check
                if self._is_whitelisted(name):
                    continue
                
                # Konfidenz berechnen
                confidence = self._calculate_confidence(name, line, pattern_idx)
                
                # Nur bei ausreichender Konfidenz hinzufügen
                if confidence >= self.config['confidence_threshold']:
                    findings.append({
                        'file': str(file_path),
                        'line': line_num,
                        'name': name,
                        'context': line.strip(),
                        'confidence': confidence,
                        'pattern_type': f'pattern_{pattern_idx}',
                        'timestamp': datetime.now().isoformat()
                    })
        
        return findings
    
    def _is_whitelisted(self, name: str) -> bool:
        """Prüft ob Name auf Whitelist steht"""
        # Direkte Whitelist-Prüfung
        if name in self.whitelist:
            return True
        
        # Teilstring-Prüfung für zusammengesetzte Namen
        name_parts = name.split()
        for part in name_parts:
            if part in self.whitelist:
                return True
        
        # Sehr kurze oder sehr lange Namen ausschließen
        if len(name) < 3 or len(name) > 40:
            return True
        
        # Numerische oder spezielle Zeichen
        if re.search(r'[0-9@#$%^&*()_+=\[\]{}|;:,.<>?/~`]', name):
            return True
        
        return False
    
    def _calculate_confidence(self, name: str, context: str, pattern_idx: int) -> float:
        """Berechnet Konfidenz für PII-Erkennung"""
        confidence = 0.5  # Basis-Konfidenz
        
        # Pattern-spezifische Gewichtung
        pattern_weights = [0.8, 0.9, 0.85, 0.7, 0.75]  # Gewichte für verschiedene Pattern
        if pattern_idx < len(pattern_weights):
            confidence = pattern_weights[pattern_idx]
        
        # Kontext-Analyse
        context_lower = context.lower()
        
        # Positive Kontext-Indikatoren
        for keyword in self.context_keywords:
            if keyword in context_lower:
                confidence += 0.1
        
        # Strukturelle Indikatoren
        if re.search(r'\(\s*\d{1,2}\s*[mwx]?\s*\)', context):  # Alter/Geschlecht
            confidence += 0.15
        
        if re.search(r'note\s*:?\s*[1-6]|bewertung|leistung', context_lower):  # Bewertungskontext
            confidence += 0.1
        
        # Negative Indikatoren
        if any(word in context_lower for word in ['beispiel', 'muster', 'vorlage', 'template']):
            confidence -= 0.2
        
        if 'lorem ipsum' in context_lower or 'placeholder' in context_lower:
            confidence -= 0.5
        
        # Konfidenz normalisieren
        return max(0.0, min(1.0, confidence))
    
    def _deduplicate_findings(self, findings: List[Dict]) -> List[Dict]:
        """Entfernt Duplikate aus Findings"""
        seen = set()
        unique_findings = []
        
        for finding in findings:
            # Eindeutiger Schlüssel für Duplikat-Erkennung
            key = (finding['file'], finding['name'].lower(), finding['line'])
            
            if key not in seen:
                seen.add(key)
                unique_findings.append(finding)
        
        return unique_findings
    
    def scan_directory(self, directory: Path, recursive: bool = True) -> Dict:
        """
        Scannt Verzeichnis nach PII
        Rückgabe: Zusammenfassung aller Findings
        """
        all_findings = []
        scanned_files = 0
        
        if recursive:
            file_pattern = "**/*"
        else:
            file_pattern = "*"
        
        for file_path in directory.glob(file_pattern):
            if file_path.is_file():
                findings = self.scan_file(file_path)
                all_findings.extend(findings)
                scanned_files += 1
        
        # Zusammenfassung erstellen
        summary = {
            'total_files_scanned': scanned_files,
            'total_pii_found': len(all_findings),
            'files_with_pii': len(set(f['file'] for f in all_findings)),
            'unique_names_found': len(set(f['name'] for f in all_findings)),
            'findings': all_findings,
            'scan_timestamp': datetime.now().isoformat()
        }
        
        self.logger.info(f"Directory-Scan abgeschlossen: {scanned_files} Dateien, {len(all_findings)} PII-Items")
        
        return summary
    
    def generate_report(self, findings: Dict, output_file: Optional[Path] = None) -> str:
        """Generiert DSGVO-konformen Bericht"""
        report_lines = [
            "=" * 60,
            "DSGVO-PII-SCANNER BERICHT",
            "=" * 60,
            f"Scan-Zeitstempel: {findings['scan_timestamp']}",
            f"Gescannte Dateien: {findings['total_files_scanned']}",
            f"Gefundene PII-Items: {findings['total_pii_found']}",
            f"Betroffene Dateien: {findings['files_with_pii']}",
            f"Eindeutige Namen: {findings['unique_names_found']}",
            "",
            "DETAILLIERTE FINDINGS:",
            "-" * 40
        ]
        
        # Findings nach Datei gruppieren
        files_with_findings = {}
        for finding in findings['findings']:
            file_path = finding['file']
            if file_path not in files_with_findings:
                files_with_findings[file_path] = []
            files_with_findings[file_path].append(finding)
        
        for file_path, file_findings in files_with_findings.items():
            report_lines.append(f"\nDatei: {file_path}")
            report_lines.append(f"PII-Items: {len(file_findings)}")
            
            for finding in sorted(file_findings, key=lambda x: x['line']):
                report_lines.append(
                    f"  Zeile {finding['line']:3d}: {finding['name']} "
                    f"(Konfidenz: {finding['confidence']:.2f})"
                )
                report_lines.append(f"    Kontext: {finding['context'][:80]}...")
        
        report_text = "\n".join(report_lines)
        
        # Optional in Datei speichern
        if output_file:
            try:
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(report_text)
                self.logger.info(f"Bericht gespeichert: {output_file}")
            except Exception as e:
                self.logger.error(f"Fehler beim Speichern des Berichts: {e}")
        
        return report_text


def main():
    """Hauptfunktion für CLI-Nutzung"""
    parser = argparse.ArgumentParser(
        description='DSGVO-konformer PII-Scanner für Schülerdaten',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Beispiele:
  python pii_scanner.py datei.md                    # Einzelne Datei scannen
  python pii_scanner.py unterricht/ --recursive     # Verzeichnis rekursiv scannen
  python pii_scanner.py . --report bericht.txt      # Bericht in Datei speichern
        """
    )
    
    parser.add_argument('path', type=Path, help='Datei oder Verzeichnis zum Scannen')
    parser.add_argument('--recursive', '-r', action='store_true', 
                        help='Verzeichnisse rekursiv durchsuchen')
    parser.add_argument('--config', type=Path, 
                        help='Pfad zur Konfigurationsdatei')
    parser.add_argument('--report', type=Path, 
                        help='Bericht in Datei speichern')
    parser.add_argument('--threshold', type=float, default=0.7,
                        help='Konfidenz-Schwellwert (Standard: 0.7)')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Nur Ergebnisse ausgeben, keine Logs')
    
    args = parser.parse_args()
    
    # Scanner initialisieren
    scanner = DSGVOPIIScanner(config_path=args.config)
    
    # Konfidenz-Schwellwert anpassen
    scanner.config['confidence_threshold'] = args.threshold
    
    # Stilles Logging wenn gewünscht
    if args.quiet:
        scanner.config['enable_audit_logging'] = False
        scanner.setup_logging()
    
    # Scannen
    if args.path.is_file():
        findings = scanner.scan_file(args.path)
        summary = {
            'total_files_scanned': 1,
            'total_pii_found': len(findings),
            'files_with_pii': 1 if findings else 0,
            'unique_names_found': len(set(f['name'] for f in findings)),
            'findings': findings,
            'scan_timestamp': datetime.now().isoformat()
        }
    elif args.path.is_dir():
        summary = scanner.scan_directory(args.path, recursive=args.recursive)
    else:
        print(f"Fehler: Pfad '{args.path}' existiert nicht.", file=sys.stderr)
        return 1
    
    # Bericht generieren
    report = scanner.generate_report(summary, output_file=args.report)
    
    if not args.quiet:
        print(report)
    
    # Exit-Code basierend auf Findings
    return 1 if summary['total_pii_found'] > 0 else 0


if __name__ == '__main__':
    sys.exit(main())
