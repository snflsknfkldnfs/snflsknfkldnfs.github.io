#!/usr/bin/env python3
"""
DiSoAn Repository Watch Service v2.0
Intelligente Erkennung von Änderungen für Claude Desktop Updates
"""

import os
import time
import json
import subprocess
from pathlib import Path
from datetime import datetime, timedelta
from threading import Timer

class DiSoAnRepositoryWatcher:
    def __init__(self, repo_path: str):
        self.repo_path = Path(repo_path)
        self.claude_generator = self.repo_path / "scripts/project_orientation/claude_desktop_generator_v3.py"
        self.last_updates = {}
        self.pending_updates = set()
        
        # Monitoring-Konfiguration
        self.watch_paths = {
            'seminarcloud': ['Seminar'],
            'unterricht': ['GPG5', 'GPG6', 'WiB5', 'WiB6', 'M5', 'M6', 'E5', 'E6'],
            'notizen': ['GPG5', 'GPG6', 'WiB5', 'WiB6', 'M5', 'M6', 'E5', 'E6'],
            'templates': ['ALL_PROJECTS']
        }
        
        # Log-Verzeichnis erstellen
        self.log_dir = self.repo_path / "monitoring_reports"
        self.log_dir.mkdir(exist_ok=True)
        
    def check_repository_changes(self):
        """Prüft Repository auf Änderungen seit letztem Check"""
        
        print("🔍 Prüfe Repository auf Änderungen...")
        
        # Git-Status abfragen
        try:
            result = subprocess.run(
                ["git", "status", "--porcelain"], 
                cwd=self.repo_path,
                capture_output=True, 
                text=True
            )
            
            if result.returncode == 0:
                changes = result.stdout.strip().split('\n') if result.stdout.strip() else []
                
                if changes:
                    print(f"📁 {len(changes)} Änderungen entdeckt")
                    self._process_changes(changes)
                else:
                    print("✅ Keine Änderungen seit letztem Check")
            else:
                print("⚠️ Git-Status-Abfrage fehlgeschlagen")
                
        except Exception as e:
            print(f"❌ Fehler bei Repository-Check: {e}")
            
    def _process_changes(self, changes: list):
        """Verarbeitet erkannte Änderungen"""
        
        affected_projects = set()
        
        for change in changes:
            if len(change.strip()) == 0:
                continue
                
            # Format: "XY filename"
            status = change[:2]
            filename = change[3:] if len(change) > 3 else ""
            
            # Relevante Dateien identifizieren
            if any(watch_path in filename for watch_path in self.watch_paths.keys()):
                projects = self._identify_affected_projects(Path(filename))
                affected_projects.update(projects)
                
        if affected_projects:
            print(f"🎯 Betroffene Projekte: {', '.join(affected_projects)}")
            
            for project in affected_projects:
                self._schedule_update(project, 'repository_change', filename)
                
    def _identify_affected_projects(self, file_path: Path) -> list:
        """Identifiziert welche Projekte von Änderung betroffen sind"""
        affected = []
        
        for watch_path, projects in self.watch_paths.items():
            if watch_path in str(file_path):
                if 'ALL_PROJECTS' in projects:
                    affected = list(self.watch_paths['unterricht'])  # Alle Fach-Projekte
                    affected.append('Seminar')
                else:
                    # Projekt-spezifische Zuordnung basierend auf Pfad
                    for project in projects:
                        if project.lower() in str(file_path).lower():
                            affected.append(project)
                            
        return affected
    
    def _schedule_update(self, project: str, trigger_type: str, source_path: str):
        """Plant Update für spezifisches Projekt"""
        
        # Duplikate vermeiden (Debouncing)
        update_key = f"{project}_{trigger_type}"
        current_time = datetime.now()
        
        if update_key in self.last_updates:
            time_diff = current_time - self.last_updates[update_key]
            if time_diff < timedelta(minutes=5):  # 5-Minuten-Debouncing
                return
                
        self.last_updates[update_key] = current_time
        self.pending_updates.add(project)
        
        print(f"🔄 Update geplant für {project} (Trigger: {trigger_type})")
        
        # Verzögertes Update (sammelt mehrere Änderungen)
        timer = Timer(30.0, self._execute_delayed_update, args=[project])
        timer.start()
    
    def _execute_delayed_update(self, project: str):
        """Führt verzögertes Update aus"""
        
        if project in self.pending_updates:
            try:
                # Claude Desktop Instructions regenerieren
                result = subprocess.run(
                    ["python3", str(self.claude_generator), project],
                    cwd=self.repo_path,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    print(f"✅ {project}: Claude Desktop Instructions automatisch aktualisiert")
                    self._log_successful_update(project)
                else:
                    print(f"❌ {project}: Update-Fehler - {result.stderr}")
                    self._log_failed_update(project, result.stderr)
                    
                self.pending_updates.discard(project)
                
            except Exception as e:
                print(f"❌ {project}: Exception während Update: {e}")
                self._log_failed_update(project, str(e))
    
    def _log_successful_update(self, project: str):
        """Protokolliert erfolgreiches Update"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'project': project,
            'status': 'success',
            'trigger': 'repository_watch'
        }
        self._append_to_log(log_entry)
    
    def _log_failed_update(self, project: str, error: str):
        """Protokolliert fehlgeschlagenes Update"""
        log_entry = {
            'timestamp': datetime.now().isoformat(), 
            'project': project,
            'status': 'failed',
            'trigger': 'repository_watch',
            'error': error
        }
        self._append_to_log(log_entry)
    
    def _append_to_log(self, log_entry: dict):
        """Fügt Eintrag zum Monitoring-Log hinzu"""
        log_file = self.log_dir / "repository_watch_log.json"
        
        if log_file.exists():
            with open(log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        else:
            logs = []
            
        logs.append(log_entry)
        
        # Nur letzte 1000 Einträge behalten
        if len(logs) > 1000:
            logs = logs[-1000:]
            
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(logs, f, indent=2, ensure_ascii=False)
            
    def start_continuous_monitoring(self, interval_minutes: int = 10):
        """Startet kontinuierliches Repository-Monitoring"""
        
        print(f"🚀 Repository-Watch-Service gestartet (Intervall: {interval_minutes} Minuten)")
        
        try:
            while True:
                self.check_repository_changes()
                time.sleep(interval_minutes * 60)  # Minuten in Sekunden
                
        except KeyboardInterrupt:
            print("⏹️ Repository-Watch-Service gestoppt")

def main():
    """Hauptfunktion für Repository-Watching"""
    import sys
    
    repo_path = "/Users/paulad/snflsknfkldnfs.github.io"
    watcher = DiSoAnRepositoryWatcher(repo_path)
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == 'check':
            # Einmalige Prüfung
            watcher.check_repository_changes()
        elif command == 'monitor':
            # Kontinuierliches Monitoring
            interval = int(sys.argv[2]) if len(sys.argv) > 2 else 10
            watcher.start_continuous_monitoring(interval)
        else:
            print("Verwendung: python3 repository_watch_service.py [check|monitor [interval_minutes]]")
    else:
        # Standard: Einmalige Prüfung
        watcher.check_repository_changes()

if __name__ == "__main__":
    main()
