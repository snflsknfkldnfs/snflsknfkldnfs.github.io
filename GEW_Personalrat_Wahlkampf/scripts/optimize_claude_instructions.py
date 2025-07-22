#!/usr/bin/env python3
"""
🧠 GEW Wahlkampf - Intelligente Claude Instructions Optimierung
Passt die Claude-Anweisungen dynamisch an den aktuellen Wahlkampf-Status an
"""

import json
import os
from datetime import datetime, timedelta
import re

class WahlkampfInstructionsOptimizer:
    def __init__(self):
        self.base_dir = "/Users/paulad/snflsknfkldnfs.github.io/GEW_Personalrat_Wahlkampf"
        self.config_file = f"{self.base_dir}/config/wahlkampf_config.json"
        self.instructions_file = f"{self.base_dir}/claude_desktop_instructions/GEW_Personalrat_Wahlkampf_Claude_Instructions.md"
        self.cache_dir = f"{self.base_dir}/.cache"
        
    def load_config(self):
        """Lade aktuelle Wahlkampf-Konfiguration"""
        try:
            with open(self.config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return self.create_default_config()
    
    def create_default_config(self):
        """Erstelle Standard-Konfiguration falls nicht vorhanden"""
        config = {
            "campaign": {
                "candidate": "Paul Alexander Cebulla",
                "position": "GEW Personalrat Unterfranken",
                "start_date": "2025-07-18",
                "election_date": "TBD",
                "phase": "Vorbereitung"
            },
            "targets": {
                "direct_supporters": 50,
                "multipliers": 15,
                "events_per_week": 1,
                "content_posts_per_week": 3
            },
            "current_status": {
                "supporters_count": 0,
                "events_completed": 0,
                "content_posts": 0,
                "network_contacts": 0
            },
            "focus_areas": [
                "Authentizitäts-Aufbau",
                "Netzwerk-Aktivierung", 
                "Content-Pipeline-Start",
                "System-Verständnis-Kommunikation"
            ]
        }
        
        os.makedirs(os.path.dirname(self.config_file), exist_ok=True)
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        return config
    
    def determine_campaign_phase(self, config):
        """Bestimme aktuelle Wahlkampf-Phase basierend auf Datum und Fortschritt"""
        start_date = datetime.fromisoformat(config["campaign"]["start_date"])
        days_since_start = (datetime.now() - start_date).days
        
        supporters = config.get("current_status", {}).get("supporters_count", 0)
        events = config.get("current_status", {}).get("events_completed", 0)
        
        if days_since_start < 14:
            return "Basis-Aufbau", "Fokus auf Authentizitäts-Etablierung und erste Netzwerk-Kontakte"
        elif days_since_start < 42:
            return "Differenzierung", "Schwerpunkt auf KI-Tool-Demos und systemische Lösungen"
        elif days_since_start < 70:
            return "Intensivierung", "Verstärkte Events und Testimonial-Sammlung"
        else:
            return "Endspurt", "Get-Out-The-Vote und finale Mobilisierung"
    
    def generate_dynamic_priorities(self, config, phase, phase_description):
        """Generiere phasen-spezifische Prioritäten"""
        priorities = {
            "Basis-Aufbau": [
                "Biografische Authentizität in jedem Gespräch betonen",
                "17 Jahre System-Rebellion als roten Faden verwenden",
                "Technologie-Souveränität vs Tech-Gläubigkeit differenzieren",
                "Milieu-übergreifende Vernetzung sichtbar machen"
            ],
            "Differenzierung": [
                "KI-Tool-Demonstrationen in den Vordergrund",
                "Brauchbare Illegalität als Kernkonzept etablieren",
                "Systemtheoretische Überlegenheit zeigen",
                "Cross-Generationen-Kommunikation praktizieren"
            ],
            "Intensivierung": [
                "Testimonials sammeln und strategisch einsetzen",
                "Größere Events organisieren und moderieren",
                "Opposition-Argumente proaktiv addressieren",
                "Konkrete Personalrat-Forderungen schärfen"
            ],
            "Endspurt": [
                "Direkte Wahlaufrufe mit persönlicher Note",
                "Letzte Authentizitäts-Beweise sammeln",
                "GOTV-Aktivitäten koordinieren",
                "Wahlkampf-Höhepunkt orchestrieren"
            ]
        }
        
        return priorities.get(phase, priorities["Basis-Aufbau"])
    
    def update_instructions(self):
        """Hauptfunktion: Aktualisiere Claude Instructions basierend auf aktuellem Status"""
        print("🧠 Analysiere aktuellen Wahlkampf-Status...")
        
        config = self.load_config()
        phase, phase_description = self.determine_campaign_phase(config)
        priorities = self.generate_dynamic_priorities(config, phase, phase_description)
        
        print(f"📊 Erkannte Phase: {phase}")
        print(f"📋 Prioritäten: {len(priorities)} dynamische Anweisungen")
        
        # Lade aktuelle Instructions
        try:
            with open(self.instructions_file, 'r', encoding='utf-8') as f:
                instructions = f.read()
        except FileNotFoundError:
            print(f"❌ Instructions-Datei nicht gefunden: {self.instructions_file}")
            return False
        
        # Update Timestamp
        current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
        instructions = re.sub(
            r'Auto-Update: [\d\-T:]*',
            f'Auto-Update: {current_time}',
            instructions
        )
        
        # Update Wahlkampf-Phase
        phase_section = f"""
🎯 **AKTUELLE WAHLKAMPF-PHASE**: {phase}
**Beschreibung**: {phase_description}
**Tage seit Start**: {(datetime.now() - datetime.fromisoformat(config["campaign"]["start_date"])).days}

**Dynamische Prioritäten für diese Phase:**
"""
        for i, priority in enumerate(priorities, 1):
            phase_section += f"{i}. {priority}\n"
        
        # Suche nach Wahlkampf-Phase Sektion und ersetze
        phase_pattern = r'🎯 \*\*AKTUELLE WAHLKAMPF-PHASE\*\*:.*?(?=\n�|\n\*\*|$)'
        if re.search(phase_pattern, instructions, re.DOTALL):
            instructions = re.sub(phase_pattern, phase_section.strip(), instructions, flags=re.DOTALL)
        else:
            # Füge nach Handlungslogik ein, falls Sektion nicht existiert
            handlungslogik_pattern = r'(🎯 HANDLUNGSLOGIK FÜR CLAUDE.*?(?=\n⚡|$))'
            if re.search(handlungslogik_pattern, instructions, re.DOTALL):
                instructions = re.sub(
                    handlungslogik_pattern,
                    r'\1\n\n' + phase_section,
                    instructions,
                    flags=re.DOTALL
                )
        
        # Update Status-Indikatoren
        status_updates = {
            "Unterstützer": config.get("current_status", {}).get("supporters_count", 0),
            "Events": config.get("current_status", {}).get("events_completed", 0),
            "Content": config.get("current_status", {}).get("content_posts", 0),
            "Netzwerk": config.get("current_status", {}).get("network_contacts", 0)
        }
        
        # Suche nach Status-Sektion und aktualisiere
        status_section = f"""
📊 **AKTUELLER WAHLKAMPF-STATUS** (Stand: {current_time})
- Direkte Unterstützer: {status_updates['Unterstützer']}/{config['targets']['direct_supporters']}
- Events durchgeführt: {status_updates['Events']} 
- Content Posts: {status_updates['Content']}
- Netzwerk-Kontakte: {status_updates['Netzwerk']}
- Wahlkampf-Phase: **{phase}**
"""
        
        # Füge Status-Sektion vor operative Richtlinien ein
        operative_pattern = r'(⚡ OPERATIVE RICHTLINIEN)'
        if re.search(operative_pattern, instructions):
            instructions = re.sub(
                operative_pattern,
                status_section + r'\n\1',
                instructions
            )
        
        # Speichere aktualisierte Instructions
        try:
            with open(self.instructions_file, 'w', encoding='utf-8') as f:
                f.write(instructions)
            print(f"✅ Claude Instructions erfolgreich aktualisiert")
            
            # Update config mit letzter Aktualisierung
            config["last_update"] = current_time
            config["campaign"]["phase"] = phase
            
            with open(self.config_file, 'w') as f:
                json.dump(config, f, indent=2)
            
            return True
            
        except Exception as e:
            print(f"❌ Fehler beim Speichern: {e}")
            return False
    
    def generate_status_report(self):
        """Generiere detaillierten Status-Report"""
        config = self.load_config()
        phase, phase_description = self.determine_campaign_phase(config)
        
        report = f"""
# 📊 WAHLKAMPF STATUS REPORT
**Generiert**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## 🎯 Aktuelle Phase
**{phase}**: {phase_description}

## 📈 Fortschritt
- Unterstützer: {config.get('current_status', {}).get('supporters_count', 0)}/{config['targets']['direct_supporters']} ({(config.get('current_status', {}).get('supporters_count', 0)/config['targets']['direct_supporters']*100):.1f}%)
- Events: {config.get('current_status', {}).get('events_completed', 0)}
- Content Posts: {config.get('current_status', {}).get('content_posts', 0)}

## 🔄 Nächste Optimierungen
- Claude Instructions: Phasen-spezifisch angepasst
- Strategische Prioritäten: {len(self.generate_dynamic_priorities(config, phase, phase_description))} Schwerpunkte
- Monitoring: Kontinuierliche Anpassung aktiv

## ⚡ Handlungsempfehlungen
1. Content-Pipeline für aktuelle Phase optimieren
2. Netzwerk-Aktivierung phasen-spezifisch anpassen  
3. Event-Formate an Wahlkampf-Status ausrichten
4. Authentizitäts-Botschaften kontinuierlich verstärken
"""
        
        # Speichere Report
        report_file = f"{self.base_dir}/reports/daily/{datetime.now().strftime('%Y-%m-%d')}_status_report.md"
        os.makedirs(os.path.dirname(report_file), exist_ok=True)
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"📄 Status-Report gespeichert: {report_file}")
        return report_file

def main():
    """Hauptfunktion für Command-Line Ausführung"""
    print("🚀 GEW Wahlkampf - Claude Instructions Optimizer")
    print("=" * 50)
    
    optimizer = WahlkampfInstructionsOptimizer()
    
    # Aktualisiere Instructions
    success = optimizer.update_instructions()
    
    if success:
        # Generiere Status-Report
        report_file = optimizer.generate_status_report()
        print(f"\n✅ Optimierung abgeschlossen!")
        print(f"📊 Status-Report: {report_file}")
        print(f"🧠 Claude Instructions bereit für aktuellen Wahlkampf-Status")
    else:
        print("\n❌ Optimierung fehlgeschlagen - siehe Fehler oben")

if __name__ == "__main__":
    main()