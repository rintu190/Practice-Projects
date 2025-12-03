import 'package:flutter/material.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();
  AuthProvider? _authProvider;

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  Map<String, dynamic>? _walletData;
  Map<String, dynamic>? get walletData => _walletData;

  List<dynamic> _transactions = [];
  List<dynamic> get transactions => _transactions;

  List<dynamic> _portfolio = [];
  List<dynamic> get portfolio => _portfolio;

  List<dynamic> _teamMembers = [];
  List<dynamic> get teamMembers => _teamMembers;

  double _todayPnl = 0.0;
  double get todayPnl => _todayPnl;

  List<dynamic> _pnlHistory = [];
  List<dynamic> get pnlHistory => _pnlHistory;

  int _pnlDays = 30;
  int get pnlDays => _pnlDays;

  // Fetch Dashboard Data
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dashboardData = await _dashboardService.getDashboardData();
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Wallet Data
  Future<void> fetchWalletData() async {
    try {
      _walletData = await _dashboardService.getWalletBalance();
      _transactions = await _dashboardService.getTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching wallet data: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    }
  }

  // Fetch Portfolio
  Future<void> fetchPortfolio() async {
    try {
      _portfolio = await _dashboardService.getPortfolio();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching portfolio: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    }
  }

  // Fetch Team Members
  Future<void> fetchTeamMembers() async {
    try {
      _teamMembers = await _dashboardService.getTeamMembers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching team members: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    }
  }

  // Fetch Today's P&L
  Future<void> fetchTodayPnl() async {
    try {
      final data = await _dashboardService.getTodayPnl();
      _todayPnl = (data['data']?['today_pnl'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching today\'s P&L: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    }
  }

  // Fetch P&L History
  Future<void> fetchPnlHistory({int days = 30}) async {
    try {
      _pnlDays = days;
      final data = await _dashboardService.getPnlHistory(days: days);
      _pnlHistory = data['history'] ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching P&L history: $e');
      if (e.toString().contains('Unauthorized')) {
        _authProvider?.logout();
      }
    }
  } // Refresh All

  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboardData(),
      fetchWalletData(),
      fetchPortfolio(),
      fetchTeamMembers(),
      fetchTodayPnl(),
      fetchPnlHistory(),
    ]);
  }
}
