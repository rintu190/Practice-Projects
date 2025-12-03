import 'package:flutter/material.dart';
import '../services/referral_service.dart';

class ReferralProvider with ChangeNotifier {
  final ReferralService _service = ReferralService();
  
  Map<String, dynamic>? _referralData;
  Map<String, dynamic>? _analytics;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get referralData => _referralData;
  Map<String, dynamic>? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReferralData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _referralData = await _service.getReferralCode();
      _analytics = await _service.getAnalytics();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
