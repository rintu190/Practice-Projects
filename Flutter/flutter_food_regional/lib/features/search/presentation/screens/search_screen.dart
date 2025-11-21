import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/data/providers/restaurant_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allRestaurants = ref.watch(restaurantListProvider);
    final filteredRestaurants = allRestaurants.where((restaurant) {
      final nameMatches = restaurant.name.toLowerCase().contains(_query.toLowerCase());
      final cuisineMatches = restaurant.cuisine.toLowerCase().contains(_query.toLowerCase());
      return nameMatches || cuisineMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search restaurants or cuisines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Find your favorite food',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = filteredRestaurants[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(restaurant.imageUrl),
                          ),
                          title: Text(restaurant.name),
                          subtitle: Text('${restaurant.cuisine} • ${restaurant.rating} ⭐'),
                          onTap: () => context.push('/restaurant/${restaurant.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
