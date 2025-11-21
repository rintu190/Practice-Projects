import '../../features/home/domain/models/restaurant.dart';
import '../../features/home/domain/models/menu_item.dart';

class MockData {
  static final List<Restaurant> restaurants = [
    // North Indian Restaurants
    Restaurant(
      id: '1',
      name: 'Punjabi Dhaba',
      cuisine: 'North',
      rating: 4.7,
      deliveryTime: '30-40 min',
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '101', name: 'Butter Chicken', description: 'Creamy tomato curry with tender chicken', price: 320.0, imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '102', name: 'Dal Makhani', description: 'Black lentils in creamy gravy', price: 250.0, imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '103', name: 'Tandoori Roti', description: 'Whole wheat flatbread', price: 25.0, imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '2',
      name: 'Delhi Darbar',
      cuisine: 'North',
      rating: 4.5,
      deliveryTime: '25-35 min',
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '201', name: 'Chole Bhature', description: 'Spicy chickpea curry with fried bread', price: 180.0, imageUrl: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '202', name: 'Paneer Tikka', description: 'Grilled cottage cheese in spices', price: 280.0, imageUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '203', name: 'Lassi', description: 'Sweet yogurt drink', price: 60.0, imageUrl: 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '3',
      name: 'Amritsari Kitchen',
      cuisine: 'North',
      rating: 4.8,
      deliveryTime: '35-45 min',
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '301', name: 'Amritsari Kulcha', description: 'Stuffed bread with spicy filling', price: 90.0, imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '302', name: 'Kadhai Paneer', description: 'Cottage cheese in spicy tomato gravy', price: 290.0, imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),

    // South Indian Restaurants
    Restaurant(
      id: '4',
      name: 'Chennai Express',
      cuisine: 'South',
      rating: 4.6,
      deliveryTime: '20-30 min',
      imageUrl: 'https://images.unsplash.com/photo-1567337710282-00d7985c3c6e?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '401', name: 'Masala Dosa', description: 'Crispy rice crepe with potato filling', price: 120.0, imageUrl: 'https://images.unsplash.com/photo-1630383249896-424e482df921?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '402', name: 'Idli Sambar', description: 'Steamed rice cakes with lentil soup', price: 80.0, imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '403', name: 'Filter Coffee', description: 'Traditional South Indian coffee', price: 40.0, imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '5',
      name: 'Kerala Kitchen',
      cuisine: 'South',
      rating: 4.7,
      deliveryTime: '30-40 min',
      imageUrl: 'https://images.unsplash.com/photo-1567337710282-00d7985c3c6e?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '501', name: 'Appam with Stew', description: 'Rice pancake with coconut curry', price: 150.0, imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '502', name: 'Fish Curry', description: 'Spicy coconut-based fish curry', price: 350.0, imageUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '503', name: 'Puttu Kadala', description: 'Steamed rice cake with chickpea curry', price: 100.0, imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '6',
      name: 'Hyderabadi Biryani House',
      cuisine: 'South',
      rating: 4.9,
      deliveryTime: '40-50 min',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '601', name: 'Chicken Biryani', description: 'Fragrant rice with spiced chicken', price: 280.0, imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '602', name: 'Mutton Biryani', description: 'Aromatic rice with tender mutton', price: 350.0, imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '603', name: 'Raita', description: 'Yogurt with cucumber and spices', price: 50.0, imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),

    // Odisha Cuisine Restaurants
    Restaurant(
      id: '7',
      name: 'Jagannath Bhog',
      cuisine: 'Odisha',
      rating: 4.5,
      deliveryTime: '30-40 min',
      imageUrl: 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '701', name: 'Dalma', description: 'Traditional Odia lentil curry with vegetables', price: 150.0, imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '702', name: 'Pakhala Bhata', description: 'Fermented rice with water', price: 80.0, imageUrl: 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '703', name: 'Chenna Poda', description: 'Roasted cottage cheese dessert', price: 100.0, imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '8',
      name: 'Odisha Rasoi',
      cuisine: 'Odisha',
      rating: 4.6,
      deliveryTime: '25-35 min',
      imageUrl: 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '801', name: 'Machha Besara', description: 'Fish curry with mustard paste', price: 320.0, imageUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '802', name: 'Chhena Jhili', description: 'Sweet cottage cheese fritters in syrup', price: 90.0, imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '803', name: 'Santula', description: 'Mixed vegetable curry', price: 180.0, imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '9',
      name: 'Cuttack Flavors',
      cuisine: 'Odisha',
      rating: 4.4,
      deliveryTime: '35-45 min',
      imageUrl: 'https://images.unsplash.com/photo-1596797882870-8c33deebc48d?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '901', name: 'Khaja', description: 'Crispy layered sweet pastry', price: 120.0, imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '902', name: 'Gupchup', description: 'Crispy puri with spicy water', price: 50.0, imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),

    // Fast Food Restaurants
    Restaurant(
      id: '10',
      name: 'Quick Bites',
      cuisine: 'Fast Food',
      rating: 4.3,
      deliveryTime: '15-25 min',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '1001', name: 'Veg Burger', description: 'Crispy veggie patty with cheese', price: 120.0, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '1002', name: 'French Fries', description: 'Crispy golden fries', price: 80.0, imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f390859f?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '1003', name: 'Cold Coffee', description: 'Chilled coffee with ice cream', price: 100.0, imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '11',
      name: 'Pizza Palace',
      cuisine: 'Fast Food',
      rating: 4.5,
      deliveryTime: '20-30 min',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '1101', name: 'Margherita Pizza', description: 'Classic tomato, cheese and basil', price: 250.0, imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=2069&auto=format&fit=crop'),
        MenuItem(id: '1102', name: 'Veggie Supreme', description: 'Loaded with fresh vegetables', price: 320.0, imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '1103', name: 'Garlic Bread', description: 'Toasted bread with garlic butter', price: 120.0, imageUrl: 'https://images.unsplash.com/photo-1573140401552-3fab0b24306f?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
    Restaurant(
      id: '12',
      name: 'Wrap and Roll',
      cuisine: 'Fast Food',
      rating: 4.4,
      deliveryTime: '15-20 min',
      imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop',
      menuItems: [
        MenuItem(id: '1201', name: 'Paneer Wrap', description: 'Grilled paneer in tortilla wrap', price: 150.0, imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '1202', name: 'Chicken Roll', description: 'Spicy chicken wrapped in paratha', price: 180.0, imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop'),
        MenuItem(id: '1203', name: 'Spring Roll', description: 'Crispy vegetable spring rolls', price: 100.0, imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2070&auto=format&fit=crop'),
      ],
    ),
  ];
}
