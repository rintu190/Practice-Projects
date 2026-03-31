CREATE DATABASE IF NOT EXISTS saree_haven_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE saree_haven_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('customer', 'seller', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Artisans Table
CREATE TABLE IF NOT EXISTS artisans (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL,
    image_url TEXT,
    bio TEXT,
    rating FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sellers Table
CREATE TABLE IF NOT EXISTS sellers (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NULL,
    store_name VARCHAR(150) NOT NULL,
    owner_name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL,
    image_url TEXT,
    bio TEXT,
    rating FLOAT DEFAULT 0.0,
    contact_email VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(20) NOT NULL,
    specialization VARCHAR(100),
    total_orders INT DEFAULT 0,
    pending_orders INT DEFAULT 0,
    total_earning DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sarees Table
CREATE TABLE IF NOT EXISTS sarees (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    image_urls JSON,
    artisan_id VARCHAR(50),
    seller_id VARCHAR(50),
    in_stock BOOLEAN DEFAULT TRUE,
    is_customizable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artisan_id) REFERENCES artisans(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_address TEXT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    seller_id VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    saree_id VARCHAR(50),
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (saree_id) REFERENCES sarees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Mock Data
INSERT IGNORE INTO artisans (id, name, location, image_url, bio, rating) VALUES 
('a1', 'Radha Devi', 'Varanasi, UP', 'https://images.pexels.com/photos/3621168/pexels-photo-3621168.jpeg', 'Weaving Banarasi silk for over 30 years', 4.8),
('a2', 'Mohan Lal', 'Chanderi, MP', 'https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg', 'Expert in lightweight Chanderi sarees', 4.9),
('a3', 'Lakshmi Rao', 'Kanchipuram, TN', 'https://images.pexels.com/photos/3671083/pexels-photo-3671083.jpeg', 'Known for vibrant Kanjivaram designs', 4.7);

INSERT IGNORE INTO sellers (id, store_name, owner_name, location, image_url, bio, rating, contact_email, mobile_number, specialization, total_orders, pending_orders, total_earning) VALUES
('seller1', 'Varanasi Silk House', 'Rajesh Gupta', 'Varanasi, UP', 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg', 'Family-run silk house', 4.9, 'varanasisilk@example.com', '+91 98765 43210', 'Banarasi', 1540, 12, 450000.00),
('seller2', 'Kanchi Traditions', 'Meena Sundaram', 'Kanchipuram, TN', 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg', 'Premium Kanjivaram sarees', 4.8, 'kanchitraditions@example.com', '+91 91234 56789', 'Kanjivaram', 890, 8, 230000.00),
('seller3', 'Madhya Handlooms', 'Priya Sharma', 'Chanderi, MP', 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg', 'Finest Chanderi and Maheshwari', 4.7, 'madhyahandlooms@example.com', '+91 88998 87766', 'Chanderi', 2100, 24, 650000.00),
('seller4', 'Gujarat Weaves', 'Amit Patel', 'Bhuj, Gujarat', 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg', 'Authentic Bandhani and Patola', 4.6, 'gujaratweaves@example.com', '+91 77665 54433', 'Bandhani', 450, 5, 120000.00);

-- Note: We use JSON array for image_urls to match Dart mock
INSERT IGNORE INTO sarees (id, name, description, price, category, type, image_urls, artisan_id, seller_id, in_stock, is_customizable) VALUES
('s1', 'Royal Blue Banarasi', 'Stunning royal blue Banarasi silk saree.', 12500, 'Bridal Saree', 'Banarasi', '["assets/Saree/DHAN5161.jpeg"]', 'a1', 'seller1', TRUE, FALSE),
('s2', 'Pink Chanderi Silk', 'Lightweight pink Chanderi saree.', 4500, 'Daily Wear', 'Chanderi', '["assets/Saree/pinksaree.jpeg"]', 'a2', 'seller3', FALSE, FALSE),
('s3', 'Gold Kanjivaram', 'Classic gold Kanjivaram saree.', 18000, 'Bridal Saree', 'Kanjivaram', '["assets/Saree/Sonarupa-1.jpeg"]', 'a3', 'seller2', TRUE, TRUE),
('s4', 'Red Bandhani', 'Vibrant red Bandhani saree.', 3200, 'Party Wear', 'Bandhani', '["assets/Saree/16611P_1Main.jpeg"]', 'a1', 'seller4', TRUE, FALSE);

-- Shipping Addresses Table
CREATE TABLE IF NOT EXISTS shipping_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    label VARCHAR(50) NOT NULL,
    details TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment Methods Table
CREATE TABLE IF NOT EXISTS payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    last_four VARCHAR(4) NOT NULL,
    expiry VARCHAR(10) NOT NULL,
    card_holder VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wishlists Table
CREATE TABLE IF NOT EXISTS wishlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    saree_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (user_id, saree_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (saree_id) REFERENCES sarees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
