import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/genealogy_provider.dart';

class GenealogyScreen extends StatefulWidget {
  const GenealogyScreen({super.key});

  @override
  State<GenealogyScreen> createState() => _GenealogyScreenState();
}

class _GenealogyScreenState extends State<GenealogyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GenealogyProvider>().fetchStats();
      context.read<GenealogyProvider>().fetchTree(type: 'unilevel');
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final type = _tabController.index == 0 ? 'unilevel' : 'binary';
        context.read<GenealogyProvider>().fetchTree(type: type);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Unilevel Tree'),
            Tab(text: 'Binary Tree'),
          ],
        ),
      ),
      body: Consumer<GenealogyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUnilevelView(provider.treeData),
              _buildBinaryView(provider.treeData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnilevelView(Map<String, dynamic>? data) {
    if (data == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildTreeNode(data, 0),
        ],
      ),
    );
  }

  Widget _buildTreeNode(Map<String, dynamic> node, int depth) {
    final children = (node['children'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 20.0, bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (node['name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    node['rank'] ?? 'Member',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...children.map((child) => _buildTreeNode(child, depth + 1)),
      ],
    );
  }

  Widget _buildBinaryView(Map<String, dynamic>? data) {
    if (data == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsCard(),
          const SizedBox(height: 40),
          _buildBinaryNode(data),
        ],
      ),
    );
  }

  Widget _buildBinaryNode(Map<String, dynamic>? node) {
    if (node == null) {
      return Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.grey.shade400, style: BorderStyle.solid),
            ),
            child: const Icon(Icons.add, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text('Empty', style: TextStyle(fontSize: 10)),
        ],
      );
    }

    return Column(
      children: [
        // Node
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              (node['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          node['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          node['rank'] ?? 'Member',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Children (Left/Right)
        if (node['left'] != null || node['right'] != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Leg
              Expanded(
                child: Column(
                  children: [
                    Container(height: 1, color: Colors.grey.shade400),
                    Container(
                        width: 1, height: 20, color: Colors.grey.shade400),
                    _buildBinaryNode(node['left']),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right Leg
              Expanded(
                child: Column(
                  children: [
                    Container(height: 1, color: Colors.grey.shade400),
                    Container(
                        width: 1, height: 20, color: Colors.grey.shade400),
                    _buildBinaryNode(node['right']),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Consumer<GenealogyProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF8B84FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Direct Team', stats?['direct_referrals']?.toString() ?? '0'),
              _buildStatItem(
                  'Total Team', stats?['total_team']?.toString() ?? '0'),
              _buildStatItem(
                  'Active', stats?['active_members']?.toString() ?? '0'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
