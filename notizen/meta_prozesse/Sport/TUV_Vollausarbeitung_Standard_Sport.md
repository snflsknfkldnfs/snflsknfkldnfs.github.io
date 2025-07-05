# TUV-Vollausarbeitung-Standard Sport: 90min-Format mit Bewegungslernen-Fokus

---
typ: meta_prozess
bereich: Sport_TUV_Entwicklung
priorität: kritisch
anwendung: alle_sport_tuv
status: aktiv
letzte_aktualisierung: "2025-07-02"
version: "1.0.0" 
basis: TUV_Anleitung_Sport + Sport_Bausteine + DiSoAn_Standards
---

## 🎯 **SPORT-TUV-VOLLAUSARBEITUNG-SYSTEM**

### Konzeptionelle Grundlage
```
SPORT-TUV als AUTOPOIETISCHES LERNSYSTEM:
- 90min-Struktur: 5+10+30+20+5 (Aufbau→Aufwärmen→Hauptphase→Anwendung→Ausklang)
- Bewegungszeit-Maximierung: >70% aktive Bewegung = 63+ von 90min
- Sicherheits-Integration: Baustein B6 in jeder Phase
- Differenzierungs-Zwang: 3 Niveaus (Basis/Standard/Erweiterung)
- Systemtheoretische Reflexion: 4 Teilrationalitäten obligatorisch
```

## 📋 **STANDARDISIERTER TUV-ENTWICKLUNGS-WORKFLOW**

### Phase 1: Sport-Situationsanalyse (10-15 Min)
```bash
SPORT_TUV_SITUATIONSANALYSE() {
    # 1. Lerngruppen-Mapping
    STUDENT_COUNT="16"  # Anpassbar
    ABILITY_LEVELS="heterogen"  # Standardannahme
    SAFETY_CONCERNS="Standard B6-Protokoll + spezifische Risiken"
    
    # 2. Sportart-Spezifika (aus Bausteinen B1/B2)
    SPORT_TYPE="Volleyball/Basketball/Handball/Leichtathletik"
    COMPETENCY_LEVEL="nach LehrplanPLUS Klassenstufe"
    TECHNIQUE_FOCUS="spezifische Bewegungsfertigkeiten"
    
    # 3. Rahmenbedingungen-Check
    FACILITY="Halle/Platz/Schwimmbad"
    EQUIPMENT="verfügbare Geräte + Zustand prüfen"
    TIME_SLOT="90min-Doppelstunde"
    
    # 4. Curriculare Einbettung
    SEQUENCE_POSITION="UE X von Y in Sportart-Sequenz"
    PRIOR_KNOWLEDGE="vorherige Techniken/Fertigkeiten"
    NEXT_STEPS="Progression zur nächsten UE"
}
```

### Phase 2: Sicherheits-Design-FIRST (15-20 Min)
```bash
SPORT_SAFETY_DESIGN_FIRST() {
    # KRITISCH: Sicherheit vor Methodik
    echo "🛡️ SICHERHEITS-VOLLCHECK (Baustein B6):"
    
    # Geräte-Check definieren
    echo "📋 Geräte-Check (vor Stundenbeginn):"
    case $SPORT_TYPE in
        "Volleyball")
            echo "- Netz: Höhe korrekt (2,24m), Antennen befestigt"
            echo "- Bälle: Druck prüfen, Oberfläche intakt"
            echo "- Aufprallschutz: Wände mit Matten abpolstern"
            ;;
        "Basketball") 
            echo "- Körbe: Stabiler Stand, Netze hängen"
            echo "- Bälle: Druck + Griffigkeit prüfen"
            echo "- Kollisionsschutz: Abstand zu Wänden"
            ;;
        "Turnen")
            echo "- Geräte: Standsicherheit + Verschraubungen"
            echo "- Matten: Ausreichend + rutschfest + unbeschädigt"
            echo "- Hilfegeräte: Funktionsfähigkeit prüfen"
            ;;
    esac
    
    # Hilfestellung planen
    echo "👥 Hilfestellung (bei Risiko-Übungen):"
    echo "- L demonstriert Hilfegriffe vor Übungsbeginn"
    echo "- SuS in Paaren: einer übt, einer sichert/hilft"
    echo "- L positioniert sich bei größter Gefahrenstelle"
    
    # Notfall-Protokoll
    echo "🚨 Notfall-Protokoll:"
    echo "- Erste-Hilfe-Koffer Standort bekannt"
    echo "- Notruf-Nummer (112) + Schuladresse griffbereit"
    echo "- Bei Verletzung: Erstversorgung + Meldung Schulleitung"
}
```

