# Workflow zur Bildintegration in Unterrichtsmaterialien

## Zusammenfassung des implementierten Workflows

### 1. Herausforderungen
- Direkte Bildlinks von Stock-Plattformen werden blockiert
- Brave Search MCP-Server ist nicht konfiguriert
- Alternative Lösungen wurden entwickelt

### 2. Implementierte Lösungen

#### a) Bildquellen-Dokumentation
- NASA Image Gallery (Public Domain)
- ESA/Hubble (CC BY 4.0)
- Unsplash/Pexels (Lizenzfrei)

#### b) Technische Umsetzung
1. **Manuelle Bildsuche** auf den empfohlenen Plattformen
2. **Download** in hoher Auflösung
3. **Bearbeitung** mit File-Manager MCP-Server:
   - Größenanpassung auf 800x600 Pixel
   - Konvertierung zu JPG
   - Optimierung für Web

#### c) Beispiel-Generator
Ein HTML-basierter Weltraum-Bild-Generator wurde erstellt für:
- Schnelle Platzhalter-Bilder
- Demonstration der Canvas-API
- Unterrichtszwecke zur Programmierung

### 3. Ordnerstruktur für Bilder

```
/Users/paulad/Documents/Obsidian/Bilder/
├── weltraum/
│   ├── nebel/
│   ├── galaxien/
│   └── sterne/
└── unterricht/
    ├── physik/
    └── astronomie/
```

### 4. Best Practices

1. **Namenskonvention:** `thema_beschreibung_nummer.jpg`
2. **Metadaten:** Führen Sie eine CSV mit Bildquellen
3. **Backup:** Speichern Sie Originalversionen separat
4. **Lizenzhinweise:** Dokumentieren Sie Urheberrechte

### 5. Integration in GitHub Pages

```html
<!-- Beispiel für Bildeinbindung -->
<img src="/bilder/weltraum/nebula_pillars_01.jpg" 
     alt="Pillars of Creation - Säulen der Schöpfung" 
     width="800" height="600">
<p class="bildquelle">Quelle: NASA/ESA/Hubble (Public Domain)</p>
```

### 6. Nächste Schritte

1. **API-Integration:** Evaluierung von Bildplattform-APIs
2. **Automatisierung:** Entwicklung eines Download-Scripts
3. **Metadaten-Management:** Automatische Lizenzdokumentation

---

*Dokumentation erstellt: 2025-06-01*
*Workflow getestet und implementiert in der Claude Desktop Umgebung*