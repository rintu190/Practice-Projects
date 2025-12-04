<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class SupportController {
    private $db;
    private $conn;
    private $userId;
    private $isAdmin = false;

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
                $this->isAdmin = ($payload['role'] ?? '') === 'admin';
                return;
            }
        }
        $this->sendResponse(401, false, 'Unauthorized');
    }

    public function handleRequest($action) {
        switch ($action) {
            // Tickets
            case 'create_ticket':
                $this->createTicket();
                break;
            case 'get_my_tickets':
                $this->getMyTickets();
                break;
            case 'get_ticket_details':
                $this->getTicketDetails();
                break;
            case 'add_ticket_message':
                $this->addTicketMessage();
                break;
            case 'update_ticket_status':
                $this->updateTicketStatus();
                break;
            
            // FAQs
            case 'get_faqs':
                $this->getFAQs();
                break;
            
            // Chat
            case 'send_chat_message':
                $this->sendChatMessage();
                break;
            case 'get_chat_messages':
                $this->getChatMessages();
                break;
            
            // Admin only
            case 'get_all_tickets':
                if (!$this->isAdmin) $this->sendResponse(403, false, 'Admin access required');
                $this->getAllTickets();
                break;
            case 'manage_faq':
                if (!$this->isAdmin) $this->sendResponse(403, false, 'Admin access required');
                $this->manageFAQ();
                break;
                
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    // ==================== TICKETS ====================
    
    private function createTicket() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            
            $subject = $input['subject'] ?? null;
            $description = $input['description'] ?? null;
            $category = $input['category'] ?? 'general';
            $priority = $input['priority'] ?? 'medium';
            
            if (!$subject || !$description) {
                $this->sendResponse(400, false, 'Subject and description are required');
            }
            
            $stmt = $this->conn->prepare("
                INSERT INTO support_tickets (user_id, subject, category, priority, description, status)
                VALUES (?, ?, ?, ?, ?, 'open')
            ");
            $stmt->execute([$this->userId, $subject, $category, $priority, $description]);
            
            $ticketId = $this->conn->lastInsertId();
            
            $this->sendResponse(200, true, 'Ticket created successfully', ['ticket_id' => $ticketId]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error creating ticket: ' . $e->getMessage());
        }
    }
    
    private function getMyTickets() {
        try {
            $status = $_GET['status'] ?? 'all';
            
            $sql = "
                SELECT t.*, u.phone as user_phone,
                       (SELECT COUNT(*) FROM ticket_messages WHERE ticket_id = t.id) as message_count
                FROM support_tickets t
                LEFT JOIN users u ON t.user_id = u.id
                WHERE t.user_id = ?
            ";
            
            if ($status !== 'all') {
                $sql .= " AND t.status = ?";
            }
            
            $sql .= " ORDER BY t.created_at DESC";
            
            $stmt = $this->conn->prepare($sql);
            if ($status !== 'all') {
                $stmt->execute([$this->userId, $status]);
            } else {
                $stmt->execute([$this->userId]);
            }
            
            $tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Tickets retrieved', $tickets);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching tickets: ' . $e->getMessage());
        }
    }
    
    private function getAllTickets() {
        try {
            $status = $_GET['status'] ?? 'all';
            $category = $_GET['category'] ?? 'all';
            
            $sql = "
                SELECT t.*, u.phone as user_phone,
                       (SELECT COUNT(*) FROM ticket_messages WHERE ticket_id = t.id) as message_count
                FROM support_tickets t
                LEFT JOIN users u ON t.user_id = u.id
                WHERE 1=1
            ";
            
            $params = [];
            
            if ($status !== 'all') {
                $sql .= " AND t.status = ?";
                $params[] = $status;
            }
            
            if ($category !== 'all') {
                $sql .= " AND t.category = ?";
                $params[] = $category;
            }
            
            $sql .= " ORDER BY t.priority DESC, t.created_at DESC LIMIT 100";
            
            $stmt = $this->conn->prepare($sql);
            $stmt->execute($params);
            
            $tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Tickets retrieved', $tickets);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching tickets: ' . $e->getMessage());
        }
    }
    
    private function getTicketDetails() {
        try {
            $ticketId = $_GET['ticket_id'] ?? null;
            if (!$ticketId) $this->sendResponse(400, false, 'Ticket ID required');
            
            // Get ticket
            $stmt = $this->conn->prepare("
                SELECT t.*, u.phone as user_phone
                FROM support_tickets t
                LEFT JOIN users u ON t.user_id = u.id
                WHERE t.id = ?
            ");
            $stmt->execute([$ticketId]);
            $ticket = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ticket) {
                $this->sendResponse(404, false, 'Ticket not found');
            }
            
            // Check access
            if (!$this->isAdmin && $ticket['user_id'] != $this->userId) {
                $this->sendResponse(403, false, 'Access denied');
            }
            
            // Get messages
            $stmt = $this->conn->prepare("
                SELECT m.*, u.phone as user_phone
                FROM ticket_messages m
                LEFT JOIN users u ON m.user_id = u.id
                WHERE m.ticket_id = ?
                ORDER BY m.created_at ASC
            ");
            $stmt->execute([$ticketId]);
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Ticket details retrieved', [
                'ticket' => $ticket,
                'messages' => $messages
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching ticket details: ' . $e->getMessage());
        }
    }
    
    private function addTicketMessage() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            
            $ticketId = $input['ticket_id'] ?? null;
            $message = $input['message'] ?? null;
            
            if (!$ticketId || !$message) {
                $this->sendResponse(400, false, 'Ticket ID and message are required');
            }
            
            // Verify access
            $stmt = $this->conn->prepare("SELECT user_id FROM support_tickets WHERE id = ?");
            $stmt->execute([$ticketId]);
            $ticket = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ticket) {
                $this->sendResponse(404, false, 'Ticket not found');
            }
            
            if (!$this->isAdmin && $ticket['user_id'] != $this->userId) {
                $this->sendResponse(403, false, 'Access denied');
            }
            
            // Add message
            $stmt = $this->conn->prepare("
                INSERT INTO ticket_messages (ticket_id, user_id, message, is_admin)
                VALUES (?, ?, ?, ?)
            ");
            $stmt->execute([$ticketId, $this->userId, $message, $this->isAdmin ? 1 : 0]);
            
            // Update ticket status if admin replied
            if ($this->isAdmin) {
                $this->conn->prepare("UPDATE support_tickets SET status = 'in_progress' WHERE id = ? AND status = 'open'")
                    ->execute([$ticketId]);
            }
            
            $this->sendResponse(200, true, 'Message added successfully');
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error adding message: ' . $e->getMessage());
        }
    }
    
    private function updateTicketStatus() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            
            $ticketId = $input['ticket_id'] ?? null;
            $status = $input['status'] ?? null;
            
            if (!$ticketId || !$status) {
                $this->sendResponse(400, false, 'Ticket ID and status are required');
            }
            
            // Verify access
            $stmt = $this->conn->prepare("SELECT user_id FROM support_tickets WHERE id = ?");
            $stmt->execute([$ticketId]);
            $ticket = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$ticket) {
                $this->sendResponse(404, false, 'Ticket not found');
            }
            
            // Only admin or ticket owner can update status
            if (!$this->isAdmin && $ticket['user_id'] != $this->userId) {
                $this->sendResponse(403, false, 'Access denied');
            }
            
            $sql = "UPDATE support_tickets SET status = ?";
            $params = [$status];
            
            if ($status === 'resolved' || $status === 'closed') {
                $sql .= ", resolved_at = NOW(), resolved_by = ?";
                $params[] = $this->userId;
            }
            
            $sql .= " WHERE id = ?";
            $params[] = $ticketId;
            
            $stmt = $this->conn->prepare($sql);
            $stmt->execute($params);
            
            $this->sendResponse(200, true, 'Ticket status updated');
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error updating ticket: ' . $e->getMessage());
        }
    }
    
    // ==================== FAQs ====================
    
    private function getFAQs() {
        try {
            $category = $_GET['category'] ?? 'all';
            
            $sql = "SELECT * FROM faqs WHERE is_active = 1";
            
            if ($category !== 'all') {
                $sql .= " AND category = ?";
            }
            
            $sql .= " ORDER BY display_order ASC, id ASC";
            
            $stmt = $this->conn->prepare($sql);
            if ($category !== 'all') {
                $stmt->execute([$category]);
            } else {
                $stmt->execute();
            }
            
            $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'FAQs retrieved', $faqs);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching FAQs: ' . $e->getMessage());
        }
    }
    
    private function manageFAQ() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            $action = $input['action'] ?? null;
            
            if ($action === 'create') {
                $stmt = $this->conn->prepare("
                    INSERT INTO faqs (category, question, answer, display_order, is_active)
                    VALUES (?, ?, ?, ?, ?)
                ");
                $stmt->execute([
                    $input['category'] ?? 'general',
                    $input['question'],
                    $input['answer'],
                    $input['display_order'] ?? 0,
                    $input['is_active'] ?? 1
                ]);
                $this->sendResponse(200, true, 'FAQ created');
                
            } elseif ($action === 'update') {
                $stmt = $this->conn->prepare("
                    UPDATE faqs 
                    SET category = ?, question = ?, answer = ?, display_order = ?, is_active = ?
                    WHERE id = ?
                ");
                $stmt->execute([
                    $input['category'],
                    $input['question'],
                    $input['answer'],
                    $input['display_order'],
                    $input['is_active'],
                    $input['id']
                ]);
                $this->sendResponse(200, true, 'FAQ updated');
                
            } elseif ($action === 'delete') {
                $stmt = $this->conn->prepare("DELETE FROM faqs WHERE id = ?");
                $stmt->execute([$input['id']]);
                $this->sendResponse(200, true, 'FAQ deleted');
                
            } else {
                $this->sendResponse(400, false, 'Invalid action');
            }
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error managing FAQ: ' . $e->getMessage());
        }
    }
    
    // ==================== CHAT ====================
    
    private function sendChatMessage() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            $message = $input['message'] ?? null;
            
            if (!$message) {
                $this->sendResponse(400, false, 'Message is required');
            }
            
            $stmt = $this->conn->prepare("
                INSERT INTO chat_messages (user_id, message, is_admin)
                VALUES (?, ?, ?)
            ");
            $stmt->execute([$this->userId, $message, $this->isAdmin ? 1 : 0]);
            
            $this->sendResponse(200, true, 'Message sent');
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error sending message: ' . $e->getMessage());
        }
    }
    
    private function getChatMessages() {
        try {
            $limit = $_GET['limit'] ?? 50;
            
            if ($this->isAdmin) {
                // Admin sees all messages
                $userId = $_GET['user_id'] ?? null;
                if ($userId) {
                    $sql = "SELECT c.*, u.phone as user_phone 
                            FROM chat_messages c
                            LEFT JOIN users u ON c.user_id = u.id
                            WHERE c.user_id = ?
                            ORDER BY c.created_at DESC LIMIT ?";
                    $stmt = $this->conn->prepare($sql);
                    $stmt->execute([$userId, $limit]);
                } else {
                    $sql = "SELECT c.*, u.phone as user_phone 
                            FROM chat_messages c
                            LEFT JOIN users u ON c.user_id = u.id
                            ORDER BY c.created_at DESC LIMIT ?";
                    $stmt = $this->conn->prepare($sql);
                    $stmt->execute([$limit]);
                }
            } else {
                // User sees only their messages
                $sql = "SELECT c.*, u.phone as user_phone 
                        FROM chat_messages c
                        LEFT JOIN users u ON c.user_id = u.id
                        WHERE c.user_id = ?
                        ORDER BY c.created_at DESC LIMIT ?";
                $stmt = $this->conn->prepare($sql);
                $stmt->execute([$this->userId, $limit]);
            }
            
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Messages retrieved', array_reverse($messages));
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error fetching messages: ' . $e->getMessage());
        }
    }
    
    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }
}

if (isset($_GET['action'])) {
    $controller = new SupportController();
    $controller->handleRequest($_GET['action']);
}
?>
