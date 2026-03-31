CREATE DATABASE  IF NOT EXISTS `thefrxig_saree_bazaar` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `thefrxig_saree_bazaar`;
-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)
--
-- Host: localhost    Database: saree_haven_db
-- ------------------------------------------------------
-- Server version	8.4.8-0ubuntu0.25.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `artisans`
--

DROP TABLE IF EXISTS `artisans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `artisans` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `location` varchar(200) NOT NULL,
  `image_url` text,
  `bio` text,
  `rating` float DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `artisans`
--

LOCK TABLES `artisans` WRITE;
/*!40000 ALTER TABLE `artisans` DISABLE KEYS */;
INSERT INTO `artisans` VALUES ('a1','Radha Devi','Varanasi, UP','https://images.pexels.com/photos/3621168/pexels-photo-3621168.jpeg','Weaving Banarasi silk for over 30 years',4.8,'2026-03-29 06:32:41'),('a2','Mohan Lal','Chanderi, MP','https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg','Expert in lightweight Chanderi sarees',4.9,'2026-03-29 06:32:41'),('a3','Lakshmi Rao','Kanchipuram, TN','https://images.pexels.com/photos/3671083/pexels-photo-3671083.jpeg','Known for vibrant Kanjivaram designs',4.7,'2026-03-29 06:32:41');
/*!40000 ALTER TABLE `artisans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) DEFAULT NULL,
  `saree_id` varchar(50) DEFAULT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `saree_id` (`saree_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`saree_id`) REFERENCES `sarees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,'ORD-69C923E50CF27','s1',1,12500.00),(2,'ORD-69C93274C2616','s1',1,12500.00);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` varchar(50) NOT NULL,
  `customer_id` varchar(50) DEFAULT NULL,
  `customer_name` varchar(100) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_address` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  `seller_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `seller_id` (`seller_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES ('ORD-69C923E50CF27','user_69c91f6f2e3e7','ds','rintu1990@gmail.com','sd, sd - 12',12500.00,'2026-03-29 18:36:45','processing','seller1'),('ORD-69C93274C2616','user_69c93253c1b6e','dbs','debashree@gmail.com','213123, qwew - 123',12500.00,'2026-03-29 19:38:52','shipped','seller1');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `last_four` varchar(4) NOT NULL,
  `expiry` varchar(10) NOT NULL,
  `card_holder` varchar(100) NOT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,'user_69c91f6f2e3e7','Visa','1232','1222','gasd asas',1);
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sarees`
--

DROP TABLE IF EXISTS `sarees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sarees` (
  `id` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `category` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `image_urls` json DEFAULT NULL,
  `artisan_id` varchar(50) DEFAULT NULL,
  `seller_id` varchar(50) DEFAULT NULL,
  `in_stock` tinyint(1) DEFAULT '1',
  `is_customizable` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `artisan_id` (`artisan_id`),
  KEY `seller_id` (`seller_id`),
  CONSTRAINT `sarees_ibfk_1` FOREIGN KEY (`artisan_id`) REFERENCES `artisans` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sarees_ibfk_2` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sarees`
--

LOCK TABLES `sarees` WRITE;
/*!40000 ALTER TABLE `sarees` DISABLE KEYS */;
INSERT INTO `sarees` VALUES ('s1','Royal Blue Banarasi','Stunning royal blue Banarasi silk saree.',12500.00,'Bridal Saree','Banarasi','[\"assets/Saree/DHAN5161.jpeg\"]','a1','seller1',1,0,'2026-03-29 06:32:41'),('s2','Pink Chanderi Silk','Lightweight pink Chanderi saree.',4500.00,'Daily Wear','Chanderi','[\"assets/Saree/pinksaree.jpeg\"]','a2','seller3',0,0,'2026-03-29 06:32:41'),('s3','Gold Kanjivaram','Classic gold Kanjivaram saree.',18000.00,'Bridal Saree','Kanjivaram','[\"assets/Saree/Sonarupa-1.jpeg\"]','a3','seller2',1,1,'2026-03-29 06:32:41'),('s4','Red Bandhani','Vibrant red Bandhani saree.',3200.00,'Party Wear','Bandhani','[\"assets/Saree/16611P_1Main.jpeg\"]','a1','seller4',1,0,'2026-03-29 06:32:41'),('s69c920aee7517','Sambalpuri Tissue Pata','Sambalpuri Tissue Pata',25000.00,'Bridal Saree','Sambalpuri','[\"https://www.fabodisha.com/cdn/shop/files/InShot-20240120_171841487.jpg?v=1705751357\"]',NULL,'seller1',1,0,'2026-03-29 12:53:02'),('s69c92428bd3ab','Tissue Silk bridal Saree','Tissue Silk bridal Saree',15000.00,'Bridal Saree','Sambalpuri','[\"http://127.0.0.1:8000/uploads/saree_69c92428bd2b8.jpg\"]',NULL,'seller1',1,0,'2026-03-29 13:07:52');
/*!40000 ALTER TABLE `sarees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers` (
  `id` varchar(50) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `store_name` varchar(150) NOT NULL,
  `owner_name` varchar(100) NOT NULL,
  `location` varchar(200) NOT NULL,
  `image_url` text,
  `bio` text,
  `rating` float DEFAULT '0',
  `contact_email` varchar(100) NOT NULL,
  `mobile_number` varchar(20) NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `total_orders` int DEFAULT '0',
  `pending_orders` int DEFAULT '0',
  `total_earning` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `sellers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sellers`
--

LOCK TABLES `sellers` WRITE;
/*!40000 ALTER TABLE `sellers` DISABLE KEYS */;
INSERT INTO `sellers` VALUES ('seller_69c9377c30191','user_69c9377bf2905','Partha Saree House','seller4','Sambalpur, Odisha','http://127.0.0.1:8000/uploads/store_69c939d474392.jpg','Partha Saree House',0,'seller4@gmail.com','121212121',NULL,0,0,0.00),('seller1',NULL,'Varanasi Silk House','Rajesh Gupta','Varanasi, UP','https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg','Family-run silk house',4.9,'varanasisilk@example.com','+91 98765 43210','Banarasi',1540,12,450000.00),('seller2',NULL,'Kanchi Traditions','Meena Sundaram','Kanchipuram, TN','https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg','Premium Kanjivaram sarees',4.8,'kanchitraditions@example.com','+91 91234 56789','Kanjivaram',890,8,230000.00),('seller3',NULL,'Madhya Handlooms','Priya Sharma','Chanderi, MP','https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg','Finest Chanderi and Maheshwari',4.7,'madhyahandlooms@example.com','+91 88998 87766','Chanderi',2100,24,650000.00),('seller4',NULL,'Gujarat Weaves','Amit Patel','Bhuj, Gujarat','https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg','Authentic Bandhani and Patola',4.6,'gujaratweaves@example.com','+91 77665 54433','Bandhani',450,5,120000.00);
/*!40000 ALTER TABLE `sellers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_addresses`
--

DROP TABLE IF EXISTS `shipping_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `details` text NOT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `shipping_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_addresses`
--

