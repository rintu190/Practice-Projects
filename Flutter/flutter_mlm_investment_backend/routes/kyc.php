<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class KycController {
    private $db;
    private $conn;
    private $uploadDir;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->uploadDir = __DIR__ . '/../uploads/kyc/';
        
        // Create upload directory if it doesn't exist
        if (!file_exists($this->uploadDir)) {
            mkdir($this->uploadDir, 0755, true);
        }
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'upload':
                $this->uploadKyc();
                break;
            case 'get_status':
                $this->getKycStatus();
                break;
            case 'update':
                $this->updateKyc();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        
        if (!$authHeader || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $this->sendResponse(401, false, 'Unauthorized - No token provided');
        }

        $token = $matches[1];
        $decoded = JWT::verify($token);
        
        if (!$decoded) {
            $this->sendResponse(401, false, 'Unauthorized - Invalid token');
        }

        return $decoded['id'];
    }

    private function uploadKyc() {
        $userId = $this->authenticate();
        
        // Get form data
        $panNumber = $_POST['pan_number'] ?? null;
        $aadhaarNumber = $_POST['aadhaar_number'] ?? null;

        // Validate PAN format
        if ($panNumber && !preg_match('/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/', $panNumber)) {
            $this->sendResponse(400, false, 'Invalid PAN format');
        }

        // Validate Aadhaar format
        if ($aadhaarNumber && !preg_match('/^[0-9]{12}$/', $aadhaarNumber)) {
            $this->sendResponse(400, false, 'Invalid Aadhaar format');
        }

        try {
            // Create user-specific directory
            $userDir = $this->uploadDir . $userId . '/';
            if (!file_exists($userDir)) {
                mkdir($userDir, 0755, true);
            }

            $panImage = null;
            $aadhaarFront = null;
            $aadhaarBack = null;

            // Handle PAN image upload
            if (isset($_FILES['pan_image']) && $_FILES['pan_image']['error'] === UPLOAD_ERR_OK) {
                $panImage = $this->handleFileUpload($_FILES['pan_image'], $userDir, 'pan');
            }

            // Handle Aadhaar front image upload
            if (isset($_FILES['aadhaar_front']) && $_FILES['aadhaar_front']['error'] === UPLOAD_ERR_OK) {
                $aadhaarFront = $this->handleFileUpload($_FILES['aadhaar_front'], $userDir, 'aadhaar_front');
            }

            // Handle Aadhaar back image upload
            if (isset($_FILES['aadhaar_back']) && $_FILES['aadhaar_back']['error'] === UPLOAD_ERR_OK) {
                $aadhaarBack = $this->handleFileUpload($_FILES['aadhaar_back'], $userDir, 'aadhaar_back');
            }

            // Check if KYC record exists
            $checkStmt = $this->conn->prepare("SELECT id FROM kyc_documents WHERE user_id = ?");
            $checkStmt->execute([$userId]);
            $existing = $checkStmt->fetch();

            if ($existing) {
                // Update existing record
                $updateFields = [];
                $params = [];
                
                if ($panNumber) {
                    $updateFields[] = "pan_number = ?";
                    $params[] = $panNumber;
                }
                if ($panImage) {
                    $updateFields[] = "pan_image = ?";
                    $params[] = $panImage;
                }
                if ($aadhaarNumber) {
                    $updateFields[] = "aadhaar_number = ?";
                    $params[] = $aadhaarNumber;
                }
                if ($aadhaarFront) {
                    $updateFields[] = "aadhaar_front_image = ?";
                    $params[] = $aadhaarFront;
                }
                if ($aadhaarBack) {
                    $updateFields[] = "aadhaar_back_image = ?";
                    $params[] = $aadhaarBack;
                }
                
                $updateFields[] = "status = 'pending'";
                $updateFields[] = "submitted_at = NOW()";
                $params[] = $userId;

                $sql = "UPDATE kyc_documents SET " . implode(', ', $updateFields) . " WHERE user_id = ?";
                $stmt = $this->conn->prepare($sql);
                $stmt->execute($params);
            } else {
                // Insert new record
                $stmt = $this->conn->prepare(
                    "INSERT INTO kyc_documents (user_id, pan_number, pan_image, aadhaar_number, aadhaar_front_image, aadhaar_back_image, status, submitted_at) 
                     VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())"
                );
                $stmt->execute([$userId, $panNumber, $panImage, $aadhaarNumber, $aadhaarFront, $aadhaarBack]);
            }

            // Update user's KYC status
            $userStmt = $this->conn->prepare("UPDATE users SET kyc_status = 'submitted' WHERE id = ?");
            $userStmt->execute([$userId]);

            $this->sendResponse(200, true, 'KYC documents uploaded successfully', [
                'status' => 'submitted',
                'pan_uploaded' => $panImage !== null,
                'aadhaar_uploaded' => ($aadhaarFront !== null && $aadhaarBack !== null)
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Upload failed: ' . $e->getMessage());
        }
    }

    private function handleFileUpload($file, $userDir, $prefix) {
        // Validate file type by MIME
        $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf', 'application/octet-stream'];
        
        // Get file extension
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'pdf'];
        
        // Check MIME type OR extension (some systems send generic octet-stream)
        if (!in_array($file['type'], $allowedTypes) && !in_array($extension, $allowedExtensions)) {
            throw new Exception('Invalid file type. Only JPG, JPEG, PNG, WEBP and PDF allowed. Received: ' . $file['type']);
        }
        
        // Additional check: if MIME is octet-stream, verify extension
        if ($file['type'] === 'application/octet-stream' && !in_array($extension, $allowedExtensions)) {
            throw new Exception('Invalid file extension. Only JPG, JPEG, PNG, WEBP and PDF allowed.');
        }

        // Validate file size (max 5MB)
        if ($file['size'] > 5 * 1024 * 1024) {
            throw new Exception('File size exceeds 5MB limit.');
        }

        // Generate unique filename
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = $prefix . '_' . time() . '_' . uniqid() . '.' . $extension;
        $filepath = $userDir . $filename;

        // Move uploaded file
        if (!move_uploaded_file($file['tmp_name'], $filepath)) {
            throw new Exception('Failed to save file.');
        }

        // Return relative path
        return 'uploads/kyc/' . basename($userDir) . '/' . $filename;
    }

    private function getKycStatus() {
        $userId = $this->authenticate();

        try {
            $stmt = $this->conn->prepare(
                "SELECT k.*, u.kyc_status as user_kyc_status 
                 FROM kyc_documents k 
                 RIGHT JOIN users u ON k.user_id = u.id 
                 WHERE u.id = ?"
            );
            $stmt->execute([$userId]);
            $kyc = $stmt->fetch();

            if (!$kyc || !$kyc['id']) {
                $this->sendResponse(200, true, 'No KYC documents uploaded', [
                    'status' => $kyc['user_kyc_status'] ?? 'pending',
                    'documents' => null
                ]);
            }

            $this->sendResponse(200, true, 'KYC status retrieved', [
                'status' => $kyc['status'],
                'pan_number' => $kyc['pan_number'],
                'aadhaar_number' => $kyc['aadhaar_number'] ? substr($kyc['aadhaar_number'], 0, 4) . 'XXXX' . substr($kyc['aadhaar_number'], -4) : null,
                'pan_uploaded' => !empty($kyc['pan_image']),
                'aadhaar_uploaded' => !empty($kyc['aadhaar_front_image']) && !empty($kyc['aadhaar_back_image']),
                'submitted_at' => $kyc['submitted_at'],
                'verified_at' => $kyc['verified_at'],
                'rejection_reason' => $kyc['rejection_reason']
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch KYC status: ' . $e->getMessage());
        }
    }

    private function updateKyc() {
        // Same as upload, but for updating existing documents
        $this->uploadKyc();
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
    $kyc = new KycController();
    $kyc->handleRequest($_GET['action']);
}
?>
