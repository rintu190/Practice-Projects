<?php

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/JWTHandler.php';

function handleGoogleAuthRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

    // POST /auth/google - Google Sign-In
    if ($method === 'POST' && $path === '') {
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['idToken'])) {
            http_response_code(400);
            echo json_encode(['error' => 'ID token is required']);
            return;
        }

        $idToken = $data['idToken'];
        
        // For now, we'll decode the token without verification
        // In production, you should verify the token with Google's API
        // For development, we'll extract the payload
        $tokenParts = explode('.', $idToken);
        if (count($tokenParts) !== 3) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid token format']);
            return;
        }

        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1])), true);
        
        if (!$payload || !isset($payload['email'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid token payload']);
            return;
        }

        $email = $payload['email'];
        $name = $payload['name'] ?? 'User';
        $googleId = $payload['sub'] ?? null;

        // Check if user exists with this email
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user) {
            // User exists, update google_id if not set
            if (empty($user['google_id']) && $googleId) {
                $updateStmt = $db->prepare('UPDATE users SET google_id = ? WHERE id = ?');
                $updateStmt->execute([$googleId, $user['id']]);
            }
            
            // Generate JWT token
            $token = JWTHandler::generateToken($user['id'], $user['role']);
            
            http_response_code(200);
            echo json_encode([
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'role' => $user['role']
                ]
            ]);
        } else {
            // Create new user account
            $userId = bin2hex(random_bytes(16));
            $role = 'customer'; // Default role for Google Sign-In users
            
            $insertStmt = $db->prepare('
                INSERT INTO users (id, name, email, password, role, google_id, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, NOW())
            ');
            
            // Use a random password since they're using Google Sign-In
            $randomPassword = password_hash(bin2hex(random_bytes(32)), PASSWORD_BCRYPT);
            
            $insertStmt->execute([
                $userId,
                $name,
                $email,
                $randomPassword,
                $role,
                $googleId
            ]);
            
            // Generate JWT token
            $token = JWTHandler::generateToken($userId, $role);
            
            http_response_code(201);
            echo json_encode([
                'token' => $token,
                'user' => [
                    'id' => $userId,
                    'name' => $name,
                    'email' => $email,
                    'role' => $role
                ]
            ]);
        }
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
