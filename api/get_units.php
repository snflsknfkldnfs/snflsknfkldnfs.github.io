<?php
header('Content-Type: application/json');

// Verzeichnis mit Unterrichtseinheiten
$directory = '../unterricht/';
$units = [];

// Alle Unterordner auslesen
$dirs = scandir($directory);
foreach ($dirs as $dir) {
    // Ignoriere spezielle Verzeichnisse und versteckte Dateien
    if ($dir !== '.' && $dir !== '..' && $dir !== 'template' && substr($dir, 0, 1) !== '.') {
        // Titel aus index.html extrahieren, falls vorhanden
        $title = $dir; // Standardtitel = Verzeichnisname
        $indexFile = $directory . $dir . '/index.html';
        if (file_exists($indexFile)) {
            $content = file_get_contents($indexFile);
            // Einfache Titelextraktion
            if (preg_match('/<title>(.+?)<\/title>/i', $content, $matches)) {
                $title = $matches[1];
            }
        }
        
        $units[] = [
            'folder' => $dir,
            'title' => $title
        ];
    }
}

echo json_encode($units);