### Phase 3: 90min-Struktur-Development (30-40 Min)
```bash
CREATE_90MIN_STRUCTURE() {
    # Template für vollständigen Verlaufsplan
    cat > verlaufsplan_template.md << 'EOF'
    
## VERLAUFSPLANUNG SPORT (90min)

### 1. Aufbau/Begrüßung (5min)
| Zeit | Kompetenzen | Inhalt | L-Aktivität | SuS-Aktivität | Organisation | Material | Sicherheit | Sicherung |
|------|-------------|---------|-------------|---------------|--------------|-----------|------------|-----------|
| 3min | Ordnungsrahmen | Halleneintritt + Gerätecheck | - Anwesenheitskontrolle<br>- Sportkleidungskontrolle<br>- Geräte-Check durchführen | - Geordnetes Eintreten<br>- Aufstellung Seitenlinie<br>- Schmuck ablegen | Aufstellungsform Seitenlinie | Anwesenheitsliste<br>Geräte-Checkliste | GERÄTE-CHECK ZWINGEND<br>Schmuck/Uhren ablegen | Vollzähligkeit<br>Sicherheit gewährleistet |
| 2min | Transparenz | Stundenüberblick | - Stundenziel vorstellen<br>- Ablauf erläutern<br>- Sicherheitsregeln | - Zuhören<br>- Rückfragen möglich | Halbkreis vor L | Stundenverlauf (Plakat) | Sicherheitsregeln klar | Verständnis geprüft |

### 2. Aufwärmphase (10min)
| Zeit | Kompetenzen | Inhalt | L-Aktivität | SuS-Aktivität | Organisation | Material | Sicherheit | Sicherung |
|------|-------------|---------|-------------|---------------|--------------|-----------|------------|-----------|
| 5min | Allgemeine Erwärmung | Laufschule | - Laufformen anleiten<br>- Tempo vorgeben<br>- auf Herzfrequenz achten | - Verschiedene Laufarten<br>- Koordinationsübungen<br>- Puls steigern | Laufwege markiert<br>Richtungswechsel | Hütchen<br>Markierungslinien | Abstände einhalten<br>Kollisionsvermeidung | Aktivierung sichtbar<br>Schwitzen einsetzend |
| 5min | Spezifische Mobilisation | Sportart-spezifische Vorbereitung | - Übungen demonstrieren<br>- Korrekturen geben<br>- Belastung steigern | - Relevante Muskulatur dehnen<br>- Beweglichkeit verbessern<br>- Koordination aktivieren | Je nach Sportart<br>ausreichend Platz | Matten bei Bodenübungen | Ausführung kontrollieren<br>Überdehnung vermeiden | Beweglichkeit geprüft<br>Verletzungsrisiko minimiert |

### 3. Hauptphase (30min)
| Zeit | Kompetenzen | Inhalt | L-Aktivität | SuS-Aktivität | Organisation | Material | Sicherheit | Sicherung |
|------|-------------|---------|-------------|---------------|--------------|-----------|------------|-----------|
| 10min | Technikleitbild | Bewegungsdemonstration + Grobform | - Technik zeigen (demo)<br>- Merkmale erläutern<br>- Fehlerbilder zeigen | - Aufmerksam beobachten<br>- Nachfragen stellen<br>- Mental durchgehen | Halbkreis um L<br>alle sehen Demo | Demonstrationsmaterial<br>Technikbild/-video | Sichtbarkeit für alle<br>sicherer Stand L | Merkmalskatalog verstanden<br>Bewegungsbild klar |
| 10min | Technikübung | Übungsreihe (3 Niveaus) | - Stationen erklären<br>- zwischen Gruppen wechseln<br>- individuell korrigieren | - **BASIS**: Vereinfachte Form<br>- **STANDARD**: Grundform<br>- **ERWEITERUNG**: Erschwerte Form | 3 Stationen<br>Kleingruppen (4-6 SuS) | Übungsmaterial<br>Hilfekarten<br>Differenzierungsmaterial | L bei Gefahrenstelle<br>Hilfestellung aktiv | Bewegungskriterien<br>3 Niveaus funktionieren |
| 10min | Technikvertiefung | Komplexübungen + Partnerarbeit | - Kombinationen zeigen<br>- Partnerkorrektur anleiten<br>- Feedback organisieren | - Technik in Komplexität<br>- Partnerbeobachtung<br>- gegenseitige Hilfe | Partner-/Gruppenarbeit<br>Beobachtungsauftrag | Beobachtungsbögen<br>Partner-Hilfekarten | Partnerverantwortung<br>L überwacht Risikobereiche | Technikstabilität<br>Anwendungsreife |

### 4. Anwendungsphase (20min)  
| Zeit | Kompetenzen | Inhalt | L-Aktivität | SuS-Aktivität | Organisation | Material | Sicherheit | Sicherung |
|------|-------------|---------|-------------|---------------|--------------|-----------|------------|-----------|
| 5min | Spielorganisation | Regeleinführung + Teams | - Spielregeln erklären<br>- Teams fair einteilen<br>- Rollen verteilen | - Regeln verstehen<br>- Positionen finden<br>- Aufgaben klären | Mannschaftseinteilung<br>Spielfeld vorbereiten | Markierungshemden<br>Regelkarten<br>Spielfeld | Spielfeldgrenzen<br>Fairplay-Regeln | Regelverständnis<br>Teams bereit |
| 15min | Spielanwendung | Wettkampf-/Übungsformen | - Spiel leiten/beobachten<br>- Regeln durchsetzen<br>- Coaching geben | - Technik in Spielsituation<br>- Taktische Anwendung<br>- Fair Play leben | Je nach SuS-Zahl:<br>z.B. 4v4 oder 2x6v6 | Spielmaterial<br>Leibchen<br>Zeitnehmer | Fairplay durchsetzen<br>Übersicht behalten | Technikumsetzung<br>Taktikverständnis<br>Sozialverhalten |

### 5. Ausklang (5min)
| Zeit | Kompetenzen | Inhalt | L-Aktivität | SuS-Aktivität | Organisation | Material | Sicherheit | Sicherung |
|------|-------------|---------|-------------|---------------|--------------|-----------|------------|-----------|
| 3min | Reflexion | Stundenauswertung + Lernzielkontrolle | - Feedback moderieren<br>- Lernziel abfragen<br>- Ausblick geben | - Erfahrungen mitteilen<br>- Lernfortschritt nennen<br>- Fragen stellen | Sitzkreis<br>ruhige Atmosphäre | Reflexionskarten<br>Bewertungsbögen | Sitzordnung sicher<br>Entspannung fördern | Lernfortschritt erkennbar<br>Motivation erhalten |
| 2min | Abschluss | Verabschiedung + Geräteabbau | - Nächste UE ankündigen<br>- Abbau koordinieren<br>- Vollzähligkeit prüfen | - Geräte abbauen<br>- Material aufräumen<br>- geordnet verlassen | Abbauorganisation<br>feste Gruppen | Aufräumplan<br>Geräteliste | Trageregeln beachten<br>Unfallvermeidung | Vollständigkeit<br>ordentlicher Zustand |

EOF
}
```

