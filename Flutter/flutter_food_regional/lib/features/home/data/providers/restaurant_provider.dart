import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../../../../core/exceptions/api_exception.dart';

// Restaurant service provider
final restaurantServiceProvider = Provider((ref) => RestaurantService());

// Restaurant list provider with cuisine filter
final restaurantListProvider = FutureProvider.family<List<Restaurant>, String?>((ref, cuisine) async {
  final service = ref.watch(restaurantServiceProvider);
  try {
    return await service.getRestaurants(cuisine: cuisine);
  } on ApiException catch (e) {
    throw Exception(e.message);
  }
});

// Single restaurant details provider
final restaurantProvider = FutureProvider.family<Restaurant, String>((ref, id) async {
  final service = ref.watch(restaurantServiceProvider);
  try {
    return await service.getRestaurantDetails(id);
  } on ApiException catch (e) {
    throw Exception(e.message);
  }
});
