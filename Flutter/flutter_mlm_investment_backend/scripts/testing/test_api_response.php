<?php
// Test what the dashboard API actually returns
require_once 'config/database.php';
require_once 'utils/jwt.php';

// Simulate a request to get dashboard data
$conn = Database::getInstance()->getConnection();

// Get a user ID to test with
$stmt = $conn->query("SELECT id FROM users LIMIT 1");
$user = $stmt->fetch(PDO::FETCH_ASSOC);
$userId = $user['id'];

echo "Testing dashboard API for user ID: $userId\n\n";

// Fetch user data (simulating what dashboard.php does)
$stmt = $conn->prepare("SELECT id, phone, email, `rank`, referral_code, kyc_status FROM users WHERE id = ?");
$stmt->execute([$userId]);
$userData = $stmt->fetch(PDO::FETCH_ASSOC);

echo "=== User Data Returned by API ===\n";
echo json_encode($userData, JSON_PRETTY_PRINT);
echo "\n\n";

echo "Rank value: '{$userData['rank']}'\n";
