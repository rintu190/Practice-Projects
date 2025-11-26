<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/Env.php';
Env::load(__DIR__ . '/../.env');

try {
    $database = new Database();
    $db = $database->getConnection();

    $sql = file_get_contents(__DIR__ . '/migrations/add_is_veg_to_menu_items.sql');
    
    // Remove "USE flutter_food_regional;" as PDO selects DB in connection
    $sql = str_replace('USE flutter_food_regional;', '', $sql);

    $db->exec($sql);
    echo "Migration applied successfully!\n";
} catch (PDOException $e) {
    echo "Migration failed: " . $e->getMessage() . "\n";
}
