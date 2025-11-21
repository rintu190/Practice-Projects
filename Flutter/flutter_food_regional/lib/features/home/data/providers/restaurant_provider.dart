import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/models/restaurant.dart';

final restaurantListProvider = Provider<List<Restaurant>>((ref) {
  return MockData.restaurants;
});

final restaurantProvider = Provider.family<Restaurant?, String>((ref, id) {
  final restaurants = ref.watch(restaurantListProvider);
  try {
    return restaurants.firstWhere((r) => r.id == id);
  } catch (e) {
    return null;
  }
});
