<?php
header('Content-Type: application/json');

function parseMarkdownFrontMatter($content) {
    $pattern = '/^---\s(.*?)\s---/s';
    if (preg_match($pattern, $content, $matches)) {
        $frontMatter = $matches[1];
        $data = [];
        
        // Title
        if (preg_match('/title:\s*"(.+?)"/i', $frontMatter, $matches)) {
            $data['title'] = $matches[1];
        }
        
        // Date
        if (preg_match('/date:\s*(.+?)$/im', $frontMatter, $matches)) {
            $data['date'] = trim($matches[1]);
        }
        
        // Class
        if (preg_match('/class:\s*"(.+?)"/i', $frontMatter, $matches)) {
            $data['class'] = $matches[1];
        }
        
        // Unit
        if (preg_match('/unit:\s*"(.+?)"/i', $frontMatter, $matches)) {
            $data['unit'] = $matches[1];
        }
        
        // Methods
        $methods = [];
        if (preg_match('/methods:\s(.*?)(?:success_rating|tags)/s', $frontMatter, $methodsSection)) {
            preg_match_all('/\s*-\s*(.+?)$/m', $methodsSection[1], $methodMatches);
            if (isset($methodMatches[1])) {
                $methods = array_map('trim', $methodMatches[1]);
            }
        }
        $data['methods'] = $methods;
        
        // Success rating
        if (preg_match('/success_rating:\s*(\d+)/i', $frontMatter, $matches)) {
            $data['success_rating'] = (int)$matches[1];
        }
        
        // Tags
        $tags = [];
        if (preg_match('/tags:\s(.*?)(?:---|\Z)/s', $frontMatter, $tagsSection)) {
            preg_match_all('/\s*-\s*(.+?)$/m', $tagsSection[1], $tagMatches);
            if (isset($tagMatches[1])) {
                $tags = array_map('trim', $tagMatches[1]);
            }
        }
        $data['tags'] = $tags;
        
        return $data;
    }
    
    return null;
}

function getContentSection($content, $section) {
    $pattern = '/## ' . preg_quote($section, '/') . '\s*(.*?)(?:## |$)/s';
    if (preg_match($pattern, $content, $matches)) {
        return trim($matches[1]);
    }
    return '';
}

// Verzeichnis mit Reflexionen
$baseDir = '../notizen/reflexionen/unterrichtseinheiten/';
$reflections = [];

// Alle Unterordner durchsuchen
if (is_dir($baseDir)) {
    $units = scandir($baseDir);
    foreach ($units as $unit) {
        if ($unit !== '.' && $unit !== '..' && is_dir($baseDir . $unit)) {
            $unitDir = $baseDir . $unit . '/';
            $files = scandir($unitDir);
            
            foreach ($files as $file) {
                if (preg_match('/^reflexion_.*\.md$/', $file)) {
                    $filePath = $unitDir . $file;
                    $content = file_get_contents($filePath);
                    
                    // Frontmatter und Inhalt extrahieren
                    $data = parseMarkdownFrontMatter($content);
                    
                    if ($data) {
                        // Inhaltssektionen extrahieren
                        $data['successes'] = getContentSection($content, 'Was ist gut gelaufen\?');
                        $data['challenges'] = getContentSection($content, 'Was waren Herausforderungen\?');
                        $data['improvements'] = getContentSection($content, 'Ideen für Verbesserungen');
                        
                        // URL zur Markdown-Datei (relativ)
                        $data['url'] = 'viewer.php?file=' . urlencode(str_replace('../', '', $filePath));
                        
                        $reflections[] = $data;
                    }
                }
            }
        }
    }
}

// Nach Datum sortieren (neueste zuerst)
usort($reflections, function($a, $b) {
    return strcmp($b['date'], $a['date']);
});

echo json_encode($reflections);
