import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/investment_service.dart';
import '../../data/models/investment_product.dart';
import 'investment_detail_screen.dart'; // For navigation
import 'investment_purchase_screen.dart';

class InvestmentCategoriesScreen extends StatefulWidget {
  const InvestmentCategoriesScreen({super.key});

  @override
  State<InvestmentCategoriesScreen> createState() =>
      _InvestmentCategoriesScreenState();
}

class _InvestmentCategoriesScreenState
    extends State<InvestmentCategoriesScreen> {
  final InvestmentService _investmentService = InvestmentService();
  bool _isLoading = true;
  List<InvestmentCategory> categories = [];
  String? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _investmentService.getProducts();
      _groupProductsIntoCategories(products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plans: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _groupProductsIntoCategories(List<InvestmentProduct> products) {
    final Map<String, List<InvestmentProduct>> grouped = {};
    
    for (var product in products) {
      final category = product.category ?? 'Other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(product);
    }

    final List<InvestmentCategory> newCategories = [];
    int idCounter = 1;

    // Define category metadata (icon, color, description)
    final Map<String, Map<String, dynamic>> meta = {
      'Securities': {
        'icon': Icons.trending_up,
        'color': Colors.blue,
        'desc': 'Stock and bond investments'
      },
      'Derivatives': {
        'icon': Icons.candlestick_chart,
        'color': Colors.orange,
        'desc': 'Options and futures trading'
      },
      'Currency': {
        'icon': Icons.currency_exchange,
        'color': Colors.green,
        'desc': 'Forex and currency trading'
      },
      'Commodity': {
        'icon': Icons.store,
        'color': Colors.amber,
        'desc': 'Gold, silver, and commodity futures'
      },
      'Real Estate': {
        'icon': Icons.real_estate_agent,
        'color': Colors.red,
        'desc': 'Property and real estate investments'
      },
    };

    grouped.forEach((categoryName, productList) {
      final metadata = meta[categoryName] ?? {
        'icon': Icons.category,
        'color': Colors.grey,
        'desc': 'Various investment plans'
      };

      // Sort plans by min amount (Bronze < Silver < Gold)
      productList.sort((a, b) => a.minAmount.compareTo(b.minAmount));

      newCategories.add(InvestmentCategory(
        id: idCounter++,
        name: categoryName,
        icon: metadata['icon'] as IconData,
        color: metadata['color'] as Color,
        description: metadata['desc'] as String,
        plans: productList.map((p) => InvestmentPlan(
          id: p.id, // Add ID to InvestmentPlan
          tier: p.tier ?? 'Standard',
          minAmount: p.minAmount,
          maxAmount: p.maxAmount,
          roiPercentage: p.roiPercentage,
          duration: p.durationDays,
          features: _getFeaturesForTier(p.tier ?? 'Standard', p.roiFrequency),
        )).toList(),
      ));
    });

    setState(() {
      categories = newCategories;
    });
  }

  List<String> _getFeaturesForTier(String tier, String frequency) {
    final freq = frequency[0].toUpperCase() + frequency.substring(1);
    final base = ['$freq ROI'];
    
    switch (tier) {
      case 'Bronze':
        return [...base, 'Low Risk', 'Standard Support'];
      case 'Silver':
        return [...base, 'Medium Risk', 'Priority Support', 'Flexible Withdrawal'];
      case 'Gold':
        return [...base, 'Low Risk', 'VIP Support', 'Flexible Withdrawal', 'Bonus Rewards'];
      default:
        return [...base, 'Standard Features'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Investment Plans'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) =>
            _buildCategoryCard(context, categories[index]),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, InvestmentCategory category) {
    final isExpanded = _expandedCategoryId == category.id.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Category Header
          InkWell(
            onTap: () => setState(() {
              _expandedCategoryId = isExpanded ? null : category.id.toString();
            }),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, color: category.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Plans (shown when expanded)
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: category.plans
                    .map((plan) => _buildPlanTile(context, category, plan))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(
      BuildContext context, InvestmentCategory category, InvestmentPlan plan) {
    Color tierColor = Colors.grey;
    switch (plan.tier) {
      case 'Bronze':
        tierColor = const Color(0xFFCD7F32);
        break;
      case 'Silver':
        tierColor = const Color(0xFFC0C0C0);
        break;
      case 'Gold':
        tierColor = const Color(0xFFFFD700);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tierColor, width: 1.5),
                  ),
                  child: Text(
                    plan.tier,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plan.roiPercentage}% ROI',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${plan.duration} Days',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Investment Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Min Investment',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(plan.minAmount.toDouble()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Max Investment',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.maxAmount == null
                          ? 'Unlimited'
                          : Formatters.formatCurrency(
                              plan.maxAmount!.toDouble()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Features
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: plan.features
                      .map((feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: category.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11,
                                color: category.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Invest Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvestmentPurchaseScreen(
                        category: category,
                        plan: plan,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: category.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Invest Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvestmentCategory {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<InvestmentPlan> plans;

  InvestmentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.plans,
  });
}

class InvestmentPlan {
  final int id;
  final String tier;
  final double minAmount;
  final double? maxAmount;
  final double roiPercentage;
  final int duration;
  final List<String> features;

  InvestmentPlan({
    required this.id,
    required this.tier,
    required this.minAmount,
    required this.maxAmount,
    required this.roiPercentage,
    required this.duration,
    required this.features,
  });
}
