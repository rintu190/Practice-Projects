import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/payment_method.dart';
import '../../data/providers/payment_provider.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
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
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Card Number (Last 4 digits)'),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (numberController.text.length == 4 && expiryController.text.isNotEmpty) {
                        setState(() => isLoading = true);
                        final method = PaymentMethod(
                          type: 'Card',
                          title: 'Card ending in ${numberController.text}',
                          subtitle: 'Expires ${expiryController.text}',
                        );
                        try {
                          await ref.read(paymentProvider.notifier).addPaymentMethod(method);
                          if (context.mounted) context.pop();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUPIDialog() {
    final upiController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add UPI'),
          content: TextField(
            controller: upiController,
            decoration: const InputDecoration(labelText: 'UPI ID'),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (upiController.text.isNotEmpty) {
                        setState(() => isLoading = true);
                        final method = PaymentMethod(
                          type: 'UPI',
                          title: upiController.text,
                          subtitle: 'UPI',
                        );
                        try {
                          await ref.read(paymentProvider.notifier).addPaymentMethod(method);
                          if (context.mounted) context.pop();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsAsync = ref.watch(paymentProvider);

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
      body: paymentMethodsAsync.when(
        data: (methods) {
          if (methods.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No payment methods added'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              return ListTile(
                leading: Icon(
                  method.type == 'Card' ? Icons.credit_card : Icons.qr_code,
                  color: method.type == 'Card' ? Colors.blue : Colors.green,
                ),
                title: Text(method.title),
                subtitle: Text(method.subtitle),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (method.id != null) {
                      try {
                        await ref.read(paymentProvider.notifier).deletePaymentMethod(method.id!);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(paymentProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
