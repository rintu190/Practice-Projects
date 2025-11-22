
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/payment_method.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<List<PaymentMethod>> getPaymentMethods() async {
    print('DEBUG: Fetching payment methods...');
    try {
      final response = await _apiClient.get(
        ApiConstants.paymentMethods,
        requiresAuth: true,
      );
      print('DEBUG: Fetch payment methods response: $response');
      
      if (response == null) {
        return [];
      }

      if (response is! List) {
        print('DEBUG: Response is not a list: ${response.runtimeType}');
        return [];
      }

      final List<dynamic> data = response;
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } catch (e, stack) {
      print('DEBUG: Error fetching payment methods: $e');
      print(stack);
      rethrow;
    }
  }

  Future<PaymentMethod> addPaymentMethod(PaymentMethod method) async {
    print('DEBUG: Adding payment method: ${method.toJson()}');
    try {
      final response = await _apiClient.post(
        ApiConstants.paymentMethods,
        body: method.toJson(),
        requiresAuth: true,
      );
      print('DEBUG: Add payment method response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');

      if (response is! Map<String, dynamic>) {
        throw FormatException('Expected Map<String, dynamic> but got ${response.runtimeType}: $response');
      }

      return PaymentMethod.fromJson(response);
    } catch (e, stack) {
      print('DEBUG: Error adding payment method: $e');
      print(stack);
      rethrow;
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    print('DEBUG: Deleting payment method: $id');
    try {
      await _apiClient.delete(
        '${ApiConstants.paymentMethods}/$id',
        requiresAuth: true,
      );
      print('DEBUG: Payment method deleted successfully');
    } catch (e, stack) {
      print('DEBUG: Error deleting payment method: $e');
      print(stack);
      rethrow;
    }
  }
}
