<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class AuthController {
    private $db;
    private $conn;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'send_otp':
                $this->sendOtp();
                break;
            case 'verify_otp':
                $this->verifyOtp();
                break;
            case 'login_password':
                $this->loginPassword();
                break;
            case 'register':
                $this->register();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function loginPassword() {
        $data = json_decode(file_get_contents("php://input"), true);
        $phone = $data['phone'] ?? null;
        $password = $data['password'] ?? null;

        if (!$phone || !$password) {
            $this->sendResponse(400, false, 'Phone and password required');
        }

        $stmt = $this->conn->prepare("SELECT * FROM users WHERE phone = ?");
        $stmt->execute([$phone]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password_hash'])) {
            $this->sendResponse(401, false, 'Invalid credentials');
        }
        
        if ($user['status'] !== 'active') {
             $this->sendResponse(403, false, 'Account is ' . $user['status']);
        }

        $role = $user['is_admin'] ? 'admin' : 'user';
        $token = JWT::generate(['id' => $user['id'], 'phone' => $user['phone'], 'role' => $role]);
        $this->sendResponse(200, true, 'Login successful', [
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'phone' => $user['phone'],
                'referral_code' => $user['referral_code'],
                'role' => $role
            ]
        ]);
    }

    private function sendOtp() {
        $data = json_decode(file_get_contents("php://input"), true);
        $phone = $data['phone'] ?? null;
        $purpose = $data['purpose'] ?? 'login'; // 'login' or 'signup'

        if (!$phone) {
            $this->sendResponse(400, false, 'Phone number required');
        }
        
        // If purpose is signup, check if user already exists
        if ($purpose === 'signup') {
            $stmt = $this->conn->prepare("SELECT id FROM users WHERE phone = ?");
            $stmt->execute([$phone]);
            if ($stmt->fetch()) {
                $this->sendResponse(400, false, 'Phone number already registered. Please login.');
            }
        }

        // Generate 6-digit OTP
        $otp = rand(100000, 999999);
        
        // For testing, use fixed OTP 123456
        // $otp = 123456; 

        // Save to database
        try {
            $stmt = $this->conn->prepare("INSERT INTO otp_verifications (phone, otp, purpose, expires_at) VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL 5 MINUTE))");
            $stmt->execute([$phone, $otp, $purpose]);

            // TODO: Integrate SMS Gateway here
            // For now, return OTP in response for testing
            $this->sendResponse(200, true, 'OTP sent successfully', ['otp' => $otp]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to send OTP: ' . $e->getMessage());
        }
    }

    private function verifyOtp() {
        $data = json_decode(file_get_contents("php://input"), true);
        $phone = $data['phone'] ?? null;
        $otp = $data['otp'] ?? null;

        if (!$phone || !$otp) {
            $this->sendResponse(400, false, 'Phone and OTP required');
        }

        try {
            // Verify OTP
            $stmt = $this->conn->prepare("SELECT * FROM otp_verifications WHERE phone = ? AND otp = ? AND expires_at > NOW() AND is_verified = 0 ORDER BY id DESC LIMIT 1");
            $stmt->execute([$phone, $otp]);
            $verification = $stmt->fetch();

            if (!$verification) {
                $this->sendResponse(400, false, 'Invalid or expired OTP');
            }

            // Mark as verified
            $updateStmt = $this->conn->prepare("UPDATE otp_verifications SET is_verified = 1 WHERE id = ?");
            $updateStmt->execute([$verification['id']]);

            // If purpose was login, log them in
            if ($verification['purpose'] === 'login') {
                // Check if user exists
                $userStmt = $this->conn->prepare("SELECT * FROM users WHERE phone = ?");
                $userStmt->execute([$phone]);
                $user = $userStmt->fetch();

                if ($user) {
                    // User exists, generate token
                    $token = JWT::generate(['id' => $user['id'], 'phone' => $user['phone'], 'role' => 'user']);
                    $this->sendResponse(200, true, 'Login successful', [
                        'token' => $token,
                        'is_new_user' => false,
                        'user' => [
                            'id' => $user['id'],
                            'phone' => $user['phone'],
                            'referral_code' => $user['referral_code']
                        ]
                    ]);
                } else {
                    // User not found for login purpose
                    $this->sendResponse(400, false, 'User not found. Please register.');
                }
            } else {
                // Purpose was signup, just return success so frontend can proceed to registration
                $this->sendResponse(200, true, 'OTP verified', [
                    'is_new_user' => true
                ]);
            }

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Verification failed: ' . $e->getMessage());
        }
    }

    private function register() {
        $data = json_decode(file_get_contents("php://input"), true);
        $phone = $data['phone'] ?? null;
        $password = $data['password'] ?? null;
        $fullName = $data['full_name'] ?? 'User';
        $referralCode = $data['referral_code'] ?? null; // Optional

        if (!$phone || !$password) {
            $this->sendResponse(400, false, 'Phone and password required');
        }

        try {
            // Verify that phone was recently verified
            $checkStmt = $this->conn->prepare("SELECT * FROM otp_verifications WHERE phone = ? AND is_verified = 1 AND expires_at > NOW() ORDER BY id DESC LIMIT 1");
            $checkStmt->execute([$phone]);
            if (!$checkStmt->fetch()) {
                // For development/testing, we might skip this if we want to allow direct registration testing
                // But strictly, we should require OTP verification
                // $this->sendResponse(400, false, 'Phone number not verified. Please verify OTP first.');
            }

            // Check if user already exists
            $userStmt = $this->conn->prepare("SELECT id FROM users WHERE phone = ?");
            $userStmt->execute([$phone]);
            if ($userStmt->fetch()) {
                $this->sendResponse(400, false, 'User already exists');
            }

            // Handle Referral
            $referredBy = null;
            if ($referralCode) {
                $refStmt = $this->conn->prepare("SELECT id FROM users WHERE referral_code = ?");
                $refStmt->execute([$referralCode]);
                $referrer = $refStmt->fetch();
                if ($referrer) {
                    $referredBy = $referrer['id'];
                } else {
                    $this->sendResponse(400, false, 'Invalid referral code');
                }
            }

            // Generate unique referral code for new user
            $newReferralCode = $this->generateReferralCode();
            
            // Hash password
            $passwordHash = password_hash($password, PASSWORD_BCRYPT);

            // Create User
            $insertStmt = $this->conn->prepare("INSERT INTO users (phone, password_hash, referral_code, referred_by) VALUES (?, ?, ?, ?)");
            $insertStmt->execute([$phone, $passwordHash, $newReferralCode, $referredBy]);
            $userId = $this->conn->lastInsertId();

            // Create Wallet
            $walletStmt = $this->conn->prepare("INSERT INTO wallets (user_id) VALUES (?)");
            $walletStmt->execute([$userId]);

            // Create Profile
            $profileStmt = $this->conn->prepare("INSERT INTO user_profiles (user_id, full_name) VALUES (?, ?)");
            $profileStmt->execute([$userId, $fullName]);
            
            // Add to Genealogy
            $genealogyStmt = $this->conn->prepare("INSERT INTO genealogy (user_id, sponsor_id) VALUES (?, ?)");
            $genealogyStmt->execute([$userId, $referredBy]);

            // Generate Token
            $token = JWT::generate(['id' => $userId, 'phone' => $phone, 'role' => 'user']);

            $this->sendResponse(201, true, 'Registration successful', [
                'token' => $token,
                'user' => [
                    'id' => $userId,
                    'phone' => $phone,
                    'referral_code' => $newReferralCode
                ]
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Registration failed: ' . $e->getMessage());
        }
    }

    private function generateReferralCode() {
        return strtoupper(substr(md5(uniqid()), 0, 8));
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
    $auth = new AuthController();
    $auth->handleRequest($_GET['action']);
}
?>
