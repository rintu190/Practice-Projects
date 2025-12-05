<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class ProfileController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->authenticate();
    }

    private function authenticate() {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authHeader = $headers['Authorization'] ?? '';

        if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
            $payload = JWT::verify($token);
            if ($payload) {
                $this->userId = $payload['id'];
                return;
            }
        }
        
        $this->sendResponse(401, false, 'Unauthorized');
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'get':
                $this->getProfile();
                break;
            case 'update':
                $this->updateProfile();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getProfile() {
        try {
            $stmt = $this->conn->prepare("
                SELECT u.phone, u.email, u.referral_code,
                       p.full_name, p.date_of_birth, p.gender, 
                       p.address, p.city, p.state, p.pincode, p.profile_image
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE u.id = ?
            ");
            $stmt->execute([$this->userId]);
            $profile = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$profile) {
                $this->sendResponse(404, false, 'Profile not found');
            }
            
            $this->sendResponse(200, true, 'Profile fetched successfully', $profile);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch profile: ' . $e->getMessage());
        }
    }

    private function updateProfile() {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $fullName = $data['full_name'] ?? null;
        $email = $data['email'] ?? null;
        $dateOfBirth = $data['date_of_birth'] ?? null;
        $gender = $data['gender'] ?? null;
        $address = $data['address'] ?? null;
        $city = $data['city'] ?? null;
        $state = $data['state'] ?? null;
        $pincode = $data['pincode'] ?? null;

        if (!$fullName) {
            $this->sendResponse(400, false, 'Full name is required');
        }

        try {
            // Start transaction
            $this->conn->beginTransaction();

            // Update email in users table if provided
            if ($email) {
                $stmt = $this->conn->prepare("UPDATE users SET email = ? WHERE id = ?");
                $stmt->execute([$email, $this->userId]);
            }

            // Check if profile exists
            $stmt = $this->conn->prepare("SELECT user_id FROM user_profiles WHERE user_id = ?");
            $stmt->execute([$this->userId]);
            $exists = $stmt->fetch();

            if ($exists) {
                // Update existing profile
                $stmt = $this->conn->prepare("
                    UPDATE user_profiles 
                    SET full_name = ?, date_of_birth = ?, gender = ?, 
                        address = ?, city = ?, state = ?, pincode = ?,
                        updated_at = NOW()
                    WHERE user_id = ?
                ");
                $stmt->execute([
                    $fullName, $dateOfBirth, $gender,
                    $address, $city, $state, $pincode,
                    $this->userId
                ]);
            } else {
                // Insert new profile
                $stmt = $this->conn->prepare("
                    INSERT INTO user_profiles 
                    (user_id, full_name, date_of_birth, gender, address, city, state, pincode)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ");
                $stmt->execute([
                    $this->userId, $fullName, $dateOfBirth, $gender,
                    $address, $city, $state, $pincode
                ]);
            }

            $this->conn->commit();
            $this->sendResponse(200, true, 'Profile updated successfully');
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to update profile: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        $response = [
            'success' => $success,
            'message' => $message
        ];
        if ($data !== null) {
            $response['data'] = $data;
        }
        echo json_encode($response);
        exit();
    }
}

// Handle request
if (isset($_GET['action'])) {
    $profile = new ProfileController();
    $profile->handleRequest($_GET['action']);
}
?>
