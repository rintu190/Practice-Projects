<?php
require_once __DIR__ . '/config/database.php';

$table = $_GET['table'] ?? null;

if (!$table) {
    die("Please provide a table name via ?table= parameter");
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    echo "Schema for table '$table':\n";
    $stmt = $conn->query("DESCRIBE $table");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
