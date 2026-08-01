import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../models/market.dart';
import '../theme.dart';

class MarketDetailScreen extends StatefulWidget {
  final Market market;

  const MarketDetailScreen({super.key, required this.market});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.market.category.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppTheme.accentPurple)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.market.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.3, color: AppTheme.textColor)),
                    const SizedBox(height: 16),
                    
                    // Large Yes / No blocks
                    Row(
                      children: [
                        Expanded(
                          child: _buildOutcomeBlock('YES', widget.market.yesPrice, AppTheme.yesColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOutcomeBlock('NO', widget.market.noPrice, AppTheme.noColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Chart Area
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.black.withOpacity(0.05), strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('₹${val.toInt()}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)))),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 30), FlSpot(1, 45), FlSpot(2, 35), FlSpot(3, 50), FlSpot(4, 60), FlSpot(5, 55), FlSpot(6, 62),
                              ],
                              isCurved: true,
                              color: AppTheme.yesColor,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.yesColor.withOpacity(0.15),
                              ),
                            ),
                          ],
                          minY: 0,
                          maxY: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // New Market Stats grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassDecoration,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatColumn('24H Volume', widget.market.volume24h)),
                              Container(width: 1, height: 40, color: Colors.black.withOpacity(0.05)),
                              Expanded(child: _buildStatColumn('Total Volume', widget.market.volume)),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                          Row(
                            children: [
                              Expanded(child: _buildStatColumn('Start Date', widget.market.startDate)),
                              Container(width: 1, height: 40, color: Colors.black.withOpacity(0.05)),
                              Expanded(child: _buildStatColumn('End Date', widget.market.endDate)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.accentPurple,
                      labelColor: AppTheme.textColor,
                      unselectedLabelColor: AppTheme.textMuted,
                      tabs: const [
                        Tab(text: 'Order Book'),
                        Tab(text: 'Rules'),
                        Tab(text: 'Activity'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderBook(),
                          _buildRules(),
                          _buildActivity(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Fixed Bottom Bar for Trading triggers
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yesColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                      shadowColor: AppTheme.yesColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showTradeSheet(context, true),
                    child: const Text('Buy Yes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.noColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                      shadowColor: AppTheme.noColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showTradeSheet(context, false),
                    child: const Text('Buy No', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOutcomeBlock(String label, int price, Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text('₹$price', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textColor)),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderBook() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bids (Buy Yes)', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
            Text('Asks (Buy No)', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),
        _orderBookRow('₹62', '452', '₹38', '920', AppTheme.yesColor, AppTheme.noColor),
        _orderBookRow('₹61', '125', '₹39', '140', AppTheme.yesColor, AppTheme.noColor),
        _orderBookRow('₹60', '800', '₹40', '50', AppTheme.yesColor, AppTheme.noColor),
      ],
    );
  }

  Widget _orderBookRow(String p1, String s1, String p2, String s2, Color c1, Color c2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Text(p1, style: TextStyle(color: c1, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text(s1, style: const TextStyle(color: AppTheme.textMuted))]),
          Row(children: [Text(s2, style: const TextStyle(color: AppTheme.textMuted)), const SizedBox(width: 8), Text(p2, style: TextStyle(color: c2, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildRules() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('This market resolves to YES if the underlying event occurs before the specified expiry date. Resolution relies on the official source. If the source is unavailable, a consensus of major news outlets applies.', style: TextStyle(color: AppTheme.textMuted, height: 1.5)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Source', style: TextStyle(color: AppTheme.textMuted)),
              Text('Official Announcement', style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Volume', style: TextStyle(color: AppTheme.textMuted)),
              Text(widget.market.volume, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActivity() {
    return ListView(
      children: [
        _activityRow('User_982 bought 100 YES', '2 mins ago'),
        _activityRow('Whale_X sold 500 NO', '5 mins ago'),
        _activityRow('Trader_Z bought 50 YES', '12 mins ago'),
      ],
    );
  }

  Widget _activityRow(String action, String time) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.05), child: const Icon(Icons.swap_horiz, color: AppTheme.textColor)),
      title: Text(action, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor)),
      subtitle: Text(time, style: const TextStyle(color: AppTheme.textMuted)),
    );
  }

  void _showTradeSheet(BuildContext context, bool isYes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => TradeSheet(market: widget.market, isYes: isYes),
    );
  }
}

class TradeSheet extends StatefulWidget {
  final Market market;
  final bool isYes;

  const TradeSheet({super.key, required this.market, required this.isYes});

  @override
  State<TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends State<TradeSheet> {
  final TextEditingController _amountController = TextEditingController();
  bool _isYes = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isYes = widget.isYes;
  }

  Future<void> _submitOrder(double amount, int price) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final shares = (amount / price).round();

    try {
      final response = await ApiConfig.post(
        '/api/orders/create.php',
        jsonBody: json.encode({
          'user_id': 1,
          'market_id': widget.market.id,
          'outcome': _isYes ? 'YES' : 'NO',
          'shares': shares > 0 ? shares : 1,
          'price_per_share': price,
          'total_amount': amount,
        }),
      );

      if (mounted) {
        Navigator.pop(context);
        if (response.statusCode == 200) {
          final resData = json.decode(response.body);
          if (resData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order Placed Successfully! Shares: ${shares > 0 ? shares : 1}'),
                backgroundColor: AppTheme.yesColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(resData['message'] ?? 'Failed to place order')),
            );
          }
        } else {
          // Local fallback response notice
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order Submitted: ₹${amount.toStringAsFixed(0)} on ${_isYes ? "YES" : "NO"}'),
              backgroundColor: AppTheme.accentPurple,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order Placed: ₹${amount.toStringAsFixed(0)} on ${_isYes ? "YES" : "NO"} (Demo Mode)'),
            backgroundColor: AppTheme.accentPurple,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _isYes ? AppTheme.yesColor : AppTheme.noColor;
    int currentPrice = _isYes ? widget.market.yesPrice : widget.market.noPrice;
    
    double inputAmount = double.tryParse(_amountController.text) ?? 0.0;
    double potentialPayout = currentPrice > 0 ? (inputAmount / currentPrice) * 100 : 0;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trade ${widget.market.category}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
              const Text('Bal: ₹5,000', style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
               Expanded(
                 child: GestureDetector(
                   onTap: () => setState(() => _isYes = true),
                   child: Container(
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     decoration: BoxDecoration(
                        color: _isYes ? AppTheme.yesColor.withOpacity(0.15) : Colors.transparent,
                        border: Border.all(color: _isYes ? AppTheme.yesColor : Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                     ),
                     child: Center(child: Text('Buy YES ₹${widget.market.yesPrice}', style: TextStyle(color: _isYes ? AppTheme.yesColor : AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 16))),
                   ),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: GestureDetector(
                   onTap: () => setState(() => _isYes = false),
                   child: Container(
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     decoration: BoxDecoration(
                        color: !_isYes ? AppTheme.noColor.withOpacity(0.15) : Colors.transparent,
                        border: Border.all(color: !_isYes ? AppTheme.noColor : Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                     ),
                     child: Center(child: Text('Buy NO ₹${widget.market.noPrice}', style: TextStyle(color: !_isYes ? AppTheme.noColor : AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 16))),
                   ),
                 ),
               ),
            ],
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration,
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState((){}),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textColor),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textColor),
                hintText: '0',
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                   const Text('Est. Shares', style: TextStyle(color: AppTheme.textMuted)),
                   Text(currentPrice > 0 ? (inputAmount / currentPrice).toStringAsFixed(2) : '0.00', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                   Text('Fees', style: TextStyle(color: AppTheme.textMuted)),
                   Text('₹0.00', style: TextStyle(color: AppTheme.yesColor, fontWeight: FontWeight.bold)),
                ]),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                   const Text('Potential Return', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                   Text('₹${potentialPayout.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.yesColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: activeColor.withOpacity(0.5)
            ),
            onPressed: _isSubmitting ? null : () => _submitOrder(inputAmount, currentPrice),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
