
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
DialogueEngine für ArtefaktCraft

Diese Klasse steuert den interaktiven Dialog zur Sammlung von Metadaten
für die Artefakterstellung, wahlweise mit Unterstützung durch ein KI-Modell
und mit Integration von MCP-Ressourcen für eine höhere Qualität.
"""

import os
import logging
import yaml
from typing import Dict, Any, List, Optional
from pathlib import Path
import importlib.util

class DialogueEngine:
    """Engine für die interaktive Dialogführung zur Artefakterstellung."""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialisiert die Dialogue-Engine.
        
        Args:
            config: Die Anwendungskonfiguration
        """
        self.logger = logging.getLogger("artefaktcraft.dialogue")
        self.config = config
        
        # Prüfen, ob OpenAI-Integration konfiguriert ist
        self.openai_enabled = "openai" in config and "api_key" in config["openai"]
        if self.openai_enabled:
            self._init_openai()
        else:
            self.logger.info("OpenAI-Integration ist deaktiviert oder nicht konfiguriert")
        
        # Dialog-Flows laden
        self.dialog_flows = {}
        self._load_dialog_flows()
        
        # MCP-Server-Integration referenzieren (wird später gesetzt)
        self.mcp_integration = None
        
        # Standard-Prompt-Vorlagen für Optimierung
        self.standard_prompts = {
            "lernziel": (
                "Formulieren Sie ein präzises Lernziel nach dem Mager-Schema mit den drei Komponenten: "
                "(1) Kompetenz: Was sollen die Schülerinnen und Schüler können? "
                "(2) Bedingungen: Unter welchen Umständen sollen sie es können? "
                "(3) Beurteilungsmaßstab: Woran erkennt man, dass sie es können? "
                "Artefakttyp: {artefakt_type}, Fach: {fach}, Jahrgangsstufe: {jahrgangsstufe}"
            ),
            "lehrplanbezug": (
                "Formulieren Sie einen präzisen und korrekten Lehrplanbezug für das Fach {fach} in Jahrgangsstufe {jahrgangsstufe} "
                "zum Thema '{title}'. Nennen Sie relevante Kompetenzerwartungen aus dem LehrplanPLUS."
            ),
            "methodenwahl": (
                "Empfehlen Sie aktivierende und kompetenzorientierte Methoden für einen Unterricht im Fach {fach} "
                "in Jahrgangsstufe {jahrgangsstufe} zum Thema '{title}', der auf folgendes Lernziel abzielt: {lernziel}"
            )
        }
    
    def set_mcp_integration(self, mcp_integration):
        """
        Setzt die MCP-Server-Integration.
        
        Args:
            mcp_integration: Die MCP-Server-Integration-Instanz
        """
        self.mcp_integration = mcp_integration
    
    def _init_openai(self):
        """Initialisiert die OpenAI-Integration, falls aktiviert."""
        try:
            import openai
            openai.api_key = self.config["openai"]["api_key"]
            self.openai_model = self.config["openai"].get("model", "gpt-4")
            self.openai_temp = self.config["openai"].get("temperature", 0.7)
            self.openai_max_tokens = self.config["openai"].get("max_tokens", 4000)
            self.logger.info(f"OpenAI-Integration initialisiert mit Modell {self.openai_model}")
        except ImportError:
            self.logger.warning("OpenAI-Modul konnte nicht importiert werden, KI-Integration deaktiviert")
            self.openai_enabled = False
        except Exception as e:
            self.logger.error(f"Fehler bei der Initialisierung der OpenAI-Integration: {str(e)}")
            self.openai_enabled = False
    
    def _load_dialog_flows(self):
        """Lädt alle verfügbaren Dialog-Flows aus den Konfigurationen."""
        base_dir = Path(self.config["repository"]["template_path"])
        
        # Für jeden Artefakt-Typ den Dialog-Flow laden
        for artefakt_type in self.config["artefakt_types"]:
            artefakt_id = artefakt_type["id"]
            dialog_flow_file = artefakt_type.get("dialog_flow")
            
            if dialog_flow_file:
                dialog_flow_path = base_dir / dialog_flow_file
                
                # Prüfen, ob die Datei existiert
                if dialog_flow_path.exists():
                    try:
                        with open(dialog_flow_path, 'r', encoding='utf-8') as file:
                            self.dialog_flows[artefakt_id] = yaml.safe_load(file)
                            self.logger.info(f"Dialog-Flow für Artefakt-Typ '{artefakt_id}' geladen")
                    except Exception as e:
                        self.logger.error(f"Fehler beim Laden des Dialog-Flows für '{artefakt_id}': {str(e)}")
                else:
                    self.logger.warning(f"Dialog-Flow-Datei für '{artefakt_id}' nicht gefunden: {dialog_flow_path}")
        
        self.logger.info(f"{len(self.dialog_flows)} Dialog-Flows geladen")
    
    def run_dialogue(self, artefakt_type: str) -> Dict[str, Any]:
        """
        Führt einen interaktiven Dialog zur Sammlung von Metadaten durch.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            
        Returns:
            Die gesammelten Metadaten
        """
        self.logger.info(f"Starte Dialog für Artefakt-Typ '{artefakt_type}'")
        
        # Artefakt-Typ-Konfiguration laden
        artefakt_type_config = None
        for at in self.config["artefakt_types"]:
            if at["id"] == artefakt_type:
                artefakt_type_config = at
                break
        
        if not artefakt_type_config:
            self.logger.error(f"Ungültiger Artefakt-Typ: {artefakt_type}")
            raise ValueError(f"Ungültiger Artefakt-Typ: {artefakt_type}")
        
        # Dialog-Flow verwenden, falls vorhanden
        if artefakt_type in self.dialog_flows:
            return self._run_flow_dialogue(artefakt_type, artefakt_type_config)
        
        # Fallback: Einfachen schemabasierten Dialog durchführen
        return self._run_schema_dialogue(artefakt_type_config)
    
    def _run_flow_dialogue(self, artefakt_type: str, artefakt_type_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Führt einen Dialog basierend auf einem vordefinierten Flow durch.
        
        Args:
            artefakt_type: ID des Artefakt-Typs
            artefakt_type_config: Konfiguration des Artefakt-Typs
            
        Returns:
            Die gesammelten Metadaten
        """
        flow = self.dialog_flows[artefakt_type]
        metadata = {}
        context = {
            "artefakt_type": artefakt_type,
            "artefakt_name": artefakt_type_config["name"]
        }
        
        print(f"\n=== Dialog zur Erstellung eines Artefakts vom Typ '{artefakt_type_config['name']}' ===\n")
        
        # Wenn der Flow eine Einleitung hat, diese anzeigen
        if "introduction" in flow:
            print(flow["introduction"].format(**context))
        
        # Die Schritte des Flows durchlaufen
        for step in flow["steps"]:
            step_id = step["id"]
            prompt = step["prompt"].format(**context)
            field_type = step.get("type", "string")
            
            # MCP-Daten für diesen Schritt laden, falls verfügbar und relevant
            mcp_data = self._load_mcp_data_for_step(step, context, metadata)
            
            # Falls OpenAI aktiviert ist und KI-unterstützte Vorschläge gewünscht sind
            ai_suggestion = None
            if self.openai_enabled and step.get("ai_assisted", False):
                ai_suggestion = self._get_ai_suggestion(step, context, metadata, mcp_data)
            
            # Eingabeaufforderung mit optionalem KI-Vorschlag
            value = self._prompt_for_input(prompt, field_type, ai_suggestion, step.get("options", []))
            
            # Wert speichern
            metadata[step_id] = value
            context[step_id] = value
            
            # Wenn der Schritt eine Nachbereitung hat, diese anzeigen
            if "post_process" in step:
                post_text = step["post_process"].format(**context, **metadata)
                print(post_text)
        
        # Wenn der Flow einen Abschluss hat, diesen anzeigen
        if "conclusion" in flow:
            print("\n" + flow["conclusion"].format(**context, **metadata))
        
        return metadata
    
    def _load_mcp_data_for_step(self, step: Dict[str, Any], context: Dict[str, Any], metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Lädt relevante MCP-Daten für einen Dialog-Schritt.
        
        Args:
            step: Definition des Dialog-Schritts
            context: Kontext des Dialogs
            metadata: Bisher gesammelte Metadaten
            
        Returns:
            MCP-Daten für diesen Schritt
        """
        if not self.mcp_integration:
            return {}
        
        step_id = step["id"]
        mcp_data = {}
        
        # Relevante MCP-Daten abhängig vom Step-ID und Kontext laden
        if step_id == "lernbereich" and "fach" in metadata and "jahrgangsstufe" in metadata:
            # Lehrplan-Daten für Lernbereich-Auswahl laden
            try:
                lehrplan = self.mcp_integration.get_lehrplan_resource(
                    metadata["fach"],
                    metadata["jahrgangsstufe"]
                )
                if lehrplan:
                    mcp_data["lehrplan"] = lehrplan
            except Exception as e:
                self.logger.warning(f"Fehler beim Laden der Lehrplan-Daten: {str(e)}")
        
        elif step_id in ["fach", "jahrgangsstufe"]:
            # Verfügbare Artefakte dieses Typs für Inspiration laden
            try:
                artefakte = self.mcp_integration.get_artefacts(context["artefakt_type"])
                if artefakte:
                    mcp_data["artefakte"] = artefakte
            except Exception as e:
                self.logger.warning(f"Fehler beim Laden der Artefakte: {str(e)}")
        
        return mcp_data
    
    def _run_schema_dialogue(self, artefakt_type_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Führt einen einfachen, schemabasierten Dialog durch.
        
        Args:
            artefakt_type_config: Konfiguration des Artefakt-Typs
            
        Returns:
            Die gesammelten Metadaten
        """
        schema = artefakt_type_config["metadata_schema"]
        metadata = {}
        
        print(f"\n=== Dialog zur Erstellung eines Artefakts vom Typ '{artefakt_type_config['name']}' ===\n")
        
        for field in schema:
            field_name = field["name"]
            prompt = field.get("prompt", f"Bitte geben Sie {field_name} ein")
            field_type = field.get("type", "string")
            required = field.get("required", False)
            options = field.get("options", [])
            
            # Falls das Feld optional ist und leer gelassen werden kann
            if not required:
                prompt += " (optional)"
            
            # MCP-Daten für dieses Feld laden, falls verfügbar und relevant
            mcp_data = {}
            if self.mcp_integration and field_name in ["lernbereich", "fach", "jahrgangsstufe"]:
                mcp_data = self._load_mcp_data_for_field(field_name, metadata)
            
            # AI-Vorschlag generieren, falls OpenAI aktiviert ist
            ai_suggestion = None
            if self.openai_enabled and field_name in self.standard_prompts:
                try:
                    # Prompt mit Metadaten formatieren
                    prompt_template = self.standard_prompts[field_name]
                    formatted_prompt = prompt_template.format(
                        artefakt_type=artefakt_type_config["name"],
                        **metadata,
                        **{k: v for k, v in metadata.items() if k in ["fach", "jahrgangsstufe", "title", "lernziel"]}
                    )
                    
                    # KI-Vorschlag generieren
                    ai_suggestion = self._get_ai_suggestion_with_prompt(
                        field_name,
                        formatted_prompt,
                        mcp_data
                    )
                except Exception as e:
                    self.logger.warning(f"Fehler beim Generieren des KI-Vorschlags für {field_name}: {str(e)}")
            
            # Eingabeaufforderung
            value = self._prompt_for_input(prompt, field_type, ai_suggestion, options)
            
            # Wenn das Feld erforderlich ist und leer gelassen wurde, erneut nachfragen
            while required and (value is None or (isinstance(value, str) and value.strip() == "")):
                print("Dieses Feld ist erforderlich.")
                value = self._prompt_for_input(prompt, field_type, ai_suggestion, options)
            
            # Wert speichern
            metadata[field_name] = value
        
        return metadata
    
    def _load_mcp_data_for_field(self, field_name: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Lädt relevante MCP-Daten für ein Metadaten-Feld.
        
        Args:
            field_name: Name des Felds
            metadata: Bisher gesammelte Metadaten
            
        Returns:
            MCP-Daten für dieses Feld
        """
        if not self.mcp_integration:
            return {}
        
        mcp_data = {}
        
        try:
            if field_name == "lernbereich" and "fach" in metadata and "jahrgangsstufe" in metadata:
                # Lehrplan-Daten für Lernbereich-Auswahl laden
                lehrplan = self.mcp_integration.get_lehrplan_resource(
                    metadata["fach"],
                    metadata["jahrgangsstufe"]
                )
                if lehrplan:
                    mcp_data["lehrplan"] = lehrplan
            
            elif field_name in ["fach", "jahrgangsstufe"]:
                # Verfügbare Fächer oder Jahrgangsstufen laden
                if hasattr(self.mcp_integration, "get_available_resources"):
                    resources = self.mcp_integration.get_available_resources(field_name)
                    if resources:
                        mcp_data["resources"] = resources
            
            # Kompetenzmodell laden, wenn relevant
            if "fach" in metadata and field_name in ["lernbereich", "lernziel"]:
                kompetenzmodell = self.mcp_integration.get_kompetenzmodell(metadata["fach"])
                if kompetenzmodell:
                    mcp_data["kompetenzmodell"] = kompetenzmodell
        
        except Exception as e:
            self.logger.warning(f"Fehler beim Laden der MCP-Daten für Feld {field_name}: {str(e)}")
        
        return mcp_data
    
    def _get_ai_suggestion(self, step: Dict[str, Any], context: Dict[str, Any], metadata: Dict[str, Any], mcp_data: Dict[str, Any] = None) -> Optional[str]:
        """
        Ruft einen KI-generierten Vorschlag für einen Dialog-Schritt ab.
        
        Args:
            step: Definition des Dialog-Schritts
            context: Kontext des Dialogs
            metadata: Bisher gesammelte Metadaten
            mcp_data: Optionale MCP-Daten für eine bessere KI-Unterstützung
            
        Returns:
            Ein KI-generierter Vorschlag oder None bei Fehlern
        """
        if not self.openai_enabled:
            return None
        
        try:
            import openai
            
            # Promptvorlage aus dem Schritt laden
            ai_prompt_template = step.get("ai_prompt", "Basierend auf dem bisherigen Kontext ({context}), generiere einen Vorschlag für {field_description}.")
            
            # Lehrplan- und Kompetenzmodell-Informationen hinzufügen, falls verfügbar
            lehrplan_info = ""
            kompetenzmodell_info = ""
            
            if mcp_data:
                if "lehrplan" in mcp_data:
                    lehrplan = mcp_data["lehrplan"]
                    lehrplan_info = f"Lehrplan: {json.dumps(lehrplan, ensure_ascii=False)}"
                
                if "kompetenzmodell" in mcp_data:
                    kompetenzmodell = mcp_data["kompetenzmodell"]
                    kompetenzmodell_info = f"Kompetenzmodell: {json.dumps(kompetenzmodell, ensure_ascii=False)}"
                
                if "artefakte" in mcp_data:
                    artefakte = mcp_data["artefakte"]
                    artefakte_info = f"Ähnliche Artefakte als Inspiration: {json.dumps([a.get('metadata', {}) for a in artefakte[:3]], ensure_ascii=False)}"
            
            # Prompt mit Kontext und Metadaten formatieren
            prompt = ai_prompt_template.format(
                context=str(context),
                metadata=str(metadata),
                field_description=step.get("description", step["prompt"]),
                lehrplan_info=lehrplan_info,
                kompetenzmodell_info=kompetenzmodell_info
            )
            
            # OpenAI-Anfrage senden
            response = openai.ChatCompletion.create(
                model=self.openai_model,
                messages=[
                    {"role": "system", "content": "Du bist ein Assistent für die Erstellung pädagogischer Artefakte. Basierend auf dem gegebenen Kontext, generiere konkrete, hilfreiche Vorschläge, die den Qualitätsstandards für Unterrichtsplanung entsprechen."},
                    {"role": "user", "content": prompt}
                ],
                temperature=self.openai_temp,
                max_tokens=self.openai_max_tokens
            )
            
            # Antwort extrahieren und zurückgeben
            suggestion = response.choices[0].message.content.strip()
            self.logger.debug(f"KI-Vorschlag generiert für Schritt '{step['id']}': {suggestion[:50]}...")
            return suggestion
            
        except Exception as e:
            self.logger.error(f"Fehler beim Generieren des KI-Vorschlags: {str(e)}")
            return None
    
    def _get_ai_suggestion_with_prompt(self, field_name: str, prompt: str, mcp_data: Dict[str, Any] = None) -> Optional[str]:
        """
        Generiert einen KI-Vorschlag mit einem spezifischen Prompt.
        
        Args:
            field_name: Name des Felds
            prompt: Der zu verwendende Prompt
            mcp_data: Optionale MCP-Daten für eine bessere KI-Unterstützung
            
        Returns:
            Ein KI-generierter Vorschlag oder None bei Fehlern
        """
        if not self.openai_enabled:
            return None
        
        try:
            import openai
            import json
            
            # Lehrplan- und Kompetenzmodell-Informationen hinzufügen, falls verfügbar
            additional_context = ""
            
            if mcp_data:
                if "lehrplan" in mcp_data:
                    lehrplan = mcp_data["lehrplan"]
                    additional_context += f"\nLehrplaninformationen:\n{json.dumps(lehrplan, ensure_ascii=False, indent=2)}"
                
                if "kompetenzmodell" in mcp_data:
                    kompetenzmodell = mcp_data["kompetenzmodell"]
                    additional_context += f"\nKompetenzmodell:\n{json.dumps(kompetenzmodell, ensure_ascii=False, indent=2)}"
            
            # Vollständigen Prompt erstellen
            full_prompt = f"{prompt}\n\n{additional_context}"
            
            # OpenAI-Anfrage senden
            response = openai.ChatCompletion.create(
                model=self.openai_model,
                messages=[
                    {"role": "system", "content": "Du bist ein pädagogischer Assistent für Lehrkräfte, spezialisiert auf didaktisch hochwertige Unterrichtsplanung gemäß LehrplanPLUS. Deine Vorschläge sind präzise, fachlich korrekt und kompetenzorientiert."},
                    {"role": "user", "content": full_prompt}
                ],
                temperature=self.openai_temp,
                max_tokens=self.openai_max_tokens
            )
            
            # Antwort extrahieren und zurückgeben
            suggestion = response.choices[0].message.content.strip()
            self.logger.debug(f"KI-Vorschlag generiert für Feld '{field_name}': {suggestion[:50]}...")
            return suggestion
            
        except Exception as e:
            self.logger.error(f"Fehler beim Generieren des KI-Vorschlags für {field_name}: {str(e)}")
            return None
    
    def _prompt_for_input(self, prompt: str, field_type: str, ai_suggestion: Optional[str] = None, 
                          options: List[str] = None) -> Any:
        """
        Fordert den Benutzer zur Eingabe auf und verarbeitet diese entsprechend dem Feldtyp.
        
        Args:
            prompt: Eingabeaufforderung
            field_type: Typ des Feldes (string, number, boolean, enum)
            ai_suggestion: Optional ein KI-generierter Vorschlag
            options: Optionen für Enum-Felder
            
        Returns:
            Der eingegebene und konvertierte Wert
        """
        # Bei Enum-Typen die Optionen anzeigen
        if field_type == "enum" and options:
            option_text = ", ".join([f"{i+1}: {option}" for i, option in enumerate(options)])
            prompt = f"{prompt} [{option_text}]"
        
        # Wenn es einen KI-Vorschlag gibt, diesen anzeigen
        if ai_suggestion:
            # Bei langen Vorschlägen den Text kürzen und nur die ersten Zeilen anzeigen
            if len(ai_suggestion) > 200:
                lines = ai_suggestion.split("\n")
                if len(lines) > 3:
                    shortened_suggestion = "\n".join(lines[:3]) + "..."
                else:
                    shortened_suggestion = ai_suggestion[:200] + "..."
                
                prompt = f"{prompt}\n[KI-Vorschlag: {shortened_suggestion}]"
                print("Ein umfangreicher KI-Vorschlag ist verfügbar. Drücken Sie Enter ohne Eingabe, um ihn zu verwenden.")
            else:
                prompt = f"{prompt}\n[KI-Vorschlag: {ai_suggestion}]"
        
        # Eingabeaufforderung anzeigen und Eingabe einlesen
        while True:
            try:
                if field_type == "boolean":
                    user_input = input(f"{prompt} [j/n]: ").strip().lower()
                    if user_input in ["j", "ja", "y", "yes", "true", "1"]:
                        return True
                    elif user_input in ["n", "nein", "no", "false", "0"]:
                        return False
                    elif user_input == "":
                        return None
                    else:
                        print("Bitte geben Sie 'j' für ja oder 'n' für nein ein.")
                        continue
                
                elif field_type == "enum" and options:
                    user_input = input(f"{prompt}: ").strip()
                    if user_input == "":
                        return None
                    
                    # Prüfen, ob die Eingabe eine Zahl ist
                    try:
                        option_index = int(user_input) - 1
                        if 0 <= option_index < len(options):
                            return options[option_index]
                        else:
                            print(f"Bitte geben Sie eine Zahl zwischen 1 und {len(options)} ein.")
                            continue
                    except ValueError:
                        # Prüfen, ob die Eingabe direkt eine der Optionen ist
                        if user_input in options:
                            return user_input
                        else:
                            print(f"Ungültige Eingabe. Bitte wählen Sie eine der Optionen: {', '.join(options)}")
                            continue
                
                elif field_type == "number":
                    user_input = input(f"{prompt}: ").strip()
                    if user_input == "":
                        return None
                    
                    try:
                        # Prüfen, ob es sich um eine Ganzzahl oder Fließkommazahl handelt
                        if "." in user_input:
                            return float(user_input)
                        else:
                            return int(user_input)
                    except ValueError:
                        print("Bitte geben Sie eine gültige Zahl ein.")
                        continue
                
                else:  # string ist der Standardtyp
                    user_input = input(f"{prompt}: ").strip()
                    if user_input == "" and ai_suggestion:
                        # Bei leerer Eingabe den KI-Vorschlag verwenden, falls vorhanden
                        print(f"KI-Vorschlag übernommen.")
                        return ai_suggestion
                    return user_input
                
            except KeyboardInterrupt:
                print("\nEingabe abgebrochen.")
                return None
            except EOFError:
                print("\nEingabe abgebrochen.")
                return None
