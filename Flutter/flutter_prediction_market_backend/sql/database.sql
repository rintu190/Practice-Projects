CREATE DATABASE IF NOT EXISTS poly_market;
USE poly_market;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15) UNIQUE NOT NULL,
    wallet_balance DECIMAL(10, 2) DEFAULT 5000.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS markets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    yes_price DECIMAL(5, 2) NOT NULL,
    no_price DECIMAL(5, 2) NOT NULL,
    yes_shares INT DEFAULT 0,
    no_shares INT DEFAULT 0,
    liquidity_k DECIMAL(10,2) DEFAULT 500.00,
    volume DECIMAL(15, 2) DEFAULT 0.00,
    volume_24h DECIMAL(15, 2) DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_ending_soon BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE', 'RESOLVED', 'CANCELLED') DEFAULT 'ACTIVE',
    winning_outcome ENUM('PENDING', 'YES', 'NO') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    market_id INT NOT NULL,
    outcome ENUM('YES', 'NO') NOT NULL,
    shares INT NOT NULL,
    price_per_share DECIMAL(5,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (market_id) REFERENCES markets(id)
);

CREATE TABLE IF NOT EXISTS user_positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    market_id INT NOT NULL,
    yes_shares INT DEFAULT 0,
    no_shares INT DEFAULT 0,
    total_invested DECIMAL(10,2) DEFAULT 0.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY user_market_unique (user_id, market_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (market_id) REFERENCES markets(id)
);

/* Mock Data */
INSERT INTO users (id, mobile, wallet_balance) 
VALUES (1, '9999999999', 5000.00)
ON DUPLICATE KEY UPDATE wallet_balance = VALUES(wallet_balance);

INSERT IGNORE INTO markets (id, category, title, yes_price, no_price, yes_shares, no_shares, liquidity_k, volume, volume_24h, start_date, end_date, is_ending_soon, status) VALUES
(1, 'Sports', 'CSK vs MI - Who will win the match?', 62.00, 38.00, 1500, 700, 2000.00, 250000.00, 45000.00, '2026-03-25', '2026-04-10', FALSE, 'ACTIVE'),
(2, 'Politics', 'NDA to secure 400+ seats in 2024 Elections?', 75.00, 25.00, 3000, 1000, 2500.00, 1400000.00, 120000.00, '2026-01-15', '2026-06-04', FALSE, 'ACTIVE'),
(3, 'Finance', 'NIFTY 50 to cross 25,000 before December?', 45.00, 55.00, 800, 1000, 1500.00, 820000.00, 22000.00, '2026-02-01', '2026-12-31', FALSE, 'ACTIVE'),
(4, 'Movies', 'Will Kalki 2898 AD gross ₹1000 Crore globally?', 80.00, 20.00, 1600, 400, 1000.00, 110000.00, 84000.00, '2026-03-10', '2026-05-30', TRUE, 'ACTIVE'),
(5, 'Crypto', 'Bitcoin to reach $100k by December?', 52.00, 48.00, 520, 480, 1000.00, 3400000.00, 500000.00, '2026-01-01', '2026-12-31', FALSE, 'ACTIVE');



