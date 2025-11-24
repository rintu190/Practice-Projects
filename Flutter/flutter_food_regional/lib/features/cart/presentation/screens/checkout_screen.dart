import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../profile/data/providers/address_provider.dart';
import '../../../profile/data/providers/selected_address_provider.dart';
import '../../../profile/data/providers/payment_provider.dart';
import '../../../orders/data/providers/order_provider.dart';
import '../../../profile/data/models/address.dart';
import '../../../profile/data/models/payment_method.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;
  PaymentMethod? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    final totalAmount = ref.watch(cartTotalProvider);
    final deliveryFee = 2.0;
    final finalTotal = totalAmount + deliveryFee;
    
    final addressesAsync = ref.watch(addressProvider);
    final paymentMethodsAsync = ref.watch(paymentProvider);
    final cartItems = ref.watch(cartProvider);

    final selectedAddress = ref.watch(selectedAddressProvider);

    // Auto-select first address if not selected
    addressesAsync.whenData((addresses) {
      if (selectedAddress == null && addresses.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedAddressProvider.notifier).selectAddress(addresses.first);
        });
      }
    });

    paymentMethodsAsync.whenData((methods) {
      if (_selectedPaymentMethod == null && methods.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedPaymentMethod = methods.first);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: addressesAsync.when(
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          return ListTile(
                            title: const Text('No address found'),
                            trailing: TextButton(
                              onPressed: () => context.push('/address'),
                              child: const Text('Add'),
                            ),
                          );
                        }
                        
                        final displayAddress = selectedAddress ?? addresses.first;
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.orange),
                          title: Text(displayAddress.locality),
                          subtitle: Text('${displayAddress.houseNumber}, ${displayAddress.street}, ${displayAddress.city}'),
                          trailing: TextButton(
                            onPressed: () async {
                              await context.push('/address-selection');
                              // Refresh addresses after returning
                              ref.invalidate(addressProvider);
                            },
                            child: const Text('Change'),
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => ListTile(title: Text('Error: $e')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: paymentMethodsAsync.when(
                      data: (methods) {
                        if (methods.isEmpty) {
                          return ListTile(
                            title: const Text('No payment method found'),
                            trailing: TextButton(
                              onPressed: () => context.push('/payment-methods'),
                              child: const Text('Add'),
                            ),
                          );
                        }

                        final displayMethod = _selectedPaymentMethod ?? methods.first;
                        return ListTile(
                          leading: Icon(
                            displayMethod.type == 'Card' ? Icons.credit_card : Icons.qr_code,
                            color: displayMethod.type == 'Card' ? Colors.blue : Colors.green,
                          ),
                          title: Text(displayMethod.title),
                          subtitle: Text(displayMethod.subtitle),
                          trailing: TextButton(
                            onPressed: () async {
                              await context.push('/payment-methods');
                              ref.invalidate(paymentProvider);
                            },
                            child: const Text('Change'),
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => ListTile(title: Text('Error: $e')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('₹${totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee'),
                      Text('₹${deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${finalTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (selectedAddress == null) || 
                                 (_selectedPaymentMethod == null) ||
                                 cartItems.isEmpty
                          ? null
                          : () async {
                              if (selectedAddress == null || _selectedPaymentMethod == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select address and payment method')),
                                );
                                return;
                              }
                              setState(() => _isProcessing = true);
                              try {
                                // Assume all items are from the same restaurant for now, or take the first one
                                // In a real app, we'd handle multi-restaurant orders differently
                                final restaurantId = cartItems.first.menuItem.restaurantId;
                                
                                final items = cartItems.map((item) => {
                                  'menuItemId': item.menuItem.id,
                                  'quantity': item.quantity,
                                  'price': item.menuItem.price,
                                }).toList();

                                await ref.read(orderProvider.notifier).createOrder(
                                  restaurantId: restaurantId,
                                  addressId: selectedAddress.id!,
                                  totalAmount: finalTotal,
                                  items: items,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order placed successfully!')),
                                  );
                                  ref.read(cartProvider.notifier).clearCart();

                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error placing order: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isProcessing = false);
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
