
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
TemplateRenderer für ArtefaktCraft

Diese Klasse ist verantwortlich für das Rendern von Templates auf Basis
der gesammelten Metadaten, um die endgültigen Artefakt-Inhalte zu erstellen.
Unterstützt jetzt auch dynamische MCP-Ressourcen-Verlinkungen.
"""

import os
import logging
import yaml
import jinja2
from typing import Dict, Any, Optional, List, Callable
from pathlib import Path
from datetime import datetime

class TemplateRenderer:
    """Renderer für Artefakt-Templates mit MCP-Integration."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert den Template-Renderer.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.template")
        self.config = config
        
        # Jinja2-Umgebung initialisieren
        template_path = config["repository"]["template_path"]
        self.jinja_env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(template_path),
            autoescape=False,
            trim_blocks=True,
            lstrip_blocks=True
        )
        
        # Zusätzliche Jinja2-Filter registrieren
        self._register_filters()
        
        # MCP-Server-Integration referenzieren (wird in der render_template-Methode verwendet)
        self.mcp_integration = None
        
        self.logger.info(f"Template-Renderer initialisiert mit Pfad: {template_path}")
    
    def _register_filters(self):
        """Registriert zusätzliche Filter für Jinja2."""
        
        def format_date(value, format="%Y-%m-%d"):
            """Formatiert ein Datum."""
            if isinstance(value, datetime):
                return value.strftime(format)
            elif isinstance(value, str):
                try:
                    return datetime.strptime(value, "%Y-%m-%d").strftime(format)
                except ValueError:
                    return value
            return value
        
        def capitalize_first(value):
            """Ersten Buchstaben großschreiben."""
            if value and isinstance(value, str):
                return value[0].upper() + value[1:]
            return value
        
        def to_yaml_front_matter(value):
            """Konvertiert ein Dictionary in YAML-Front-Matter."""
            if isinstance(value, dict):
                yaml_str = yaml.dump(value, default_flow_style=False, sort_keys=False, allow_unicode=True)
                return f"---\n{yaml_str}---\n"
            return value
        
        def lehrplan_link(fach, jahrgangsstufe, lernbereich=None):
            """Erstellt einen MCP-Ressourcen-Link zu Lehrplan-Informationen."""
            if lernbereich:
                return f"{{{{mcp:lehrplan:{fach}{jahrgangsstufe}_Lehrplan_LB{lernbereich}_Detail}}}}"
            else:
                return f"{{{{mcp:lehrplan:{fach}{jahrgangsstufe}_Lehrplan_Ueberblick}}}}"
        
        def kompetenzmodell_link(fach, bereich=None):
            """Erstellt einen MCP-Ressourcen-Link zum Kompetenzmodell."""
            if bereich:
                return f"{{{{mcp:kompetenzmodell:{fach}_Kompetenzmodell_{bereich}}}}}"
            else:
                return f"{{{{mcp:kompetenzmodell:{fach}_Kompetenzmodell_Detailanalyse}}}}"
        
        def methodenfinder_link(fach, kompetenz=None):
            """Erstellt einen MCP-Ressourcen-Link zum Methodenfinder."""
            if kompetenz:
                return f"{{{{mcp:methodik:{fach}_Methodenfinder_{kompetenz}}}}}"
            else:
                return f"{{{{mcp:methodik:{fach}_Methodenfinder_Kompetenzorientiert}}}}"
        
        # Filter registrieren
        self.jinja_env.filters["format_date"] = format_date
        self.jinja_env.filters["capitalize_first"] = capitalize_first
        self.jinja_env.filters["to_yaml_front_matter"] = to_yaml_front_matter
        self.jinja_env.filters["lehrplan_link"] = lehrplan_link
        self.jinja_env.filters["kompetenzmodell_link"] = kompetenzmodell_link
        self.jinja_env.filters["methodenfinder_link"] = methodenfinder_link
    
    def set_mcp_integration(self, mcp_integration):
        """
        Setzt die MCP-Server-Integration.
        
        Args:
            mcp_integration: Die MCP-Server-Integration-Instanz
        """
        self.mcp_integration = mcp_integration
    
    def render_template(self, artefakt_type: str, metadata: Dict[str, Any]) -> str:
        """
        Rendert ein Template für den angegebenen Artefakt-Typ mit den gegebenen Metadaten.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die Metadaten für das Rendering
            
        Returns:
            Der gerenderte Inhalt
            
        Raises:
            ValueError: Wenn der Artefakt-Typ ungültig ist oder das Template nicht gefunden wurde
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
        
        # Template-Datei bestimmen
        template_file = artefakt_type_config["template"]
        
        try:
            # Template laden
            template = self.jinja_env.get_template(template_file)
            
            # MCP-Server-Integration importieren, falls nicht bereits gesetzt
            if self.mcp_integration is None and "mcp_server" in self.config.get("integration", {}):
                try:
                    from core.app import ArtefaktCraft
                    # Referenzieren, aber nicht initialisieren - wir nutzen die vorhandene Instanz
                    self.mcp_integration = ArtefaktCraft._instance.mcp_integration
                except (ImportError, AttributeError):
                    self.logger.warning("MCP-Server-Integration konnte nicht referenziert werden")
            
            # Lehrplan-Daten laden (wenn MCP-Integration verfügbar)
            lehrplan_data = {}
            kompetenzmodell_data = {}
            if self.mcp_integration and hasattr(self.mcp_integration, "get_lehrplan_resource"):
                fach = metadata.get("fach")
                jahrgangsstufe = metadata.get("jahrgangsstufe")
                if fach and jahrgangsstufe:
                    lehrplan_data = self.mcp_integration.get_lehrplan_resource(fach, jahrgangsstufe)
                    kompetenzmodell_data = self.mcp_integration.get_kompetenzmodell(fach)
            
            # Kontextdaten vorbereiten
            context = {
                # Metadaten
                **metadata,
                
                # Systemdaten
                "now": datetime.now(),
                "artefakt_type": artefakt_type,
                "artefakt_name": artefakt_type_config["name"],
                
                # MCP-Daten
                "lehrplan": lehrplan_data,
                "kompetenzmodell": kompetenzmodell_data,
                
                # MCP-Helfer
                "mcp_link": self._create_mcp_link_function(),
                
                # Hilfsmethoden
                "yaml_dump": lambda obj: yaml.dump(obj, default_flow_style=False, sort_keys=False, allow_unicode=True)
            }
            
            # Template rendern
            content = template.render(**context)
            self.logger.info(f"Template für Artefakt-Typ '{artefakt_type}' erfolgreich gerendert")
            
            # MCP-Ressourcen-Verweise verarbeiten
            if self.mcp_integration and hasattr(self.mcp_integration, "process_resource_links"):
                content = self.mcp_integration.process_resource_links(content)
                self.logger.info("MCP-Ressourcen-Verweise verarbeitet")
            
            return content
            
        except jinja2.exceptions.TemplateNotFound:
            self.logger.error(f"Template-Datei nicht gefunden: {template_file}")
            raise ValueError(f"Template-Datei nicht gefunden: {template_file}")
        except Exception as e:
            self.logger.error(f"Fehler beim Rendern des Templates: {str(e)}")
            raise
    
    def _create_mcp_link_function(self) -> Callable:
        """
        Erstellt eine Hilfsfunktion zum Generieren von MCP-Links.
        
        Returns:
            Funktion zum Generieren von MCP-Links
        """
        def mcp_link(resource_type: str, resource_path: str) -> str:
            """
            Generiert einen MCP-Ressourcen-Link.
            
            Args:
                resource_type: Der Ressourcentyp
                resource_path: Der Pfad zur Ressource
                
            Returns:
                Der generierte MCP-Link
            """
            return f"{{{{mcp:{resource_type}:{resource_path}}}}}"
        
        return mcp_link
    
    def create_custom_template(self, template_content: str, metadata: Dict[str, Any]) -> str:
        """
        Rendert ein benutzerdefiniertes Template mit den gegebenen Metadaten.
        
        Args:
            template_content: Der Inhalt des benutzerdefinierten Templates
            metadata: Die Metadaten für das Rendering
            
        Returns:
            Der gerenderte Inhalt
        """
        try:
            # Template aus String erstellen
            template = self.jinja_env.from_string(template_content)
            
            # Lehrplan-Daten laden (wenn MCP-Integration verfügbar)
            lehrplan_data = {}
            kompetenzmodell_data = {}
            if self.mcp_integration and hasattr(self.mcp_integration, "get_lehrplan_resource"):
                fach = metadata.get("fach")
                jahrgangsstufe = metadata.get("jahrgangsstufe")
                if fach and jahrgangsstufe:
                    lehrplan_data = self.mcp_integration.get_lehrplan_resource(fach, jahrgangsstufe)
                    kompetenzmodell_data = self.mcp_integration.get_kompetenzmodell(fach)
            
            # Kontextdaten vorbereiten
            context = {
                # Metadaten
                **metadata,
                
                # Systemdaten
                "now": datetime.now(),
                
                # MCP-Daten
                "lehrplan": lehrplan_data,
                "kompetenzmodell": kompetenzmodell_data,
                
                # MCP-Helfer
                "mcp_link": self._create_mcp_link_function(),
                
                # Hilfsmethoden
                "yaml_dump": lambda obj: yaml.dump(obj, default_flow_style=False, sort_keys=False, allow_unicode=True)
            }
            
            # Template rendern
            content = template.render(**context)
            self.logger.info("Benutzerdefiniertes Template erfolgreich gerendert")
            
            # MCP-Ressourcen-Verweise verarbeiten
            if self.mcp_integration and hasattr(self.mcp_integration, "process_resource_links"):
                content = self.mcp_integration.process_resource_links(content)
                self.logger.info("MCP-Ressourcen-Verweise im benutzerdefinierten Template verarbeitet")
            
            return content
            
        except Exception as e:
            self.logger.error(f"Fehler beim Rendern des benutzerdefinierten Templates: {str(e)}")
            raise
    
    def get_template_details(self, template_file: str) -> Dict[str, Any]:
        """
        Holt Informationen über ein Template.
        
        Args:
            template_file: Die Template-Datei
            
        Returns:
            Details zum Template (Variablen, Kommentare, etc.)
        """
        try:
            # Template-Pfad
            template_path = os.path.join(self.config["repository"]["template_path"], template_file)
            
            # Prüfen, ob das Template existiert
            if not os.path.exists(template_path):
                self.logger.error(f"Template-Datei nicht gefunden: {template_file}")
                return {"error": f"Template-Datei nicht gefunden: {template_file}"}
            
            # Template-Inhalt lesen
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            # Template-Umgebung für die Analyse
            env = jinja2.Environment()
            ast = env.parse(template_content)
            
            # Variablen extrahieren
            variables = set()
            for node in ast.find_all(jinja2.nodes.Name):
                if not node.ctx == "store" and not node.name.startswith("_"):
                    variables.add(node.name)
            
            # Kommentare extrahieren
            comments = []
            lines = template_content.split("\n")
            for line in lines:
                if "{#" in line and "#}" in line:
                    comment = line[line.find("{#") + 2:line.find("#}")]
                    comments.append(comment.strip())
            
            return {
                "file": template_file,
                "variables": sorted(list(variables)),
                "comments": comments,
                "size": os.path.getsize(template_path),
                "modified": datetime.fromtimestamp(os.path.getmtime(template_path)).strftime("%Y-%m-%d %H:%M:%S")
            }
            
        except Exception as e:
            self.logger.error(f"Fehler beim Analysieren des Templates {template_file}: {str(e)}")
            return {"error": str(e)}

    def analyze_template_mcp_links(self, template_file: str) -> List[Dict[str, Any]]:
        """
        Analysiert ein Template auf MCP-Ressourcen-Verweise.
        
        Args:
            template_file: Die Template-Datei
            
        Returns:
            Liste der gefundenen MCP-Ressourcen-Verweise
        """
        try:
            # Template-Pfad
            template_path = os.path.join(self.config["repository"]["template_path"], template_file)
            
            # Prüfen, ob das Template existiert
            if not os.path.exists(template_path):
                self.logger.error(f"Template-Datei nicht gefunden: {template_file}")
                return []
            
            # Template-Inhalt lesen
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            # MCP-Links suchen (sowohl direkte als auch über Filter)
            import re
            
            # Direkte Links: {{mcp:resource_type:path}}
            direct_pattern = r"\{\{mcp:([a-zA-Z0-9_]+):([^}]+)\}\}"
            direct_matches = re.finditer(direct_pattern, template_content)
            
            # Filter-Links: | lehrplan_link(...) | kompetenzmodell_link(...) | methodenfinder_link(...)
            filter_pattern = r"\|\s*(lehrplan_link|kompetenzmodell_link|methodenfinder_link)\s*\(([^)]+)\)"
            filter_matches = re.finditer(filter_pattern, template_content)
            
            # Ergebnisse sammeln
            mcp_links = []
            
            for match in direct_matches:
                mcp_links.append({
                    "type": "direct",
                    "resource_type": match.group(1),
                    "resource_path": match.group(2),
                    "reference": match.group(0)
                })
            
            for match in filter_matches:
                filter_name = match.group(1)
                filter_args = match.group(2).strip()
                
                mcp_links.append({
                    "type": "filter",
                    "filter_name": filter_name,
                    "filter_args": filter_args,
                    "reference": match.group(0)
                })
            
            return mcp_links
            
        except Exception as e:
            self.logger.error(f"Fehler beim Analysieren der MCP-Links im Template {template_file}: {str(e)}")
            return []
