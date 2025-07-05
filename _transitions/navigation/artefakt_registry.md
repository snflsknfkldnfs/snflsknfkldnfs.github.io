# Repository Artefakt-Registry - Automatische Navigation

---
typ: navigation_system
funktion: Automatische Erkennung + Kategorisierung + Verfügbarkeit
status: aktiv
self_updating: true
letzte_aktualisierung: "2025-07-04"
---

## 📁 **REPOSITORY-STRUKTUR-MAPPING**

### Haupt-Kategorien mit automatischer Erkennung:
```yaml
UNTERRICHTS_ARTEFAKTE:
  pfad_pattern: "/unterricht/**/*.md"
  kategorien:
    - sequenzplanungen: "*sequenz*.md"
    - buv_ausarbeitungen: "BUV_*.md"
    - tuv_entwicklungen: "TUV_*.md" 
    - jahresplanungen: "*jahresplan*.md"
    - material_sammlungen: "Material/**/*"

FACH_SPEZIFISCHE_BEREICHE:
  sport: "/unterricht/Sport/**/*"
  gpg: "/unterricht/GPG*/**/*"
  mathematik: "/unterricht/M*/**/*"
  wib: "/unterricht/WiB*/**/*"
  englisch: "/unterricht/E*/**/*"

STANDARDS_UND_QUALITÄT:
  disoAn: "/notizen/DiSoAn/**/*"
  buv_standards: "/notizen/**/BUV_*"
  classroom_management: "/notizen/classroom*/**/*"
  lehrplan_bezug: "**/*lehrplan*"

TEMPLATES_UND_HILFSMITTEL:
  html_templates: "/templates/**/*.html"
  arbeitsblatt_templates: "/templates/*arbeitsblatt*"
  transition_templates: "/_transitions/**/*"
  
META_PROZESSE:
  chat_transitions: "**/chat_transitions/**/*"
  selbstlernende_systeme: "/notizen/meta_prozesse/**/*"
  pata_standards: "**/*PATA*"
```

## 🎯 **KONTEXTUELLE VERFÜGBARKEITS-MATRIX**

### Automatische Ressourcen-Aktivierung je Anforderung:
```yaml
SPORT_ANFRAGE:
  priorität_1: ["/unterricht/Sport/", "**/*sicherheit*", "**/*B6*"]
  priorität_2: ["**/BUV_*Sport*", "/notizen/bewegungslernen/"]
  priorität_3: ["/notizen/DiSoAn/", "/templates/sport*"]
  
GPG_ANFRAGE:
  priorität_1: ["/unterricht/GPG*/", "**/*schulbuch*", "**/*heterogen*"]
  priorität_2: ["/templates/*.html", "/notizen/*DaZ*"]
  priorität_3: ["/notizen/DiSoAn/", "**/*fachintegration*"]

BUV_ENTWICKLUNG:
  priorität_1: ["/unterricht/*/BUV_*", "/notizen/BUV_Standards/"]
  priorität_2: ["/unterricht/3. BUV/", "/notizen/DiSoAn/"]
  priorität_3: ["/seminarcloud/", "**/*seminarleiter*"]

SEQUENZ_PLANUNG:
  priorität_1: ["**/*sequenz*", "**/*jahresplan*", "**/*lehrplan*"]
  priorität_2: ["/notizen/didaktik/", "/templates/"]
  priorität_3: ["/notizen/DiSoAn/", "**/*progression*"]
```

## 🔍 **AUTOMATISCHER RESSOURCEN-SCANNER**

### JavaScript-Logic für Repository-Durchsuchung:
```javascript
class RepositoryArtefaktScanner {
    constructor(anforderung) {
        this.anforderung = anforderung;
        this.gefundeneArtefakte = new Map();
        this.relevanzScores = new Map();
    }
    
    async scanForRelevantArtefakte() {
        // 1. Kategorie-basierter Scan
        const kategorien = this.getRelevantCategories();
        
        // 2. Pattern-Matching für Artefakte
        for (let kategorie of kategorien) {
            const artefakte = await this.scanPattern(kategorie.pattern);
            this.kategorisiereArtefakte(artefakte, kategorie.priorität);
        }
        
        // 3. Kontext-Relevanz-Bewertung
        this.bewerteRelevanz();
        
        // 4. Navigation-Index erstellen
        return this.generiereNavigationIndex();
    }
    
    generiereNavigationIndex() {
        return {
            sofort_verfügbar: this.gefundeneArtefakte.get('priorität_1'),
            unterstützend: this.gefundeneArtefakte.get('priorität_2'),
            meta_ebene: this.gefundeneArtefakte.get('priorität_3'),
            vollständiger_kontext: this.getAllContextPaths()
        };
    }
}
```

## 📊 **QUALITÄTS-EBENEN-BEWUSSTSEIN**

### Automatische Multi-Level-Verfügbarkeit:
```yaml
EBENE_1_DIREKT:
  beschreibung: "Spezifische Projekt-Artefakte"
  auto_scan: "aktueller_projekt_pfad/**/*"
  verfügbarkeit: "sofort_sichtbar"

EBENE_2_DOMAIN:
  beschreibung: "Fachbereich-spezifische Ressourcen"
  auto_scan: "fachbereich_pattern/**/*"
  verfügbarkeit: "prioritär_geladen"

EBENE_3_STANDARDS:
  beschreibung: "Qualitäts-Standards und Methodik"
  auto_scan: ["/notizen/standards/**/*", "/_transitions/standards/**/*"]
  verfügbarkeit: "automatisch_referenziert"

EBENE_4_REFERENZEN:
  beschreibung: "Best-Practice-Beispiele"
  auto_scan: ["**/BUV_*", "**/TUV_*", "/unterricht/*/"]
  verfügbarkeit: "vergleichend_verfügbar"

EBENE_5_META:
  beschreibung: "Systemtheoretische Fundierung"
  auto_scan: ["/notizen/DiSoAn/**/*", "/notizen/systemtheorie/**/*"]
  verfügbarkeit: "reflexiv_integriert"
```

## 🎪 **NAVIGATION-INDEX-GENERATOR**

### Template für automatisch erstellte Navigation:
```markdown
# Automatisch generierter Navigation-Index

## SOFORT VERFÜGBARE RESSOURCEN:
### Direkte Projekt-Artefakte:
- [Liste_automatisch_erkannter_direkter_Artefakte]

### Domain-spezifische Unterstützung:  
- [Liste_fachbereich_relevanter_Ressourcen]

## QUALITÄTS-STANDARDS VERFÜGBAR:
### Automatisch aktivierte Standards:
- [Situationsspezifische_Standards]

### Referenz-Qualität verfügbar:
- [Best_Practice_Beispiele]

## META-EBENEN-BEWUSSTSEIN:
### Systemtheoretische Fundierung:
- [DiSoAn_Ressourcen]

### Selbstlernende Integration:
- [PATA_Standards_und_Meta_Prozesse]

## ADAPTIVE NAVIGATION:
**Relevanz-Scores**: [Automatisch_berechnete_Prioritäten]
**Kontext-Mapping**: [Situationsspezifische_Verfügbarkeit]
**Vollständigkeits-Check**: [Alle_Ebenen_verfügbar: JA/NEIN]
```

---

**FUNKTION**: Automatische Repository-weite Navigation mit kontextueller Verfügbarkeit  
**SELBSTAKTUALISIEREND**: Kontinuierliche Verbesserung durch Nutzungsfeedback  
**MEHREBENEN-BEWUSST**: Garantierte Verfügbarkeit aller Qualitäts-Dimensionen