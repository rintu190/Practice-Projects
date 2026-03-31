<?php
$path = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);
$ext = pathinfo($path, PATHINFO_EXTENSION);

$staticTypes = [
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'svg' => 'image/svg+xml'
];

if (array_key_exists(strtolower($ext), $staticTypes)) {
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: " . $staticTypes[strtolower($ext)]);
    readfile(__DIR__ . $path);
    return true;
}

// Proceed to normal routing if not a static file
return false;
