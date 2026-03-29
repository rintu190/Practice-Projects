import '../models/artisan_model.dart';
import '../models/order_model.dart';
import '../models/saree_model.dart';
import '../models/seller_model.dart';

class MockRepository {
  static const List<String> categories = [
    'Bridal Saree',
    'Cotton Saree',
    'Silk Saree',
    'Party Wear',
    'Daily Wear',
  ];

  static const List<String> types = [
    'Banarasi',
    'Kanjivaram',
    'Chanderi',
    'Tussar',
    'Bandhani',
    'Sambalpuri',
  ];

  static const List<Artisan> artisans = [
    Artisan(
      id: 'a1',
      name: 'Radha Devi',
      location: 'Varanasi, UP',
      imageUrl: 'https://images.pexels.com/photos/3621168/pexels-photo-3621168.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Weaving Banarasi silk for over 30 years, preserving the family tradition.',
      rating: 4.8,
    ),
    Artisan(
      id: 'a2',
      name: 'Mohan Lal',
      location: 'Chanderi, MP',
      imageUrl: 'https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Expert in lightweight Chanderi sarees with intricate zari work.',
      rating: 4.9,
    ),
    Artisan(
      id: 'a3',
      name: 'Lakshmi Rao',
      location: 'Kanchipuram, TN',
      imageUrl: 'https://images.pexels.com/photos/3671083/pexels-photo-3671083.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Known for her vibrant Kanjivaram designs and durable weaves.',
      rating: 4.7,
    ),
  ];

  static const List<Seller> sellers = [
    Seller(
      id: 'seller1',
      storeName: 'Varanasi Silk House',
      ownerName: 'Rajesh Gupta',
      location: 'Varanasi, Uttar Pradesh',
      imageUrl: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Family-run silk house since 1952. Specializing in authentic Banarasi weaves passed down through generations.',
      rating: 4.9,
      contactEmail: 'varanasisilk@example.com',
      mobileNumber: '+91 98765 43210',
      specialization: 'Banarasi',
      totalOrders: 1540,
      pendingOrders: 12,
      totalEarning: 450000.0,
    ),
    Seller(
      id: 'seller2',
      storeName: 'Kanchi Traditions',
      ownerName: 'Meena Sundaram',
      location: 'Kanchipuram, Tamil Nadu',
      imageUrl: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Premium Kanjivaram sarees crafted by master weavers of Kanchipuram with pure gold zari.',
      rating: 4.8,
      contactEmail: 'kanchitraditions@example.com',
      mobileNumber: '+91 91234 56789',
      specialization: 'Kanjivaram',
      totalOrders: 890,
      pendingOrders: 8,
      totalEarning: 230000.0,
    ),
    Seller(
      id: 'seller3',
      storeName: 'Madhya Handlooms',
      ownerName: 'Priya Sharma',
      location: 'Chanderi, Madhya Pradesh',
      imageUrl: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Curating the finest Chanderi and Maheshwari sarees directly from the looms of central India.',
      rating: 4.7,
      contactEmail: 'madhyahandlooms@example.com',
      mobileNumber: '+91 88998 87766',
      specialization: 'Chanderi',
      totalOrders: 2100,
      pendingOrders: 24,
      totalEarning: 650000.0,
    ),
    Seller(
      id: 'seller4',
      storeName: 'Gujarat Weaves',
      ownerName: 'Amit Patel',
      location: 'Bhuj, Gujarat',
      imageUrl: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=200',
      bio: 'Authentic Bandhani and Patola sarees from the artisan clusters of Gujarat.',
      rating: 4.6,
      contactEmail: 'gujaratweaves@example.com',
      mobileNumber: '+91 77665 54433',
      specialization: 'Bandhani',
      totalOrders: 450,
      pendingOrders: 5,
      totalEarning: 120000.0,
    ),
  ];

