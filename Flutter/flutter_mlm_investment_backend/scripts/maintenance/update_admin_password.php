<?php
require_once __DIR__ . '/config/database.php';

$db = Database::getInstance();
$conn = $db->getConnection();

$phone = '9876543210';
$password = 'admin123';
$hash = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("UPDATE users SET password_hash = ? WHERE phone = ?");
$stmt->execute([$hash, $phone]);

echo "Password updated successfully for phone: $phone\n";
echo "You can now login with:\n";
echo "Phone: $phone\n";
echo "Password: $password\n";
?>
