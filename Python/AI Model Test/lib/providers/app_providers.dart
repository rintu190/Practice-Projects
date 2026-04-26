import 'package:flutter/material.dart';
import '../models/market.dart';
import '../models/position.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

/// Provider for managing market data and state
class MarketsProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  
  List<Market> _markets = [];
  List<Market> _filteredMarkets = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Getters
  List<Market> get markets => _filteredMarkets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  MarketsProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dataService.initialize();
      _markets = _dataService.getMockMarkets();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to load markets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMarkets = _markets;

    if (_selectedCategory != 'All') {
      _filteredMarkets = _filteredMarkets
          .where((m) => m.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredMarkets = _filteredMarkets
          .where((m) =>
              m.question.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Market? getMarketById(String id) {
    try {
      return _dataService.getMarketById(id);
    } catch (e) {
      _error = 'Market not found';
      return null;
    }
  }

  Future<void> updateMarketPrice(String marketId, double yesPrice) async {
    try {
      _dataService.updateMarketPrice(marketId, yesPrice);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update market price';
      notifyListeners();
    }
  }
}

/// Provider for managing portfolio and positions
class PortfolioProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  
  late User _user;
  List<Position> _positions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User get user => _user;
  List<Position> get positions => _positions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PortfolioProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dataService.initialize();
      _user = _dataService.getUser();
      _positions = _dataService.getUserPositions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load portfolio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({
    required String marketId,
    required String outcome,
    required double shares,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would call the API and update the position
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to place order: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sellPosition(String positionId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _positions.removeWhere((p) => p.id == positionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to sell position: $e';
      notifyListeners();
      return false;
    }
  }

  double getTotalPositionValue() {
    return _positions.fold<double>(0, (sum, pos) => sum + pos.currentValue);
  }

  double getTotalProfit() {
    return _positions.fold<double>(0, (sum, pos) => sum + pos.profit);
  }
}

/// Provider for managing user authentication and profile
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Mock login - replace with actual authentication
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: 'user_001',
        username: 'trader_pro',
        email: email,
        balance: 5234.50,
        totalProfit: 1245.75,
        totalTrades: 47,
      );
      _isAuthenticated = true;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mock logout
  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Mock sign up - replace with actual API
  Future<bool> signUp(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        balance: 1000.0, // Starting balance
        totalProfit: 0,
        totalTrades: 0,
      );
      _isAuthenticated = true;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Sign up failed: $e';
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
