import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../admin/data/services/admin_service.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  Map<String, List<dynamic>> _pendingItems = {
    'deposits': [],
    'withdrawals': [],
    'transfers': [],
    'kyc': [],
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPendingItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _adminService.getPendingApprovals();
      setState(() {
        _pendingItems = {
          'deposits': items['deposits'] ?? [],
          'withdrawals': items['withdrawals'] ?? [],
          'transfers': items['transfers'] ?? [],
          'kyc': items['kyc'] ?? [],
        };
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

  Future<void> _handleApproval(String type, int id, bool approve) async {
    try {
      await _adminService.approveItem(type, id, approve);
      await _loadPendingItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Approved successfully' : 'Rejected successfully'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
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
        // Tabs
        Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Deposits'),
                    if (_pendingItems['deposits']!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildBadge(_pendingItems['deposits']!.length),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Withdrawals'),
                    if (_pendingItems['withdrawals']!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildBadge(_pendingItems['withdrawals']!.length),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Transfers'),
                    if (_pendingItems['transfers']!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildBadge(_pendingItems['transfers']!.length),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('KYC'),
                    if (_pendingItems['kyc']!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildBadge(_pendingItems['kyc']!.length),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDepositsList(),
                      _buildWithdrawalsList(),
                      _buildTransfersList(),
                      _buildKycList(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDepositsList() {
    final deposits = _pendingItems['deposits']!;
    if (deposits.isEmpty) {
      return const Center(child: Text('No pending deposits'));
    }

    return ListView.builder(
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        final deposit = deposits[index];
        return _buildApprovalCard(
          icon: Icons.arrow_downward,
          iconColor: Colors.green,
          title: 'Deposit Request',
          subtitle: 'User: ${deposit['user_phone'] ?? deposit['user_id']}',
          amount: Formatters.formatCurrency((deposit['amount'] ?? 0).toDouble()),
          date: deposit['created_at'] ?? '',
          details: [
            'Method: ${deposit['payment_method'] ?? 'N/A'}',
            'Reference: ${deposit['transaction_id'] ?? 'N/A'}',
          ],
          onApprove: () => _handleApproval('deposit', deposit['id'], true),
          onReject: () => _handleApproval('deposit', deposit['id'], false),
        );
      },
    );
  }

  Widget _buildWithdrawalsList() {
    final withdrawals = _pendingItems['withdrawals']!;
    if (withdrawals.isEmpty) {
      return const Center(child: Text('No pending withdrawals'));
    }

    return ListView.builder(
      itemCount: withdrawals.length,
      itemBuilder: (context, index) {
        final withdrawal = withdrawals[index];
        return _buildApprovalCard(
          icon: Icons.arrow_upward,
          iconColor: Colors.red,
          title: 'Withdrawal Request',
          subtitle: 'User: ${withdrawal['user_phone'] ?? withdrawal['user_id']}',
          amount: Formatters.formatCurrency((withdrawal['amount'] ?? 0).toDouble()),
          date: withdrawal['created_at'] ?? '',
          details: [
            'Bank: ${withdrawal['bank_name'] ?? 'N/A'}',
            'Account: ${withdrawal['account_number'] ?? 'N/A'}',
          ],
          onApprove: () => _handleApproval('withdrawal', withdrawal['id'], true),
          onReject: () => _handleApproval('withdrawal', withdrawal['id'], false),
        );
      },
    );
  }

  Widget _buildTransfersList() {
    final transfers = _pendingItems['transfers']!;
    if (transfers.isEmpty) {
      return const Center(child: Text('No pending transfers'));
    }

    return ListView.builder(
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _buildApprovalCard(
          icon: Icons.swap_horiz,
          iconColor: Colors.blue,
          title: 'Transfer Request',
          subtitle: 'User: ${transfer['user_phone'] ?? transfer['user_id']}',
          amount: Formatters.formatCurrency((transfer['amount'] ?? 0).toDouble()),
          date: transfer['created_at'] ?? '',
          details: [
            'From: ${transfer['from_wallet'] ?? 'N/A'}',
            'To: ${transfer['to_wallet'] ?? 'N/A'}',
          ],
          onApprove: () => _handleApproval('transfer', transfer['id'], true),
          onReject: () => _handleApproval('transfer', transfer['id'], false),
        );
      },
    );
  }

  Widget _buildKycList() {
    final kycList = _pendingItems['kyc']!;
    if (kycList.isEmpty) {
      return const Center(child: Text('No pending KYC'));
    }

    return ListView.builder(
      itemCount: kycList.length,
      itemBuilder: (context, index) {
        final kyc = kycList[index];
        return _buildApprovalCard(
          icon: Icons.verified_user,
          iconColor: Colors.purple,
          title: 'KYC Verification',
          subtitle: 'User: ${kyc['user_phone'] ?? kyc['user_id']}',
          amount: null,
          date: kyc['created_at'] ?? '',
          details: [
            'Document Type: ${kyc['document_type'] ?? 'N/A'}',
            'Document Number: ${kyc['document_number'] ?? 'N/A'}',
          ],
          onApprove: () => _handleApproval('kyc', kyc['id'], true),
          onReject: () => _handleApproval('kyc', kyc['id'], false),
        );
      },
    );
  }

  Widget _buildApprovalCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? amount,
    required String date,
    required List<String> details,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (amount != null)
                        Text(
                          amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ...details.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          detail,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Actions
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
