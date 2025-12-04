import 'package:flutter/material.dart';
import '../../data/services/admin_service.dart';

class CommissionSettingsScreen extends StatefulWidget {
  const CommissionSettingsScreen({Key? key}) : super(key: key);

  @override
  _CommissionSettingsScreenState createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    try {
      final rules = await _adminService.getCommissionRules();
      setState(() {
        _rules = rules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _updateRule(int id, double percentage, double fixedAmount, bool isActive) async {
    try {
      await _adminService.updateCommissionRule(id, percentage, fixedAmount, isActive);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rule updated')));
      _loadRules();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commission Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                return CommissionRuleCard(
                  rule: _rules[index],
                  onUpdate: _updateRule,
                );
              },
            ),
    );
  }
}

class CommissionRuleCard extends StatefulWidget {
  final dynamic rule;
  final Function(int, double, double, bool) onUpdate;

  const CommissionRuleCard({
    Key? key,
    required this.rule,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CommissionRuleCardState createState() => _CommissionRuleCardState();
}

class _CommissionRuleCardState extends State<CommissionRuleCard> {
  late TextEditingController _percentageController;
  late TextEditingController _fixedAmountController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController(text: widget.rule['percentage'].toString());
    _fixedAmountController = TextEditingController(text: widget.rule['fixed_amount'].toString());
    _isActive = widget.rule['is_active'] == 1;
  }

  @override
  void didUpdateWidget(CommissionRuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _percentageController.text = widget.rule['percentage'].toString();
      _fixedAmountController.text = widget.rule['fixed_amount'].toString();
      _isActive = widget.rule['is_active'] == 1;
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _fixedAmountController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onUpdate(
      int.parse(widget.rule['id'].toString()),
      double.tryParse(_percentageController.text) ?? 0,
      double.tryParse(_fixedAmountController.text) ?? 0,
      _isActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.rule['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Type: ${widget.rule['type']} | Model: ${widget.rule['model_type']}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.blue),
                  onPressed: _handleSave,
                  tooltip: 'Save Changes',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _percentageController,
                    decoration: const InputDecoration(labelText: 'Percentage (%)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fixedAmountController,
                    decoration: const InputDecoration(labelText: 'Fixed Amount'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (val) {
                setState(() {
                  _isActive = val;
                });
                // Optional: Auto-save on toggle, or let user click save
                // For now, let's auto-save toggle for convenience, but keep text fields manual
                _handleSave(); 
              },
            ),
          ],
        ),
      ),
    );
  }
}