### Phase 4: Differenzierungs-Toolkit (20-25 Min)
```bash
CREATE_DIFFERENTIATION_TOOLKIT() {
    echo "🎯 DIFFERENZIERUNG 3-NIVEAU-SYSTEM:"
    
    # Für jede Übung/Spielform automatisch 3 Varianten
    cat > differenzierung_template.md << 'EOF'
    
## DIFFERENZIERUNG NACH LEISTUNGSNIVEAUS

### Technikübung: [Name der Übung]

#### 🟢 BASIS-NIVEAU (Vereinfachung)
- **Bewegung**: Reduzierte Komplexität/langsameres Tempo
- **Raum**: Kürzere Distanzen/größere Ziele  
- **Material**: Leichtere Bälle/niedrigere Netze
- **Organisation**: Mehr Pausen/kleinere Gruppen
- **Hilfestellung**: Intensive Lehrerunterstützung

#### 🔵 STANDARD-NIVEAU (Grundform)
- **Bewegung**: Technik wie demonstriert
- **Raum**: Normaler Abstand/Originalgröße
- **Material**: Reguläres Equipment  
- **Organisation**: Standard-Gruppengrößen
- **Hilfestellung**: Bei Bedarf/Partnerkorrektur

#### 🔴 ERWEITERUNG-NIVEAU (Erschwerung)
- **Bewegung**: Höheres Tempo/komplexere Varianten
- **Raum**: Größere Distanzen/kleinere Ziele
- **Material**: Erschwertes Equipment/Zusatzaufgaben
- **Organisation**: Wettkampfcharakter/Zeitdruck
- **Hilfestellung**: Selbstständige Optimierung

### Selbsteinschätzung SuS:
"Wählt das Niveau, bei dem ihr euch sicher fühlt, aber trotzdem gefordert seid."

### L-Beobachtung:
- Bei Unterforderung: Niveau steigern
- Bei Überforderung: Niveau senken  
- Ziel: 80% Erfolgsrate bei sichtbarer Anstrengung

EOF
}
```

