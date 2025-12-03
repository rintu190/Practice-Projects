import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/admin_service.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  List<dynamic> _pendingItems = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPendingApprovals();
  }

  Future<void> _fetchPendingApprovals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _adminService.getPendingApprovals();
      if (mounted) {
        setState(() {
          _pendingItems = result['data']?['items'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveItem(String type, int itemId) async {
    try {
      await _adminService.approveSingleItem(type: type, itemId: itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _fetchPendingApprovals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectItem(String type, int itemId) async {
    _showRejectDialog(type, itemId);
  }

  void _showRejectDialog(String type, int itemId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject this $type?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.rejectSingleItem(
                  type: type,
                  itemId: itemId,
                  reason: reasonController.text.isEmpty
                      ? 'No reason provided'
                      : reasonController.text,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type rejected'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  _fetchPendingApprovals();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPendingApprovals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPendingApprovals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _pendingItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: AppColors.success),
                          const SizedBox(height: 16),
                          const Text(
                            'No pending approvals',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchPendingApprovals,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPendingApprovals,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingItems.length,
                        itemBuilder: (context, index) {
                          final item = _pendingItems[index];
                          final type = item['type'] ?? 'unknown';
                          final itemId = item['id'] ?? 0;
                          final userId = item['user_id'] ?? 'N/A';
                          final userName = item['user_name'] ?? 'Unknown User';
                          final amount = item['amount'] ?? 0;
                          final createdAt = item['created_at'] ?? '';

                          return _buildApprovalCard(
                            type: type,
                            userId: userId,
                            userName: userName,
                            amount: amount,
                            createdAt: createdAt,
                            itemData: item,
                            onApprove: () => _approveItem(type, itemId as int),
                            onReject: () => _rejectItem(type, itemId as int),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildApprovalCard({
    required String type,
    required dynamic userId,
    required String userName,
    required dynamic amount,
    required String createdAt,
    required Map<String, dynamic> itemData,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    Color typeColor = AppColors.primary;
    IconData typeIcon = Icons.help_outline;

    if (type == 'deposit') {
      typeColor = Colors.green;
      typeIcon = Icons.arrow_downward;
    } else if (type == 'withdrawal') {
      typeColor = Colors.red;
      typeIcon = Icons.arrow_upward;
    } else if (type == 'transfer') {
      typeColor = Colors.blue;
      typeIcon = Icons.compare_arrows;
    } else if (type == 'kyc') {
      typeColor = Colors.orange;
      typeIcon = Icons.badge;
    } else if (type == 'bank') {
      typeColor = Colors.purple;
      typeIcon = Icons.account_balance;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userName (ID: $userId)',
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

          // Details
          if (type == 'kyc') ...[
            Text('Document: ${itemData['document_type'] ?? 'N/A'}'),
            Text('Number: ${itemData['document_number'] ?? 'N/A'}'),
            if (itemData['document_image'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Image: ${itemData['document_image']}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
              ),
          ] else if (type == 'bank') ...[
            Text('Bank: ${itemData['bank_name'] ?? 'N/A'}'),
            Text('Account: ${itemData['account_number'] ?? 'N/A'}'),
            Text('IFSC: ${itemData['ifsc_code'] ?? 'N/A'}'),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(double.tryParse(amount.toString()) ?? 0.0),
                      style: const TextStyle(
                        fontSize: 16,
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
                      'Created',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt.split(' ').isNotEmpty
                          ? createdAt.split(' ')[0]
                          : createdAt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
