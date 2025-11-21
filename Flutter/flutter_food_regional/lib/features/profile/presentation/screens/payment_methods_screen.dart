import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<Map<String, String>> _paymentMethods = [
    {'type': 'Card', 'title': 'Visa ending in 4242', 'subtitle': 'Expires 12/25'},
    {'type': 'UPI', 'title': 'user@upi', 'subtitle': 'Paytm'},
  ];

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Payment Method',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit/Debit Card'),
                onTap: () {
                  context.pop();
                  _showAddCardDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('UPI ID'),
                onTap: () {
                  context.pop();
                  _showAddUPIDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCardDialog() {
    // Simplified for mock
    setState(() {
      _paymentMethods.add({
        'type': 'Card',
        'title': 'Mastercard ending in 8888',
        'subtitle': 'Expires 01/28',
      });
    });
  }

  void _showAddUPIDialog() {
    // Simplified for mock
    setState(() {
      _paymentMethods.add({
        'type': 'UPI',
        'title': 'newuser@upi',
        'subtitle': 'GPay',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPaymentMethod,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          return ListTile(
            leading: Icon(
              method['type'] == 'Card' ? Icons.credit_card : Icons.qr_code,
              color: method['type'] == 'Card' ? Colors.blue : Colors.green,
            ),
            title: Text(method['title']!),
            subtitle: Text(method['subtitle']!),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _paymentMethods.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
