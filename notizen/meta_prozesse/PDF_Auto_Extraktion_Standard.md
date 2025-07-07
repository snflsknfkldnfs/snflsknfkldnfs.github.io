# PDF Auto-Extraktion Standard - Meta-Prozess

## Übersicht

Automatisierter Standard für die PDF-Inhaltsextraktion in der Educational Repository mit nahtloser Claude Desktop MCP Integration.

## System-Architektur

### 1. GitHub Actions Workflow
- **Datei**: `.github/workflows/pdf-auto-extraction.yml`
- **Trigger**: PDF-Uploads, Pull Requests, manueller Aufruf
- **Funktionen**:
  - Automatische Erkennung neuer/geänderter PDFs
  - Text-Extraktion (direkt + OCR für Scans)
  - Metadaten-Generierung
  - Automatische Commits der extrahierten Inhalte

### 2. Claude Desktop MCP Integration
- **Konfiguration**: `/Users/paulad/Library/Application Support/Claude/claude_desktop_config.json`
- **Server**: `pdf-extraction` (aus `/Users/paulad/mcp-pdf-extraction-server`)
- **Zugriffsrechte**: Alle Repository-Pfade + extracted_content

### 3. Lokale Extraktion
- **Script**: `scripts/extract_pdf_content.py`
- **Funktionen**: Standalone-Extraktion, Batch-Processing, Metadaten-Management

## Verwendung

### Automatisch (GitHub Actions)
```bash
# Neues PDF hochladen
git add unterricht/neue_datei.pdf
git commit -m "Add neue_datei.pdf"
git push
# → Automatische Extraktion in extracted_content/
```

### Manuell (Lokal)
```bash
# Einzelne Datei
python scripts/extract_pdf_content.py unterricht/datei.pdf

# Alle PDFs in einem Ordner
python scripts/extract_pdf_content.py unterricht/ --recursive

# Mit spezifischen Optionen
python scripts/extract_pdf_content.py \
  --output-dir extracted_content \
  --max-pages 15 \
  --languages deu eng \
  --force
```

### Claude Chat Integration
```
Bitte extrahiere den Inhalt aus der PDF-Datei: 
/Users/paulad/snflsknfkldnfs.github.io/unterricht/beispiel.pdf
```

## Ordnerstruktur

```
snflsknfkldnfs.github.io/
├── .github/workflows/
│   └── pdf-auto-extraction.yml      # GitHub Actions Workflow
├── extracted_content/               # Extrahierte Inhalte
│   ├── metadata/                   # JSON-Metadaten
│   ├── datei_name.txt             # Extrahierte Texte
│   └── extraction_summary.json    # Übersicht
├── scripts/
│   └── extract_pdf_content.py     # Lokales Extraktions-Script
└── unterricht/                    # Original PDFs
    └── 3. BUV/
        └── 3. BUV_Cebulla_GPG_E.pdf
```

## Features

### Text-Extraktion
- **Direkte Extraktion**: Für normale PDFs mit eingebettetem Text
- **OCR-Extraktion**: Für gescannte Dokumente (Tesseract mit deu+eng)
- **Intelligente Erkennung**: Automatische Unterscheidung zwischen Text-PDF und Scan
- **Seitenbegrenzung**: Standard 10 Seiten (konfigurierbar)

### Metadaten-System
```json
{
  "source_file": "pfad/zur/datei.pdf",
  "extracted_at": "2025-07-07T...",
  "extraction_type": "Direct|OCR",
  "total_pages": 85,
  "extracted_pages": 10,
  "file_size": 2048576,
  "content_length": 45000,
  "file_hash": "a1b2c3d4",
  "pdf_metadata": {
    "title": "BUV Dokumentation",
    "author": "Paul Cebulla"
  }
}
```

### Claude MCP Commands

```bash
# Im Claude Chat verfügbare Funktionen:
- extract_text: PDF-Inhalte extrahieren
- get_metadata: Metadaten abrufen  
- search_content: Durchsuchung extrahierter Inhalte
- list_pdfs: Verfügbare PDFs auflisten
```

