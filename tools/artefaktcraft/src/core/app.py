
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ArtefaktCraft - Hauptanwendungsklasse

Diese Klasse stellt den Einstiegspunkt in die ArtefaktCraft-Anwendung dar und
koordiniert die verschiedenen Komponenten. Optimiert für MCP-Integration.
"""

import os
import sys
import logging
import yaml
from pathlib import Path
from typing import Dict, Any, Optional, List

# Lokale Module
from core.config_manager import ConfigManager
from core.artefakt_manager import ArtefaktManager
from core.dialogue_engine import DialogueEngine
from core.template_renderer import TemplateRenderer
from core.repository_manager import RepositoryManager
from core.integrations import GitIntegration, MCPServerIntegration

class ArtefaktCraft:
    """Hauptklasse der ArtefaktCraft-Anwendung."""
    
    # Klassenweite Singleton-Instanz für einfachen Zugriff
    _instance = None
    
    def __init__(self, config_path: Optional[str] = None):
        """
        Initialisiert die ArtefaktCraft-Anwendung.
        
        Args:
            config_path: Pfad zur Konfigurationsdatei (optional)
        """
        # Singleton-Pattern implementieren
        if ArtefaktCraft._instance is not None:
            logging.getLogger("artefaktcraft").warning("ArtefaktCraft-Instanz bereits initialisiert. Verwende vorhandene Instanz.")
            return
        
        # Als Singleton-Instanz registrieren
        ArtefaktCraft._instance = self
        
        # Standard-Konfigurationspfad, falls nicht angegeben
        if config_path is None:
            base_dir = Path(__file__).parent.parent.parent
            config_path = str(base_dir / "config" / "config.yaml")
        
        # Konfiguration laden
        self.config_manager = ConfigManager(config_path)
        self.config = self.config_manager.get_config()
        
        # Logger einrichten
        self._setup_logging()
        self.logger = logging.getLogger("artefaktcraft")
        self.logger.info("ArtefaktCraft wird initialisiert...")
        
        # Komponenten initialisieren
        self.artefakt_manager = ArtefaktManager(self.config)
        self.repository_manager = RepositoryManager(self.config)
        
        # Integrationen initialisieren - MCP zuerst
        self.mcp_integration = None
        self.git_integration = None
        
        # MCP-Integration initialisieren (höchste Priorität)
        if self.config.get("integration", {}).get("mcp_server", {}).get("enabled", False):
            self.mcp_integration = MCPServerIntegration(self.config)
            self.logger.info("MCP-Server-Integration aktiviert")
        
        # Git-Integration initialisieren
        if self.config.get("integration", {}).get("git", {}).get("enabled", False):
            self.git_integration = GitIntegration(self.config)
            self.logger.info("Git-Integration aktiviert")
        
        # Template-Renderer initialisieren (nach Integrationen)
        self.template_renderer = TemplateRenderer(self.config)
        if self.mcp_integration:
            self.template_renderer.set_mcp_integration(self.mcp_integration)
        
        # Dialog-Engine initialisieren (nach Integrationen und Template-Renderer)
        self.dialogue_engine = DialogueEngine(self.config)
        if self.mcp_integration:
            self.dialogue_engine.set_mcp_integration(self.mcp_integration)
        
        self.logger.info("ArtefaktCraft wurde erfolgreich initialisiert")
    
    def _setup_logging(self):
        """Richtet das Logging basierend auf der Konfiguration ein."""
        log_config = self.config.get("logging", {})
        log_level = getattr(logging, log_config.get("level", "INFO"))
        log_format = log_config.get("format", "%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        
        # Root-Logger konfigurieren, falls noch nicht geschehen
        root_logger = logging.getLogger()
        if not root_logger.handlers:
            logging.basicConfig(
                level=log_level,
                format=log_format
            )
        
        # Datei-Handler hinzufügen, wenn konfiguriert
        if "file" in log_config:
            log_dir = os.path.dirname(log_config["file"])
            os.makedirs(log_dir, exist_ok=True)
            
            file_handler = logging.FileHandler(log_config["file"], encoding="utf-8")
            file_handler.setFormatter(logging.Formatter(log_format))
            
            # Prüfen, ob der Handler bereits existiert
            handler_exists = False
            for handler in logging.getLogger().handlers:
                if isinstance(handler, logging.FileHandler) and handler.baseFilename == os.path.abspath(log_config["file"]):
                    handler_exists = True
                    break
            
            if not handler_exists:
                logging.getLogger().addHandler(file_handler)
    
    def create_artefakt(self, artefakt_type: str, interactive: bool = True, metadata: Optional[Dict[str, Any]] = None) -> str:
        """
        Erstellt ein neues Artefakt durch interaktiven Dialog oder mit vorgegebenen Metadaten.
        
        Args:
            artefakt_type: Typ des zu erstellenden Artefakts
            interactive: Ob der Dialog interaktiv durchgeführt werden soll
            metadata: Vordefinierte Metadaten (optional, nur wenn interactive=False)
            
        Returns:
            Pfad zum erstellten Artefakt
        """
        self.logger.info(f"Starte Erstellung eines Artefakts vom Typ '{artefakt_type}'")
        
        # Artefakt-Typ überprüfen
        if not self.artefakt_manager.is_valid_type(artefakt_type):
            available_types = self.artefakt_manager.get_available_types()
            self.logger.error(f"Ungültiger Artefakt-Typ: {artefakt_type}. Verfügbare Typen: {', '.join(available_types)}")
            raise ValueError(f"Ungültiger Artefakt-Typ: {artefakt_type}")
        
        # Metadaten sammeln (entweder interaktiv oder vorgegeben)
        if interactive:
            metadata = self.dialogue_engine.run_dialogue(artefakt_type)
        elif metadata is None:
            self.logger.error("Bei nicht-interaktivem Modus müssen Metadaten angegeben werden")
            raise ValueError("Bei nicht-interaktivem Modus müssen Metadaten angegeben werden")
        
        # Metadaten validieren
        self.artefakt_manager.validate_metadata(artefakt_type, metadata)
        
        # Template rendern
        content = self.template_renderer.render_template(artefakt_type, metadata)
        
        # Ausgabepfad bestimmen und Artefakt speichern
        output_path = self.repository_manager.determine_output_path(artefakt_type, metadata)
        self.repository_manager.save_artefakt(output_path, content)
        
        # MCP-Server benachrichtigen, falls aktiviert
        if self.mcp_integration:
            self.mcp_integration.notify_artefact_creation(artefakt_type, metadata, output_path)
        
        # Git-Integration, falls aktiviert
        if self.git_integration:
            commit_message = self.git_integration.generate_commit_message(artefakt_type, metadata)
            if self.config.get("integration", {}).get("git", {}).get("auto_commit", False):
                self.git_integration.commit_changes(output_path, commit_message)
                self.logger.info(f"Änderungen automatisch mit Git committet: {commit_message}")
            else:
                self.logger.info(f"Vorgeschlagener Git-Commit-Message: {commit_message}")
        
        self.logger.info(f"Artefakt erfolgreich erstellt: {output_path}")
        return output_path
    
    def get_available_artefakt_types(self) -> List[Dict[str, Any]]:
        """
        Gibt eine Liste aller verfügbaren Artefakt-Typen mit Metadaten zurück.
        
        Returns:
            Liste von Artefakt-Typ-Definitionen
        """
        return self.artefakt_manager.get_available_types_with_metadata()
    
    def validate_repository_structure(self) -> Dict[str, Any]:
        """
        Überprüft die Repository-Struktur und gibt einen Status-Bericht zurück.
        
        Returns:
            Status-Bericht zur Repository-Struktur
        """
        return self.repository_manager.validate_structure()
    
    def get_artefakt_by_criteria(self, criteria: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Sucht ein Artefakt anhand von Kriterien.
        
        Args:
            criteria: Suchkriterien (z.B. Typ, Fach, Jahrgangsstufe)
            
        Returns:
            Das gefundene Artefakt oder None
        """
        if self.mcp_integration and hasattr(self.mcp_integration, "get_artefacts"):
            artefacts = self.mcp_integration.get_artefacts(
                artefakt_type=criteria.get("artefakt_type"),
                fach=criteria.get("fach")
            )
            
            if not artefacts:
                return None
            
            # Filtern nach weiteren Kriterien
            for artefakt in artefacts:
                matches = True
                for key, value in criteria.items():
                    if key in ["artefakt_type", "fach"]:
                        continue  # Diese wurden bereits beim API-Aufruf berücksichtigt
                    
                    if key not in artefakt.get("metadata", {}) or artefakt["metadata"][key] != value:
                        matches = False
                        break
                
                if matches:
                    return artefakt
            
            return None
        else:
            self.logger.warning("MCP-Integration ist nicht verfügbar oder unterstützt die Artefakt-Suche nicht")
            return None
    
    def synchronize_mcp_resources(self) -> Dict[str, Any]:
        """
        Synchronisiert Ressourcen mit dem MCP-Server.
        
        Returns:
            Ein Dictionary mit Informationen über die Synchronisation
        """
        if self.mcp_integration and hasattr(self.mcp_integration, "synchronize_resources"):
            return self.mcp_integration.synchronize_resources()
        else:
            self.logger.warning("MCP-Integration ist nicht verfügbar oder unterstützt die Ressourcensynchronisation nicht")
            return {"success": False, "message": "MCP-Integration nicht verfügbar"}
    
    def run_cli(self):
        """Startet die Kommandozeilen-Schnittstelle."""
        from interfaces.cli import ArtefaktCraftCLI
        cli = ArtefaktCraftCLI(self)
        cli.start()
    
    def run_web_interface(self, open_browser=True):
        """Startet die Web-Schnittstelle."""
        from interfaces.web import ArtefaktCraftWeb
        web = ArtefaktCraftWeb(self)
        web.start(open_browser)
