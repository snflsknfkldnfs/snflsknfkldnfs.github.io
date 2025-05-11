
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ArtefaktManager für ArtefaktCraft

Diese Klasse verwaltet die verfügbaren Artefakt-Typen und ist verantwortlich
für die Validierung von Metadaten und die Bereitstellung von Artefakt-Konfigurationen.
"""

import logging
from typing import Dict, Any, List, Optional

class ArtefaktManager:
    """Manager für die Artefakt-Typen und deren Metadaten."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert den Artefakt-Manager.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.artefakt")
        self.config = config
        self.artefakt_types = {at["id"]: at for at in config["artefakt_types"]}
        self.logger.info(f"{len(self.artefakt_types)} Artefakt-Typen geladen")
    
    def is_valid_type(self, artefakt_type: str) -> bool:
        """
        Überprüft, ob ein Artefakt-Typ gültig ist.
        
        Args:
            artefakt_type: ID des zu überprüfenden Artefakt-Typs
            
        Returns:
            True, wenn der Artefakt-Typ existiert, sonst False
        """
        return artefakt_type in self.artefakt_types
    
    def get_available_types(self) -> List[str]:
        """
        Gibt eine Liste aller verfügbaren Artefakt-Typ-IDs zurück.
        
        Returns:
            Liste von Artefakt-Typ-IDs
        """
        return list(self.artefakt_types.keys())
    
    def get_available_types_with_metadata(self) -> List[Dict[str, Any]]:
        """
        Gibt eine Liste aller verfügbaren Artefakt-Typen mit vollständigen Metadaten zurück.
        
        Returns:
            Liste von Artefakt-Typ-Definitionen
        """
        return list(self.artefakt_types.values())
    
    def get_artefakt_type_config(self, artefakt_type: str) -> Optional[Dict[str, Any]]:
        """
        Gibt die Konfiguration für einen bestimmten Artefakt-Typ zurück.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            
        Returns:
            Die Konfiguration des Artefakt-Typs oder None, wenn nicht gefunden
        """
        return self.artefakt_types.get(artefakt_type)
    
    def validate_metadata(self, artefakt_type: str, metadata: Dict[str, Any]) -> bool:
        """
        Validiert die Metadaten für einen Artefakt-Typ.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die zu validierenden Metadaten
            
        Returns:
            True, wenn die Metadaten gültig sind
            
        Raises:
            ValueError: Wenn die Metadaten ungültig sind
            KeyError: Wenn der Artefakt-Typ nicht existiert
        """
        if not self.is_valid_type(artefakt_type):
            self.logger.error(f"Ungültiger Artefakt-Typ: {artefakt_type}")
            raise KeyError(f"Ungültiger Artefakt-Typ: {artefakt_type}")
        
        artefakt_type_config = self.artefakt_types[artefakt_type]
        schema = artefakt_type_config["metadata_schema"]
        
        # Erforderliche Felder überprüfen
        for field in schema:
            field_name = field["name"]
            required = field.get("required", False)
            
            if required and (field_name not in metadata or metadata[field_name] is None):
                self.logger.error(f"Erforderliches Feld '{field_name}' fehlt in den Metadaten für Artefakt-Typ '{artefakt_type}'")
                raise ValueError(f"Erforderliches Feld '{field_name}' fehlt in den Metadaten für Artefakt-Typ '{artefakt_type}'")
            
            # Wenn das Feld vorhanden ist, Typ und Wertebeschränkungen prüfen
            if field_name in metadata and metadata[field_name] is not None:
                field_type = field.get("type", "string")
                value = metadata[field_name]
                
                # Typ-Validierung
                if field_type == "string" and not isinstance(value, str):
                    self.logger.error(f"Feld '{field_name}' muss ein String sein, ist aber {type(value)}")
                    raise ValueError(f"Feld '{field_name}' muss ein String sein, ist aber {type(value)}")
                elif field_type == "number" and not isinstance(value, (int, float)):
                    self.logger.error(f"Feld '{field_name}' muss eine Zahl sein, ist aber {type(value)}")
                    raise ValueError(f"Feld '{field_name}' muss eine Zahl sein, ist aber {type(value)}")
                elif field_type == "boolean" and not isinstance(value, bool):
                    self.logger.error(f"Feld '{field_name}' muss ein Boolean sein, ist aber {type(value)}")
                    raise ValueError(f"Feld '{field_name}' muss ein Boolean sein, ist aber {type(value)}")
                elif field_type == "enum" and value not in field.get("options", []):
                    self.logger.error(f"Feld '{field_name}' muss einer der Werte {field.get('options', [])} sein, ist aber {value}")
                    raise ValueError(f"Feld '{field_name}' muss einer der Werte {field.get('options', [])} sein, ist aber {value}")
        
        self.logger.info(f"Metadaten für Artefakt-Typ '{artefakt_type}' erfolgreich validiert")
        return True
    
    def get_metadata_schema(self, artefakt_type: str) -> List[Dict[str, Any]]:
        """
        Gibt das Metadaten-Schema für einen Artefakt-Typ zurück.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            
        Returns:
            Das Metadaten-Schema als Liste von Felddefinitionen
            
        Raises:
            KeyError: Wenn der Artefakt-Typ nicht existiert
        """
        if not self.is_valid_type(artefakt_type):
            self.logger.error(f"Ungültiger Artefakt-Typ: {artefakt_type}")
            raise KeyError(f"Ungültiger Artefakt-Typ: {artefakt_type}")
        
        return self.artefakt_types[artefakt_type]["metadata_schema"]