  static final List<Saree> sarees = [
    Saree(
      id: 's1',
      name: 'Royal Blue Banarasi',
      description: 'A stunning royal blue Banarasi silk saree with gold zari border. The intricate butta work and rich pallu make it perfect for weddings and festive occasions.',
      price: 12500,
      category: 'Bridal Saree',
      type: 'Banarasi',
      imageUrls: ['assets/Saree/DHAN5161.jpeg'],
      artisan: artisans[0],
      sellerId: 'seller1',
    ),
    Saree(
      id: 's2',
      name: 'Pink Chanderi Silk',
      description: 'Lightweight pink Chanderi saree with delicate floral motifs woven in pure silk. Ideal for summer events and daytime celebrations.',
      price: 4500,
      category: 'Daily Wear',
      type: 'Chanderi',
      imageUrls: ['assets/Saree/pinksaree.jpeg'],
      artisan: artisans[1],
      sellerId: 'seller3',
      inStock: false,
    ),
    Saree(
      id: 's3',
      name: 'Gold Kanjivaram',
      description: 'Classic gold Kanjivaram saree with temple border design. Handwoven with pure mulberry silk and real gold zari threads.',
      price: 18000,
      category: 'Bridal Saree',
      type: 'Kanjivaram',
      imageUrls: ['assets/Saree/Sonarupa-1.jpeg'],
      artisan: artisans[2],
      sellerId: 'seller2',
      isCustomizable: true,
    ),
    Saree(
      id: 's4',
      name: 'Red Bandhani',
      description: 'Vibrant red Bandhani saree with traditional tie-dye patterns from Gujarat. Each knot is hand-tied creating mesmerizing patterns.',
      price: 3200,
      category: 'Party Wear',
      type: 'Bandhani',
      imageUrls: ['assets/Saree/16611P_1Main.jpeg'],
      artisan: artisans[0],
      sellerId: 'seller4',
    ),
    Saree(
      id: 's5',
      name: 'Emerald Green Banarasi',
      description: 'Luxurious emerald green Banarasi silk with intricate meenakari jaal work. A masterpiece of Varanasi craftsmanship.',
      price: 15800,
      category: 'Bridal Saree',
      type: 'Banarasi',
      imageUrls: ['assets/Saree/DHAN5190.jpeg'],
      artisan: artisans[0],
      sellerId: 'seller1',
      inStock: false,
    ),
    Saree(
      id: 's6',
      name: 'Maroon Kanjivaram Silk',
      description: 'Deep maroon Kanjivaram with rich peacock border. Weighs over 800 grams of pure silk — a true bridal heirloom.',
      price: 22000,
      category: 'Bridal Saree',
      type: 'Kanjivaram',
      imageUrls: ['assets/Saree/PIK05632.jpeg'],
      artisan: artisans[2],
      sellerId: 'seller2',
      isCustomizable: true,
    ),
    Saree(
      id: 's7',
      name: 'Beige Tussar Silk',
      description: 'Natural beige Tussar silk saree with hand-painted Madhubani art. Each piece is unique and tells a story from Bihar folklore.',
      price: 6800,
      category: 'Silk Saree',
      type: 'Tussar',
      imageUrls: ['assets/Saree/Sonarupa-1.jpeg'],
      artisan: artisans[1],
      sellerId: 'seller3',
    ),
    Saree(
      id: 's8',
      name: 'Blue Sambalpuri Ikat',
      description: 'Stunning blue Sambalpuri saree with traditional ikat patterns from Odisha. The resist-dyeing technique creates unique geometric designs.',
      price: 5500,
      category: 'Cotton Saree',
      type: 'Sambalpuri',
      imageUrls: ['assets/Saree/yellowSaree.jpeg'],
      artisan: artisans[1],
      sellerId: 'seller3',
    ),
    Saree(
      id: 's9',
      name: 'Yellow Bandhani Dupatta',
      description: 'Bright yellow Bandhani work on pure georgette. Lightweight and versatile — perfect for casual elegance.',
      price: 2800,
      category: 'Daily Wear',
      type: 'Bandhani',
      imageUrls: ['assets/Saree/yellowSaree.jpeg'],
      artisan: artisans[0],
      sellerId: 'seller4',
    ),
    Saree(
      id: 's10',
      name: 'Ivory Chanderi Cotton',
      description: 'Elegant ivory Chanderi cotton saree with silver zari checks. The sheer fabric has a natural lustre that catches light beautifully.',
      price: 3800,
      category: 'Cotton Saree',
      type: 'Chanderi',
      imageUrls: ['assets/Saree/Golden_Embroidered_Chiffon_Saree-ZB132146_01_7eabd462-ecb6-4eee-89d4-6263038fd89f.jpeg'],
      artisan: artisans[1],
      sellerId: 'seller3',
    ),
    Saree(
      id: 's11',
      name: 'Purple Banarasi Organza',
      description: 'Contemporary purple Banarasi organza with floral jaal. Lightweight yet luxurious — perfect for modern celebrations.',
      price: 9500,
      category: 'Party Wear',
      type: 'Banarasi',
      imageUrls: ['assets/Saree/16611P_1Main.jpeg'],
      artisan: artisans[0],
      sellerId: 'seller1',
    ),
    Saree(
      id: 's12',
      name: 'Red Sambalpuri Cotton',
      description: 'Handloom red Sambalpuri cotton saree with traditional fish motifs. Perfect for everyday ethnic wear with comfort.',
      price: 4200,
      category: 'Daily Wear',
      type: 'Sambalpuri',
      imageUrls: ['assets/Saree/kamakshi-aza-soft-silk-wholesale-designer-sarees-collection-1.jpeg'],
      artisan: artisans[2],
      sellerId: 'seller3',
    ),
  ];

