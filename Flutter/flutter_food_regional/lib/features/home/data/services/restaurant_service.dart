import '../../../../core/services/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/restaurant.dart';

class RestaurantService {
  final ApiClient _apiClient = ApiClient();

  // Get all restaurants with optional cuisine filter
  Future<List<Restaurant>> getRestaurants({String? cuisine}) async {
    String endpoint = ApiConstants.restaurants;
    
    if (cuisine != null && cuisine != 'All') {
      endpoint += '?cuisine=$cuisine';
    }

    final response = await _apiClient.get(endpoint);
    
    final List<dynamic> restaurantList = response as List;
    return restaurantList
        .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Get restaurant details with menu items
  Future<Restaurant> getRestaurantDetails(String id) async {
    final response = await _apiClient.get('${ApiConstants.restaurants}/$id');
    return Restaurant.fromJson(response as Map<String, dynamic>);
  }

  // Get menu items for a restaurant
  Future<List> getRestaurantMenu(String id) async {
    final response = await _apiClient.get('${ApiConstants.restaurants}/$id/menu');
    // The response will be handled by getRestaurantDetails
    return response as List;
  }

  void dispose() {
    _apiClient.dispose();
  }
}
