<?php
// Überprüfe, ob ein Dateiparameter übergeben wurde
if (!isset($_GET['file'])) {
    header('Location: index.html');
    exit;
}

// Dateiname säubern und Pfad validieren
$file = $_GET['file'];
$file = str_replace('..', '', $file); // Verhindere directory traversal
$filePath = $file;

// Überprüfe, ob die Datei existiert
if (!file_exists($filePath)) {
    header('HTTP/1.0 404 Not Found');
    echo "Datei nicht gefunden.";
    exit;
}

// Lese den Inhalt der Markdown-Datei
$content = file_get_contents($filePath);

// Extrahiere den Frontmatter (falls vorhanden)
$metadata = [];
if (preg_match('/^---\s(.*?)\s---/s', $content, $matches)) {
    $frontMatter = $matches[1];
    
    // Title
    if (preg_match('/title:\s*"(.+?)"/i', $frontMatter, $matches)) {
        $metadata['title'] = $matches[1];
    }
    
    // Weitere Metadaten extrahieren...
    
    // Entferne den Frontmatter aus dem Inhalt für die Anzeige
    $content = preg_replace('/^---\s(.*?)\s---/s', '', $content);
}

// Titel festlegen
$title = isset($metadata['title']) ? $metadata['title'] : basename($filePath);

// Einfache Markdown-zu-HTML-Konvertierung (sehr grundlegend)
function convertMarkdownToHtml($markdown) {
    // Überschriften
    $markdown = preg_replace('/^## (.*?)$/m', '<h2>$1</h2>', $markdown);
    $markdown = preg_replace('/^### (.*?)$/m', '<h3>$1</h3>', $markdown);
    
    // Listen
    $markdown = preg_replace('/^\s*- (.*?)$/m', '<li>$1</li>', $markdown);
    $markdown = preg_replace('/(<li>.*?<\/li>(\n|$))+/', '<ul>$0</ul>', $markdown);
    
    // Absätze
    $markdown = preg_replace('/^([^<].*?)$/m', '<p>$1</p>', $markdown);
    
    // Leere Absätze entfernen
    $markdown = preg_replace('/<p><\/p>/', '', $markdown);
    
    return $markdown;
}

$htmlContent = convertMarkdownToHtml($content);
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title); ?></title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .markdown-content {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: white;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        .markdown-content h2 {
            color: #2980b9;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
            margin-top: 30px;
        }
        .markdown-content ul {
            padding-left: 20px;
        }
        .back-link {
            margin-bottom: 20px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="javascript:history.back()" class="back-link">← Zurück</a>
        
        <div class="markdown-content">
            <h1><?php echo htmlspecialchars($title); ?></h1>
            <?php echo $htmlContent; ?>
        </div>
    </div>
</body>
</html>
