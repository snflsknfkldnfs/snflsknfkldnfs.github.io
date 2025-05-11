
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Web-Interface für ArtefaktCraft

Diese Klasse implementiert eine Weboberfläche für die ArtefaktCraft-Anwendung.
"""

import os
import sys
import logging
import json
import traceback
from typing import Dict, Any, List, Optional
from pathlib import Path
import threading
import webbrowser

# Flask-Abhängigkeiten
try:
    from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
except ImportError:
    logging.error("Flask ist nicht installiert. Bitte installieren Sie es mit 'pip install flask'")
    raise

class ArtefaktCraftWeb:
    """Weboberfläche für ArtefaktCraft."""
    
    def __init__(self, app):
        """
        Initialisiert die Weboberfläche.
        
        Args:
            app: Die ArtefaktCraft-Anwendungsinstanz
        """
        self.logger = logging.getLogger("artefaktcraft.web")
        self.app = app
        self.config = app.config
        
        # Web-Konfiguration
        web_config = self.config.get("ui", {}).get("web_interface", {})
        self.host = web_config.get("host", "127.0.0.1")
        self.port = web_config.get("port", 8080)
        self.templates_dir = web_config.get("templates_dir", "./templates")
        self.static_dir = web_config.get("static_dir", "./static")
        
        # Flask-App erstellen
        self.flask_app = Flask(
            "ArtefaktCraft",
            template_folder=self.templates_dir,
            static_folder=self.static_dir
        )
        self.flask_app.secret_key = os.urandom(24)
        
        # Routen registrieren
        self._register_routes()
        
        self.logger.info("Web-Interface initialisiert")
    
    def _register_routes(self):
        """Registriert die Flask-Routen."""
        
        @self.flask_app.route('/')
        def index():
            """Startseite"""
            return render_template('index.html', title="ArtefaktCraft")
        
        @self.flask_app.route('/artefakte')
        def artefakte():
            """Liste aller verfügbaren Artefakt-Typen"""
            artefakt_types = self.app.get_available_artefakt_types()
            return render_template('artefakte.html', title="Artefakt-Typen", artefakt_types=artefakt_types)
        
        @self.flask_app.route('/erstellen/<artefakt_type>', methods=['GET', 'POST'])
        def erstellen(artefakt_type):
            """Formular zur Erstellung eines Artefakts"""
            # Artefakt-Typ überprüfen
            artefakt_types = self.app.get_available_artefakt_types()
            artefakt_type_config = None
            
            for at in artefakt_types:
                if at["id"] == artefakt_type:
                    artefakt_type_config = at
                    break
            
            if not artefakt_type_config:
                flash(f"Ungültiger Artefakt-Typ: {artefakt_type}", "error")
                return redirect(url_for('artefakte'))
            
            # POST-Anfrage verarbeiten
            if request.method == 'POST':
                try:
                    # Formular-Daten sammeln
                    metadata = {}
                    for field in artefakt_type_config["metadata_schema"]:
                        field_name = field["name"]
                        field_type = field.get("type", "string")
                        
                        if field_name in request.form:
                            value = request.form[field_name]
                            
                            # Typkonvertierung
                            if field_type == "number":
                                if value.strip():
                                    if "." in value:
                                        value = float(value)
                                    else:
                                        value = int(value)
                                else:
                                    value = None
                            elif field_type == "boolean":
                                value = value.lower() in ["true", "1", "yes", "y", "on"]
                            
                            metadata[field_name] = value
                    
                    # Artefakt erstellen
                    output_path = self.app.create_artefakt(artefakt_type, False, metadata)
                    
                    flash(f"Artefakt erfolgreich erstellt: {output_path}", "success")
                    return redirect(url_for('artefakte'))
                    
                except Exception as e:
                    self.logger.error(f"Fehler bei der Erstellung des Artefakts: {str(e)}", exc_info=True)
                    flash(f"Fehler bei der Erstellung des Artefakts: {str(e)}", "error")
            
            # GET-Anfrage oder Fehler bei POST
            return render_template(
                'erstellen.html',
                title=f"Artefakt erstellen: {artefakt_type_config['name']}",
                artefakt_type=artefakt_type,
                artefakt_type_config=artefakt_type_config
            )
        
        @self.flask_app.route('/repository')
        def repository():
            """Repository-Status"""
            try:
                result = self.app.validate_repository_structure()
                return render_template('repository.html', title="Repository-Status", result=result)
            except Exception as e:
                self.logger.error(f"Fehler bei der Validierung der Repository-Struktur: {str(e)}", exc_info=True)
                flash(f"Fehler bei der Validierung der Repository-Struktur: {str(e)}", "error")
                return redirect(url_for('index'))
        
        @self.flask_app.route('/api/repository/init', methods=['POST'])
        def api_repository_init():
            """API-Endpunkt zur Initialisierung der Repository-Struktur"""
            try:
                created_dirs = self.app.repository_manager.create_missing_structure()
                return jsonify({"success": True, "created_dirs": created_dirs})
            except Exception as e:
                self.logger.error(f"Fehler bei der Initialisierung der Repository-Struktur: {str(e)}", exc_info=True)
                return jsonify({"success": False, "error": str(e), "traceback": traceback.format_exc()})
        
        @self.flask_app.route('/api/artefakt/vorschau', methods=['POST'])
        def api_artefakt_vorschau():
            """API-Endpunkt zur Vorschau eines Artefakts"""
            try:
                data = request.json
                artefakt_type = data.get("artefakt_type")
                metadata = data.get("metadata", {})
                
                if not artefakt_type:
                    return jsonify({"success": False, "error": "Artefakt-Typ nicht angegeben"})
                
                # Artefakt-Typ überprüfen
                artefakt_types = self.app.get_available_artefakt_types()
                artefakt_type_config = None
                
                for at in artefakt_types:
                    if at["id"] == artefakt_type:
                        artefakt_type_config = at
                        break
                
                if not artefakt_type_config:
                    return jsonify({"success": False, "error": f"Ungültiger Artefakt-Typ: {artefakt_type}"})
                
                # Metadaten validieren
                try:
                    self.app.artefakt_manager.validate_metadata(artefakt_type, metadata)
                except Exception as e:
                    return jsonify({"success": False, "error": f"Ungültige Metadaten: {str(e)}"})
                
                # Template rendern
                content = self.app.template_renderer.render_template(artefakt_type, metadata)
                
                return jsonify({"success": True, "content": content})
                
            except Exception as e:
                self.logger.error(f"Fehler bei der Vorschau des Artefakts: {str(e)}", exc_info=True)
                return jsonify({"success": False, "error": str(e), "traceback": traceback.format_exc()})
        
        @self.flask_app.errorhandler(404)
        def page_not_found(e):
            """404-Fehlerseite"""
            return render_template('error.html', title="404 - Seite nicht gefunden", error=e), 404
        
        @self.flask_app.errorhandler(500)
        def server_error(e):
            """500-Fehlerseite"""
            return render_template('error.html', title="500 - Serverfehler", error=e), 500
    
    def start(self, open_browser=True):
        """
        Startet die Weboberfläche.
        
        Args:
            open_browser: Ob der Browser automatisch geöffnet werden soll
        """
        # URL zusammenbauen
        url = f"http://{self.host}:{self.port}"
        
        # Browser öffnen
        if open_browser:
            threading.Timer(1.0, lambda: webbrowser.open(url)).start()
        
        self.logger.info(f"Web-Interface wird gestartet auf {url}")
        
        # Flask-App starten
        self.flask_app.run(
            host=self.host,
            port=self.port,
            debug=False,
            use_reloader=False
        )
