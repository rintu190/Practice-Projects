import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../models/market.dart';
import '../theme.dart';
import 'market_detail_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _selectedSort = 'Trending'; // Trending, Volume, Ending Soon
  int _currentHeroIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'image': 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?auto=format&fit=crop&q=80&w=200'},
    {'name': 'Politics', 'image': 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&q=80&w=200'},
    {'name': 'Sports', 'image': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&q=80&w=200'},
    {'name': 'Movies', 'image': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&q=80&w=200'},
    {'name': 'Finance', 'image': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&q=80&w=200'},
    {'name': 'Crypto', 'image': 'https://images.unsplash.com/photo-1605792657660-596af9009e82?auto=format&fit=crop&q=80&w=200'},
  ];

  List<Market> _allMarkets = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveMarkets();
  }

  Future<void> _fetchLiveMarkets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiConfig.get('/api/markets/read.php');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List dynamicList = data['data'];
          setState(() {
             _allMarkets = dynamicList.map((m) => Market.fromJson(m)).toList();
             _isLoading = false;
          });
        } else {
           setState(() {
             _errorMessage = data['message'] ?? 'Failed to load markets';
             _isLoading = false;
           });
        }
      } else {
        setState(() {
          _errorMessage = 'Server disconnected (HTTP ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
      setState(() {
        _errorMessage = 'Could not reach server. Verify PHP server running on port 8000.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredMarkets = _allMarkets.take(3).toList();
    final endingSoonMarkets = _allMarkets.where((m) => m.isEndingSoon).toList();
    
    // Filter markets by category & search query
    List<Market> filtered = _allMarkets.where((m) {
      final matchesCategory = _selectedCategory == 'All' || m.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Apply Sort filter
    if (_selectedSort == 'Ending Soon') {
      filtered.sort((a, b) => (b.isEndingSoon ? 1 : 0).compareTo(a.isEndingSoon ? 1 : 0));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
             backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
             radius: 18,
          ),
        ),
        title: Row(
          children: [
            const Text('PolyMarket', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5, color: AppTheme.textColor)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: Colors.green),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accentPurple, size: 16),
                SizedBox(width: 6),
                Text('₹5,000', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 26, color: AppTheme.textColor),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentPurple))
          : _errorMessage.isNotEmpty 
             ? Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.textMuted),
                     const SizedBox(height: 16),
                     Text(_errorMessage, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     ElevatedButton(
                       onPressed: _fetchLiveMarkets,
                       style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
                       child: const Text('Retry Connection', style: TextStyle(color: Colors.white)),
                     )
                   ],
                 ),
               )
             : RefreshIndicator(
        color: AppTheme.accentPurple,
        onRefresh: _fetchLiveMarkets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breaking Market News Ticker
                _buildLiveTickerBanner(),
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search markets (e.g. Bitcoin, MI vs CSK, Elections)...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accentPurple),
                        suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Quick Stats Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentPurple.withOpacity(0.08), Colors.purple.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentPurple.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickStatItem('24h Volume', '₹54.2L', Icons.insights, Colors.indigo),
                        Container(width: 1, height: 30, color: Colors.black.withOpacity(0.08)),
                        _quickStatItem('Active Trades', '2,480', Icons.swap_calls, Colors.teal),
                        Container(width: 1, height: 30, color: Colors.black.withOpacity(0.08)),
                        _quickStatItem('Bullish Sentiment', '68%', Icons.trending_up, Colors.green),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Swipeable Hero Carousel
                if (featuredMarkets.isNotEmpty && _searchQuery.isEmpty) ...[
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.92),
                      onPageChanged: (idx) => setState(() => _currentHeroIndex = idx),
                      itemCount: featuredMarkets.length,
                      itemBuilder: (context, index) {
                         return Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                           child: _buildHeroCard(featuredMarkets[index]),
                         );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(featuredMarkets.length, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentHeroIndex == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                         color: _currentHeroIndex == index ? AppTheme.accentPurple : Colors.grey.shade300,
                         borderRadius: BorderRadius.circular(4)
                      ),
                    )),
                  ),
                ],
                
                const SizedBox(height: 28),
                
                // Image Circular Category Filters
                SizedBox(
                  height: 105,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final catData = _categories[index];
                      final category = catData['name']!;
                      final imageUrl = catData['image']!;
                      final isSelected = _selectedCategory == category;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.accentPurple : Colors.black.withOpacity(0.05),
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    if (isSelected) BoxShadow(color: AppTheme.accentPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                                    else BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                    colorFilter: isSelected 
                                       ? null 
                                       : ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.lighten),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.textColor : AppTheme.textMuted,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Closing Soon Horizontal List
                if (endingSoonMarkets.isNotEmpty && _selectedCategory == 'All' && _searchQuery.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.orange, size: 22),
                        SizedBox(width: 8),
                        Text('Closing Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppTheme.textColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: endingSoonMarkets.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _buildEndingSoonCard(context, endingSoonMarkets[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Active Markets Header & Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isNotEmpty ? 'Search Results (${filtered.length})' : 'Active Markets', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppTheme.textColor)
                      ),
                      Row(
                        children: [
                          _buildSortChip('Trending'),
                          const SizedBox(width: 6),
                          _buildSortChip('Ending Soon'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No markets found for "${_searchQuery.isNotEmpty ? _searchQuery : _selectedCategory}"', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildStandardMarketCard(context, m),
                  )).toList(),
                  
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveTickerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.04)),
          bottom: BorderSide(color: Colors.black.withOpacity(0.04)),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '🔥 BTC odds surge to 52% • CSK vs MI odds active • 12,450 trades today',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.accentPurple : Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(Market market) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MarketDetailScreen(market: market)));
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accentPurple, AppTheme.accentPurple.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppTheme.accentPurple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 14),
                      SizedBox(width: 4),
                      Text('TRENDING NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
               child: Text(market.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                Expanded(child: _buildHeroPriceBtn(market, 'YES', market.yesPrice, AppTheme.yesColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildHeroPriceBtn(market, 'NO', market.noPrice, AppTheme.noColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndingSoonCard(BuildContext context, Market market) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MarketDetailScreen(market: market)));
      },
      child: Container(
         width: 260,
         padding: const EdgeInsets.all(20),
         decoration: AppTheme.premiumCardDecoration.copyWith(
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                 child: Text(market.category.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 12),
              Expanded(
                 child: Text(market.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3, color: AppTheme.textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildCompactPrice(market.yesPrice, AppTheme.yesColor),
                    _buildCompactPrice(market.noPrice, AppTheme.noColor),
                 ],
              ),
              const SizedBox(height: 12),
              Row(
                 children: [
                    const Icon(Icons.schedule, color: AppTheme.textMuted, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text('Ends ${market.endDate}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                 ],
              )
           ],
         ),
      ),
    );
  }

  Widget _buildCompactPrice(int price, Color color) {
     return Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Center(
           child: Text('₹$price', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
     );
  }

  Widget _buildHeroPriceBtn(Market market, String label, int price, Color color) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.cardColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          builder: (_) => TradeSheet(market: market, isYes: label == 'YES'),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$label  ', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
                TextSpan(text: '₹$price', style: const TextStyle(color: AppTheme.bgColor, fontWeight: FontWeight.w900, fontSize: 18)),
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardMarketCard(BuildContext context, Market market) {
    final int total = market.yesPrice + market.noPrice;
    final int yesFlex = total > 0 ? (market.yesPrice / total * 100).toInt() : 50;
    final int noFlex = 100 - yesFlex;

    // Calculate payout multipliers
    final double yesMultiplier = market.yesPrice > 0 ? 100 / market.yesPrice : 2.0;
    final double noMultiplier = market.noPrice > 0 ? 100 / market.noPrice : 2.0;

    // Icon & Color mapping per Category
    IconData catIcon;
    Color catColor;
    switch (market.category.toLowerCase()) {
      case 'sports':
        catIcon = Icons.sports_cricket_rounded;
        catColor = Colors.orange.shade700;
        break;
      case 'politics':
        catIcon = Icons.account_balance_rounded;
        catColor = Colors.blue.shade700;
        break;
      case 'finance':
        catIcon = Icons.show_chart_rounded;
        catColor = Colors.green.shade700;
        break;
      case 'movies':
        catIcon = Icons.movie_filter_rounded;
        catColor = Colors.purple.shade700;
        break;
      case 'crypto':
        catIcon = Icons.currency_bitcoin_rounded;
        catColor = Colors.amber.shade800;
        break;
      default:
        catIcon = Icons.bolt_rounded;
        catColor = AppTheme.accentPurple;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MarketDetailScreen(market: market)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.premiumCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Avatar + Category Name + Verified Badge + Trend Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  market.category.toUpperCase(), 
                  style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8)
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, color: AppTheme.accentPurple, size: 13),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.yesColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up, color: AppTheme.yesColor, size: 12),
                      SizedBox(width: 4),
                      Text('+3.4% 24h', style: TextStyle(color: AppTheme.yesColor, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Market Title
            Text(
              market.title, 
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.35, color: AppTheme.textColor)
            ),

            const SizedBox(height: 16),

            // Odds Progress Bar & Multiplier Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Yes ', style: TextStyle(color: AppTheme.yesColor, fontWeight: FontWeight.w900, fontSize: 13)),
                    Text('${yesFlex}%', style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text('(${yesMultiplier.toStringAsFixed(2)}x payout)', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    Text('(${noMultiplier.toStringAsFixed(2)}x payout) ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text('${noFlex}%', style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900, fontSize: 13)),
                    const SizedBox(width: 2),
                    const Text(' No', style: TextStyle(color: AppTheme.noColor, fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Sleek Rounded Gradient Probability Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: yesFlex, 
                    child: Container(
                      height: 8, 
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: noFlex, 
                    child: Container(
                      height: 8, 
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFFF3D00), Color(0xFFDD2C00)]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // High Impact Interactive Buy Buttons
            Row(
              children: [
                Expanded(child: _buildStandardPriceBtn(market, 'Yes', market.yesPrice, AppTheme.yesColor, yesMultiplier)),
                const SizedBox(width: 12),
                Expanded(child: _buildStandardPriceBtn(market, 'No', market.noPrice, AppTheme.noColor, noMultiplier)),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Bottom Footer Meta: Volume, Expiry, Trader Count & Action arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                   children: [
                      Icon(Icons.bar_chart_rounded, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(market.volume, style: const TextStyle(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 12),
                      Icon(Icons.people_outline_rounded, color: Colors.grey.shade400, size: 15),
                      const SizedBox(width: 4),
                      const Text('1.2k', style: TextStyle(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule_rounded, color: Colors.grey.shade400, size: 14),
                      const SizedBox(width: 4),
                      Text(market.endDate, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                   ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('Trade', style: TextStyle(color: AppTheme.accentPurple, fontSize: 11, fontWeight: FontWeight.w900)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, color: AppTheme.accentPurple, size: 12),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStandardPriceBtn(Market market, String label, int price, Color color, double multiplier) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.cardColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          builder: (_) => TradeSheet(market: market, isYes: label.toUpperCase() == 'YES'),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(width: 6),
                Text('₹$price', style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${multiplier.toStringAsFixed(1)}x', 
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
