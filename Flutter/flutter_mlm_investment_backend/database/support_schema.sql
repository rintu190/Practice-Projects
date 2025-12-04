-- Support Tickets Table
CREATE TABLE IF NOT EXISTS support_tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    category ENUM('general', 'investment', 'withdrawal', 'technical', 'account', 'other') DEFAULT 'general',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    resolved_by INT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_category (category)
);

-- Ticket Messages/Replies Table
CREATE TABLE IF NOT EXISTS ticket_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id)
);

-- FAQs Table
CREATE TABLE IF NOT EXISTS faqs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category ENUM('general', 'investment', 'withdrawal', 'account', 'security', 'mlm') DEFAULT 'general',
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_active (is_active)
);

-- Chat Messages Table (Simple Implementation)
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    admin_id INT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Insert Sample FAQs
INSERT INTO faqs (category, question, answer, display_order) VALUES
('investment', 'How do I start investing?', 'To start investing, navigate to the Investment tab, browse available plans, select one that suits your goals, and click "Invest Now". Ensure you have sufficient balance in your E-Wallet.', 1),
('investment', 'What is ROI and how is it calculated?', 'ROI (Return on Investment) is the profit you earn on your investment. It is calculated based on the plan''s percentage and frequency (daily, weekly, or monthly). For example, a 10% monthly plan on ₹10,000 earns ₹1,000 per month.', 2),
('investment', 'Can I withdraw my investment before maturity?', 'Yes, but early withdrawal may incur penalties as specified in the plan details. Check the "Early Withdrawal Penalty" before investing.', 3),
('withdrawal', 'How long does a withdrawal take?', 'Withdrawals are processed within 24-48 hours after admin approval. Bank transfers may take an additional 1-3 business days.', 1),
('withdrawal', 'What is the minimum withdrawal amount?', 'The minimum withdrawal amount is ₹500. Ensure your E-Wallet balance meets this requirement.', 2),
('account', 'How do I verify my KYC?', 'Go to Profile > KYC Documents, upload your ID proof (Aadhaar, PAN, etc.), and submit. Admin will verify within 24 hours.', 1),
('account', 'How do I change my password?', 'Navigate to Profile > Settings > Change Password. Enter your current password and new password, then save.', 2),
('mlm', 'How does the referral system work?', 'Share your unique referral code with friends. When they register and invest, you earn commissions based on the MLM plan (Direct Bonus, Level Commissions, etc.).', 1),
('mlm', 'What are the different MLM ranks?', 'Ranks include Member, Bronze, Silver, Gold, Platinum, and Diamond. Ranks are assigned based on your investment volume and team performance.', 2),
('security', 'Is my money safe?', 'Yes, we use bank-grade encryption and secure payment gateways. Your funds are held in segregated accounts and monitored 24/7.', 1),
('general', 'How do I contact support?', 'You can create a support ticket, use live chat, or email us at support@example.com. We respond within 24 hours.', 1);
