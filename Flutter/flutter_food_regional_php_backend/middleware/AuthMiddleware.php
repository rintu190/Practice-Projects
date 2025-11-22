<?php

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware {
    
    public static function authenticate() {
        $headers = null;
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
        }
        
        $authHeader = null;
        if (isset($headers['Authorization'])) {
            $authHeader = $headers['Authorization'];
        } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
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
