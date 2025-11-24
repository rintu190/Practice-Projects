-- Create commissions table
CREATE TABLE IF NOT EXISTS commissions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    order_id VARCHAR(36) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
