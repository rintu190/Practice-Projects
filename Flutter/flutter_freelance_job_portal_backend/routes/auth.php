<?php
// Auth Routes

if (!isset($action)) {
    sendResponse(400, false, 'Invalid request');
}

$db = Database::getInstance();
$conn = $db->getConnection();

switch ($action) {
    case 'register':
        handleRegister($conn);
        break;
    case 'login':
        handleLogin($conn);
        break;
    case 'social_login':
        // TODO: Implement social login
        sendResponse(501, false, 'Social login not implemented');
        break;
    default:
        sendResponse(404, false, 'Invalid auth action');
}

function handleRegister($conn) {
    // Get JSON input
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['email']) || !isset($data['password']) || !isset($data['user_type'])) {
        sendResponse(400, false, 'Missing required fields');
    }
    
    // Hash password
    $password_hash = password_hash($data['password'], PASSWORD_DEFAULT);
    
    // Insert user
    $sql = "INSERT INTO users (email, password_hash, user_type, name, phone, created_at) VALUES (:email, :password, :type, :name, :phone, NOW())";
    $stmt = $conn->prepare($sql);
    
    try {
        $stmt->execute([
            ':email' => $data['email'],
            ':password' => $password_hash,
            ':type' => $data['user_type'],
            ':name' => $data['name'] ?? '',
            ':phone' => $data['phone'] ?? ''
        ]);
        
        $userId = $conn->lastInsertId();
        sendResponse(201, true, 'User registered successfully', ['user_id' => $userId]);
    } catch (PDOException $e) {
        if ($e->getCode() == 23000) { // Duplicate entry
            sendResponse(409, false, 'Email already exists');
        } else {
            sendResponse(500, false, 'Registration failed: ' . $e->getMessage());
        }
    }
}

function handleLogin($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['email']) || !isset($data['password'])) {
        sendResponse(400, false, 'Missing email or password');
    }
    
    $sql = "SELECT id, name, email, password_hash, user_type FROM users WHERE email = :email";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':email' => $data['email']]);
    
    $user = $stmt->fetch();
    
    if ($user && password_verify($data['password'], $user['password_hash'])) {
        // Remove password from response
        unset($user['password_hash']);
        sendResponse(200, true, 'Login successful', ['user' => $user]);
    } else {
        sendResponse(401, false, 'Invalid credentials');
    }
}
