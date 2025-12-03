import 'package:flutter/material.dart';
import '../services/genealogy_service.dart';

class GenealogyProvider with ChangeNotifier {
  final GenealogyService _service = GenealogyService();
  
  Map<String, dynamic>? _treeData;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get treeData => _treeData;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTree({String type = 'unilevel', int? rootId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _treeData = await _service.getTree(type: type, rootId: rootId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await _service.getStats();
      notifyListeners();
    } catch (e) {
      print('Error fetching genealogy stats: $e');
    }
  }
}
