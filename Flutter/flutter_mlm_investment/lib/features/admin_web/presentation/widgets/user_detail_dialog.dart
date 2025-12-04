import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../admin/data/services/admin_service.dart';

class UserDetailDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const UserDetailDialog({
    super.key,
    required this.userId,
    required this.onUpdate,
  });

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _isUpdating = false;

  String? _selectedRank;
  String? _selectedStatus;

  final List<String> _ranks = ['Member', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
  final List<String> _statuses = ['active', 'inactive', 'suspended', 'banned'];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _adminService.getUserDetails(widget.userId);
      setState(() {
        _details = details;
        
        // Normalize Rank (Handle case mismatch, e.g. 'member' vs 'Member')
        String apiRank = details['user']['rank']?.toString() ?? 'Member';
        _selectedRank = _ranks.firstWhere(
          (r) => r.toLowerCase() == apiRank.toLowerCase(),
          orElse: () => _ranks.first,
        );

        // Normalize Status (Handle case mismatch, e.g. 'Active' vs 'active')
        String apiStatus = details['user']['status']?.toString() ?? 'active';
        _selectedStatus = _statuses.firstWhere(
          (s) => s.toLowerCase() == apiStatus.toLowerCase(),
          orElse: () => _statuses.first,
        );
        
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

  Future<void> _updateUser() async {
    setState(() => _isUpdating = true);
    try {
      await _adminService.updateUser(
        widget.userId,
        rank: _selectedRank,
        status: _selectedStatus,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'User #${widget.userId}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection('Personal Information', [
                            _buildInfoRow('Phone', _details!['user']['phone'] ?? 'N/A'),
                            _buildInfoRow('Email', _details!['user']['email'] ?? 'N/A'),
                            _buildInfoRow('Referral Code', _details!['user']['referral_code'] ?? 'N/A'),
                            _buildInfoRow('Joined', _details!['user']['created_at'] ?? 'N/A'),
                          ]),

                          const SizedBox(height: 24),

                          _buildSection('Wallet Balances', [
                            _buildInfoRow(
                              'E-Wallet',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['user']['e_wallet_balance']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                            _buildInfoRow(
                              'Investment Wallet',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['user']['investment_wallet_balance']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                            _buildInfoRow(
                              'Earnings',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['user']['earnings_balance']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                            _buildInfoRow(
                              'Total Earned',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['user']['total_earned']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          _buildSection('Investment Summary', [
                            _buildInfoRow(
                              'Active Investments',
                              (_details!['investments_summary']['count'] ?? 0).toString(),
                            ),
                            _buildInfoRow(
                              'Total Invested',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['investments_summary']['total_invested']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                            _buildInfoRow(
                              'Total Profit',
                              Formatters.formatCurrency(
                                double.tryParse(_details!['investments_summary']['total_profit']?.toString() ?? '0') ?? 0.0,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          _buildSection('Team Information', [
                            _buildInfoRow(
                              'Total Referrals',
                              (_details!['referrals_count'] ?? 0).toString(),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Edit Section
                          const Text(
                            'Update User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRank,
                            decoration: const InputDecoration(
                              labelText: 'Rank',
                              border: OutlineInputBorder(),
                            ),
                            items: _ranks.map((rank) {
                              return DropdownMenuItem(value: rank, child: Text(rank));
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedRank = value),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _statuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedStatus = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isUpdating ? null : _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isUpdating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update User'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
