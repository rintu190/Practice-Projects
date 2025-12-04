import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/support_service.dart';
import 'create_ticket_screen.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final SupportService _supportService = SupportService();
  List<dynamic> _faqs = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  final Map<String, IconData> _categoryIcons = {
    'general': Icons.info_outline,
    'investment': Icons.trending_up,
    'withdrawal': Icons.account_balance_wallet,
    'account': Icons.person_outline,
    'security': Icons.security,
    'mlm': Icons.people_outline,
  };

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoading = true);
    try {
      final faqs = await _supportService.getFAQs(category: _selectedCategory);
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', 'all', Icons.apps),
                const SizedBox(width: 8),
                _buildCategoryChip('General', 'general', Icons.info_outline),
                const SizedBox(width: 8),
                _buildCategoryChip('Investment', 'investment', Icons.trending_up),
                const SizedBox(width: 8),
                _buildCategoryChip('Withdrawal', 'withdrawal', Icons.account_balance_wallet),
                const SizedBox(width: 8),
                _buildCategoryChip('Account', 'account', Icons.person_outline),
                const SizedBox(width: 8),
                _buildCategoryChip('Security', 'security', Icons.security),
                const SizedBox(width: 8),
                _buildCategoryChip('MLM', 'mlm', Icons.people_outline),
              ],
            ),
          ),
        ),

        // FAQs List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _faqs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _faqs.length,
                      itemBuilder: (context, index) {
                        return _buildFAQCard(_faqs[index]);
                      },
                    ),
        ),

        // Help Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTicketScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Still need help? Create a ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = value);
        _loadFAQs();
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No FAQs found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(dynamic faq) {
    final category = faq['category'] ?? 'general';
    final icon = _categoryIcons[category] ?? Icons.help_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            faq['question'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              category.toUpperCase(),
              style: TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer'] ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
