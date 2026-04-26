<?php
include '../../config/db.php';

$sql = "SELECT * FROM markets ORDER BY volume DESC";
$result = $conn->query($sql);

        
$markets = [];
function formatMoney($amount) {
    if ($amount >= 100000) return '₹' . round($amount / 100000, 1) . 'L';
    if ($amount >= 1000) return '₹' . round($amount / 1000, 1) . 'K';
    return '₹' . $amount;
}

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {

        $formattedStart = date("M d, Y", strtotime($row['start_date']));
        $formattedEnd = date("M d, Y", strtotime($row['end_date']));

        // LMSR Spot Price Equation: P = e^(S/k) / Sum(e^(S_i / k))
        $yes_shares = (int)($row['yes_shares'] ?? 0);
        $no_shares = (int)($row['no_shares'] ?? 0);
        $k = (float)($row['liquidity_k'] ?? 1000.0);
        
        $e_yes = exp($yes_shares / $k);
        $e_no = exp($no_shares / $k);
        $sum_e = $e_yes + $e_no;
        
        $yes_price = round(($e_yes / $sum_e) * 100);
        $no_price = round(($e_no / $sum_e) * 100);

        // Sanity constraints to prevent 0 or 100 (markets shouldn't be entirely locked)
        if ($yes_price >= 100) $yes_price = 99; if ($no_price <= 0) $no_price = 1;
        if ($no_price >= 100) $no_price = 99; if ($yes_price <= 0) $yes_price = 1;

        $markets[] = [
            'id' => (string)$row['id'],
            'category' => $row['category'],
            'title' => $row['title'],
            'yesPrice' => $yes_price,
            'noPrice' => $no_price,
            'volume' => formatMoney($row['volume']),
            'volume24h' => formatMoney($row['volume_24h']),
            'startDate' => $formattedStart,
            'endDate' => $formattedEnd,
            'isEndingSoon' => (bool)$row['is_ending_soon']
        ];
    }
}

echo json_encode(["status" => "success", "data" => $markets]);
$conn->close();
?>
