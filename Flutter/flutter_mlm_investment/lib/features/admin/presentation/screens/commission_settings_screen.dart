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
                final rule = _rules[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rule['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Type: ${rule['type']} | Model: ${rule['model_type']}'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: rule['percentage'].toString(),
                                decoration: const InputDecoration(labelText: 'Percentage (%)'),
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (val) {
                                  _updateRule(
                                    int.parse(rule['id'].toString()),
                                    double.tryParse(val) ?? 0,
                                    double.parse(rule['fixed_amount'].toString()),
                                    rule['is_active'] == 1,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: rule['fixed_amount'].toString(),
                                decoration: const InputDecoration(labelText: 'Fixed Amount'),
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (val) {
                                  _updateRule(
                                    int.parse(rule['id'].toString()),
                                    double.parse(rule['percentage'].toString()),
                                    double.tryParse(val) ?? 0,
                                    rule['is_active'] == 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SwitchListTile(
                          title: const Text('Active'),
                          value: rule['is_active'] == 1,
                          onChanged: (val) {
                             _updateRule(
                                int.parse(rule['id'].toString()),
                                double.parse(rule['percentage'].toString()),
                                double.parse(rule['fixed_amount'].toString()),
                                val,
                              );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
