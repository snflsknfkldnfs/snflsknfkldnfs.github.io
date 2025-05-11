
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Konfigurationsmanager für ArtefaktCraft

Diese Klasse ist verantwortlich für das Laden, Validieren und Bereitstellen
der Konfigurationsdaten für die ArtefaktCraft-Anwendung.
"""

import os
import yaml
import logging
from typing import Dict, Any, Optional
from pathlib import Path

class ConfigManager:
    """Manager für die Konfiguration der ArtefaktCraft-Anwendung."""
    
    def __init__(self, config_path: str):
        """
        Initialisiert den Konfigurationsmanager.
        
        Args:
            config_path: Pfad zur Konfigurationsdatei
        """
        self.logger = logging.getLogger("artefaktcraft.config")
        self.config_path = config_path
        self.config = self._load_config()
        self._process_environment_variables()
        self._validate_config()
        
    def _load_config(self) -> Dict[str, Any]:
        """
        Lädt die Konfiguration aus der YAML-Datei.
        
        Returns:
            Die geladene Konfiguration als Dictionary
        
        Raises:
            FileNotFoundError: Wenn die Konfigurationsdatei nicht gefunden wurde
            yaml.YAMLError: Wenn die Konfigurationsdatei ungültiges YAML enthält
        """
        try:
            with open(self.config_path, 'r', encoding='utf-8') as file:
                config = yaml.safe_load(file)
                self.logger.info(f"Konfiguration erfolgreich aus {self.config_path} geladen")
                return config
        except FileNotFoundError:
            self.logger.error(f"Konfigurationsdatei nicht gefunden: {self.config_path}")
            raise
        except yaml.YAMLError as e:
            self.logger.error(f"Fehler beim Parsen der Konfigurationsdatei: {str(e)}")
            raise
    
    def _process_environment_variables(self):
        """
        Verarbeitet Umgebungsvariablen in der Konfiguration.
        
        Ersetzt alle Werte im Format ${VARIABLE_NAME} durch den Wert
        der entsprechenden Umgebungsvariable.
        """
        def _process_value(value):
            if isinstance(value, str) and value.startswith("${") and value.endswith("}"):
                env_var_name = value[2:-1]
                env_var_value = os.environ.get(env_var_name)
                if env_var_value is None:
                    self.logger.warning(f"Umgebungsvariable {env_var_name} nicht gefunden")
                    return value
                return env_var_value
            return value
        
        def _process_dict(d):
            for key, value in d.items():
                if isinstance(value, dict):
                    _process_dict(value)
                elif isinstance(value, list):
                    d[key] = [_process_value(item) if not isinstance(item, dict) else _process_dict(item) 
                              for item in value]
                else:
                    d[key] = _process_value(value)
            return d
        
        self.config = _process_dict(self.config)
        self.logger.debug("Umgebungsvariablen in der Konfiguration verarbeitet")
    
    def _validate_config(self):
        """
        Validiert die Konfiguration auf erforderliche Schlüssel und Werte.
        
        Raises:
            ValueError: Wenn die Konfiguration ungültig ist
        """
        # Erforderliche Schlüssel überprüfen
        required_keys = ["repository", "artefakt_types"]
        for key in required_keys:
            if key not in self.config:
                self.logger.error(f"Fehlender erforderlicher Konfigurationsschlüssel: {key}")
                raise ValueError(f"Fehlender erforderlicher Konfigurationsschlüssel: {key}")
        
        # Repository-Pfade überprüfen
        repo_config = self.config["repository"]
        required_repo_keys = ["base_path", "template_path", "output_paths"]
        for key in required_repo_keys:
            if key not in repo_config:
                self.logger.error(f"Fehlender erforderlicher Repository-Konfigurationsschlüssel: {key}")
                raise ValueError(f"Fehlender erforderlicher Repository-Konfigurationsschlüssel: {key}")
        
        # Artefakt-Typen überprüfen
        artefakt_types = self.config["artefakt_types"]
        if not isinstance(artefakt_types, list) or len(artefakt_types) == 0:
            self.logger.error("Keine Artefakt-Typen in der Konfiguration definiert")
            raise ValueError("Keine Artefakt-Typen in der Konfiguration definiert")
        
        required_type_keys = ["id", "name", "template", "output_dir", "metadata_schema"]
        for artefakt_type in artefakt_types:
            for key in required_type_keys:
                if key not in artefakt_type:
                    self.logger.error(f"Fehlender erforderlicher Schlüssel '{key}' für Artefakt-Typ '{artefakt_type.get('id', 'unbekannt')}'")
                    raise ValueError(f"Fehlender erforderlicher Schlüssel '{key}' für Artefakt-Typ '{artefakt_type.get('id', 'unbekannt')}'")
        
        self.logger.info("Konfiguration erfolgreich validiert")
    
    def get_config(self) -> Dict[str, Any]:
        """
        Gibt die gesamte Konfiguration zurück.
        
        Returns:
            Die Konfiguration als Dictionary
        """
        return self.config
    
    def get_artefakt_type_config(self, artefakt_type_id: str) -> Optional[Dict[str, Any]]:
        """
        Gibt die Konfiguration für einen bestimmten Artefakt-Typ zurück.
        
        Args:
            artefakt_type_id: ID des Artefakt-Typs
        
        Returns:
            Die Konfiguration des Artefakt-Typs oder None, wenn nicht gefunden
        """
        for artefakt_type in self.config["artefakt_types"]:
            if artefakt_type["id"] == artefakt_type_id:
                return artefakt_type
        
        self.logger.warning(f"Artefakt-Typ '{artefakt_type_id}' nicht in der Konfiguration gefunden")
        return None
    
    def save_config(self, config: Dict[str, Any]):
        """
        Speichert die Konfiguration in die YAML-Datei.
        
        Args:
            config: Die zu speichernde Konfiguration
        """
        try:
            with open(self.config_path, 'w', encoding='utf-8') as file:
                yaml.dump(config, file, default_flow_style=False, sort_keys=False, allow_unicode=True)
            
            self.config = config
            self.logger.info(f"Konfiguration erfolgreich in {self.config_path} gespeichert")
        except Exception as e:
            self.logger.error(f"Fehler beim Speichern der Konfiguration: {str(e)}")
            raise