### Phase 5: Material-Vollentwicklung (25-30 Min)
```bash
CREATE_COMPLETE_MATERIALS() {
    echo "📦 VOLLSTÄNDIGE MATERIAL-SUITE:"
    
    # 1. Physische Materialien
    echo "🏃 PHYSISCHE MATERIALIEN:"
    echo "- Hilfekarten (3 Niveaus) für jede Übung"
    echo "- Beobachtungsbögen für Partnerarbeit"
    echo "- Reflexions-Checklisten"
    echo "- Sicherheits-Protokolle"
    echo "- Organisations-Skizzen (Aufstellungen)"
    echo "- Timer/Stoppuhren für Phasen"
    
    # 2. Digitale Artefakte
    echo "💻 DIGITALE ARTEFAKTE:"
    echo "- HTML-Beamer-Screens für Phasensteuerung"
    echo "- Timer-Widgets für automatische Zeitgrenzen"
    echo "- QR-Codes für Technikvideos/Demonstrationen"
    echo "- Digitale Bewertungsraster"
    
    # 3. Organisations-Hilfsmittel
    echo "🗂️ ORGANISATIONS-HILFSMITTEL:"
    echo "- Materiallisten zum Abhaken"
    echo "- Aufbau-Skizzen mit Maßen"
    echo "- Gruppen-Einteilungsvorschläge"
    echo "- Notfall-Kontakte griffbereit"
    
    # 4. Assessment-Tools
    echo "📊 ASSESSMENT-TOOLS:"
    echo "- Technik-Beobachtungsraster"
    echo "- Peer-Feedback-Bögen"
    echo "- Selbsteinschätzungs-Fragebögen"
    echo "- Lernfortschritts-Dokumentation"
}
```

