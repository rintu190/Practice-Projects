import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  int _currentHeroIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

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
      // 10.0.2.2 points to localhost for Android Emulators
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/markets/read.php'));
      
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
        _errorMessage = 'Could not reach server. Run "php -S localhost:8000"';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active subsets from the live array
    final featuredMarkets = _allMarkets.take(3).toList();
    final endingSoonMarkets = _allMarkets.where((m) => m.isEndingSoon).toList();
    
    final displayedMarkets = _selectedCategory == 'All'
        ? _allMarkets.where((m) => !m.isEndingSoon).toList()
        : _allMarkets.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
             backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
             radius: 18,
          ),
        ),
        title: const Text('PolyMarket', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5, color: AppTheme.textColor)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accentPurple, size: 16),
                SizedBox(width: 8),
                Text('₹5,000', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28, color: AppTheme.textColor),
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
                // Swipeable Hero Carousel
                if (featuredMarkets.isNotEmpty) ...[
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
                
                const SizedBox(height: 32),
                
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
                
                const SizedBox(height: 32),
                
                // Closing Soon Horizontal List
                if (endingSoonMarkets.isNotEmpty && _selectedCategory == 'All') ...[
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
                
                // Active Markets
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('Active Markets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppTheme.textColor)),
                ),
                const SizedBox(height: 16),
                
                if (displayedMarkets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No active markets in this category.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...displayedMarkets.map((m) => Padding(
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
                Expanded(child: _buildHeroPriceBtn('YES', market.yesPrice, AppTheme.yesColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildHeroPriceBtn('NO', market.noPrice, AppTheme.noColor)),
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

  Widget _buildHeroPriceBtn(String label, int price, Color color) {
    return Container(
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
    );
  }

  Widget _buildStandardMarketCard(BuildContext context, Market market) {
    final int total = market.yesPrice + market.noPrice;
    final int yesFlex = total > 0 ? (market.yesPrice / total * 100).toInt() : 50;
    final int noFlex = 100 - yesFlex;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(market.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4, color: AppTheme.textColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Expanded(flex: yesFlex, child: Container(height: 6, color: AppTheme.yesColor)),
                  Expanded(flex: noFlex, child: Container(height: 6, color: AppTheme.noColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStandardPriceBtn('Yes', market.yesPrice, AppTheme.yesColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildStandardPriceBtn('No', market.noPrice, AppTheme.noColor)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                   children: [
                      Icon(Icons.bar_chart_rounded, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(market.volume, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_filled, color: Colors.grey.shade400, size: 14),
                      const SizedBox(width: 4),
                      Text(market.endDate, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                   ],
                ),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                   child: Text(market.category.toUpperCase(), style: const TextStyle(color: AppTheme.textColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStandardPriceBtn(String label, int price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(width: 8),
          Text('₹$price', style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}
