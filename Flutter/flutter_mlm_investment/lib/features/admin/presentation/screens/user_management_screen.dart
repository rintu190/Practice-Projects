import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getUsers(search: _searchController.text);
      setState(() {
        _users = users;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by phone or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadUsers();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadUsers(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            (user['phone'] ?? 'U').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(user['phone'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['email'] != null) Text(user['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(user['status'] ?? 'active',
                    user['status'] == 'active' ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                _buildBadge(user['rank'] ?? 'Member', Colors.blue),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(userId: user['id']),
            ),
          ).then((_) => _loadUsers());
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_details == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load details')),
      );
    }

    final user = _details!['user'];
    final investments = _details!['investments_summary'];
    final referrals = _details!['referrals_count'];

    return Scaffold(
      appBar: AppBar(
        title: Text('User #${user['id']}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(user, referrals),
            const SizedBox(height: 16),
            _buildWalletCard(user),
            const SizedBox(height: 16),
            _buildInvestmentCard(investments),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(dynamic user, dynamic referrals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildRow('Phone', user['phone']),
            _buildRow('Email', user['email'] ?? 'N/A'),
            _buildRow('Status', user['status']),
            _buildRow('Rank', user['rank']),
            _buildRow('KYC Status', user['kyc_status']),
            _buildRow('Referrals', referrals.toString()),
            _buildRow('Joined', user['created_at']),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wallets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _showAdjustWalletDialog(user['id']),
                  child: const Text('Adjust'),
                ),
              ],
            ),
            const Divider(),
            _buildRow('E-Wallet', Formatters.formatCurrency(user['e_wallet_balance'])),
            _buildRow('Investment Wallet', Formatters.formatCurrency(user['investment_wallet_balance'])),
            _buildRow('Earnings', Formatters.formatCurrency(user['earnings_balance'])),
            _buildRow('Total Earned', Formatters.formatCurrency(user['total_earned'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(dynamic investments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Investments Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildRow('Active Count', investments['count'].toString()),
            _buildRow('Total Invested', Formatters.formatCurrency(investments['total_invested'] ?? 0)),
            _buildRow('Total Profit', Formatters.formatCurrency(investments['total_profit'] ?? 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showEditDialog(dynamic user) {
    String status = user['status'];
    String rank = user['rank'];
    final ranks = ['Member', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    final statuses = ['active', 'inactive', 'suspended', 'banned'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: statuses.contains(status) ? status : statuses.first,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ranks.contains(rank) ? rank : ranks.first,
                decoration: const InputDecoration(labelText: 'Rank'),
                items: ranks.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => rank = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _adminService.updateUser(user['id'], rank: rank, status: status);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadDetails();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustWalletDialog(int userId) {
    double amount = 0;
    String type = 'credit';
    String walletType = 'e_wallet';
    String description = 'Admin Adjustment';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adjust Wallet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: walletType,
                  decoration: const InputDecoration(labelText: 'Wallet'),
                  items: const [
                    DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                    DropdownMenuItem(value: 'investment_wallet', child: Text('Investment Wallet')),
                    DropdownMenuItem(value: 'earnings', child: Text('Earnings Wallet')),
                  ],
                  onChanged: (val) => setState(() => walletType = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'credit', child: Text('Credit (+)')),
                    DropdownMenuItem(value: 'debit', child: Text('Debit (-)')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => amount = double.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (val) => description = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (amount <= 0) return;
                try {
                  await _adminService.adjustWallet(userId, amount, type, walletType, description);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadDetails();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
