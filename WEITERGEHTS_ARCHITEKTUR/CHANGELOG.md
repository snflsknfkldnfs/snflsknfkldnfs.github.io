# CHANGELOG - weitergehts.io Architektur

Alle wichtigen Änderungen und Entscheidungen in der Architektur-Entwicklung.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/).

## [1.0.0] - 2025-07-28

### Hinzugefügt - Initial Architecture
- **Projektvision** definiert: Einfaches, konversationsbasiertes Lehrerunterstützungssystem
- **3+3 Ebenen-Architektur** spezifiziert:
  - Bildungsebenen: Mikro (Stunde) → Meso (Sequenz) → Makro (Curriculum)  
  - PATA-Ebenen: Quality Gate → Learning Engine → System Monitor
- **PATA-System-Spezifikation** für systemweite Qualität und Lernen
- **Implementierungsanforderungen** für Entwicklungsteam
- **Token-Effizienz-Strategie** (~600 tokens PATA-Overhead)

### Entscheidungen

#### Architektur-Paradigma
- **ENTSCHEIDUNG:** 3+3 Ebenen-Struktur statt unendlicher Meta-Verschachtelung
- **BEGRÜNDUNG:** Balance zwischen pädagogischer Vollständigkeit und technischer Effizienz
- **ALTERNATIVE VERWORFEN:** Komplexe Meta-Meta-Ebenen des bestehenden Systems

#### PATA-System-Design
- **ENTSCHEIDUNG:** PATA-Ebenen vollständig unsichtbar für User
- **BEGRÜNDUNG:** Einfachheit für unerfahrene Lehrer priorisiert
- **IMPLEMENTATION:** Hintergrund-Services ohne User-Interface

#### Zielgruppe-Fokus
- **ENTSCHEIDUNG:** Primär unerfahrene Lehrer, sekundär alle Lehrer
- **BEGRÜNDUNG:** Analyse zeigte Marktlücke bei Berufseinsteigern
- **KONSEQUENZ:** Einfachheit über Feature-Reichtum priorisiert

#### Technologie-Stack
- **ENTSCHEIDUNG:** Standard Web-Technologien statt experimenteller Tools
- **BEGRÜNDUNG:** Wartbarkeit und Skalierbarkeit über Innovation
- **ALTERNATIVE VERWORFEN:** MCP-Server-Abhängigkeiten des Altsystems

### Analysiert - Bestehendes System

#### Stärken identifiziert
- Systemtheoretische Luhmann-Basis → **BEIBEHALTEN**
- PATA-Standards-Konzept → **VEREINFACHT ÜBERNOMMEN**  
- Qualitätssicherungs-Mechanismen → **AUTOMATISIERT**
- Reflexions-Engineering-Ansatz → **STREAMLINED INTEGRIERT**

#### Probleme identifiziert
- Überengineering für Zielgruppe → **RADIKALE VEREINFACHUNG**
- Hohe technische Einstiegshürden → **ELIMINIERT**
- Komplexe Repository-Struktur → **NICHT ÜBERNOMMEN**
- MCP-Server-Abhängigkeiten → **ERSETZT DURCH STANDARD-APIS**

### Verworfene Konzepte

#### Aus bestehendem System nicht übernommen
- **Meta-Meta-Prozess-Ebenen:** Zu komplex für praktische Nutzung
- **MCP-Server-Integration:** Wartungsintensiv und schwer skalierbar
- **Git-basierte User-Workflows:** Zu technisch für Zielgruppe
- **Jekyll-Website-Generation:** Overengineering für Anforderungen

#### Vereinfachte Alternativen implementiert
- **Statt komplexer Meta-Ebenen:** 3 klare PATA-Layer
- **Statt MCP-Server:** Standard RESTful APIs
- **Statt Git-Workflows:** Einfache Conversation-UI
- **Statt Jekyll:** Standard Web-Framework

## Entwickler-Notizen

### Kritische Designentscheidungen
1. **Token-Budget-Management:** Strikte 4600 Token-Grenze pro Request
2. **Asynchrone PATA-2/3-Verarbeitung:** Blockiert nicht User-Experience
3. **Anonymisierte Cross-Instance-Learning:** Privacy-First-Ansatz
4. **Quality-Gate-Validierung:** Synchron und blockierend für Qualitätssicherung

### Implementierungs-Prioritäten
1. **MVP:** Mikro-Ebene + PATA-1 + Basis-Conversation-UI
2. **Phase 2:** Meso/Makro-Ebenen + vollständige PATA-Integration  
3. **Phase 3:** Advanced Features + Sophisticated Personalization

### Zu überwachende Metriken
- **Quality Consistency:** >90% über alle Instanzen
- **Learning Progress:** Messbar alle 100 Interaktionen
- **System Stability:** Keine manuellen Interventionen nötig
- **User Satisfaction:** Tracked via Feedback-Ratings

---

**Architektur-Status:** Final für Entwicklungsbeginn  
**Nächster Meilenstein:** MVP-Implementierung  
**Review-Datum:** Nach MVP-Testing