  static final List<Order> orders = [
    Order(
      id: 'ORD-001',
      customerName: 'Anjali Sharma',
      customerEmail: 'anjali@example.com',
      customerAddress: 'Jayanagar, Bangalore, Karnataka',
      items: [
        OrderItem(saree: sarees[0], quantity: 1, price: 12500),
      ],
      totalAmount: 12500,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.shipped,
      sellerId: 'seller1',
    ),
    Order(
      id: 'ORD-002',
      customerName: 'Suresh Kumar',
      customerEmail: 'suresh@example.com',
      customerAddress: 'Salt Lake, Kolkata, West Bengal',
      items: [
        OrderItem(saree: sarees[4], quantity: 2, price: 15800),
      ],
      totalAmount: 31600,
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: OrderStatus.pending,
      sellerId: 'seller1',
    ),
    Order(
      id: 'ORD-003',
      customerName: 'Meera Patel',
      customerEmail: 'meera@example.com',
      customerAddress: 'Ahmedabad, Gujarat',
      items: [
        OrderItem(saree: sarees[10], quantity: 1, price: 9500),
      ],
      totalAmount: 9500,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
      sellerId: 'seller1',
    ),
  ];

  // Helper methods
  static List<Saree> getSareesByCategory(String category) {
    if (category == 'All') return sarees;
    return sarees.where((s) => s.category == category).toList();
  }

  static List<Saree> getSareesByType(String type) {
    if (type == 'All') return sarees;
    return sarees.where((s) => s.type == type).toList();
  }

  static List<Saree> getSareesBySeller(String sellerId) {
    return sarees.where((s) => s.sellerId == sellerId).toList();
  }

  static Seller? getSellerById(String id) {
    try {
      return sellers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Saree> searchSarees(String query) {
    final lowerQuery = query.toLowerCase();
    return sarees.where((s) =>
      s.name.toLowerCase().contains(lowerQuery) ||
      s.category.toLowerCase().contains(lowerQuery) ||
      s.type.toLowerCase().contains(lowerQuery) ||
      s.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  static List<Order> getOrdersBySeller(String sellerId) {
    return orders.where((o) => o.sellerId == sellerId).toList();
  }

  static void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      orders[orderIndex].status = newStatus;
    }
  }
}
