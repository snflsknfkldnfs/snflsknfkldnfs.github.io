#!/usr/bin/env python3
"""
🌐 GEW Wahlkampf - Intelligentes Netzwerk-Management
Trackt und optimiert systematisch das Wahlkampf-Netzwerk
"""

import json
import os
from datetime import datetime
from typing import Dict, List, Any

class WahlkampfNetzwerkManager:
    def __init__(self):
        self.base_dir = "/Users/paulad/snflsknfkldnfs.github.io/GEW_Personalrat_Wahlkampf"
        self.cache_dir = f"{self.base_dir}/.cache/network"
        self.contacts_file = f"{self.cache_dir}/network_status.json"
        
        # Anonyme Kontakt-Kategorien für DSGVO-Konformität
        self.network_segments = {
            "basketball_community": {
                "name": "Basketball-Community",
                "description": "Basketballabteilung + Sportnetzwerk",
                "potential": "Führungskompetenz-Testimonials",
                "target_activation": 25
            },
            "jmu_network": {
                "name": "JMU-Netzwerk", 
                "description": "Uni-Kontakte Bildungswissenschaft/Lehramt",
                "potential": "Akademische Glaubwürdigkeit + Peer-Gruppe",
                "target_activation": 20
            },
            "montessori_colleagues": {
                "name": "Montessori-Kollegium",
                "description": "Alternative Pädagogik-Erfahrung", 
                "potential": "Innovation + praktische Kompetenz",
                "target_activation": 15
            },
            "edtech_community": {
                "name": "EdTech-Community",
                "description": "Think Tank + Technologie-Expertise",
                "potential": "Zukunfts-Kompetenz demonstrieren", 
                "target_activation": 10
            },
            "gew_members": {
                "name": "GEW-Mitglieder",
                "description": "Direkte Wahlberechtigung",
                "potential": "Direkte Stimmen",
                "target_activation": 50
            },
            "mittelschul_teachers": {
                "name": "Mittelschul-Lehrkräfte",
                "description": "Hauptzielgruppe regional",
                "potential": "Authentizitäts-Basis",
                "target_activation": 30
            },
            "milieu_cross": {
                "name": "Milieu-übergreifend",
                "description": "Professor bis Obdachloser",
                "potential": "Gesellschaftliche Vernetzung beweisen",
                "target_activation": 8
            }
        }
    
    def initialize_network_tracking(self):
        """Initialisiere Netzwerk-Tracking-System"""
        print("🌐 Initialisiere Netzwerk-Management...")
        
        os.makedirs(self.cache_dir, exist_ok=True)
        
        network_status = {
            "last_update": datetime.now().isoformat(),
            "total_contacts": 0,
            "activated_supporters": 0,
            "segments": {}
        }
        
        # Initialisiere alle Segmente
        for segment_id, segment_info in self.network_segments.items():
            network_status["segments"][segment_id] = {
                "name": segment_info["name"],
                "description": segment_info["description"],
                "potential": segment_info["potential"],
                "target_activation": segment_info["target_activation"],
                "current_contacts": 0,
                "activated_count": 0,
                "last_contact": None,
                "engagement_level": "unbekannt",
                "notes": []
            }
        
        # Speichere initiale Struktur
        with open(self.contacts_file, 'w') as f:
            json.dump(network_status, f, indent=2)
        
        print(f"✅ Netzwerk-Tracking initialisiert: {self.contacts_file}")
        return network_status
    
    def load_network_status(self):
        """Lade aktuellen Netzwerk-Status"""
        try:
            with open(self.contacts_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return self.initialize_network_tracking()
    
    def update_segment_status(self, segment_id: str, contacts_count: int, activated_count: int, notes: str = ""):
        """Aktualisiere Status eines Netzwerk-Segments"""
        network_status = self.load_network_status()
        
        if segment_id not in network_status["segments"]:
            print(f"❌ Unbekanntes Segment: {segment_id}")
            return False
        
        segment = network_status["segments"][segment_id]
        segment["current_contacts"] = contacts_count
        segment["activated_count"] = activated_count
        segment["last_contact"] = datetime.now().isoformat()
        
        if notes:
            segment["notes"].append({
                "timestamp": datetime.now().isoformat(),
                "note": notes
            })
        
        # Berechne Engagement-Level
        if activated_count == 0:
            engagement = "nicht_aktiviert"
        elif activated_count / max(contacts_count, 1) < 0.3:
            engagement = "niedrig"
        elif activated_count / max(contacts_count, 1) < 0.7:
            engagement = "mittel"
        else:
            engagement = "hoch"
        
        segment["engagement_level"] = engagement
        
        # Aktualisiere Gesamtstatistiken
        network_status["total_contacts"] = sum(s["current_contacts"] for s in network_status["segments"].values())
        network_status["activated_supporters"] = sum(s["activated_count"] for s in network_status["segments"].values())
        network_status["last_update"] = datetime.now().isoformat()
        
        # Speichere Updates
        with open(self.contacts_file, 'w') as f:
            json.dump(network_status, f, indent=2)
        
        print(f"✅ Segment '{segment['name']}' aktualisiert: {activated_count}/{contacts_count} aktiviert")
        return True
    
    def generate_network_report(self):
        """Generiere detaillierten Netzwerk-Report"""
        network_status = self.load_network_status()
        
        report = f"""# 🌐 NETZWERK-STATUS REPORT
**Generiert**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## 📊 Gesamtübersicht
- **Gesamtkontakte**: {network_status['total_contacts']}
- **Aktivierte Unterstützer**: {network_status['activated_supporters']}
- **Aktivierungsrate**: {(network_status['activated_supporters']/max(network_status['total_contacts'], 1)*100):.1f}%

## 🎯 Segment-Analyse

"""
        
        for segment_id, segment in network_status["segments"].items():
            target = segment["target_activation"]
            current = segment["activated_count"]
            progress = (current / target * 100) if target > 0 else 0
            
            status_emoji = "🟢" if progress >= 80 else "🟡" if progress >= 50 else "🔴"
            
            report += f"""### {status_emoji} {segment['name']}
**Ziel**: {segment['potential']}
- Kontakte: {segment['current_contacts']} | Aktiviert: {current}/{target} ({progress:.1f}%)
- Engagement: {segment['engagement_level']}
- Letzter Kontakt: {segment.get('last_contact', 'Noch nicht')}

"""
        
        # Strategische Empfehlungen
        report += "\n## 🚀 Strategische Empfehlungen\n\n"
        
        # Finde Segmente mit niedrigster Aktivierung
        segments_by_progress = sorted(
            network_status["segments"].items(),
            key=lambda x: x[1]["activated_count"] / max(x[1]["target_activation"], 1)
        )
        
        for segment_id, segment in segments_by_progress[:3]:
            if segment["activated_count"] < segment["target_activation"] * 0.5:
                report += f"- **{segment['name']}**: Aktivierung verstärken - {segment['potential']}\n"
        
        # Identifiziere Erfolgs-Segmente
        successful_segments = [s for s in network_status["segments"].values() 
                             if s["activated_count"] / max(s["target_activation"], 1) >= 0.8]
        
        if successful_segments:
            report += f"\n### ✅ Erfolgreiche Segmente ({len(successful_segments)})\n"
            for segment in successful_segments:
                report += f"- **{segment['name']}**: Ansatz auf andere Segmente übertragen\n"
        
        # Speichere Report
        report_file = f"{self.base_dir}/reports/daily/{datetime.now().strftime('%Y-%m-%d')}_network_report.md"
        os.makedirs(os.path.dirname(report_file), exist_ok=True)
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"📄 Netzwerk-Report gespeichert: {report_file}")
        return report_file
    
    def get_activation_checklist(self):
        """Generiere Aktivierungs-Checkliste für heute"""
        network_status = self.load_network_status()
        
        checklist = f"""# 📋 NETZWERK-AKTIVIERUNG CHECKLISTE - {datetime.now().strftime('%Y-%m-%d')}

## 🎯 Prioritäre Segmente heute

"""
        
        # Sortiere Segmente nach Priorität (niedrigste Aktivierung zuerst)
        segments_by_priority = sorted(
            network_status["segments"].items(),
            key=lambda x: (
                x[1]["activated_count"] / max(x[1]["target_activation"], 1),  # Aktivierungsrate
                -x[1]["target_activation"]  # Bei Gleichstand: höhere Ziele priorisieren
            )
        )
        
        for i, (segment_id, segment) in enumerate(segments_by_priority[:3], 1):
            missing = segment["target_activation"] - segment["activated_count"]
            if missing > 0:
                checklist += f"""### {i}. {segment['name']} 
**Ziel heute**: {min(missing, 3)} neue Aktivierungen
**Ansatz**: {segment['potential']}
- [ ] Kontakt 1: ________________
- [ ] Kontakt 2: ________________  
- [ ] Kontakt 3: ________________

"""
        
        checklist += """## 💬 Aktivierungs-Script Template

**Persönlicher Einstieg**: "Hi [Name], ich kandidiere für GEW Personalrat..."
**Problem-Sharing**: "Kennst du das Problem mit..."
**Lösungs-Ansatz**: "Mein Konzept der brauchbaren Illegalität..."
**Authentizitäts-Beweis**: "17 Jahre System-Rebellion von iPhone-Jailbreaking bis..."
**Call to Action**: "Kann ich mit deiner Unterstützung rechnen?"

## 📊 Update am Abend
```
# Beispiel-Update:
python3 network_manager.py update basketball_community 12 8 "Gute Resonanz bei Vereinsmitgliedern"
```
"""
        
        # Speichere Checkliste
        checklist_file = f"{self.cache_dir}/{datetime.now().strftime('%Y-%m-%d')}_activation_checklist.md"
        
        with open(checklist_file, 'w', encoding='utf-8') as f:
            f.write(checklist)
        
        print(f"📋 Aktivierungs-Checkliste: {checklist_file}")
        return checklist_file
    
    def export_anonymous_stats(self):
        """Exportiere anonyme Statistiken für Dashboard"""
        network_status = self.load_network_status()
        
        stats = {
            "timestamp": datetime.now().isoformat(),
            "total_contacts": network_status["total_contacts"],
            "activated_supporters": network_status["activated_supporters"],
            "activation_rate": network_status["activated_supporters"] / max(network_status["total_contacts"], 1),
            "segments_status": {}
        }
        
        for segment_id, segment in network_status["segments"].items():
            stats["segments_status"][segment_id] = {
                "name": segment["name"],
                "progress": segment["activated_count"] / max(segment["target_activation"], 1),
                "engagement": segment["engagement_level"],
                "target_reached": segment["activated_count"] >= segment["target_activation"]
            }
        
        # Speichere für Dashboard-Integration
        stats_file = f"{self.base_dir}/reports/dashboard/network_stats.json"
        with open(stats_file, 'w') as f:
            json.dump(stats, f, indent=2)
        
        return stats

