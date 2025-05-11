
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
RepositoryManager für ArtefaktCraft

Diese Klasse ist verantwortlich für die Interaktion mit dem Repository,
insbesondere für die Bestimmung von Ausgabepfaden und das Speichern von Artefakten.
"""

import os
import logging
import re
from typing import Dict, Any, List, Tuple
from pathlib import Path
import shutil

class RepositoryManager:
    """Manager für die Interaktion mit dem Repository."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert den Repository-Manager.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.repository")
        self.config = config
        self.base_path = Path(config["repository"]["base_path"])
        self.output_paths = config["repository"]["output_paths"]
        
        self.logger.info(f"Repository-Manager initialisiert mit Basis-Pfad: {self.base_path}")
    
    def determine_output_path(self, artefakt_type: str, metadata: Dict[str, Any]) -> str:
        """
        Bestimmt den Ausgabepfad für ein Artefakt.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die Metadaten des Artefakts
            
        Returns:
            Der absolute Pfad, an dem das Artefakt gespeichert werden soll
            
        Raises:
            ValueError: Wenn der Artefakt-Typ ungültig ist
        """
        # Artefakt-Typ-Konfiguration finden
        artefakt_type_config = None
        for at in self.config["artefakt_types"]:
            if at["id"] == artefakt_type:
                artefakt_type_config = at
                break
        
        if not artefakt_type_config:
            self.logger.error(f"Ungültiger Artefakt-Typ: {artefakt_type}")
            raise ValueError(f"Ungültiger Artefakt-Typ: {artefakt_type}")
        
        # Variablen im output_dir-Pfad ersetzen
        output_dir_template = artefakt_type_config["output_dir"]
        output_dir = output_dir_template
        
        # Ersetzung von ${fach} mit dem tatsächlichen Fach
        if "${fach}" in output_dir:
            fach = metadata.get("fach", "").lower()
            if fach not in self.output_paths:
                self.logger.error(f"Ungültiges Fach: {fach}. Verfügbare Fächer: {', '.join(self.output_paths.keys())}")
                raise ValueError(f"Ungültiges Fach: {fach}")
            output_dir = output_dir.replace("${fach}", self.output_paths[fach])
        
        # Weitere Variablen ersetzen
        for key, value in metadata.items():
            if f"${{{key}}}" in output_dir:
                output_dir = output_dir.replace(f"${{{key}}}", str(value))
        
        # Prüfen, ob noch ungelöste Variablen vorhanden sind
        if "${" in output_dir and "}" in output_dir:
            self.logger.warning(f"Ungelöste Variablen im Ausgabepfad: {output_dir}")
        
        # Vollständigen Ausgabepfad erstellen
        full_output_dir = self.base_path / output_dir
        
        # Dateinamen erstellen
        filename = self._create_filename(metadata.get("title", f"Untitled_{artefakt_type}"))
        full_path = full_output_dir / filename
        
        self.logger.info(f"Ausgabepfad für Artefakt bestimmt: {full_path}")
        return str(full_path)
    
    def _create_filename(self, title: str) -> str:
        """
        Erstellt einen gültigen Dateinamen aus einem Titel.
        
        Args:
            title: Der Titel des Artefakts
            
        Returns:
            Ein gültiger Dateiname
        """
        # Ungültige Zeichen ersetzen
        filename = re.sub(r'[^\w\s-]', '', title)
        # Leerzeichen durch Unterstriche ersetzen
        filename = re.sub(r'\s+', '_', filename)
        # Mehrfache Unterstriche durch einfache ersetzen
        filename = re.sub(r'_+', '_', filename)
        # Markdown-Erweiterung hinzufügen
        filename = f"{filename}.md"
        
        return filename
    
    def save_artefakt(self, path: str, content: str) -> bool:
        """
        Speichert ein Artefakt an dem angegebenen Pfad.
        
        Args:
            path: Der Pfad, an dem das Artefakt gespeichert werden soll
            content: Der Inhalt des Artefakts
            
        Returns:
            True, wenn das Speichern erfolgreich war, sonst False
        """
        try:
            # Verzeichnis erstellen, falls es nicht existiert
            os.makedirs(os.path.dirname(path), exist_ok=True)
            
            # Datei schreiben
            with open(path, 'w', encoding='utf-8') as file:
                file.write(content)
            
            self.logger.info(f"Artefakt erfolgreich gespeichert: {path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Fehler beim Speichern des Artefakts: {str(e)}")
            return False
    
    def validate_structure(self) -> Dict[str, Any]:
        """
        Überprüft die Repository-Struktur und gibt einen Status-Bericht zurück.
        
        Returns:
            Ein Dictionary mit Informationen über den Status des Repositorys
        """
        result = {
            "base_path_exists": os.path.exists(self.base_path),
            "output_paths": {},
            "templates_path_exists": os.path.exists(self.config["repository"]["template_path"]),
            "templates": []
        }
        
        # Ausgabepfade überprüfen
        for fach, path in self.output_paths.items():
            full_path = self.base_path / path
            result["output_paths"][fach] = {
                "path": str(full_path),
                "exists": os.path.exists(full_path)
            }
        
        # Templates überprüfen
        templates_path = Path(self.config["repository"]["template_path"])
        if os.path.exists(templates_path):
            for at in self.config["artefakt_types"]:
                template_file = templates_path / at["template"]
                result["templates"].append({
                    "artefakt_type": at["id"],
                    "path": str(template_file),
                    "exists": os.path.exists(template_file)
                })
        
        self.logger.info("Repository-Struktur validiert")
        return result
    
    def create_missing_structure(self) -> List[str]:
        """
        Erstellt fehlende Verzeichnisse im Repository.
        
        Returns:
            Eine Liste der erstellten Verzeichnisse
        """
        created_dirs = []
        
        # Basis-Verzeichnis erstellen, falls es nicht existiert
        if not os.path.exists(self.base_path):
            os.makedirs(self.base_path, exist_ok=True)
            created_dirs.append(str(self.base_path))
            self.logger.info(f"Basis-Verzeichnis erstellt: {self.base_path}")
        
        # Ausgabepfade erstellen
        for fach, path in self.output_paths.items():
            full_path = self.base_path / path
            if not os.path.exists(full_path):
                os.makedirs(full_path, exist_ok=True)
                created_dirs.append(str(full_path))
                self.logger.info(f"Ausgabepfad erstellt: {full_path}")
        
        # Template-Verzeichnis erstellen
        templates_path = Path(self.config["repository"]["template_path"])
        if not os.path.exists(templates_path):
            os.makedirs(templates_path, exist_ok=True)
            created_dirs.append(str(templates_path))
            self.logger.info(f"Template-Verzeichnis erstellt: {templates_path}")
        
        return created_dirs
    
    def find_similar_artefacts(self, artefakt_type: str, metadata: Dict[str, Any]) -> List[Tuple[str, float]]:
        """
        Findet ähnliche Artefakte im Repository.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die Metadaten des Artefakts
            
        Returns:
            Eine Liste von Tupeln (Pfad, Ähnlichkeitswert) für ähnliche Artefakte
        """
        # Diese Methode ist eine Platzhalter-Implementierung
        # In einer vollständigen Implementierung würde hier eine inhaltliche Analyse stattfinden
        
        self.logger.info(f"Suche nach ähnlichen Artefakten vom Typ '{artefakt_type}'")
        return []  # Platzhalter
