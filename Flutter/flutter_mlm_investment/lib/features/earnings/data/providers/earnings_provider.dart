import 'package:flutter/material.dart';
import '../services/earnings_service.dart';

class EarningsProvider extends ChangeNotifier {
  final EarningsService _earningsService = EarningsService();
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _breakdown;
  List<dynamic> _history = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get breakdown => _breakdown;
  List<dynamic> get history => _history;

  Future<void> fetchEarningsBreakdown() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _breakdown = await _earningsService.getEarningsBreakdown();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEarningsHistory({bool refresh = false}) async {
    if (refresh) {
      _history = [];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newHistory = await _earningsService.getEarningsHistory(
        offset: _history.length,
      );
      
      if (refresh) {
        _history = newHistory;
      } else {
        _history.addAll(newHistory);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdrawEarnings(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _earningsService.withdrawEarnings(amount);
      // Refresh breakdown after successful withdrawal
      await fetchEarningsBreakdown();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