LOCK TABLES `shipping_addresses` WRITE;
/*!40000 ALTER TABLE `shipping_addresses` DISABLE KEYS */;
INSERT INTO `shipping_addresses` VALUES (1,'user_69c91f6f2e3e7','BF3, kaspapuram, chennai','',1);
/*!40000 ALTER TABLE `shipping_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_settings`
--

DROP TABLE IF EXISTS `user_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_settings` (
  `user_id` varchar(50) NOT NULL,
  `push_notifications` tinyint(1) DEFAULT '1',
  `promotional_emails` tinyint(1) DEFAULT '0',
  `dark_mode` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_settings`
--

LOCK TABLES `user_settings` WRITE;
/*!40000 ALTER TABLE `user_settings` DISABLE KEYS */;
INSERT INTO `user_settings` VALUES ('user_69c93253c1b6e',1,1,1),('user_69c9377bf2905',1,0,0);
/*!40000 ALTER TABLE `user_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('customer','seller','admin') DEFAULT 'customer',
  `image_url` text,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('user_69c91f6f2e3e7','Gajendra Bagha','rintu1990@gmail.com','$2y$12$n11PbqwtW8KNgr3no4xjUuH0zOAfqGTRM4YUJcxt9kK2ReDdG//8O','seller',NULL,NULL,'2026-03-29 12:47:43'),('user_69c93253c1b6e','debashree','debashree@gmail.com','$2y$12$k1Dwu0xGPstej/mQ4PDewetuUm0bRd8HFiVE01.M/TrzcycefLw0K','customer','http://127.0.0.1:8000/uploads/user_69c941d35b597.jpeg','123','2026-03-29 14:08:20'),('user_69c9340017bac','seller Test','seller1@gmail.com','$2y$12$I7/diKB7hKHojMmHCoNj2eK4AqtfRgFsX8NrqsYpk4rKhY6y0rztu','seller',NULL,NULL,'2026-03-29 14:15:28'),('user_69c936f0eeb0d','seller2','seller2@gmail.com','$2y$12$0RQaTLHiqcVZWu92wTDZieFSnr4zLXMzwi2vwFQyj/VAzxmaAZy7K','seller',NULL,NULL,'2026-03-29 14:28:01'),('user_69c9370134987','seller2','seller3@gmail.com','$2y$12$EQXzneW3f3rb4iFNk3htCOKx1gJib8owid7duzJwFRsz.q7pJLgii','seller',NULL,NULL,'2026-03-29 14:28:17'),('user_69c9377bf2905','seller4','seller4@gmail.com','$2y$12$e2oxcZM06UUdYErCBcy.vOA1/9IunEwTQ3O3ZyHhqWYvoUEyQkG0O','seller',NULL,NULL,'2026-03-29 14:30:20');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlists` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `saree_id` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`saree_id`),
  KEY `saree_id` (`saree_id`),
  CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`saree_id`) REFERENCES `sarees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlists`
--

LOCK TABLES `wishlists` WRITE;
/*!40000 ALTER TABLE `wishlists` DISABLE KEYS */;
INSERT INTO `wishlists` VALUES (1,'user_69c93253c1b6e','s1','2026-03-29 14:16:57'),(2,'user_69c93253c1b6e','s4','2026-03-29 15:34:06');
/*!40000 ALTER TABLE `wishlists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'saree_haven_db'
--

--
-- Dumping routines for database 'saree_haven_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-31 12:56:34
