<?php
$host = "127.0.0.1";
$user = "root";
$pass = "root123";
$dbname = "poly_market";

$conn = @new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    // Try alternate password or localhost socket
    $pass = "Open@120";
    $conn = @new mysqli($host, $user, $pass, $dbname);
    if ($conn->connect_error) {
        $conn = new mysqli("localhost", $user, $pass, $dbname);
    }
}

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>