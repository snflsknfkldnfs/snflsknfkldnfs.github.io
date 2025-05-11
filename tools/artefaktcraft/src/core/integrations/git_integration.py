
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
GitIntegration für ArtefaktCraft

Diese Klasse ermöglicht die Integration mit Git für die Versionskontrolle der Artefakte.
"""

import os
import logging
import subprocess
from typing import Dict, Any, List, Optional

class GitIntegration:
    """Integration mit Git für die Versionskontrolle."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert die Git-Integration.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.git")
        self.config = config
        self.base_path = config["repository"]["base_path"]
        self.commit_message_template = config.get("integration", {}).get("git", {}).get(
            "commit_message_template", "ArtefaktCraft: {artefakt_type} '{title}' erstellt/aktualisiert")
        
        # Git-Verfügbarkeit prüfen
        self.git_available = self._check_git_availability()
        if not self.git_available:
            self.logger.warning("Git ist nicht verfügbar oder das Repository ist kein Git-Repository")
    
    def _check_git_availability(self) -> bool:
        """
        Überprüft, ob Git verfügbar ist und ob das Repository ein Git-Repository ist.
        
        Returns:
            True, wenn Git verfügbar ist und das Repository ein Git-Repository ist, sonst False
        """
        try:
            # Prüfen, ob Git installiert ist
            result = subprocess.run(["git", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
            if result.returncode != 0:
                self.logger.warning("Git ist nicht installiert oder nicht im PATH")
                return False
            
            # Prüfen, ob das Verzeichnis ein Git-Repository ist
            result = subprocess.run(
                ["git", "-C", self.base_path, "rev-parse", "--is-inside-work-tree"],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False
            )
            if result.returncode != 0:
                self.logger.warning(f"Das Verzeichnis {self.base_path} ist kein Git-Repository")
                return False
            
            return True
            
        except Exception as e:
            self.logger.error(f"Fehler bei der Überprüfung der Git-Verfügbarkeit: {str(e)}")
            return False
    
    def commit_changes(self, file_path: str, commit_message: str) -> bool:
        """
        Führt einen Git-Commit für die angegebene Datei durch.
        
        Args:
            file_path: Der Pfad zur Datei, die committet werden soll
            commit_message: Die Commit-Nachricht
            
        Returns:
            True, wenn der Commit erfolgreich war, sonst False
        """
        if not self.git_available:
            self.logger.warning("Git ist nicht verfügbar, Commit wird übersprungen")
            return False
        
        try:
            # Datei zum Staging-Bereich hinzufügen
            result = subprocess.run(
                ["git", "-C", self.base_path, "add", file_path],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False
            )
            if result.returncode != 0:
                self.logger.error(f"Fehler beim Hinzufügen der Datei zum Staging-Bereich: {result.stderr}")
                return False
            
            # Änderungen committen
            result = subprocess.run(
                ["git", "-C", self.base_path, "commit", "-m", commit_message],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False
            )
            if result.returncode != 0:
                self.logger.error(f"Fehler beim Committen der Änderungen: {result.stderr}")
                return False
            
            self.logger.info(f"Änderungen erfolgreich committet: {commit_message}")
            return True
            
        except Exception as e:
            self.logger.error(f"Fehler beim Git-Commit: {str(e)}")
            return False
    
    def generate_commit_message(self, artefakt_type: str, metadata: Dict[str, Any]) -> str:
        """
        Generiert eine Commit-Nachricht für ein Artefakt.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die Metadaten des Artefakts
            
        Returns:
            Die generierte Commit-Nachricht
        """
        # Artefakt-Typ-Konfiguration finden
        artefakt_type_name = artefakt_type
        for at in self.config["artefakt_types"]:
            if at["id"] == artefakt_type:
                artefakt_type_name = at["name"]
                break
        
        # Titel aus den Metadaten extrahieren
        title = metadata.get("title", f"Untitled_{artefakt_type}")
        
        # Commit-Nachricht formatieren
        commit_message = self.commit_message_template.format(
            artefakt_type=artefakt_type_name,
            title=title,
            **metadata
        )
        
        return commit_message