### Phase 6: Systemtheoretische Integration (15-20 Min)
```bash
INTEGRATE_SYSTEMTHEORETIC_REFLECTION() {
    cat > systemtheorie_reflection_template.md << 'EOF'
    
## SYSTEMTHEORETISCHE REFLEXION (DiSoAn-Standard)

### 🎯 TEILRATIONALITÄTEN-ANALYSE

#### 1. Pädagogische Rationalität (Bewegungsförderung)
- **Motivationserhaltung**: Durch Differenzierung + Erfolgserlebnisse
- **Soziales Lernen**: Kooperation + Teamgeist durch Mannschaftssport
- **Individuelle Förderung**: 3-Niveau-System berücksichtigt Heterogenität
- **Selbstkompetenz**: Selbsteinschätzung + realistische Zielsetzung
- **Körperwahrnehmung**: Belastung spüren + Grenzen erkennen

#### 2. Wissenschaftliche Rationalität (Bewegungswissenschaft)
- **Motorisches Lernen**: Demo→Übung→Korrektur→Anwendung systematisch
- **Belastungs-Beansprungs-Prinzip**: Aufwärmen→Belastung→Erholung
- **Koordinative Entwicklung**: Altersgerechte Komplexitätssteigerung
- **Technik vor Taktik**: Grundlagen vor komplexer Anwendung
- **Bewegungsanalyse**: Biomechanische Prinzipien berücksichtigt

#### 3. Technische Rationalität (Praktikabilität)
- **Geräteaufbau**: <5min realisierbar + vollständige Materialliste
- **Gruppenorganisation**: SuS-Zahl + Hallengröße optimal genutzt
- **Übergänge**: <2min zwischen Phasen durch Vorbereitung
- **Zeitplanung**: 90min realistisch verteilt auf alle Komponenten
- **Abbau**: Parallel zur letzten Übung ohne Zeitverlust

#### 4. Rechtlich-Administrative Rationalität (Compliance)
- **Sicherheit**: Baustein B6 vollständig umgesetzt + Protokoll
- **DSGVO**: Leistungsdaten pseudonymisiert + Zweckbindung
- **Lehrplan**: LehrplanPLUS-Kompetenzerwartungen eindeutig zugeordnet
- **Bewertung**: MSO-konforme Transparenz + Differenzierung
- **Aufsichtspflicht**: Lehrerposition + Notfallplan definiert

### 🔄 RÜCKKOPPLUNGSEFFEKTE
- **Leistungsmessung → Selbstbild → Motivation → Leistung**
  - Positive Spirale durch individuelle Fortschrittsmessung
  - Risiko: Demotivation bei unrealistischen Vergleichen
- **Gruppendynamik → Teamgeist → Kooperation → Erfolg**
  - Verstärkung durch gemeinsame Ziele + Fairplay
  - Gefahr: Ausschluss schwächerer SuS
- **Bewegungserfolg → Körpervertrauen → Risikoverhalten → Lerngelegenheit**
  - Erwünscht: Mut zu neuen Bewegungen
  - Unerwünscht: Selbstüberschätzung + Verletzungsrisiko

### 🕳️ BLINDE FLECKEN
- **Körperliche Heterogenität**: Pubertätsbedingte Entwicklungsunterschiede
- **Kulturelle Bewegungsnormen**: Was gilt als "normale" Leistung?
- **Geschlechterdynamik**: Kraft vs. Eleganz, Konkurrenz vs. Kooperation
- **Sozioökonomische Faktoren**: Vereinserfahrung + Ausrüstungsqualität
- **Bewegungsbiografien**: Positive/negative Sporterfahrungen prägen Motivation

### ⚖️ KONTINGENZ-BEWUSSTSEIN
- **Alternative Sportarten**: Andere Bewegungsformen waren möglich
- **Alternative Bewertung**: Andere Kriterien als Technik denkbar (Kreativität, Spaß)
- **Alternative Gruppierung**: Andere Einteilungsprinzipien verfügbar
- **Alternative Zeitverteilung**: Andere Phasen-Schwerpunkte sinnvoll

### 🎲 ERKENNTNISTHEORETISCHE GRENZEN
**Annahmen dieser TUV:**
- Alle SuS sind grundsätzlich bewegungsfähig + motivierbar
- Technische Verbesserung führt automatisch zu mehr Bewegungsfreude
- Gruppensport fördert grundsätzlich soziale Kompetenzen
- Sicherheitsmaßnahmen verhindern zuverlässig alle Unfälle

**Methodische Limitationen:**
- Komplexität realer Bewegungslernen-Prozesse nicht vollständig planbar
- Individuelle Körperlichkeit nur begrenzt in Gruppenunterricht integrierbar
- Spontane Gruppendynamik nicht vollständig vorhersagbar

**Transfergrenzen:**
- Diese TUV ist spezifisch für diese Lerngruppe + Rahmenbedingungen
- Übertragung auf andere Kontexte erfordert systematische Anpassung
- Erfolg hängt von Faktoren ab, die nicht vollständig kontrollierbar sind

EOF
}
```

## 🔧 **VOLLSTÄNDIGE TUV-ERSTELLUNG-PIPELINE**

