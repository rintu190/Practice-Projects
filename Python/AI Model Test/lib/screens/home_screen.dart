import 'package:flutter/material.dart';
import '../models/market.dart';
import '../services/mock_data_service.dart';
import '../widgets/market_card.dart';
import 'market_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockDataService _dataService = MockDataService();
  late List<Market> _markets;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const List<String> categories = [
    'All',
    'Cryptocurrency',
    'Economics',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _dataService.initialize();
    _markets = _dataService.getMockMarkets();
  }

  List<Market> get _filteredMarkets {
    var filtered = _markets;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((m) => m.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              m.question.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polymarket'),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  leading: const Icon(Icons.search),
                  hintText: 'Search markets...',
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return <Widget>[];
              },
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              children: categories
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : 'All';
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Markets List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredMarkets.length,
              itemBuilder: (context, index) {
                final market = _filteredMarkets[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketDetailScreen(
                          market: market,
                        ),
                      ),
                    );
                  },
                  child: MarketCard(market: market),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
