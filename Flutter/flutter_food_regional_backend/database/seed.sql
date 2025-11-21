-- Seed data for restaurants and menu items from Flutter mock data
USE flutter_food_regional;

-- Insert North Indian Restaurants
INSERT INTO restaurants (id, name, cuisine, rating, delivery_time, image_url) VALUES
('1', 'Punjabi Dhaba', 'North', 4.7, '30-40 min', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop'),
('2', 'Delhi Darbar', 'North', 4.5, '25-35 min', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop'),
('3', 'Amritsari Kitchen', 'North', 4.8, '35-45 min', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop'),
('4', 'Chennai Express', 'South', 4.6, '20-30 min', 'https://images.unsplash.com/photo-1567337710282-00d7985c3c6e?q=80&w=2070&auto=format&fit=crop'),
('5', 'Kerala Kitchen', 'South', 4.7, '30-40 min', 'https://images.unsplash.com/photo-1567337710282-00d7985c3c6e?q=80&w=2070&auto=format&fit=crop'),
('6', 'Hyderabadi Biryani House', 'South', 4.9, '40-50 min', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop'),
('7', 'Jagannath Bhog', 'Odisha', 4.5, '30-40 min', 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop'),
('8', 'Odisha Rasoi', 'Odisha', 4.6, '25-35 min', 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop'),
('9', 'Cuttack Flavors', 'Odisha', 4.4, '35-45 min', 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop'),
('10', 'Quick Bites', 'Fast Food', 4.3, '15-25 min', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop'),
('11', 'Pizza Palace', 'Fast Food', 4.5, '20-30 min', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop'),
('12', 'Wrap and Roll', 'Fast Food', 4.4, '15-20 min', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop');

-- Insert Menu Items
INSERT INTO menu_items (id, restaurant_id, name, description, price, image_url) VALUES
-- Punjabi Dhaba menu
('101', '1', 'Butter Chicken', 'Creamy tomato curry with tender chicken', 320.00, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?q=80&w=2070&auto=format&fit=crop'),
('102', '1', 'Dal Makhani', 'Black lentils in creamy gravy', 250.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop'),
('103', '1', 'Tandoori Roti', 'Whole wheat flatbread', 25.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
-- Delhi Darbar menu
('201', '2', 'Chole Bhature', 'Spicy chickpea curry with fried bread', 180.00, 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=2070&auto=format&fit=crop'),
('202', '2', 'Paneer Tikka', 'Grilled cottage cheese in spices', 280.00, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=2070&auto=format&fit=crop'),
('203', '2', 'Lassi', 'Sweet yogurt drink', 60.00, 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?q=80&w=2070&auto=format&fit=crop'),
-- Amritsari Kitchen menu
('301', '3', 'Amritsari Kulcha', 'Stuffed bread with spicy filling', 90.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
('302', '3', 'Kadhai Paneer', 'Cottage cheese in spicy tomato gravy', 290.00, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=2070&auto=format&fit=crop'),
-- Chennai Express menu
('401', '4', 'Masala Dosa', 'Crispy rice crepe with potato filling', 120.00, 'https://images.unsplash.com/photo-1630383249896-424e482df921?q=80&w=2070&auto=format&fit=crop'),
('402', '4', 'Idli Sambar', 'Steamed rice cakes with lentil soup', 80.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=2070&auto=format&fit=crop'),
('403', '4', 'Filter Coffee', 'Traditional South Indian coffee', 40.00, 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop'),
-- Kerala Kitchen menu
('501', '5', 'Appam with Stew', 'Rice pancake with coconut curry', 150.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
('502', '5', 'Fish Curry', 'Spicy coconut-based fish curry', 350.00, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop'),
('503', '5', 'Puttu Kadala', 'Steamed rice cake with chickpea curry', 100.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
-- Hyderabadi Biryani House menu
('601', '6', 'Chicken Biryani', 'Fragrant rice with spiced chicken', 280.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop'),
('602', '6', 'Mutton Biryani', 'Aromatic rice with tender mutton', 350.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop'),
('603', '6', 'Raita', 'Yogurt with cucumber and spices', 50.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
-- Jagannath Bhog menu
('701', '7', 'Dalma', 'Traditional Odia lentil curry with vegetables', 150.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop'),
('702', '7', 'Pakhala Bhata', 'Fermented rice with water', 80.00, 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop'),
('703', '7', 'Chenna Poda', 'Roasted cottage cheese dessert', 100.00, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
-- Odisha Rasoi menu
('801', '8', 'Machha Besara', 'Fish curry with mustard paste', 320.00, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop'),
('802', '8', 'Chhena Jhili', 'Sweet cottage cheese fritters in syrup', 90.00, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
('803', '8', 'Santula', 'Mixed vegetable curry', 180.00, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070&auto=format&fit=crop'),
-- Cuttack Flavors menu
('901', '9', 'Khaja', 'Crispy layered sweet pastry', 120.00, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
('902', '9', 'Gupchup', 'Crispy puri with spicy water', 50.00, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?q=80&w=2070&auto=format&fit=crop'),
-- Quick Bites menu
('1001', '10', 'Veg Burger', 'Crispy veggie patty with cheese', 120.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop'),
('1002', '10', 'French Fries', 'Crispy golden fries', 80.00, 'https://images.unsplash.com/photo-1576107232684-1279f390859f?q=80&w=2070&auto=format&fit=crop'),
('1003', '10', 'Cold Coffee', 'Chilled coffee with ice cream', 100.00, 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop'),
-- Pizza Palace menu
('1101', '11', 'Margherita Pizza', 'Classic tomato, cheese and basil', 250.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=2069&auto=format&fit=crop'),
('1102', '11', 'Veggie Supreme', 'Loaded with fresh vegetables', 320.00, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop'),
('1103', '11', 'Garlic Bread', 'Toasted bread with garlic butter', 120.00, 'https://images.unsplash.com/photo-1573140401552-3fab0b24306f?q=80&w=2070&auto=format&fit=crop'),
-- Wrap and Roll menu
('1201', '12', 'Paneer Wrap', 'Grilled paneer in tortilla wrap', 150.00, 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop'),
('1202', '12', 'Chicken Roll', 'Spicy chicken wrapped in paratha', 180.00, 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop'),
('1203', '12', 'Spring Roll', 'Crispy vegetable spring rolls', 100.00, 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop');
