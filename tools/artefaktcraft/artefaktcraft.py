
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ArtefaktCraft - Hauptanwendungsskript

Dieses Skript startet ArtefaktCraft entweder im CLI- oder Web-Modus.
Optimiert mit MCP-Server-Integration für standardisierte pädagogische Artefakte.
"""

import os
import sys
import argparse
import logging
import time

# System-Pfad anpassen, um das src-Verzeichnis zu importieren
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(script_dir, "src"))

# Jetzt können wir die Anwendungsmodule importieren
from core.app import ArtefaktCraft

def setup_logging(log_level, log_file=None):
    """Richtet das grundlegende Logging ein."""
    # Root-Logger konfigurieren
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level))
    
    # Handler und Formatter
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
    
    # Konsolen-Handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
    
    # Datei-Handler (optional)
    if log_file:
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)

def check_mcp_server(host="localhost", port=3000, max_retries=3, retry_delay=1):
    """
    Überprüft, ob ein MCP-Server läuft.
    
    Args:
        host: Hostname des MCP-Servers
        port: Port des MCP-Servers
        max_retries: Maximale Anzahl von Wiederholungsversuchen
        retry_delay: Verzögerung zwischen Wiederholungsversuchen in Sekunden
        
    Returns:
        True, wenn der MCP-Server erreichbar ist, sonst False
    """
    import socket
    
    logger = logging.getLogger("artefaktcraft.mcp_check")
    logger.info(f"Überprüfe MCP-Server auf {host}:{port}...")
    
    for attempt in range(max_retries):
        try:
            # Socket-Verbindung zum MCP-Server herstellen
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(2)  # 2 Sekunden Timeout
                s.connect((host, port))
                logger.info(f"MCP-Server ist erreichbar auf {host}:{port}")
                return True
        except (socket.timeout, ConnectionRefusedError, socket.error) as e:
            logger.warning(f"Verbindung zum MCP-Server fehlgeschlagen (Versuch {attempt+1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay)
    
    logger.error(f"MCP-Server ist nicht erreichbar auf {host}:{port}")
    return False

def main():
    """Hauptfunktion der Anwendung."""
    # Kommandozeilenargumente parsen
    parser = argparse.ArgumentParser(description="ArtefaktCraft - Tool zur Erstellung pädagogischer Artefakte")
    parser.add_argument("--config", help="Pfad zur Konfigurationsdatei", default=os.path.join(script_dir, "config", "config.yaml"))
    parser.add_argument("--web", action="store_true", help="Startet die Weboberfläche")
    parser.add_argument("--port", type=int, help="Port für die Weboberfläche", default=8080)
    parser.add_argument("--host", help="Host für die Weboberfläche", default="127.0.0.1")
    parser.add_argument("--no-browser", action="store_true", help="Öffnet keinen Browser automatisch")
    parser.add_argument("--log-level", choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], default="INFO", help="Log-Level")
    parser.add_argument("--log-file", help="Pfad zur Log-Datei", default=os.path.join(script_dir, "logs", "artefaktcraft.log"))
    parser.add_argument("--skip-mcp-check", action="store_true", help="Überspringe die Überprüfung des MCP-Servers")
    parser.add_argument("--mcp-host", help="Hostname des MCP-Servers", default="localhost")
    parser.add_argument("--mcp-port", type=int, help="Port des MCP-Servers", default=3000)
    parser.add_argument("command", nargs="?", choices=["create", "list", "validate", "init", "sync"], help="Auszuführender Befehl (optional)")
    parser.add_argument("args", nargs="*", help="Argumente für den Befehl")
    
    args = parser.parse_args()
    
    # Logging einrichten
    setup_logging(args.log_level, args.log_file)
    logger = logging.getLogger("artefaktcraft.main")
    
    try:
        # MCP-Server überprüfen (übersprungen, wenn --skip-mcp-check)
        if not args.skip_mcp_check:
            if not check_mcp_server(args.mcp_host, args.mcp_port):
                logger.warning("MCP-Server ist nicht erreichbar. ArtefaktCraft wird ohne MCP-Server-Integration gestartet.")
                mcp_confirmation = input("Möchten Sie trotzdem fortfahren? (j/n): ").strip().lower()
                if mcp_confirmation not in ["j", "ja", "y", "yes"]:
                    logger.info("Beenden auf Benutzeranfrage")
                    sys.exit(0)
        
        # ArtefaktCraft initialisieren
        app = ArtefaktCraft(args.config)
        
        # Direkten Befehl ausführen, wenn angegeben
        if args.command:
            if args.command == "create":
                if not args.args:
                    logger.error("Fehler: Artefakt-Typ fehlt")
                    print("Verwendung: artefaktcraft.py create <artefakt_typ>")
                    sys.exit(1)
                
                artefakt_type = args.args[0]
                app.create_artefakt(artefakt_type, True)
                sys.exit(0)
                
            elif args.command == "list":
                artefakt_types = app.get_available_artefakt_types()
                print("Verfügbare Artefakt-Typen:")
                for at in artefakt_types:
                    print(f"- {at['name']} (ID: {at['id']})")
                sys.exit(0)
                
            elif args.command == "validate":
                result = app.validate_repository_structure()
                print("Repository-Struktur:")
                for key, value in result.items():
                    if isinstance(value, dict):
                        print(f"{key}:")
                        for subkey, subvalue in value.items():
                            print(f"  {subkey}: {subvalue}")
                    else:
                        print(f"{key}: {value}")
                sys.exit(0)
                
            elif args.command == "init":
                created_dirs = app.repository_manager.create_missing_structure()
                print("Erstellte Verzeichnisse:")
                for directory in created_dirs:
                    print(f"- {directory}")
                sys.exit(0)
                
            elif args.command == "sync":
                if not hasattr(app, "mcp_integration") or not app.mcp_integration:
                    logger.error("MCP-Integration ist nicht verfügbar")
                    sys.exit(1)
                
                result = app.mcp_integration.synchronize_resources()
                if result["success"]:
                    print(f"Synchronisation erfolgreich: {len(result['synchronized_resources'])} Ressourcen synchronisiert")
                    for resource in result["synchronized_resources"]:
                        print(f"- {resource['type']}: {resource['count']} Dateien")
                else:
                    print(f"Synchronisation fehlgeschlagen: {result.get('message', 'Unbekannter Fehler')}")
                sys.exit(0)
        
        # Web- oder CLI-Modus starten
        if args.web:
            # Konfiguration überschreiben
            app.config["ui"]["web_interface"]["port"] = args.port
            app.config["ui"]["web_interface"]["host"] = args.host
            
            # Weboberfläche starten
            app.run_web_interface(not args.no_browser)
        else:
            # CLI starten
            app.run_cli()
            
    except KeyboardInterrupt:
        logger.info("Beenden durch Benutzer (Strg+C)")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fehler beim Starten von ArtefaktCraft: {str(e)}", exc_info=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
