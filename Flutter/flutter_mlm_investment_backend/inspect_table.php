<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    echo "Wallets Table:\n";
    $stmt = $conn->query("DESCRIBE wallets");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

    echo "\nInvestment Wallets Table:\n";
    $stmt = $conn->query("DESCRIBE investment_wallets");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

    echo "\nUser Investments Table:\n";
    $stmt = $conn->query("DESCRIBE user_investments");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

    echo "\nTransactions Table:\n";
    $stmt = $conn->query("DESCRIBE transactions");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
