
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/address.dart';

class AddressService {
  final ApiClient _apiClient;

  AddressService(this._apiClient);

  Future<List<Address>> getAddresses() async {
    print('DEBUG: Fetching addresses...');
    try {
      final response = await _apiClient.get(
        ApiConstants.addresses,
        requiresAuth: true,
      );
      print('DEBUG: Fetch addresses response: $response');
      
      if (response == null) {
        print('DEBUG: Response is null');
        return [];
      }

      if (response is! List) {
        print('DEBUG: Response is not a list: ${response.runtimeType}');
        return [];
      }

      final List<dynamic> data = response;
      final addresses = data.map((json) => Address.fromJson(json)).toList();
      print('DEBUG: Parsed ${addresses.length} addresses');
      return addresses;
    } catch (e, stack) {
      print('DEBUG: Error fetching addresses: $e');
      print(stack);
      rethrow;
    }
  }

  Future<Address> addAddress(Address address) async {
    print('DEBUG: Adding address: ${address.toJson()}');
    try {
      final response = await _apiClient.post(
        ApiConstants.addresses,
        body: address.toJson(),
        requiresAuth: true,
      );
      print('DEBUG: Add address response: $response');
      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e, stack) {
      print('DEBUG: Error adding address: $e');
      print(stack);
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    print('DEBUG: Deleting address: $id');
    try {
      await _apiClient.delete(
        '${ApiConstants.addresses}/$id',
        requiresAuth: true,
      );
      print('DEBUG: Address deleted successfully');
    } catch (e, stack) {
      print('DEBUG: Error deleting address: $e');
      print(stack);
      rethrow;
    }
  }

  Future<Address> updateAddress(String id, Address address) async {
    print('DEBUG: Updating address: $id with ${address.toJson()}');
    try {
      final response = await _apiClient.put(
        '${ApiConstants.addresses}/$id',
        body: address.toJson(),
        requiresAuth: true,
      );
      print('DEBUG: Update address response: $response');
      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e, stack) {
      print('DEBUG: Error updating address: $e');
      print(stack);
      rethrow;
    }
  }

  Future<Address> setDefaultAddress(String id) async {
    print('DEBUG: Setting default address: $id');
    try {
      final response = await _apiClient.put(
        '${ApiConstants.addresses}/$id/set-default',
        body: {},
        requiresAuth: true,
      );
      print('DEBUG: Set default address response: $response');
      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e, stack) {
      print('DEBUG: Error setting default address: $e');
      print(stack);
      rethrow;
    }
  }
}
