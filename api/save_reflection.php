<?php
header('Content-Type: application/json');

// Überprüfe, ob alle erforderlichen Felder vorhanden sind
if (!isset($_POST['unit']) || !isset($_POST['title'])) {
    echo json_encode(['success' => false, 'message' => 'Erforderliche Felder fehlen']);
    exit;
}

// Parameter auslesen
$unit = preg_replace('/[^a-zA-Z0-9_-]/', '', $_POST['unit']); // Sicherstellen, dass keine ungültigen Zeichen
$title = htmlspecialchars($_POST['title']);
$class = isset($_POST['class']) ? htmlspecialchars($_POST['class']) : '';
$successRating = isset($_POST['success-rating']) ? intval($_POST['success-rating']) : 3;

// Methoden und Tags
$methods = isset($_POST['methods']) ? json_decode($_POST['methods'], true) : [];
$tags = isset($_POST['tags']) ? json_decode($_POST['tags'], true) : [];

// Textfelder
$successes = isset($_POST['successes']) ? htmlspecialchars($_POST['successes']) : '';
$challenges = isset($_POST['challenges']) ? htmlspecialchars($_POST['challenges']) : '';
$improvements = isset($_POST['improvements']) ? htmlspecialchars($_POST['improvements']) : '';
$methodNotes = isset($_POST['method-notes']) ? htmlspecialchars($_POST['method-notes']) : '';
$classNotes = isset($_POST['class-notes']) ? htmlspecialchars($_POST['class-notes']) : '';
$notes = isset($_POST['notes']) ? htmlspecialchars($_POST['notes']) : '';

// Datum und Dateiname
$date = date('Y-m-d');
$filename = "reflexion_" . $date . ".md";
$targetDir = "../notizen/reflexionen/unterrichtseinheiten/$unit";

// Zielverzeichnis erstellen, falls nicht vorhanden
if (!is_dir($targetDir)) {
    if (!mkdir($targetDir, 0755, true)) {
        echo json_encode(['success' => false, 'message' => 'Fehler beim Erstellen des Verzeichnisses']);
        exit;
    }
}

// Markdown-Inhalt generieren
$content = <<<EOT
---
title: "Reflexion: $title"
date: $date
class: "$class"
unit: "$unit"
methods: 
EOT;

// Methoden hinzufügen
foreach ($methods as $method) {
    $content .= "  - " . htmlspecialchars($method) . "\n";
}

$content .= "success_rating: $successRating\n";
$content .= "tags:\n";

// Tags hinzufügen
foreach ($tags as $tag) {
    $content .= "  - " . htmlspecialchars($tag) . "\n";
}

$content .= "---\n\n";
$content .= "## Was ist gut gelaufen?\n\n$successes\n\n";
$content .= "## Was waren Herausforderungen?\n\n$challenges\n\n";
$content .= "## Ideen für Verbesserungen\n\n$improvements\n\n";
$content .= "## Notizen zu verwendeten Methoden\n\n$methodNotes\n\n";
$content .= "## Notizen zur Lerngruppe\n\n$classNotes\n\n";
$content .= "## Sonstiges\n\n$notes\n";

// Datei speichern
$fullPath = "$targetDir/$filename";
if (file_put_contents($fullPath, $content)) {
    echo json_encode(['success' => true, 'file' => $fullPath]);
    
    // Git-Commit, falls Git vorhanden
    if (function_exists('exec')) {
        chdir('../');
        exec('git add ' . escapeshellarg($fullPath));
        exec('git commit -m "Neue Reflexion für ' . escapeshellarg($unit) . ': ' . escapeshellarg($title) . '"');
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Speichern der Datei']);
}
