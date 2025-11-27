<?php

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware {
    
    public static function authenticate() {
        $authHeader = null;
        
        // 1. Try apache_request_headers()
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            // Handle case-insensitivity
            $headers = array_change_key_case($headers, CASE_LOWER);
            if (isset($headers['authorization'])) {
                $authHeader = $headers['authorization'];
            }
        }
        
        // 2. Try $_SERVER['HTTP_AUTHORIZATION']
        if (!$authHeader && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        // 3. Try $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] (Common in shared hosting)
        if (!$authHeader && isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
        }
        
        // 4. Try getting from $_GET for debugging/fallback (optional, but useful)
        if (!$authHeader && isset($_GET['token'])) {
            $authHeader = 'Bearer ' . $_GET['token'];
        }

        if (!$authHeader) {
            http_response_code(401);
            echo json_encode(['error' => 'No token provided']);
            exit();
        }
        $arr = explode(" ", $authHeader);
        
        if (count($arr) !== 2 || $arr[0] !== 'Bearer') {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid authorization header']);
            exit();
        }

        $token = $arr[1];
        $secret = $_ENV['JWT_SECRET'] ?? 'your_secret_key_here';

        try {
            $decoded = JWT::decode($token, new Key($secret, 'HS256'));
            return $decoded->userId;
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid token']);
            exit();
        }
    }
}
