<?php
include '../../config/db.php';

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    die(json_encode(["status" => "error", "message" => "Method not allowed"]));
}

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data['user_id'] ?? 1; // Default to mock user 1
$market_id = $data['market_id'] ?? null;
$outcome = $data['outcome'] ?? null; // 'YES' or 'NO'
$shares = $data['shares'] ?? 0;
$total_amount = $data['total_amount'] ?? 0;
$price_per_share = $data['price_per_share'] ?? 0;

if (!$market_id || !$outcome || $shares <= 0 || $total_amount <= 0) {
    die(json_encode(["status" => "error", "message" => "Invalid order data"]));
}

$conn->begin_transaction();

try {
    // Check wallet balance
    $wallet_stmt = $conn->prepare("SELECT wallet_balance FROM users WHERE id = ? FOR UPDATE");
    $wallet_stmt->bind_param("i", $user_id);
    $wallet_stmt->execute();
    $wallet_res = $wallet_stmt->get_result();
    
    if ($wallet_res->num_rows === 0) {
        throw new Exception("User not found");
    }
    
    $user = $wallet_res->fetch_assoc();
    if ($user['wallet_balance'] < $total_amount) {
        throw new Exception("Insufficient balance");
    }
    
    // Deduct balance
    $new_balance = $user['wallet_balance'] - $total_amount;
    $update_wallet = $conn->prepare("UPDATE users SET wallet_balance = ? WHERE id = ?");
    $update_wallet->bind_param("di", $new_balance, $user_id);
    $update_wallet->execute();
    
    // Increment the market's specific share liquidity pool to shift the LMSR curve dynamically
    if (strtoupper($outcome) === 'YES') {
        $update_pool = $conn->prepare("UPDATE markets SET yes_shares = yes_shares + ?, volume = volume + ? WHERE id = ?");
    } else {
        $update_pool = $conn->prepare("UPDATE markets SET no_shares = no_shares + ?, volume = volume + ? WHERE id = ?");
    }
    $update_pool->bind_param("idi", $shares, $total_amount, $market_id);
    $update_pool->execute();
    
    // Insert order ledger record
    $insert_order = $conn->prepare("INSERT INTO orders (user_id, market_id, outcome, shares, price_per_share, total_amount) VALUES (?, ?, ?, ?, ?, ?)");
    $insert_order->bind_param("iisidd", $user_id, $market_id, $outcome, $shares, $price_per_share, $total_amount);
    $insert_order->execute();
    
    // Upsert user_positions table
    if (strtoupper($outcome) === 'YES') {
        $pos_stmt = $conn->prepare("INSERT INTO user_positions (user_id, market_id, yes_shares, total_invested) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE yes_shares = yes_shares + VALUES(yes_shares), total_invested = total_invested + VALUES(total_invested)");
    } else {
        $pos_stmt = $conn->prepare("INSERT INTO user_positions (user_id, market_id, no_shares, total_invested) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE no_shares = no_shares + VALUES(no_shares), total_invested = total_invested + VALUES(total_invested)");
    }
    $pos_stmt->bind_param("iiid", $user_id, $market_id, $shares, $total_amount);
    $pos_stmt->execute();
    
    $conn->commit();
    echo json_encode([
        "status" => "success", 
        "message" => "Order placed successfully",
        "new_balance" => $new_balance
    ]);
    
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}

$conn->close();
?>
