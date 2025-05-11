
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Command-Line-Interface für ArtefaktCraft

Diese Klasse implementiert eine Kommandozeilen-Schnittstelle für die ArtefaktCraft-Anwendung.
"""

import os
import sys
import logging
import argparse
import json
from typing import Dict, Any, List, Optional
import colorama
from colorama import Fore, Style

class ArtefaktCraftCLI:
    """Kommandozeilen-Schnittstelle für ArtefaktCraft."""
    
    def __init__(self, app):
        """
        Initialisiert die CLI.
        
        Args:
            app: Die ArtefaktCraft-Anwendungsinstanz
        """
        self.logger = logging.getLogger("artefaktcraft.cli")
        self.app = app
        self.config = app.config
        
        # Farbkonfiguration
        colorama.init(autoreset=True)
        cli_config = self.config.get("ui", {}).get("cli", {})
        self.prompt_color = getattr(Fore, cli_config.get("prompt_color", "GREEN").upper())
        self.response_color = getattr(Fore, cli_config.get("response_color", "BLUE").upper())
        self.error_color = getattr(Fore, cli_config.get("error_color", "RED").upper())
        
        self.logger.info("CLI initialisiert")
    
    def start(self):
        """Startet die CLI und verarbeitet die Kommandozeilenargumente."""
        parser = argparse.ArgumentParser(description="ArtefaktCraft - Tool zur Erstellung pädagogischer Artefakte")
        
        # Subparsers für verschiedene Befehle
        subparsers = parser.add_subparsers(dest="command", help="Verfügbare Befehle")
        
        # Befehl: create
        create_parser = subparsers.add_parser("create", help="Erstellt ein neues Artefakt")
        create_parser.add_argument("type", help="Typ des zu erstellenden Artefakts")
        create_parser.add_argument("--metadata", "-m", help="Metadaten im JSON-Format (für nicht-interaktiven Modus)")
        create_parser.add_argument("--non-interactive", "-n", action="store_true", help="Nicht-interaktiver Modus")
        
        # Befehl: list
        list_parser = subparsers.add_parser("list", help="Listet verfügbare Artefakt-Typen auf")
        
        # Befehl: validate
        validate_parser = subparsers.add_parser("validate", help="Validiert die Repository-Struktur")
        
        # Befehl: init
        init_parser = subparsers.add_parser("init", help="Initialisiert fehlende Repository-Struktur")
        
        # Kommandozeilenargumente parsen
        args = parser.parse_args()
        
        # Wenn kein Befehl angegeben wurde, interaktiven Modus starten
        if not args.command:
            self._interactive_mode()
            return
        
        # Befehl ausführen
        if args.command == "create":
            self._handle_create(args)
        elif args.command == "list":
            self._handle_list()
        elif args.command == "validate":
            self._handle_validate()
        elif args.command == "init":
            self._handle_init()
    
    def _interactive_mode(self):
        """Startet den interaktiven Modus der CLI."""
        print(f"{Fore.CYAN}=== ArtefaktCraft - Interaktiver Modus ==={Style.RESET_ALL}")
        print("Geben Sie 'exit' oder 'quit' ein, um zu beenden.")
        print("Verfügbare Befehle: create, list, validate, init, help")
        
        while True:
            try:
                command = input(f"\n{self.prompt_color}artefaktcraft> {Style.RESET_ALL}").strip()
                
                if command in ["exit", "quit"]:
                    print(f"{self.response_color}Auf Wiedersehen!{Style.RESET_ALL}")
                    break
                
                parts = command.split()
                cmd = parts[0] if parts else ""
                
                if cmd == "help":
                    self._show_help()
                elif cmd == "create":
                    if len(parts) < 2:
                        print(f"{self.error_color}Fehler: Artefakt-Typ fehlt{Style.RESET_ALL}")
                        print("Verwendung: create <artefakt_typ>")
                    else:
                        self._handle_create_interactive(parts[1])
                elif cmd == "list":
                    self._handle_list()
                elif cmd == "validate":
                    self._handle_validate()
                elif cmd == "init":
                    self._handle_init()
                else:
                    print(f"{self.error_color}Unbekannter Befehl: {cmd}{Style.RESET_ALL}")
                    print("Geben Sie 'help' ein, um verfügbare Befehle anzuzeigen.")
                
            except KeyboardInterrupt:
                print("\nEingabe abgebrochen.")
                continue
            except EOFError:
                print("\nAuf Wiedersehen!")
                break
            except Exception as e:
                print(f"{self.error_color}Fehler: {str(e)}{Style.RESET_ALL}")
                self.logger.error(f"Fehler im interaktiven Modus: {str(e)}", exc_info=True)
    
    def _show_help(self):
        """Zeigt die Hilfe für den interaktiven Modus an."""
        print(f"{Fore.CYAN}=== ArtefaktCraft - Hilfe ==={Style.RESET_ALL}")
        print("Verfügbare Befehle:")
        print(f"  {Fore.GREEN}create <artefakt_typ>{Style.RESET_ALL} - Erstellt ein neues Artefakt")
        print(f"  {Fore.GREEN}list{Style.RESET_ALL} - Listet verfügbare Artefakt-Typen auf")
        print(f"  {Fore.GREEN}validate{Style.RESET_ALL} - Validiert die Repository-Struktur")
        print(f"  {Fore.GREEN}init{Style.RESET_ALL} - Initialisiert fehlende Repository-Struktur")
        print(f"  {Fore.GREEN}help{Style.RESET_ALL} - Zeigt diese Hilfe an")
        print(f"  {Fore.GREEN}exit{Style.RESET_ALL} oder {Fore.GREEN}quit{Style.RESET_ALL} - Beendet die Anwendung")
    
    def _handle_create(self, args):
        """
        Verarbeitet den 'create'-Befehl.
        
        Args:
            args: Die Kommandozeilenargumente
        """
        try:
            # Artefakt-Typ überprüfen
            artefakt_types = self.app.get_available_artefakt_types()
            artefakt_type_ids = [at["id"] for at in artefakt_types]
            
            if args.type not in artefakt_type_ids:
                print(f"{self.error_color}Fehler: Ungültiger Artefakt-Typ: {args.type}{Style.RESET_ALL}")
                print(f"Verfügbare Typen: {', '.join(artefakt_type_ids)}")
                return
            
            # Metadaten verarbeiten
            metadata = None
            if args.non_interactive:
                if not args.metadata:
                    print(f"{self.error_color}Fehler: Im nicht-interaktiven Modus müssen Metadaten angegeben werden{Style.RESET_ALL}")
                    return
                
                try:
                    metadata = json.loads(args.metadata)
                except json.JSONDecodeError:
                    print(f"{self.error_color}Fehler: Ungültiges JSON-Format für Metadaten{Style.RESET_ALL}")
                    return
            
            # Artefakt erstellen
            output_path = self.app.create_artefakt(args.type, not args.non_interactive, metadata)
            
            print(f"{self.response_color}Artefakt erfolgreich erstellt: {output_path}{Style.RESET_ALL}")
            
        except Exception as e:
            print(f"{self.error_color}Fehler bei der Erstellung des Artefakts: {str(e)}{Style.RESET_ALL}")
            self.logger.error(f"Fehler bei der Erstellung des Artefakts: {str(e)}", exc_info=True)
    
    def _handle_create_interactive(self, artefakt_type):
        """
        Verarbeitet den 'create'-Befehl im interaktiven Modus.
        
        Args:
            artefakt_type: Der Typ des zu erstellenden Artefakts
        """
        try:
            # Artefakt-Typ überprüfen
            artefakt_types = self.app.get_available_artefakt_types()
            artefakt_type_ids = [at["id"] for at in artefakt_types]
            
            if artefakt_type not in artefakt_type_ids:
                print(f"{self.error_color}Fehler: Ungültiger Artefakt-Typ: {artefakt_type}{Style.RESET_ALL}")
                print(f"Verfügbare Typen: {', '.join(artefakt_type_ids)}")
                return
            
            # Artefakt erstellen
            output_path = self.app.create_artefakt(artefakt_type, True)
            
            print(f"{self.response_color}Artefakt erfolgreich erstellt: {output_path}{Style.RESET_ALL}")
            
        except Exception as e:
            print(f"{self.error_color}Fehler bei der Erstellung des Artefakts: {str(e)}{Style.RESET_ALL}")
            self.logger.error(f"Fehler bei der Erstellung des Artefakts: {str(e)}", exc_info=True)
    
    def _handle_list(self):
        """Verarbeitet den 'list'-Befehl."""
        try:
            artefakt_types = self.app.get_available_artefakt_types()
            
            print(f"{Fore.CYAN}=== Verfügbare Artefakt-Typen ==={Style.RESET_ALL}")
            
            for at in artefakt_types:
                print(f"{Fore.GREEN}{at['id']}{Style.RESET_ALL}: {at['name']}")
                
                # Metadaten-Schema anzeigen, wenn vorhanden
                if "metadata_schema" in at:
                    print("  Metadaten-Schema:")
                    for field in at["metadata_schema"]:
                        required = "Erforderlich" if field.get("required", False) else "Optional"
                        field_type = field.get("type", "string")
                        print(f"    {field['name']} ({field_type}, {required})")
                
                print()
            
        except Exception as e:
            print(f"{self.error_color}Fehler beim Auflisten der Artefakt-Typen: {str(e)}{Style.RESET_ALL}")
            self.logger.error(f"Fehler beim Auflisten der Artefakt-Typen: {str(e)}", exc_info=True)
    
    def _handle_validate(self):
        """Verarbeitet den 'validate'-Befehl."""
        try:
            result = self.app.validate_repository_structure()
            
            print(f"{Fore.CYAN}=== Repository-Struktur-Validierung ==={Style.RESET_ALL}")
            
            # Basis-Pfad
            base_path_status = f"{Fore.GREEN}OK{Style.RESET_ALL}" if result["base_path_exists"] else f"{Fore.RED}Fehlt{Style.RESET_ALL}"
            print(f"Basis-Pfad: {self.config['repository']['base_path']} - {base_path_status}")
            
            # Templates-Pfad
            templates_path_status = f"{Fore.GREEN}OK{Style.RESET_ALL}" if result["templates_path_exists"] else f"{Fore.RED}Fehlt{Style.RESET_ALL}"
            print(f"Templates-Pfad: {self.config['repository']['template_path']} - {templates_path_status}")
            
            # Ausgabepfade
            print("\nAusgabepfade:")
            for fach, info in result["output_paths"].items():
                status = f"{Fore.GREEN}OK{Style.RESET_ALL}" if info["exists"] else f"{Fore.RED}Fehlt{Style.RESET_ALL}"
                print(f"  {fach}: {info['path']} - {status}")
            
            # Templates
            print("\nTemplates:")
            for template in result["templates"]:
                status = f"{Fore.GREEN}OK{Style.RESET_ALL}" if template["exists"] else f"{Fore.RED}Fehlt{Style.RESET_ALL}"
                print(f"  {template['artefakt_type']}: {template['path']} - {status}")
            
            # Gesamtstatus
            all_ok = (
                result["base_path_exists"] and
                result["templates_path_exists"] and
                all(info["exists"] for info in result["output_paths"].values()) and
                all(template["exists"] for template in result["templates"])
            )
            
            print(f"\nGesamtstatus: {Fore.GREEN}OK{Style.RESET_ALL}" if all_ok else f"{Fore.RED}Fehler{Style.RESET_ALL}")
            
            if not all_ok:
                print(f"\nFührend Sie '{Fore.CYAN}init{Style.RESET_ALL}' aus, um fehlende Strukturen zu erstellen.")
            
        except Exception as e:
            print(f"{self.error_color}Fehler bei der Validierung der Repository-Struktur: {str(e)}{Style.RESET_ALL}")
            self.logger.error(f"Fehler bei der Validierung der Repository-Struktur: {str(e)}", exc_info=True)
    
    def _handle_init(self):
        """Verarbeitet den 'init'-Befehl."""
        try:
            created_dirs = self.app.repository_manager.create_missing_structure()
            
            if created_dirs:
                print(f"{Fore.CYAN}=== Repository-Struktur initialisiert ==={Style.RESET_ALL}")
                print("Folgende Verzeichnisse wurden erstellt:")
                for directory in created_dirs:
                    print(f"  {directory}")
            else:
                print(f"{self.response_color}Repository-Struktur ist bereits vollständig.{Style.RESET_ALL}")
            
        except Exception as e:
            print(f"{self.error_color}Fehler bei der Initialisierung der Repository-Struktur: {str(e)}{Style.RESET_ALL}")
            self.logger.error(f"Fehler bei der Initialisierung der Repository-Struktur: {str(e)}", exc_info=True)
