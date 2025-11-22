import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../models/payment_method.dart';
import '../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ApiClient());
});

final paymentProvider = AsyncNotifierProvider<PaymentNotifier, List<PaymentMethod>>(() {
  return PaymentNotifier();
});

class PaymentNotifier extends AsyncNotifier<List<PaymentMethod>> {
  PaymentService get _paymentService => ref.read(paymentServiceProvider);

  @override
  Future<List<PaymentMethod>> build() async {
    return _paymentService.getPaymentMethods();
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _paymentService.addPaymentMethod(method);
      return _paymentService.getPaymentMethods();
    });
  }

  Future<void> deletePaymentMethod(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _paymentService.deletePaymentMethod(id);
      return _paymentService.getPaymentMethods();
    });
  }
}
