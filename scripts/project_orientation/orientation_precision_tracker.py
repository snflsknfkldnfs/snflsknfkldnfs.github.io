#!/usr/bin/env python3
"""
DiSoAn Orientierungs-Präzisions-Tracker v1.0
Verlässliche Standardisierung durch State-Hashing und Quality-Assurance
"""

import hashlib
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

class DiSoAnOrientationPrecisionTracker:
    def __init__(self, repo_path: str):
        self.repo_path = Path(repo_path)
        self.orientation_log = self.repo_path / "orientation_tracking/orientation_precision_log.json"
        self.orientation_log.parent.mkdir(exist_ok=True)
        
    def calculate_repository_state_hash(self) -> str:
        """Berechnet SHA-256 Hash des aktuellen Repository-Zustands"""
        
        # Relevante Pfade für Orientierung
        relevant_paths = [
            self.repo_path / "claude_desktop_instructions",
            self.repo_path / "notizen/meta_prozesse", 
            self.repo_path / "seminarcloud"
        ]
        
        hash_components = []
        
        for path in relevant_paths:
            if path.exists():
                if path.is_file():
                    with open(path, 'rb') as f:
                        hash_components.append(f.read())
                else:
                    # Für Verzeichnisse: Hash aller relevanten Dateien
                    for file_path in sorted(path.rglob("*.md")):
                        try:
                            with open(file_path, 'rb') as f:
                                hash_components.append(f.read())
                        except (PermissionError, FileNotFoundError):
                            continue
        
        # Kombinierter Hash
        combined_content = b''.join(hash_components)
        return hashlib.sha256(combined_content).hexdigest()
    
    def generate_orientation_checksum(self, orientation_output: str) -> str:
        """Generiert Checksumme für Orientierungs-Output"""
        
        # Normalisierung: Entferne variable Timestamps für Vergleichbarkeit
        normalized_output = orientation_output
        
        # Entferne Timestamp-Zeilen
        lines = normalized_output.split('\n')
        filtered_lines = []
        
        for line in lines:
            if not any(pattern in line.lower() for pattern in ['2025-07-08t', 'auto-update:', 'timestamp:']):
                filtered_lines.append(line)
        
        normalized_content = '\n'.join(filtered_lines)
        return hashlib.md5(normalized_content.encode()).hexdigest()
    
    def log_orientation_execution(self, 
                                orientation_output: str,
                                repository_hash: str,
                                execution_context: Dict) -> Dict:
        """Protokolliert Orientierungs-Ausführung mit Precision-Tracking"""
        
        timestamp = datetime.now().isoformat()
        output_checksum = self.generate_orientation_checksum(orientation_output)
        
        log_entry = {
            'timestamp': timestamp,
            'repository_state_hash': repository_hash,
            'orientation_output_checksum': output_checksum,
            'execution_context': execution_context,
            'output_length': len(orientation_output),
            'quality_metrics': self._calculate_quality_metrics(orientation_output)
        }
        
        # Zu Log hinzufügen
        self._append_to_precision_log(log_entry)
        
        return log_entry
    
    def _calculate_quality_metrics(self, orientation_output: str) -> Dict:
        """Berechnet Qualitäts-Metriken für Orientierung"""
        
        # Standard-Komponenten prüfen
        required_components = [
            'DiSoAn-STANDARDS AKTIVIERT',
            'SYSTEMTHEORETISCHE',
            'STAKEHOLDER',
            'HANDLUNGSLOGIK',
            'SELBSTREFLEXION'
        ]
        
        components_present = sum(1 for comp in required_components if comp in orientation_output)
        completeness_score = (components_present / len(required_components)) * 100
        
        # Konsistenz-Indikatoren
        consistency_indicators = [
            'Luhmann' in orientation_output,
            'Autopoiesis' in orientation_output,
            'PATA-Protokoll' in orientation_output,
            'LAA' in orientation_output,
            '142 Einheiten' in orientation_output
        ]
        
        consistency_score = (sum(consistency_indicators) / len(consistency_indicators)) * 100
        
        return {
            'completeness_score': completeness_score,
            'consistency_score': consistency_score,
            'overall_quality': (completeness_score + consistency_score) / 2
        }
    
    def _append_to_precision_log(self, log_entry: Dict):
        """Fügt Eintrag zum Präzisions-Log hinzu"""
        
        if self.orientation_log.exists():
            with open(self.orientation_log, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        else:
            logs = []
        
        logs.append(log_entry)
        
        # Nur letzte 100 Einträge behalten
        if len(logs) > 100:
            logs = logs[-100:]
        
        with open(self.orientation_log, 'w', encoding='utf-8') as f:
            json.dump(logs, f, indent=2, ensure_ascii=False)
    
    def analyze_orientation_consistency(self, last_n: int = 10) -> Dict:
        """Analysiert Konsistenz der letzten N Orientierungen"""
        
        if not self.orientation_log.exists():
            return {'error': 'Noch keine Orientierungs-Logs verfügbar'}
        
        with open(self.orientation_log, 'r', encoding='utf-8') as f:
            logs = json.load(f)
        
        if len(logs) < 2:
            return {'error': 'Mindestens 2 Orientierungen für Vergleich nötig'}
        
        recent_logs = logs[-last_n:]
        
        # Repository-State-Änderungen
        unique_repo_hashes = set(log['repository_state_hash'] for log in recent_logs)
        repo_stability = len(unique_repo_hashes) == 1
        
        # Output-Checksummen
        unique_output_checksums = set(log['orientation_output_checksum'] for log in recent_logs)
        output_consistency = len(unique_output_checksums)
        
        # Qualitäts-Metriken
        quality_scores = [log['quality_metrics']['overall_quality'] for log in recent_logs]
        avg_quality = sum(quality_scores) / len(quality_scores)
        quality_variance = max(quality_scores) - min(quality_scores)
        
        return {
            'analysis_timestamp': datetime.now().isoformat(),
            'analyzed_orientations': len(recent_logs),
            'repository_stability': repo_stability,
            'unique_repository_states': len(unique_repo_hashes),
            'output_consistency_variants': output_consistency,
            'average_quality_score': avg_quality,
            'quality_variance': quality_variance,
            'consistency_assessment': 'EXCELLENT' if output_consistency <= 2 and quality_variance < 5 else 
                                   'GOOD' if output_consistency <= 3 and quality_variance < 10 else 
                                   'NEEDS_OPTIMIZATION'
        }

def track_current_orientation():
    """Tracked aktuelle Orientierung für Precision-Analysis"""
    
    tracker = DiSoAnOrientationPrecisionTracker("/Users/paulad/snflsknfkldnfs.github.io")
    
    # Repository-State erfassen
    repo_hash = tracker.calculate_repository_state_hash()
    print(f"📊 Repository-State-Hash: {repo_hash[:16]}...")
    
    # Simulierte Orientierung (in realer Anwendung würde hier der echte Output verwendet)
    sample_orientation = "DiSoAn-STANDARDS AKTIVIERT - Systemtheoretische Perspektive - Luhmann - Autopoiesis"
    
    # Logging
    log_result = tracker.log_orientation_execution(
        orientation_output=sample_orientation,
        repository_hash=repo_hash,
        execution_context={'trigger': 'manual_test', 'version': '1.0'}
    )
    
    print(f"✅ Orientierung geloggt - Qualität: {log_result['quality_metrics']['overall_quality']:.1f}%")
    
    # Konsistenz-Analyse
    consistency = tracker.analyze_orientation_consistency()
    print(f"🎯 Konsistenz-Assessment: {consistency.get('consistency_assessment', 'ERROR')}")
    
    return log_result

if __name__ == "__main__":
    track_current_orientation()
