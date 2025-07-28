# 01 - Projektvision weitergehts.io

**Version:** 1.0.0  
**Datum:** 2025-07-28  
**Autor:** Architektur-Team  

## Das Problem

Unerfahrene Lehrer verbringen zu viel Zeit mit Unterrichtsvorbereitung und wissen oft nicht, was in ihrer konkreten Situation funktioniert.

## Die Lösung

Ein KI-System, das mit Lehrern normal redet, ihre Situation versteht und passende Unterrichtsmaterialien erstellt. Das System lernt kontinuierlich aus den Erfahrungen der Lehrer.

## Wie es funktioniert

### Der Grundzyklus
1. **Lehrer beschreibt Situation:** "Hab morgen 7. Klasse Mathe, Bruchrechnung, die Hälfte versteht nichts"
2. **System fragt nach:** "Welche Brüche hattet ihr schon? Was für Materialien hast du?"
3. **System erstellt Material:** Arbeitsblätter, Ablaufplan, Tafelbilder - sofort verwendbar
4. **Lehrer setzt um:** Unterricht mit den erstellten Materialien
5. **Feedback:** "Wie war's? Was hat funktioniert?"
6. **System lernt:** Wird beim nächsten Mal besser angepasst sein

## Drei Ebenen des Kontexts

Das System versteht und berücksichtigt:

### Mikro-Ebene: Einzelne Stunde
- Zeitrahmen: "heute/morgen"
- Scope: Eine 45-Minuten-Unterrichtsstunde
- Output: Sofort verwendbare Materialien
- Context-Tokens: ~2000

### Meso-Ebene: Unterrichtssequenz  
- Zeitrahmen: "nächste Wochen"
- Scope: Zusammenhängende Lerneinheiten (4-8 Stunden)
- Output: Strukturierte Lernreihe
- Context-Tokens: ~4000

### Makro-Ebene: Curriculum-Orientierung
- Zeitrahmen: "Schuljahr/Fach"
- Scope: Lehrplan-Einordnung und Jahresplanung
- Output: Curriculare Verortung
- Context-Tokens: ~1000

## Was das System können muss

### Kommunikation
- Natürliche Gespräche führen (Text und Audio)
- Sinnvolle Nachfragen stellen bei Unklarheiten
- Impulse geben, nicht nur reagieren
- Kontext aus vorherigen Gesprächen verstehen

### Kontextverständnis
- Fächer, Jahrgangsstufen, Schultypen einordnen
- Schülerbedürfnisse und -hintergründe berücksichtigen
- Lehrplan-Anforderungen integrieren
- Verfügbare Ressourcen einbeziehen

### Materialgenerierung
- Arbeitsblätter und Aufgabenstellungen
- Strukturierte Unterrichtsverläufe mit Timing
- Tafelbilder und Präsentationen
- Differenzierungsmaterialien für verschiedene Leistungsniveaus
- Bewertungsraster und Evaluationshilfen

### Lernen und Adaptation
- Feedback verarbeiten und daraus lernen
- Muster erkennen (was funktioniert bei welchen Lehrern/Situationen?)
- Präferenzen speichern und anwenden
- Qualität der Vorschläge kontinuierlich verbessern

## Der Lernprozess

### Erste Begegnungen (Zyklus 1-5)
- System lernt Grundlagen über Lehrer und Unterrichtskontext
- Standardmaterialien mit ersten individuellen Anpassungen
- Aufbau von Vertrauen und Verständnis für das System

### Anpassungsphase (Zyklus 5-20)
- System erkennt Muster in Präferenzen und Lehrstil
- Materialien werden zunehmend individueller und passender
- Feedback wird spezifischer und zielführender

### Expertenmodus (Zyklus 20+)
- Hochindividualisierte, präzise passende Materialien
- Proaktive Vorschläge basierend auf erkannten Mustern
- System fungiert als persönlicher, erfahrener Lehr-Assistent

## Grenzen und Risiken

### Was das System nicht tut
- Lehrer ersetzen oder bevormunden
- Pädagogische Entscheidungen abnehmen
- Beziehung zu Schülern ersetzen
- Automatisch "perfekte" Lösungen garantieren

### Mögliche Probleme
- **Abhängigkeit:** System soll unterstützen, nicht abhängig machen
- **Qualitätskontrolle:** Materialien müssen pädagogisch sinnvoll sein
- **Datenschutz:** Sensitive Informationen müssen geschützt bleiben
- **Fehlinterpretationen:** System kann Kontext missverstehen

## Das Ergebnis

Ein System, das wie ein erfahrener, immer verfügbarer Kollege funktioniert: versteht die Situation, macht konkrete Vorschläge, lernt aus Erfahrungen und wird mit der Zeit immer hilfreicher.

**Kern-Prinzip:** Beschreiben → Material → Ausprobieren → Feedback → Besser werden

---

**Kritische Designentscheidung:** Das System muss für unerfahrene Lehrer sofort nutzbar sein, ohne technische Vorkenntnisse oder komplexe Einarbeitung.