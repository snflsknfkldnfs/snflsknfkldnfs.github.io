
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MCPServerIntegration für ArtefaktCraft

Diese erweiterte Klasse ermöglicht die Integration mit MCP-Servern für die
Verteilung, Synchronisation und dynamische Referenzierung von Artefakten und 
Ressourcen im standardisierten Prozess.
"""

import os
import logging
import json
import requests
import time
import threading
import hashlib
from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple, Union
import shutil

class MCPResourceCache:
    """Cache für MCP-Ressourcen zur Verbesserung der Performance."""
    
    def __init__(self, cache_path: str, max_age: int = 3600):
        """
        Initialisiert den Ressourcen-Cache.
        
        Args:
            cache_path: Pfad zum Cache-Verzeichnis
            max_age: Maximales Alter der Cache-Einträge in Sekunden (Standard: 1 Stunde)
        """
        self.logger = logging.getLogger("artefaktcraft.mcp.cache")
        self.cache_path = Path(cache_path)
        self.max_age = max_age
        
        # Cache-Verzeichnis erstellen, falls es nicht existiert
        os.makedirs(self.cache_path, exist_ok=True)
        
        self.logger.info(f"MCP-Ressourcen-Cache initialisiert: {self.cache_path} (max_age={max_age}s)")
    
    def get(self, key: str) -> Optional[Dict[str, Any]]:
        """
        Holt einen Eintrag aus dem Cache.
        
        Args:
            key: Der Cache-Schlüssel
            
        Returns:
            Die Cache-Daten oder None, wenn nicht im Cache oder abgelaufen
        """
        cache_file = self.cache_path / f"{self._hash_key(key)}.json"
        
        if not cache_file.exists():
            return None
        
        try:
            with open(cache_file, 'r', encoding='utf-8') as f:
                cache_entry = json.load(f)
            
            # Prüfen, ob der Cache-Eintrag abgelaufen ist
            if time.time() - cache_entry["timestamp"] > self.max_age:
                self.logger.debug(f"Cache-Eintrag abgelaufen: {key}")
                return None
            
            self.logger.debug(f"Cache-Hit für {key}")
            return cache_entry["data"]
            
        except Exception as e:
            self.logger.warning(f"Fehler beim Lesen des Cache-Eintrags {key}: {str(e)}")
            return None
    
    def set(self, key: str, data: Dict[str, Any]) -> bool:
        """
        Speichert einen Eintrag im Cache.
        
        Args:
            key: Der Cache-Schlüssel
            data: Die zu cachenden Daten
            
        Returns:
            True bei Erfolg, sonst False
        """
        cache_file = self.cache_path / f"{self._hash_key(key)}.json"
        
        try:
            cache_entry = {
                "timestamp": time.time(),
                "data": data
            }
            
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(cache_entry, f)
            
            self.logger.debug(f"Cache-Eintrag gespeichert: {key}")
            return True
            
        except Exception as e:
            self.logger.warning(f"Fehler beim Speichern des Cache-Eintrags {key}: {str(e)}")
            return False
    
    def invalidate(self, key: Optional[str] = None) -> bool:
        """
        Invalidiert einen oder alle Cache-Einträge.
        
        Args:
            key: Der zu invalidierende Cache-Schlüssel oder None für alle Einträge
            
        Returns:
            True bei Erfolg, sonst False
        """
        try:
            if key is None:
                # Alle Cache-Einträge löschen
                for cache_file in self.cache_path.glob("*.json"):
                    cache_file.unlink()
                self.logger.info("Gesamter Cache invalidiert")
            else:
                # Nur einen Eintrag löschen
                cache_file = self.cache_path / f"{self._hash_key(key)}.json"
                if cache_file.exists():
                    cache_file.unlink()
                    self.logger.debug(f"Cache-Eintrag invalidiert: {key}")
            
            return True
            
        except Exception as e:
            self.logger.warning(f"Fehler beim Invalidieren des Caches: {str(e)}")
            return False
    
    def _hash_key(self, key: str) -> str:
        """
        Erzeugt einen Hash-Wert für einen Cache-Schlüssel.
        
        Args:
            key: Der zu hashende Schlüssel
            
        Returns:
            Der Hash-Wert als Hexadezimalstring
        """
        return hashlib.md5(key.encode()).hexdigest()

class MCPServerIntegration:
    """Integration mit MCP-Servern für die Verteilung und Referenzierung von Artefakten."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert die MCP-Server-Integration.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.mcp")
        self.config = config
        
        # MCP-Konfiguration
        mcp_config = config.get("integration", {}).get("mcp_server", {})
        self.enabled = mcp_config.get("enabled", False)
        self.url = mcp_config.get("url", "http://localhost:3000")
        self.auth_token = mcp_config.get("auth_token", "")
        
        # Synchronisations-Konfiguration
        sync_config = mcp_config.get("synchronization", {})
        self.sync_interval = sync_config.get("interval", 300)  # 5 Minuten
        self.auto_sync = sync_config.get("auto_sync", True)
        self.resources = sync_config.get("resources", [])
        
        # Cache initialisieren
        cache_config = mcp_config.get("cache", {})
        if cache_config.get("enabled", True):
            cache_path = cache_config.get("path", "./.cache/mcp")
            cache_max_age = cache_config.get("max_age", 3600)
            self.cache = MCPResourceCache(cache_path, cache_max_age)
        else:
            self.cache = None
        
        # Verbindung überprüfen
        if self.enabled:
            self.available = self._check_server_availability()
            if self.available:
                self.logger.info(f"MCP-Server verfügbar: {self.url}")
                
                # Synchronisations-Thread starten
                if self.auto_sync:
                    self._start_sync_thread()
            else:
                self.logger.warning(f"MCP-Server ist nicht verfügbar: {self.url}")
        else:
            self.available = False
            self.logger.info("MCP-Server-Integration ist deaktiviert")
    
    def _check_server_availability(self) -> bool:
        """
        Überprüft, ob der MCP-Server verfügbar ist.
        
        Returns:
            True, wenn der Server verfügbar ist, sonst False
        """
        try:
            headers = self._get_headers()
            
            response = requests.get(f"{self.url}/api/health", headers=headers, timeout=5)
            return response.status_code == 200
            
        except Exception as e:
            self.logger.error(f"Fehler bei der Überprüfung der MCP-Server-Verfügbarkeit: {str(e)}")
            return False
    
    def _get_headers(self) -> Dict[str, str]:
        """
        Erstellt die HTTP-Header für MCP-API-Anfragen.
        
        Returns:
            Dictionary mit HTTP-Headern
        """
        headers = {
            "Content-Type": "application/json",
            "User-Agent": "ArtefaktCraft/2.0"
        }
        
        if self.auth_token:
            headers["Authorization"] = f"Bearer {self.auth_token}"
        
        return headers
    
    def _start_sync_thread(self):
        """Startet einen Thread für die periodische Synchronisation mit dem MCP-Server."""
        def sync_worker():
            while True:
                try:
                    self.logger.debug(f"Führe periodische Synchronisation mit MCP-Server durch...")
                    self.synchronize_resources()
                except Exception as e:
                    self.logger.error(f"Fehler bei der periodischen Synchronisation: {str(e)}")
                
                time.sleep(self.sync_interval)
        
        sync_thread = threading.Thread(target=sync_worker, daemon=True)
        sync_thread.start()
        self.logger.info(f"Synchronisations-Thread gestartet (Intervall: {self.sync_interval}s)")
    
    def notify_artefact_creation(self, artefakt_type: str, metadata: Dict[str, Any], file_path: str) -> bool:
        """
        Benachrichtigt den MCP-Server über die Erstellung eines neuen Artefakts.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            metadata: Die Metadaten des Artefakts
            file_path: Der Pfad zur Artefakt-Datei
            
        Returns:
            True, wenn die Benachrichtigung erfolgreich war, sonst False
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return False
        
        try:
            # Artefakt-Inhalt lesen
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Artefakt-Daten vorbereiten
            artefakt_data = {
                "type": artefakt_type,
                "metadata": metadata,
                "file_path": os.path.relpath(file_path, self.config["repository"]["base_path"]),
                "content": content,
                "repository": os.path.basename(self.config["repository"]["base_path"]),
                "created_at": time.time()
            }
            
            # Server benachrichtigen
            headers = self._get_headers()
            
            response = requests.post(
                f"{self.url}/api/artefacts",
                headers=headers,
                json=artefakt_data,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                self.logger.info(f"MCP-Server erfolgreich über Artefakt '{metadata.get('title', 'Untitled')}' benachrichtigt")
                
                # Cache invalidieren für Artefaktlisten
                if self.cache:
                    self.cache.invalidate("artefacts_list")
                
                return True
            else:
                self.logger.error(f"Fehler bei der Benachrichtigung des MCP-Servers: {response.status_code} {response.text}")
                return False
            
        except Exception as e:
            self.logger.error(f"Fehler bei der Benachrichtigung des MCP-Servers: {str(e)}")
            return False
    
    def get_artefacts(self, artefakt_type: Optional[str] = None, fach: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Holt eine Liste von Artefakten vom MCP-Server.
        
        Args:
            artefakt_type: Optional ein Filter für den Artefakt-Typ
            fach: Optional ein Filter für das Fach
            
        Returns:
            Liste von Artefakt-Daten oder leere Liste bei Fehler
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return []
        
        # Cache-Schlüssel generieren
        cache_key = f"artefacts_list_{artefakt_type or 'all'}_{fach or 'all'}"
        
        # Versuchen, aus dem Cache zu laden
        if self.cache:
            cached_data = self.cache.get(cache_key)
            if cached_data:
                return cached_data
        
        try:
            # Query-Parameter vorbereiten
            params = {}
            if artefakt_type:
                params["type"] = artefakt_type
            if fach:
                params["fach"] = fach
            
            # API-Anfrage
            headers = self._get_headers()
            
            response = requests.get(
                f"{self.url}/api/artefacts",
                headers=headers,
                params=params,
                timeout=10
            )
            
            if response.status_code == 200:
                artefacts = response.json()
                self.logger.info(f"{len(artefacts)} Artefakte vom MCP-Server geladen")
                
                # Im Cache speichern
                if self.cache:
                    self.cache.set(cache_key, artefacts)
                
                return artefacts
            else:
                self.logger.error(f"Fehler beim Laden der Artefakte: {response.status_code} {response.text}")
                return []
            
        except Exception as e:
            self.logger.error(f"Fehler beim Laden der Artefakte: {str(e)}")
            return []
    
    def get_lehrplan_resource(self, fach: str, jahrgangsstufe: Optional[str] = None) -> Dict[str, Any]:
        """
        Holt Lehrplan-Ressourcen vom MCP-Server.
        
        Args:
            fach: Das Fach (WiB, GPG, etc.)
            jahrgangsstufe: Optional die Jahrgangsstufe
            
        Returns:
            Lehrplan-Daten oder leeres Dictionary bei Fehler
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return {}
        
        # Cache-Schlüssel generieren
        cache_key = f"lehrplan_{fach}_{jahrgangsstufe or 'all'}"
        
        # Versuchen, aus dem Cache zu laden
        if self.cache:
            cached_data = self.cache.get(cache_key)
            if cached_data:
                return cached_data
        
        try:
            # Query-Parameter vorbereiten
            params = {"fach": fach}
            if jahrgangsstufe:
                params["jahrgangsstufe"] = jahrgangsstufe
            
            # API-Anfrage
            headers = self._get_headers()
            
            response = requests.get(
                f"{self.url}/api/resources/lehrplan",
                headers=headers,
                params=params,
                timeout=10
            )
            
            if response.status_code == 200:
                lehrplan_data = response.json()
                self.logger.info(f"Lehrplan-Daten für {fach} Jahrgangsstufe {jahrgangsstufe or 'alle'} geladen")
                
                # Im Cache speichern
                if self.cache:
                    self.cache.set(cache_key, lehrplan_data)
                
                return lehrplan_data
            else:
                self.logger.error(f"Fehler beim Laden der Lehrplan-Daten: {response.status_code} {response.text}")
                return {}
            
        except Exception as e:
            self.logger.error(f"Fehler beim Laden der Lehrplan-Daten: {str(e)}")
            return {}
    
    def get_kompetenzmodell(self, fach: str) -> Dict[str, Any]:
        """
        Holt das Kompetenzmodell für ein Fach vom MCP-Server.
        
        Args:
            fach: Das Fach (WiB, GPG, etc.)
            
        Returns:
            Kompetenzmodell-Daten oder leeres Dictionary bei Fehler
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return {}
        
        # Cache-Schlüssel generieren
        cache_key = f"kompetenzmodell_{fach}"
        
        # Versuchen, aus dem Cache zu laden
        if self.cache:
            cached_data = self.cache.get(cache_key)
            if cached_data:
                return cached_data
        
        try:
            # API-Anfrage
            headers = self._get_headers()
            
            response = requests.get(
                f"{self.url}/api/resources/kompetenzmodell/{fach}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                kompetenzmodell = response.json()
                self.logger.info(f"Kompetenzmodell für {fach} geladen")
                
                # Im Cache speichern
                if self.cache:
                    self.cache.set(cache_key, kompetenzmodell)
                
                return kompetenzmodell
            else:
                self.logger.error(f"Fehler beim Laden des Kompetenzmodells: {response.status_code} {response.text}")
                return {}
            
        except Exception as e:
            self.logger.error(f"Fehler beim Laden des Kompetenzmodells: {str(e)}")
            return {}
    
    def get_resource_content(self, resource_type: str, resource_path: str) -> Optional[str]:
        """
        Holt den Inhalt einer Ressource vom MCP-Server.
        
        Args:
            resource_type: Der Ressourcentyp (z.B. "templates", "lehrplan", etc.)
            resource_path: Der Pfad zur Ressource
            
        Returns:
            Der Inhalt der Ressource oder None bei Fehler
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return None
        
        # Cache-Schlüssel generieren
        cache_key = f"resource_{resource_type}_{resource_path}"
        
        # Versuchen, aus dem Cache zu laden
        if self.cache:
            cached_data = self.cache.get(cache_key)
            if cached_data and "content" in cached_data:
                return cached_data["content"]
        
        try:
            # API-Anfrage
            headers = self._get_headers()
            
            response = requests.get(
                f"{self.url}/api/resources/{resource_type}/{resource_path}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                content = response.text
                self.logger.info(f"Ressource {resource_type}/{resource_path} geladen")
                
                # Im Cache speichern
                if self.cache:
                    self.cache.set(cache_key, {"content": content})
                
                return content
            else:
                self.logger.error(f"Fehler beim Laden der Ressource: {response.status_code} {response.text}")
                return None
            
        except Exception as e:
            self.logger.error(f"Fehler beim Laden der Ressource: {str(e)}")
            return None
    
    def synchronize_resources(self) -> Dict[str, Any]:
        """
        Synchronisiert Ressourcen mit dem MCP-Server.
        
        Returns:
            Ein Dictionary mit Informationen über die Synchronisation
        """
        if not self.enabled or not self.available:
            self.logger.warning("MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar")
            return {"success": False, "message": "MCP-Server-Integration ist deaktiviert oder Server nicht verfügbar"}
        
        result = {
            "success": True,
            "synchronized_resources": [],
            "failed_resources": [],
            "timestamp": time.time()
        }
        
        try:
            # Für jede konfigurierte Ressource
            for resource in self.resources:
                resource_type = resource.get("type")
                source = resource.get("source")
                destination = resource.get("destination")
                
                if not all([resource_type, source, destination]):
                    self.logger.warning(f"Unvollständige Ressourcen-Konfiguration: {resource}")
                    result["failed_resources"].append({
                        "type": resource_type,
                        "source": source,
                        "destination": destination,
                        "error": "Unvollständige Konfiguration"
                    })
                    continue
                
                # Ressourcenliste vom Server holen
                try:
                    headers = self._get_headers()
                    
                    response = requests.get(
                        f"{self.url}/api/resources/{resource_type}",
                        headers=headers,
                        timeout=10
                    )
                    
                    if response.status_code != 200:
                        self.logger.error(f"Fehler beim Abrufen der Ressourcenliste: {response.status_code} {response.text}")
                        result["failed_resources"].append({
                            "type": resource_type,
                            "source": source,
                            "destination": destination,
                            "error": f"HTTP {response.status_code}: {response.text}"
                        })
                        continue
                    
                    resource_list = response.json()
                    
                    # Zielverzeichnis erstellen
                    os.makedirs(destination, exist_ok=True)
                    
                    # Ressourcen synchronisieren
                    for res_item in resource_list:
                        res_path = res_item.get("path")
                        if not res_path:
                            continue
                        
                        # Ressourceninhalt abrufen
                        content_response = requests.get(
                            f"{self.url}/api/resources/{resource_type}/{res_path}",
                            headers=headers,
                            timeout=10
                        )
                        
                        if content_response.status_code != 200:
                            self.logger.warning(f"Fehler beim Abrufen der Ressource {res_path}: {content_response.status_code}")
                            continue
                        
                        # Ressource speichern
                        target_path = os.path.join(destination, res_path)
                        target_dir = os.path.dirname(target_path)
                        os.makedirs(target_dir, exist_ok=True)
                        
                        with open(target_path, "wb") as f:
                            f.write(content_response.content)
                        
                        self.logger.debug(f"Ressource synchronisiert: {res_path} -> {target_path}")
                    
                    result["synchronized_resources"].append({
                        "type": resource_type,
                        "source": source,
                        "destination": destination,
                        "count": len(resource_list)
                    })
                    
                except Exception as e:
                    self.logger.error(f"Fehler bei der Synchronisation von {resource_type}: {str(e)}")
                    result["failed_resources"].append({
                        "type": resource_type,
                        "source": source,
                        "destination": destination,
                        "error": str(e)
                    })
            
            # Cache invalidieren
            if self.cache:
                self.cache.invalidate()
                self.logger.info("Cache nach Synchronisation invalidiert")
            
            self.logger.info(f"Ressourcensynchronisation abgeschlossen: {len(result['synchronized_resources'])} erfolgreich, {len(result['failed_resources'])} fehlgeschlagen")
            return result
            
        except Exception as e:
            self.logger.error(f"Fehler bei der Ressourcensynchronisation: {str(e)}")
            return {
                "success": False,
                "message": str(e),
                "timestamp": time.time()
            }
    
    def resolve_resource_link(self, resource_ref: str) -> Optional[Tuple[str, str]]:
        """
        Löst einen Ressourcenverweis in einen lokalen Pfad und Typ auf.
        
        Args:
            resource_ref: Der Ressourcenverweis (z.B. "lehrplan:WiB5_Ueberblick")
            
        Returns:
            Tuple aus Ressourcentyp und lokalem Pfad oder None bei Fehler
        """
        if not resource_ref or ":" not in resource_ref:
            return None
        
        try:
            # Ressourcenverweis parsen
            res_type, res_path = resource_ref.split(":", 1)
            
            # Passende Ressourcenkonfiguration finden
            for resource in self.resources:
                if resource.get("type") == res_type:
                    local_path = os.path.join(resource.get("destination", ""), res_path)
                    
                    # Prüfen, ob die Ressource existiert
                    if os.path.exists(local_path):
                        return (res_type, local_path)
                    
                    # Wenn nicht, versuchen, die Ressource zu synchronisieren
                    self.get_resource_content(res_type, res_path)
                    
                    if os.path.exists(local_path):
                        return (res_type, local_path)
            
            self.logger.warning(f"Ressourcenverweis konnte nicht aufgelöst werden: {resource_ref}")
            return None
            
        except Exception as e:
            self.logger.error(f"Fehler beim Auflösen des Ressourcenverweises {resource_ref}: {str(e)}")
            return None
    
    def get_linked_resources(self, content: str) -> List[Dict[str, Any]]:
        """
        Identifiziert und löst alle Ressourcenverweise in einem Inhalt auf.
        
        Args:
            content: Der Inhalt, in dem Ressourcenverweise gesucht werden sollen
            
        Returns:
            Liste von aufgelösten Ressourcenverweisen
        """
        import re
        
        # Regulärer Ausdruck für Ressourcenverweise: {{mcp:resource_type:path}}
        pattern = r"\{\{mcp:([a-zA-Z0-9_]+):([^}]+)\}\}"
        
        linked_resources = []
        
        for match in re.finditer(pattern, content):
            res_type = match.group(1)
            res_path = match.group(2)
            
            resource_ref = f"{res_type}:{res_path}"
            resolved = self.resolve_resource_link(resource_ref)
            
            if resolved:
                linked_resources.append({
                    "type": res_type,
                    "path": res_path,
                    "local_path": resolved[1],
                    "reference": match.group(0)
                })
        
        return linked_resources
    
    def process_resource_links(self, content: str) -> str:
        """
        Verarbeitet alle Ressourcenverweise in einem Inhalt.
        
        Args:
            content: Der Inhalt, in dem Ressourcenverweise verarbeitet werden sollen
            
        Returns:
            Der verarbeitete Inhalt mit aufgelösten Ressourcenverweisen
        """
        import re
        
        # Regulärer Ausdruck für Ressourcenverweise: {{mcp:resource_type:path}}
        pattern = r"\{\{mcp:([a-zA-Z0-9_]+):([^}]+)\}\}"
        
        def replace_resource_ref(match):
            res_type = match.group(1)
            res_path = match.group(2)
            
            resource_ref = f"{res_type}:{res_path}"
            resolved = self.resolve_resource_link(resource_ref)
            
            if resolved:
                res_type, local_path = resolved
                
                try:
                    # Ressourceninhalt lesen
                    with open(local_path, 'r', encoding='utf-8') as f:
                        resource_content = f.read()
                    
                    # Spezialbehandlung für verschiedene Ressourcentypen
                    if res_type == "lehrplan":
                        # Für Lehrplan: Nur notwendige Teile extrahieren
                        return self._extract_lehrplan_content(resource_content, res_path)
                    elif res_type == "kompetenzmodell":
                        # Für Kompetenzmodell: Relevante Teile als Tabelle formatieren
                        return self._format_kompetenzmodell_content(resource_content, res_path)
                    else:
                        # Standardmäßig Markdown-Inhalt zurückgeben
                        return resource_content
                
                except Exception as e:
                    self.logger.error(f"Fehler beim Lesen der Ressource {resource_ref}: {str(e)}")
                    return f"[Fehler beim Laden der Ressource {res_path}]"
            
            return f"[Ressource nicht gefunden: {res_type}:{res_path}]"
        
        # Alle Ressourcenverweise ersetzen
        processed_content = re.sub(pattern, replace_resource_ref, content)
        return processed_content
    
    def _extract_lehrplan_content(self, content: str, path: str) -> str:
        """
        Extrahiert relevante Teile aus Lehrplan-Inhalten.
        
        Args:
            content: Der Lehrplan-Inhalt
            path: Der Pfad der Ressource
            
        Returns:
            Formatierter Lehrplan-Auszug
        """
        # Je nach Pfad unterschiedliche Teile extrahieren
        if "Ueberblick" in path:
            # Für Überblicks-Dokumente: Lernbereiche-Tabelle extrahieren
            import re
            table_pattern = r"## Übersicht der Lernbereiche\s+\|(.*?)\|\s+\|[-\s|]+\|(.*?)$"
            table_match = re.search(table_pattern, content, re.DOTALL | re.MULTILINE)
            
            if table_match:
                return f"## Lernbereiche (Lehrplan)\n\n|{table_match.group(1)}|\n|---|---|---|---|\n{table_match.group(2)}"
            
        # Standardverhalten: Nur "Kompetenzerwartungen" Abschnitt
        import re
        kompetenz_pattern = r"### Kompetenzerwartungen\s+(.*?)(?=###|$)"
        kompetenz_match = re.search(kompetenz_pattern, content, re.DOTALL)
        
        if kompetenz_match:
            return f"### Kompetenzerwartungen (Lehrplan)\n\n{kompetenz_match.group(1).strip()}"
        
        # Fallback: Ersten Abschnitt verwenden
        sections = content.split("##")
        if len(sections) > 1:
            return f"## Lehrplan-Auszug\n\n{sections[1].strip()}"
        
        return content
    
    def _format_kompetenzmodell_content(self, content: str, path: str) -> str:
        """
        Formatiert Kompetenzmodell-Inhalte.
        
        Args:
            content: Der Kompetenzmodell-Inhalt
            path: Der Pfad der Ressource
            
        Returns:
            Formatierter Kompetenzmodell-Auszug
        """
        # Relevante Teile des Kompetenzmodells extrahieren
        import re
        
        # Gegenstandsbereiche extrahieren
        gb_pattern = r"### ([0-9.]+) ([A-Za-z]+)\s+(.*?)(?=###|$)"
        gb_matches = re.finditer(gb_pattern, content, re.DOTALL)
        
        result = "## Kompetenzmodell-Auszug\n\n"
        result += "| Gegenstandsbereich | Beschreibung | Prozessbezogene Kompetenzen |\n"
        result += "|-------------------|-------------|---------------------------|\n"
        
        for match in gb_matches:
            nummer = match.group(1)
            name = match.group(2)
            beschreibung = match.group(3).strip().split("\n")[0]  # Erste Zeile der Beschreibung
            
            # Kompetenzen für diesen Gegenstandsbereich suchen
            kompetenzen = []
            pk_pattern = r"#### Kompetenzen im Bereich " + re.escape(name) + r"\s+(.*?)(?=####|$)"
            pk_match = re.search(pk_pattern, content, re.DOTALL)
            if pk_match:
                # Kompetenzen aus Aufzählungen extrahieren
                komp_items = re.findall(r"- ([^\n]+)", pk_match.group(1))
                kompetenzen = ", ".join(komp_items)
            
            result += f"| {name} | {beschreibung} | {kompetenzen} |\n"
        
        return result