def main():
    """Command-Line Interface für Netzwerk-Management"""
    import sys
    
    manager = WahlkampfNetzwerkManager()
    
    if len(sys.argv) == 1:
        # Keine Argumente - zeige Status und generiere Checkliste
        print("🌐 GEW Wahlkampf - Netzwerk Manager")
        print("=" * 40)
        
        manager.generate_network_report()
        manager.get_activation_checklist()
        manager.export_anonymous_stats()
        
        print("\n✅ Alle Netzwerk-Analysen abgeschlossen!")
        
    elif len(sys.argv) >= 4 and sys.argv[1] == "update":
        # Update-Kommando: python3 network_manager.py update segment_id contacts activated [notes]
        segment_id = sys.argv[2]
        contacts = int(sys.argv[3])
        activated = int(sys.argv[4])
        notes = sys.argv[5] if len(sys.argv) > 5 else ""
        
        success = manager.update_segment_status(segment_id, contacts, activated, notes)
        if success:
            manager.export_anonymous_stats()
            print(f"✅ Segment '{segment_id}' erfolgreich aktualisiert")
        
    else:
        print("Verwendung:")
        print("  python3 network_manager.py                                    # Status & Checkliste")
        print("  python3 network_manager.py update SEGMENT KONTAKTE AKTIVIERT [NOTIZ]  # Update")
        print("\nVerfügbare Segmente:")
        for seg_id, seg_info in manager.network_segments.items():
            print(f"  {seg_id}: {seg_info['name']}")

if __name__ == "__main__":
    main()