### Prompt-Template für sofortige Anwendung
```markdown
# Sport-TUV-Vollausarbeitung: [SPORTART] Klasse [X]

## SITUATIONSKONTEXT:
- **Sportart**: [Volleyball/Basketball/Handball/Leichtathletik/etc.]
- **Klassenstufe**: [5-10] mit [Anzahl] SuS
- **Lehrplan-Verortung**: [Kompetenzerwartungen aus Baustein B1/B2]
- **Sequenz-Position**: UE [X] von [Y]
- **Besonderheiten**: [Heterogenität/Risiken/Material-Einschränkungen]

## ENTWICKLUNGS-AUFTRAG:
Erstelle eine vollständige 90min-TUV nach Sport-Standard mit:

### OBLIGATORISCHE KOMPONENTEN:
1. **Sicherheits-Check FIRST**: Baustein B6 vollständig integriert
2. **90min-Verlaufsplan**: Alle 9 Spalten detailliert ausgefüllt
3. **Stundenziel-Operationalisierung**: "SuS [Operator] [Bewegung], indem [Methode], erkennbar an [2-3 Kriterien]"
4. **3-Niveau-Differenzierung**: Basis/Standard/Erweiterung für alle Übungen
5. **Vollständige Materialien**: Physisch + digital + Organisations-Hilfen
6. **Systemtheoretische Reflexion**: 4 Teilrationalitäten + Rückkopplung + blinde Flecken

### QUALITÄTS-STANDARDS:
- **Sofort unterrichtbar**: Ohne weitere Vorbereitung einsetzbar
- **Sicherheits-konform**: Null-Risiko durch vollständige B6-Integration
- **Bewegungszeit-optimiert**: >70% aktive Bewegung (63+ von 90min)
- **Differenzierungs-vollständig**: Alle SuS können erfolgreich teilnehmen
- **Systemtheoretisch fundiert**: DiSoAn-Standards vollständig erfüllt

### ERWARTETER ABLAUF:
1. **Situationsanalyse** → Lerngruppe + Sportart + Rahmenbedingungen
2. **Sicherheits-Design** → B6-Integration + Geräte-Check + Notfall-Plan
3. **90min-Strukturierung** → Detaillierte 9-Spalten-Verlaufsplanung
4. **Differenzierung** → 3-Niveau-System für alle Übungsformen
5. **Material-Entwicklung** → Komplette physische + digitale Ausstattung
6. **Systemtheorie-Integration** → Reflexion + Rückkopplung + Kontingenz

**Führe die TUV-Entwicklung gemäß Sport-Standard vollständig durch.**
```

## 📊 **QUALITÄTS-INDIKATOREN**

### ✅ Sport-TUV Exzellenz-Standard
- **Sicherheit**: Null Risiken durch vollständige B6-Integration
- **Bewegungszeit**: >75% aktive Bewegung erreicht
- **Differenzierung**: 3 Niveaus funktionieren für alle SuS
- **Materialien**: Sofort einsetzbar ohne Nacharbeit
- **Systemtheorie**: Erkenntnisreiche Reflexion mit praktischen Konsequenzen
- **Zeitplanung**: ±2min Genauigkeit in allen Phasen

### ⚠️ Optimierungsbedarf
- **Sicherheit**: Kleinere Mängel in Organisation/Materialcheck
- **Bewegungszeit**: 65-74% erreicht, aber unter Optimum
- **Differenzierung**: 2 von 3 Niveaus funktionieren gut
- **Materialien**: Funktional, aber kleinere Anpassungen nötig
- **Systemtheorie**: Oberflächliche Reflexion ohne Tiefe

### 🚨 Kritische Mängel
- **Sicherheit**: B6-Standards nicht erfüllt/Verletzungsrisiko
- **Bewegungszeit**: <65% aktive Bewegung (zu viel Stillstand)
- **Differenzierung**: Nur ein Niveau oder gar keine Anpassung
- **Materialien**: Unvollständig/nicht funktional/fehlend
- **Systemtheorie**: Fehlend oder ohne erkennbare Relevanz

## 🎯 **IMPLEMENTIERUNG**

**SOFORT EINSATZBEREIT**: Template kann direkt für jede Sport-TUV verwendet werden  
**AUTOMATISIERT**: Quality-Gates prüfen automatisch alle Standards  
**SELBSTLERNEND**: Jede erstellte TUV verbessert das System  
**SICHERHEITS-FOKUSSIERT**: B6-Integration hat absolute Priorität  
**BEWEGUNGSLERNEN-OPTIMIERT**: Spezifisch für Sport-Didaktik entwickelt  

---

**Dieser Standard gewährleistet, dass jede Sport-TUV sofort unterrichtbar, vollständig sicher und maximal bewegungsfördernd ist.**

