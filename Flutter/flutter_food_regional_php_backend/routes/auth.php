<?php

use Firebase\JWT\JWT;

require_once __DIR__ . '/../config/Database.php';

function handleAuthRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

    // Register
    if ($method === 'POST' && $path === '/register') {
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['name'], $data['email'], $data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        // Check if user exists
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$data['email']]);
        
        if ($stmt->rowCount() > 0) {
            http_response_code(400);
            echo json_encode(['error' => 'User already exists']);
            return;
        }

        // Hash password
        $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);
        
        // Create user
        $userId = generateUuid();
        $stmt = $db->prepare('INSERT INTO users (id, name, email, password_hash, phone, role) VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([
            $userId,
            $data['name'],
            $data['email'],
            $passwordHash,
            $data['phone'] ?? null,
            $data['role'] ?? 'customer'
        ]);

        // Generate token
        $secret = $_ENV['JWT_SECRET'] ?? 'your_secret_key_here';
        $token = JWT::encode(
            ['userId' => $userId, 'exp' => time() + (7 * 24 * 60 * 60)],
            $secret,
            'HS256'
        );

        http_response_code(201);
        echo json_encode([
            'token' => $token,
            'user' => [
                'id' => $userId,
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'role' => $data['role'] ?? 'customer'
            ]
        ]);
        return;
    }

    // Login
    if ($method === 'POST' && $path === '/login') {
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['email'], $data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        // Find user
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid credentials']);
            return;
        }

        // Check password
        if (!password_verify($data['password'], $user['password_hash'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid credentials']);
            return;
        }

        // Generate token
        $secret = $_ENV['JWT_SECRET'] ?? 'your_secret_key_here';
        $token = JWT::encode(
            ['userId' => $user['id'], 'exp' => time() + (7 * 24 * 60 * 60)],
            $secret,
            'HS256'
        );

        echo json_encode([
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone'],
                'role' => $user['role']
            ]
        ]);
        return;
    }

    // Get current user
    if ($method === 'GET' && $path === '/me') {
        $userId = AuthMiddleware::authenticate();

        $stmt = $db->prepare('SELECT id, name, email, phone, role, restaurant_id, profile_picture, latitude, longitude FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
            return;
        }

        echo json_encode($user);
        return;
    }

    // Update current user
    if ($method === 'PUT' && $path === '/me') {
        $userId = AuthMiddleware::authenticate();
        $data = json_decode(file_get_contents("php://input"), true);

        $name = $data['name'] ?? null;
        $phone = $data['phone'] ?? null;
        $latitude = $data['latitude'] ?? null;
        $longitude = $data['longitude'] ?? null;

        if (!$name || !$phone) {
            http_response_code(400);
            echo json_encode(['error' => 'Name and phone are required']);
            return;
        }

        $stmt = $db->prepare('UPDATE users SET name = ?, phone = ?, latitude = ?, longitude = ? WHERE id = ?');
        $stmt->execute([$name, $phone, $latitude, $longitude, $userId]);

        // Fetch updated user
        $stmt = $db->prepare('SELECT id, name, email, phone, role, restaurant_id, profile_picture, latitude, longitude FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();

        echo json_encode($user);
        return;
    }

    // Upload profile picture
    if ($method === 'POST' && $path === '/upload-profile-picture') {
        $userId = AuthMiddleware::authenticate();

        if (!isset($_FILES['image'])) {
            http_response_code(400);
            echo json_encode(['error' => 'No image file provided']);
            return;
        }

        $file = $_FILES['image'];
        $fileName = $file['name'];
        $fileTmpName = $file['tmp_name'];
        $fileError = $file['error'];

        if ($fileError === 0) {
            $fileExt = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
            $allowed = ['jpg', 'jpeg', 'png'];

            if (in_array($fileExt, $allowed)) {
                $newFileName = uniqid('', true) . "." . $fileExt;
                $uploadDir = __DIR__ . '/../uploads/profiles/';
                
                if (!file_exists($uploadDir)) {
                    mkdir($uploadDir, 0777, true);
                }

                $fileDestination = $uploadDir . $newFileName;

                if (move_uploaded_file($fileTmpName, $fileDestination)) {
                    // Update database
                    $profilePictureUrl = '/uploads/profiles/' . $newFileName;
                    $stmt = $db->prepare('UPDATE users SET profile_picture = ? WHERE id = ?');
                    $stmt->execute([$profilePictureUrl, $userId]);

                    echo json_encode(['message' => 'Profile picture uploaded successfully', 'profile_picture' => $profilePictureUrl]);
                } else {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to move uploaded file']);
                }
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid file type. Only JPG, JPEG, and PNG are allowed.']);
            }
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error uploading file']);
        }
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}


