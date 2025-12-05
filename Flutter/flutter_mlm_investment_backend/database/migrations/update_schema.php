<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // 1. Add rank column to users table if not exists
    try {
        $conn->exec("ALTER TABLE users ADD COLUMN `rank` VARCHAR(50) DEFAULT 'Basic' AFTER status");
        echo "Added rank column to users table.\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            echo "Rank column already exists.\n";
        } else {
            throw $e;
        }
    }

    // 2. Insert default ranks
    $ranks = [
        ['Basic', 1, 0, 0],
        ['Bronze', 2, 10, 5000],
        ['Silver', 3, 50, 20000],
        ['Gold', 4, 200, 100000],
        ['Diamond', 5, 1000, 500000]
    ];

    $stmt = $conn->prepare("INSERT IGNORE INTO ranks (rank_name, rank_level, required_team_size, required_personal_investment) VALUES (?, ?, ?, ?)");
    
    foreach ($ranks as $rank) {
        $stmt->execute($rank);
    }
    echo "Default ranks inserted.\n";

    echo "Schema update completed successfully.\n";

} catch (Exception $e) {
    echo "Error updating schema: " . $e->getMessage() . "\n";
}
?>
