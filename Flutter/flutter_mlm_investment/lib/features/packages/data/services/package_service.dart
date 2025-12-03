import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';
import '../models/package.dart';
import '../models/package_purchase.dart';

class PackageService {
  Future<List<Package>> getPackages({String type = 'all'}) async {
    try {
      final token = await SharedPrefs.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}?action=get_packages&type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        final List<dynamic> packagesJson = data['data'];
        return packagesJson.map((json) => Package.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load packages');
      }
    } catch (e) {
      throw Exception('Error loading packages: $e');
    }
  }

  Future<Map<String, dynamic>> purchasePackage(int packageId) async {
    try {
      final token = await SharedPrefs.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}?action=purchase'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'package_id': packageId,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Purchase failed');
      }
    } catch (e) {
      throw Exception('Error purchasing package: $e');
    }
  }

  Future<List<PackagePurchase>> getMyPurchases() async {
    try {
      final token = await SharedPrefs.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}?action=get_my_purchases'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        final List<dynamic> purchasesJson = data['data'];
        return purchasesJson.map((json) => PackagePurchase.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load purchases');
      }
    } catch (e) {
      throw Exception('Error loading purchases: $e');
    }
  }

  Future<Map<String, dynamic>> getInvoice(String invoiceNumber) async {
    try {
      final token = await SharedPrefs.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}?action=get_invoice&invoice_number=$invoiceNumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load invoice');
      }
    } catch (e) {
      throw Exception('Error loading invoice: $e');
    }
  }
}
