<?php

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

function handleCommissionRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user role
    $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    $role = $user['role'] ?? 'customer';

    // Get commissions
    if ($method === 'GET' && $path === '') {
        if ($role === 'admin') {
            // Admin sees all commissions
            $stmt = $db->prepare('
                SELECT c.*, u.name as user_name, u.role as user_role, o.total_amount as order_total
                FROM commissions c
                JOIN users u ON c.user_id = u.id
                JOIN orders o ON c.order_id = o.id
                ORDER BY c.created_at DESC
            ');
            $stmt->execute();
        } elseif ($role === 'rider' || $role === 'restaurant') {
            // Riders and restaurants see only their commissions
            $stmt = $db->prepare('
                SELECT c.*, o.total_amount as order_total
                FROM commissions c
                JOIN orders o ON c.order_id = o.id
                WHERE c.user_id = ?
                ORDER BY c.created_at DESC
            ');
            $stmt->execute([$userId]);
        } else {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $commissions = $stmt->fetchAll();
        
        // Calculate total earnings
        $total = 0;
        foreach ($commissions as $commission) {
            // For riders and restaurant owners, only count approved commissions
            // For admins, count all commissions
            if ($role === 'admin' || $commission['status'] === 'approved') {
                $total += $commission['amount'];
            }
        }

        echo json_encode([
            'commissions' => $commissions,
            'total' => $total
        ]);
        return;
    }

    // Approve commission (Admin only)
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/approve$/', $path, $matches)) {
        $commissionId = $matches[1];

        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $stmt = $db->prepare('UPDATE commissions SET status = ? WHERE id = ?');
        $stmt->execute(['approved', $commissionId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Commission not found']);
            return;
        }

        echo json_encode(['message' => 'Commission approved successfully']);
        return;
    }

    // Reject commission (Admin only)
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/reject$/', $path, $matches)) {
        $commissionId = $matches[1];

        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $stmt = $db->prepare('UPDATE commissions SET status = ? WHERE id = ?');
        $stmt->execute(['rejected', $commissionId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Commission not found']);
            return;
        }

        echo json_encode(['message' => 'Commission rejected successfully']);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
