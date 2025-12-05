<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class UsersController {
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
            case 'get_profile':
                $this->getProfile();
                break;
            case 'update_profile':
                $this->updateProfile();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getProfile() {
        try {
            $stmt = $this->conn->prepare("
                SELECT u.id, u.phone, u.email, u.referral_code, u.referred_by, u.status, u.rank, u.kyc_status, u.created_at,
                       p.full_name, p.date_of_birth, p.gender, p.address, p.city, p.state, p.pincode, p.profile_image,
                       w.e_wallet_balance, w.earnings_balance, w.total_earned
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                LEFT JOIN wallets w ON u.id = w.user_id
                WHERE u.id = ?
            ");
            $stmt->execute([$this->userId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user) {
                $this->sendResponse(404, false, 'User not found');
            }

            // Remove sensitive data
            unset($user['password_hash']);

            $this->sendResponse(200, true, 'Profile fetched successfully', $user);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching profile: ' . $e->getMessage());
        }
    }

    private function updateProfile() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            
            $fullName = $input['full_name'] ?? null;
            $dateOfBirth = $input['date_of_birth'] ?? null;
            $gender = $input['gender'] ?? null;
            $address = $input['address'] ?? null;
            $city = $input['city'] ?? null;
            $state = $input['state'] ?? null;
            $pincode = $input['pincode'] ?? null;
            $email = $input['email'] ?? null;

            // Update user_profiles
            $stmt = $this->conn->prepare("
                INSERT INTO user_profiles (user_id, full_name, date_of_birth, gender, address, city, state, pincode)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    full_name = VALUES(full_name),
                    date_of_birth = VALUES(date_of_birth),
                    gender = VALUES(gender),
                    address = VALUES(address),
                    city = VALUES(city),
                    state = VALUES(state),
                    pincode = VALUES(pincode)
            ");
            $stmt->execute([$this->userId, $fullName, $dateOfBirth, $gender, $address, $city, $state, $pincode]);

            // Update email in users table if provided
            if ($email) {
                $emailStmt = $this->conn->prepare("UPDATE users SET email = ? WHERE id = ?");
                $emailStmt->execute([$email, $this->userId]);
            }

            $this->sendResponse(200, true, 'Profile updated successfully');
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error updating profile: ' . $e->getMessage());
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
    $users = new UsersController();
    $users->handleRequest($_GET['action']);
}