## Qualitätssicherung

### Automatische Validierung
- **File Integrity**: Hash-Überprüfung der Quelldateien
- **Content Quality**: Mindest-Textlänge für erfolgreiche Extraktion
- **Error Handling**: Detaillierte Fehlermeldungen und Recovery
- **Progress Tracking**: Status-Updates in GitHub Actions

### Standardisierte Ausgabe
- **Einheitliche Formatierung**: Strukturierte Markdown-Headers
- **Sprachunterstützung**: Deutsch und Englisch
- **Encoding**: UTF-8 für internationale Zeichen
- **Metadaten-Konsistenz**: JSON-Schema für alle Extrakte

## Erweiterte Konfiguration

### GitHub Actions Anpassung
```yaml
# Trigger für spezifische Ordner
on:
  push:
    paths:
      - 'unterricht/**/*.pdf'
      - 'seminarcloud/**/*.pdf'
```

### MCP Server Erweiterung
```json
{
  "pdfExtraction": {
    "enabled": true,
    "maxPages": 15,
    "supportedLanguages": ["deu", "eng", "fra"],
    "ocrFallback": true,
    "autoIndex": true
  }
}
```

## Troubleshooting

### Häufige Probleme

1. **OCR Abhängigkeiten fehlen**
   ```bash
   # macOS
   brew install tesseract tesseract-lang
   
   # Python
   pip install pytesseract Pillow PyMuPDF
   ```

2. **GitHub Actions Berechtigungen**
   - Repository Settings → Actions → Workflow permissions
   - "Read and write permissions" aktivieren

3. **MCP Server startet nicht**
   ```bash
   # Dependencies installieren
   cd /Users/paulad/mcp-pdf-extraction-server
   pip install -e .
   
   # Test
   python -m pdf_extraction --help
   ```

### Performance-Optimierung

- **Batch-Processing**: Mehrere PDFs parallel verarbeiten
- **Caching**: Bereits extrahierte Inhalte nicht neu verarbeiten
- **Selective Processing**: Nur geänderte Dateien verarbeiten

## Integration mit bestehenden Meta-Prozessen

### PATA Standards
- Kompatibel mit Chat_Transition_PATA_Standard.md
- Integration in DiSoAn_Systemtheoretische_Leistungsanalyse_Standard.md
- Verwendung in UE_Vollausarbeitung_Standard.md

### Git Management
- Automatische Commits mit standardisierten Messages
- Kompatibel mit Git_Repository_Management_PATA.md
- DSGVO-konforme Anonymisierung (siehe DSGVO_Automatische_Schuelerdaten_Anonymisierung_CRITICAL.md)

## Beispiel-Workflow

1. **Neue BUV-Dokumentation**:
   ```bash
   # PDF hochladen
   git add unterricht/4_BUV/BUV_Sport_Volleyball.pdf
   git commit -m "Add BUV Sport Volleyball documentation"
   git push
   ```

2. **Automatische Verarbeitung**:
   - GitHub Actions erkennt PDF
   - Extraktion startet automatisch
   - Text wird in `extracted_content/` gespeichert
   - Commit mit extrahiertem Inhalt

3. **Claude Chat Nutzung**:
   ```
   User: "Analysiere die Volleyball BUV und gib mir die Lernziele."
   Claude: [Zugriff auf extracted_content/BUV_Sport_Volleyball.txt]
   ```

## Zukunftserweiterungen

- **Mehrsprachige OCR**: Weitere Sprachen für internationale Dokumente
- **PDF-Strukturerkennung**: Automatische Gliederung und Kapitelerkennung  
- **Semantic Search**: Intelligente Suche in extrahierten Inhalten
- **Quality Metrics**: Automatische Bewertung der Extraktionsqualität

---

**Letzte Aktualisierung**: 2025-07-07  
**Version**: 1.0  
**Autor**: Claude Code Assistant  
**Status**: Produktiv