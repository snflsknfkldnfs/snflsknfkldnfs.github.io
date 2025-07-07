# REPOSITORY RESTRUCTURING PLAN
*Dual-Purpose Optimization: KI-Functionality + Formal Academic Review*

## CURRENT PROBLEM ANALYSIS

### CLUTTER ISSUES:
- Root directory: 30+ mixed files (scripts, configs, documentation)
- Unclear separation: Educational content vs Technical infrastructure  
- Missing hierarchy: No clear academic vs system organization
- AI-inefficient: Important content buried in technical folders

### DUAL-PURPOSE REQUIREMENTS:

#### FOR SEMINARLEITER (Formal Review):
- Clear academic structure
- Easy navigation to educational content
- Professional presentation
- Compliance with documentation standards

#### FOR KI-SYSTEM (Functionality):
- Efficient content discovery
- Logical meta-process organization
- Cross-reference capabilities
- Fast semantic navigation

## PROPOSED RESTRUCTURE

### NEW ROOT ORGANIZATION:
```
/
├── README.md (Professional overview)
├── index.md (Academic homepage)
├── 
├── 📚 ACADEMIC/ (Seminarleiter focus)
│   ├── unterricht/ (BUV, Materialien, Reflexionen)
│   ├── ausbildung/ (Seminar content, Bausteine)
│   └── documentation/ (TUV, formal reports)
│
├── 🤖 SYSTEM/ (KI Infrastructure)
│   ├── meta_processes/ (moved from notizen/)
│   ├── automation/ (scripts, workflows)  
│   └── infrastructure/ (MCP, configs)
│
├── 🌐 PUBLIC/ (Website content)
│   ├── _layouts/
│   ├── _includes/
│   └── assets/
│
└── 📄 EXTRACTED/ (Generated content)
    ├── pdfs/
    └── summaries/
```

### ACADEMIC SECTION STRUCTURE:
```
ACADEMIC/
├── 📋 INDEX.md (Academic overview)
├── 
├── 📖 unterricht/
│   ├── BUV/ (alle BUV-Dokumente)
│   ├── sequenzen/ (Unterrichtssequenzen)
│   ├── materialien/ (Arbeitsblätter, Medien)
│   └── reflexionen/ (Nachbereitung, Learnings)
│
├── 🎓 ausbildung/  
│   ├── seminare/ (Seminarbausteine)
│   ├── hospitationen/ (Unterrichtsbeobachtungen)
│   └── qualifikation/ (TUV, Bewertungen)
│
└── 📊 documentation/
    ├── formal/ (Offizielle Dokumente)
    ├── progress/ (Ausbildungsfortschritt)
    └── compliance/ (Standards, Richtlinien)
```

## IMMEDIATE ACTIONS (17% Context):

### 1. CREATE ACADEMIC MASTER INDEX
```markdown
# ACADEMIC/INDEX.md

## Lehramtsausbildung - Dokumentation und Materialien

### 📖 Unterrichtspraxis
- [BUV-Dokumentationen](unterricht/BUV/)
- [Unterrichtssequenzen](unterricht/sequenzen/)  
- [Materialsammlung](unterricht/materialien/)
- [Reflexionen und Learnings](unterricht/reflexionen/)

### 🎓 Seminarausbildung
- [Seminarbausteine](ausbildung/seminare/)
- [Unterrichtsbeobachtungen](ausbildung/hospitationen/)
- [Qualifikationsnachweise](ausbildung/qualifikation/)

### 📊 Formale Dokumentation
- [Offizielle Unterlagen](documentation/formal/)
- [Ausbildungsfortschritt](documentation/progress/)
- [Standards und Compliance](documentation/compliance/)
```

### 2. SYSTEM ARCHITECTURE CLEANUP
```
SYSTEM/meta_processes/ (organized by domain)
├── 🎯 CORE/
│   ├── UNIVERSAL_INFRASTRUCTURE_PRINCIPLES_V1.md
│   ├── SYSTEM_RELIABILITY_STANDARDIZATION_V1.md
│   └── SESSION_TRANSITION_CONTEXT_V1.md
│
├── 📄 PDF_PROCESSING/
│   ├── PDF_Auto_Extraktion_Standard.md
│   └── extraction_workflows/
│
├── 🧠 AI_INTEGRATION/
│   ├── CONTEXT_AWARE_INDEXING_SYSTEM_V2.md
│   ├── SEMANTIC_NAVIGATION_LAYER_V2.md
│   └── RELIABILITY_VALIDATION_SYSTEM_V2.md
│
└── 🔗 INTEGRATION/
    ├── NAVIGATION_STANDARDS_INTEGRATION_V2.md
    └── IMMEDIATE_UNIVERSAL_IMPLEMENTATION_V1.md
```

### 3. KI-EFFICIENT NAVIGATION AIDS
```
.claude/
├── CONTEXT_MAP.md (What's where for AI)
├── PRIORITY_FILES.md (Most important content)
└── CROSS_REFERENCES.md (Content relationships)
```

## IMPLEMENTATION STRATEGY

### PHASE 1: Academic Structure (Immediate)
1. Create ACADEMIC/ master directory
2. Move educational content logically
3. Create clear index files
4. Update cross-references

### PHASE 2: System Organization  
1. Restructure meta_processes by domain
2. Create SYSTEM/ technical hierarchy
3. Implement KI-navigation aids
4. Update MCP configurations

### PHASE 3: Public Optimization
1. Clean website structure
2. Professional presentation
3. Clear separation of concerns
4. Optimized for both audiences

---

**Goal**: Repository that excels for both AI-functionality AND formal academic review
**Timeline**: Phase 1 implementable with remaining context
**Success Metric**: Clear navigation for both Seminarleiter and KI systems