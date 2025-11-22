import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../models/address.dart';
import '../services/address_service.dart';

final addressServiceProvider = Provider<AddressService>((ref) {
  return AddressService(ApiClient());
});

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<Address>>(() {
  return AddressNotifier();
});

class AddressNotifier extends AsyncNotifier<List<Address>> {
  AddressService get _addressService => ref.read(addressServiceProvider);

  @override
  Future<List<Address>> build() async {
    return _addressService.getAddresses();
  }

  Future<void> addAddress(Address address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _addressService.addAddress(address);
      return _addressService.getAddresses();
    });
  }

  Future<void> deleteAddress(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _addressService.deleteAddress(id);
      return _addressService.getAddresses();
    });
  }
}
