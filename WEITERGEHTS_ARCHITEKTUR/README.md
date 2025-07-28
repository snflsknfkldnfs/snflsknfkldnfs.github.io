# weitergehts.io - Architektur-Dokumentation

**Version:** 1.0.0  
**Datum:** 2025-07-28  
**Status:** Architektur-Spezifikation für Entwicklung  

## Übersicht

Diese Dokumentation enthält alle architektonischen Entscheidungen und Spezifikationen für die Entwicklung von **weitergehts.io** - einem intelligenten, selbstlernenden Lehrerunterstützungssystem.

## Dokumentenstruktur

| Dokument | Beschreibung | Status |
|----------|--------------|--------|
| [01_Projektvision.md](01_Projektvision.md) | Grundlegende Vision und Ziele | ✅ Final |
| [02_Problemanalyse.md](02_Problemanalyse.md) | Analyse des bestehenden Systems | ✅ Final |
| [03_Systemarchitektur.md](03_Systemarchitektur.md) | 3+3 Ebenen-Architektur | ✅ Final |
| [04_PATA_Spezifikation.md](04_PATA_Spezifikation.md) | PATA-Ebenen-Details | ✅ Final |
| [05_Implementierungsanforderungen.md](05_Implementierungsanforderungen.md) | Technische Requirements | ✅ Final |
| [CHANGELOG.md](CHANGELOG.md) | Versionierung und Änderungen | ✅ Aktuell |

## Kern-Prinzipien

### Das Grundprinzip
**Lehrer beschreibt Situation → System erstellt Material → Lehrer probiert aus → System lernt → wird besser**

Das ist alles. Simpel und funktional.

### Architektur-Paradigma
**3+3 Ebenen-Struktur:**
- **3 Bildungsebenen:** Mikro (Stunde) → Meso (Sequenz) → Makro (Curriculum)
- **3 PATA-Ebenen:** Quality Gate → Learning Engine → System Monitor

### Zielgruppe
**Primär:** Unerfahrene Lehrpersonen  
**Sekundär:** Alle Lehrer, die Zeit sparen wollen

## Entwickler-Informationen

### Für die Implementierung kritisch:
1. **Einfachheit über Komplexität:** System muss für unerfahrene Lehrer nutzbar bleiben
2. **PATA-Ebenen unsichtbar:** User sieht nur einfache Konversation
3. **Token-Effizienz:** ~600 tokens PATA-Overhead pro Request
4. **Skalierbarkeit:** Von 1 auf 1.000.000 Nutzer

### Nicht implementieren:
- Komplexe Meta-Meta-Ebenen aus dem alten System
- Sichtbare technische Interfaces für Lehrer
- Überengineering-Features

## Nächste Schritte

1. **Entwickler liest alle Dokumente** in numerischer Reihenfolge
2. **Technische Implementierung** basierend auf Spezifikationen
3. **MVP-Entwicklung** mit Fokus auf Kern-Funktionalität
4. **Iterative Verbesserung** basierend auf PATA-System

---

**Wichtiger Hinweis:** Diese Architektur ist das Ergebnis einer gründlichen Analyse des bestehenden snflsknfkldnfs.github.io Systems und zielt auf radikale Vereinfachung bei Erhaltung der Kernqualitäten ab.