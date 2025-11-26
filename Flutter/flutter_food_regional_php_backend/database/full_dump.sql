-- Database Dump for flutter_food_regional
-- Generated at 2025-11-24 18:10:59

SET FOREIGN_KEY_CHECKS=0;

-- Table structure for `addresses`
DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `house_number` varchar(100) NOT NULL,
  `street` varchar(255) NOT NULL,
  `locality` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `pincode` varchar(10) NOT NULL,
  `landmark` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `addresses`
INSERT INTO `addresses` VALUES ('1cb81d3f-024a-404a-a216-051246b24d2d', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '283/405', 'farm road', 'mahanadi vihar', 'boudh', 'odisha', '762014', NULL, '37.42199830', '-122.08400000', '2025-11-23 13:20:52', '2025-11-24 09:15:47', '1');
INSERT INTO `addresses` VALUES ('3fd766d1-194a-4a7a-b60c-a3866b093cd2', 'eb8d60e3-3563-42f9-84f1-9a1511a7ba13', '123', 'Main St', 'Downtown', 'Metropolis', 'NY', '10001', NULL, NULL, NULL, '2025-11-22 17:00:59', '2025-11-22 17:00:59', '0');
INSERT INTO `addresses` VALUES ('92eba9ac-d892-43bc-b55a-28e995a313d5', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', 'wq', 'w', 'qwq', 'qwq', 'wqw', '121', NULL, '39.23725500', '-123.15003170', '2025-11-24 07:33:25', '2025-11-24 07:33:25', '0');

-- Table structure for `commissions`
DROP TABLE IF EXISTS `commissions`;
CREATE TABLE `commissions` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `order_id` varchar(36) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `percentage` decimal(5,2) NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `commissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `commissions_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `commissions`
INSERT INTO `commissions` VALUES ('0a563d38a7ed6a06df1dfdbe08a50149', '1d44c7dc-4b35-4603-846a-63e66a307c21', '79f94a2b-f3a8-4ed8-bd9d-62ccce4e5797', '16.10', '5.00', 'approved', '2025-11-24 07:53:47');
INSERT INTO `commissions` VALUES ('228adb59924ac87a5c8962913d3007c2', 'ef9b7dec-5425-4e65-9f45-7b87b0842ccc', '79f94a2b-f3a8-4ed8-bd9d-62ccce4e5797', '48.30', '15.00', 'approved', '2025-11-24 07:53:47');
INSERT INTO `commissions` VALUES ('3985a22b57074f3e0293b443ddcd3ba9', '1d44c7dc-4b35-4603-846a-63e66a307c21', '74436f44-57e1-4ec5-8308-d3889057d2c8', '16.10', '5.00', 'pending', '2025-11-24 09:19:05');
INSERT INTO `commissions` VALUES ('62eef33b47896cd159fe0826125516cf', 'ef9b7dec-5425-4e65-9f45-7b87b0842ccc', 'a02f2d59-78ae-470a-bae3-34cf3836e83d', '48.30', '15.00', 'approved', '2025-11-24 07:53:50');
INSERT INTO `commissions` VALUES ('c481607a9bd23cf787da4a5aa76176e8', '1d44c7dc-4b35-4603-846a-63e66a307c21', 'a02f2d59-78ae-470a-bae3-34cf3836e83d', '16.10', '5.00', 'approved', '2025-11-24 07:53:50');
INSERT INTO `commissions` VALUES ('cf6e7b4a605b96fee32ae822a3829cc7', 'ef9b7dec-5425-4e65-9f45-7b87b0842ccc', '74436f44-57e1-4ec5-8308-d3889057d2c8', '48.30', '15.00', 'pending', '2025-11-24 09:19:05');

-- Table structure for `menu_items`
DROP TABLE IF EXISTS `menu_items`;
CREATE TABLE `menu_items` (
  `id` varchar(36) NOT NULL,
  `restaurant_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `image_url` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `menu_items_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `menu_items`
INSERT INTO `menu_items` VALUES ('1001', '10', 'Veg Burger', 'Crispy veggie patty with cheese', '120.00', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1002', '10', 'French Fries', 'Crispy golden fries', '80.00', 'https://images.unsplash.com/photo-1576107232684-1279f390859f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1003', '10', 'Cold Coffee', 'Chilled coffee with ice cream', '100.00', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('101', '1', 'Butter Chicken', 'Creamy tomato curry with tender chicken', '320.00', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('102', '1', 'Dal Makhani', 'Black lentils in creamy gravy', '250.00', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('103', '1', 'Tandoori Roti', 'Whole wheat flatbread', '25.00', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1101', '11', 'Margherita Pizza', 'Classic tomato, cheese and basil', '250.00', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=2069&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1102', '11', 'Veggie Supreme', 'Loaded with fresh vegetables', '320.00', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1103', '11', 'Garlic Bread', 'Toasted bread with garlic butter', '120.00', 'https://images.unsplash.com/photo-1573140401552-3fab0b24306f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1201', '12', 'Paneer Wrap', 'Grilled paneer in tortilla wrap', '150.00', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1202', '12', 'Chicken Roll', 'Spicy chicken wrapped in paratha', '180.00', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('1203', '12', 'Spring Roll', 'Crispy vegetable spring rolls', '100.00', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('201', '2', 'Chole Bhature', 'Spicy chickpea curry with fried bread', '180.00', 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('202', '2', 'Paneer Tikka', 'Grilled cottage cheese in spices', '280.00', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('203', '2', 'Lassi', 'Sweet yogurt drink', '60.00', 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('301', '3', 'Amritsari Kulcha', 'Stuffed bread with spicy filling', '90.00', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('302', '3', 'Kadhai Paneer', 'Cottage cheese in spicy tomato gravy', '290.00', 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('401', '4', 'Masala Dosa', 'Crispy rice crepe with potato filling', '120.00', 'https://images.unsplash.com/photo-1630383249896-424e482df921?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('402', '4', 'Idli Sambar', 'Steamed rice cakes with lentil soup', '80.00', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('403', '4', 'Filter Coffee', 'Traditional South Indian coffee', '40.00', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('501', '5', 'Appam with Stew', 'Rice pancake with coconut curry', '150.00', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('502', '5', 'Fish Curry', 'Spicy coconut-based fish curry', '350.00', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('503', '5', 'Puttu Kadala', 'Steamed rice cake with chickpea curry', '100.00', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('601', '6', 'Chicken Biryani', 'Fragrant rice with spiced chicken', '280.00', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('602', '6', 'Mutton Biryani', 'Aromatic rice with tender mutton', '350.00', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('603', '6', 'Raita', 'Yogurt with cucumber and spices', '50.00', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('701', '7', 'Dalma', 'Traditional Odia lentil curry with vegetables', '150.00', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('702', '7', 'Pakhala Bhata', 'Fermented rice with water', '80.00', 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('703', '7', 'Chenna Poda', 'Roasted cottage cheese dessert', '100.00', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('801', '8', 'Machha Besara', 'Fish curry with mustard paste', '320.00', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('802', '8', 'Chhena Jhili', 'Sweet cottage cheese fritters in syrup', '90.00', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('803', '8', 'Santula', 'Mixed vegetable curry', '180.00', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('901', '9', 'Khaja', 'Crispy layered sweet pastry', '120.00', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');
INSERT INTO `menu_items` VALUES ('902', '9', 'Gupchup', 'Crispy puri with spicy water', '50.00', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-22 15:31:27');

-- Table structure for `order_items`
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` varchar(36) NOT NULL,
  `order_id` varchar(36) NOT NULL,
  `menu_item_id` varchar(36) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `menu_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `order_items`
INSERT INTO `order_items` VALUES ('0eeba023-4fc8-4e1e-b804-398fb21e9e1c', 'a02f2d59-78ae-470a-bae3-34cf3836e83d', '101', '1', '320.00');
INSERT INTO `order_items` VALUES ('3018aec2-b98c-48da-b47a-9cafaadcaf1d', 'c13e20de-4ca9-485b-84f2-17d6169281c8', '101', '1', '320.00');
INSERT INTO `order_items` VALUES ('aab273ab-6840-4c0e-a2b5-4000ef5d03aa', '74436f44-57e1-4ec5-8308-d3889057d2c8', '101', '1', '320.00');
INSERT INTO `order_items` VALUES ('bcbbe305-81de-4ca0-935a-61e09bd9f5c5', '7672a374-15e0-49d5-b305-4f1fb19828f2', '101', '1', '320.00');
INSERT INTO `order_items` VALUES ('bf82b50e-ec77-40c2-9bf3-1a62f152c52f', '79f94a2b-f3a8-4ed8-bd9d-62ccce4e5797', '101', '1', '320.00');
INSERT INTO `order_items` VALUES ('f8921d36-b549-4379-bc80-2f901674a192', '7672a374-15e0-49d5-b305-4f1fb19828f2', '1001', '1', '120.00');

-- Table structure for `orders`
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `restaurant_id` varchar(36) NOT NULL,
  `address_id` varchar(36) NOT NULL,
  `rider_id` varchar(36) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `address_id` (`address_id`),
  KEY `fk_orders_rider` (`rider_id`),
  CONSTRAINT `fk_orders_rider` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `orders`
INSERT INTO `orders` VALUES ('74436f44-57e1-4ec5-8308-d3889057d2c8', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '1', '92eba9ac-d892-43bc-b55a-28e995a313d5', '1d44c7dc-4b35-4603-846a-63e66a307c21', '322.00', 'delivered', '2025-11-24 07:51:52', '2025-11-24 09:19:05');
INSERT INTO `orders` VALUES ('7672a374-15e0-49d5-b305-4f1fb19828f2', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '1', '1cb81d3f-024a-404a-a216-051246b24d2d', '1d44c7dc-4b35-4603-846a-63e66a307c21', '442.00', 'rider_assigned', '2025-11-24 17:23:51', '2025-11-24 17:25:07');
INSERT INTO `orders` VALUES ('79f94a2b-f3a8-4ed8-bd9d-62ccce4e5797', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '1', '1cb81d3f-024a-404a-a216-051246b24d2d', '1d44c7dc-4b35-4603-846a-63e66a307c21', '322.00', 'delivered', '2025-11-24 07:37:55', '2025-11-24 07:53:47');
INSERT INTO `orders` VALUES ('a02f2d59-78ae-470a-bae3-34cf3836e83d', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '1', '1cb81d3f-024a-404a-a216-051246b24d2d', '1d44c7dc-4b35-4603-846a-63e66a307c21', '322.00', 'delivered', '2025-11-24 07:42:40', '2025-11-24 07:53:50');
INSERT INTO `orders` VALUES ('c13e20de-4ca9-485b-84f2-17d6169281c8', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', '1', '1cb81d3f-024a-404a-a216-051246b24d2d', '1d44c7dc-4b35-4603-846a-63e66a307c21', '322.00', 'pending', '2025-11-24 09:16:36', '2025-11-24 15:35:10');

-- Table structure for `payment_methods`
DROP TABLE IF EXISTS `payment_methods`;
CREATE TABLE `payment_methods` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `type` varchar(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `subtitle` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `payment_methods`
INSERT INTO `payment_methods` VALUES ('547b84e8-cab5-42d9-9f11-fa4db840174a', '79a74d09-4461-4afc-86a0-03ce4e8374df', 'Card', 'Visa', '12/25', '2025-11-22 17:22:38', '2025-11-22 17:22:38');
INSERT INTO `payment_methods` VALUES ('702dc32e-dd63-4346-91dc-cc6fc7c5aba9', '3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', 'UPI', '1233@qwl', 'UPI', '2025-11-22 17:26:50', '2025-11-22 17:26:50');

-- Table structure for `restaurants`
DROP TABLE IF EXISTS `restaurants`;
CREATE TABLE `restaurants` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `cuisine` varchar(50) NOT NULL,
  `rating` decimal(2,1) DEFAULT '0.0',
  `delivery_time` varchar(50) DEFAULT NULL,
  `address` text,
  `phone` varchar(20) DEFAULT NULL,
  `image_url` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `restaurants`
INSERT INTO `restaurants` VALUES ('1', 'Punjabi Dhaba', 'North', '4.7', '30-40 min', 'MG Road, Bangalore, Karnataka 560001', '+91 80 1234 5678', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-24 08:18:59', '37.42199830', '-122.08400000');
INSERT INTO `restaurants` VALUES ('10', 'Quick Bites', 'Fast Food', '4.3', '15-25 min', 'Connaught Place, New Delhi 110001', '+91 11 2345 6789', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-24 08:19:10', '37.42199830', '-122.08400000');
INSERT INTO `restaurants` VALUES ('11', 'Pizza Palace', 'Fast Food', '4.5', '20-30 min', 'Park Street, Kolkata, West Bengal 700016', '+91 33 3456 7890', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-23 07:29:16', NULL, NULL);
INSERT INTO `restaurants` VALUES ('12', 'Wrap and Roll', 'Fast Food', '4.4', '15-20 min', 'Marine Drive, Mumbai, Maharashtra 400002', '+91 22 4567 8901', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-23 07:29:16', NULL, NULL);
INSERT INTO `restaurants` VALUES ('2', 'Delhi Darbar', 'North', '4.5', '25-35 min', 'Anna Salai, Chennai, Tamil Nadu 600002', '+91 44 5678 9012', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-23 07:29:16', NULL, NULL);
INSERT INTO `restaurants` VALUES ('3', 'Amritsari Kitchen', 'North', '4.8', '35-45 min', 'Banjara Hills, Hyderabad, Telangana 500034', '+91 40 6789 0123', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-23 07:29:16', NULL, NULL);
INSERT INTO `restaurants` VALUES ('4', 'Chennai Express', 'South', '4.6', '20-30 min', 'Saheed Nagar, Bhubaneswar, Odisha 751007', '+91 674 789 0124', 'http://10.0.2.2:8000/uploads/69241d0fd50c90.29828567.jpg', '2025-11-22 15:31:27', '2025-11-24 08:53:37', NULL, NULL);
INSERT INTO `restaurants` VALUES ('5', 'Kerala Kitchen', 'South', '4.7', '30-40 min', 'Civil Lines, Jaipur, Rajasthan 302006', '+91 141 890 1235', 'http://10.0.2.2:8000/uploads/69241d18909734.32240516.jpg', '2025-11-22 15:31:27', '2025-11-24 08:53:46', NULL, NULL);
INSERT INTO `restaurants` VALUES ('6', 'Hyderabadi Biryani House', 'South', '4.9', '40-50 min', 'MG Road, Bangalore, Karnataka 560001', '+91 80 1234 5678', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop', '2025-11-22 15:31:27', '2025-11-23 07:29:16', NULL, NULL);
INSERT INTO `restaurants` VALUES ('7', 'Jagannath Bhog', 'Odisha', '4.5', '30-40 min', 'Connaught Place, New Delhi 110001', '+91 11 2345 6789', 'http://10.0.2.2:8000/uploads/69241ca64dcc14.55294126.jpg', '2025-11-22 15:31:27', '2025-11-24 08:51:58', '37.42199830', '-122.08400000');
INSERT INTO `restaurants` VALUES ('8', 'Odisha Rasoi', 'Odisha', '4.6', '25-35 min', 'Park Street, Kolkata, West Bengal 700016', '+91 33 3456 7890', 'http://10.0.2.2:8000/uploads/69241cb756fa64.86776445.jpg', '2025-11-22 15:31:27', '2025-11-24 08:52:08', NULL, NULL);
INSERT INTO `restaurants` VALUES ('9', 'Cuttack Flavors', 'Odisha', '4.4', '35-45 min', 'Marine Drive, Mumbai, Maharashtra 400002', '+91 22 4567 8901', 'http://10.0.2.2:8000/uploads/69241cc389ec10.31127271.jpg', '2025-11-22 15:31:27', '2025-11-24 08:52:21', NULL, NULL);
INSERT INTO `restaurants` VALUES ('b51ed815d9f72f931b8cc53e85d54460', 'sanlip dhaba', 'odisha', '4.0', '30-40 min', 'boudh', '12341232', 'http://10.0.2.2:8000/uploads/69241ccebae875.34588834.jpg', '2025-11-23 11:56:18', '2025-11-24 08:52:32', NULL, NULL);

-- Table structure for `users`
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `role` enum('admin','customer','rider','restaurant') DEFAULT 'customer',
  `restaurant_id` varchar(36) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_users_restaurant` (`restaurant_id`),
  CONSTRAINT `fk_users_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for `users`
INSERT INTO `users` VALUES ('18111f0b-fe42-43b7-a0a5-763d469333d6', 'admin', 'admin@gmail.com', 'admin', NULL, '$2y$12$pmFPSoz7aKNWX5yEEzL9aeLV1eo8H6kEJuSh1VPXE0U937eHzs.Mi', NULL, NULL, '2025-11-23 06:50:43', '2025-11-23 06:51:03', NULL, NULL);
INSERT INTO `users` VALUES ('1d44c7dc-4b35-4603-846a-63e66a307c21', 'Rider', 'rider@gmail.com', 'rider', NULL, '$2y$12$0SsKm/RouJoalh4OtRlv4.VwEOg9ZFIPQSJg.G3VZJwm/.EV16A72', NULL, NULL, '2025-11-23 06:48:52', '2025-11-23 06:49:30', NULL, NULL);
INSERT INTO `users` VALUES ('3d3f9ec4-f1ac-4fd9-a005-a0813f8a2473', 'Gajendra Bagha', 'rintu1990@gmail.com', 'customer', NULL, '$2y$12$.OWrfdVSkt/mMKuXRitBXuN2t0Ti5l/tONMghte.9.xt0jYXFFyma', '12312312', '/uploads/profiles/692312c964ce70.16365334.jpg', '2025-11-22 16:22:25', '2025-11-23 14:12:45', '37.42199830', '-122.08400000');
INSERT INTO `users` VALUES ('79a74d09-4461-4afc-86a0-03ce4e8374df', 'Payment User', 'payment@example.com', 'customer', NULL, '$2y$12$fSbtFtvBIFOlGRZYnhddCeZMU5XRA8efqA4Fc1zRgU6OXwcjwYOUW', NULL, NULL, '2025-11-22 17:21:40', '2025-11-22 17:21:40', NULL, NULL);
INSERT INTO `users` VALUES ('eb8d60e3-3563-42f9-84f1-9a1511a7ba13', 'Test User', 'testuser@example.com', 'customer', NULL, '$2y$12$OOsHlrS86nFyMNL/I9M3luQFTm9VlCon2DdGnIVGjn1nV0jiew5Ui', NULL, NULL, '2025-11-22 17:00:48', '2025-11-22 17:00:48', NULL, NULL);
INSERT INTO `users` VALUES ('ef9b7dec-5425-4e65-9f45-7b87b0842ccc', 'restaurant', 'restaurant@gmail.com', 'restaurant', '1', '$2y$12$6VeH5eK7PIK22QEEZDrsPuYonqGVLMWBJxAPZdk9/Fu/iOxzx.oC.', NULL, NULL, '2025-11-23 07:44:30', '2025-11-23 12:24:16', NULL, NULL);

SET FOREIGN_KEY_CHECKS=1;
