import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/address.dart';
import '../../data/providers/address_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  void _addAddress() {
    showDialog(
      context: context,
      builder: (context) {
        final houseController = TextEditingController();
        final streetController = TextEditingController();
        final localityController = TextEditingController();
        final cityController = TextEditingController();
        final stateController = TextEditingController();
        final pincodeController = TextEditingController();
        final landmarkController = TextEditingController();
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Address'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: houseController,
                        decoration: const InputDecoration(labelText: 'House/Flat No.'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: streetController,
                        decoration: const InputDecoration(labelText: 'Street / Road'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: localityController,
                        decoration: const InputDecoration(labelText: 'Locality / Area'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: stateController,
                        decoration: const InputDecoration(labelText: 'State'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Pincode'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: landmarkController,
                        decoration: const InputDecoration(labelText: 'Landmark (optional)'),
                      ),
                    ],
                  ),
                ),
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
                          if (houseController.text.isNotEmpty &&
                              streetController.text.isNotEmpty &&
                              cityController.text.isNotEmpty &&
                              stateController.text.isNotEmpty &&
                              pincodeController.text.isNotEmpty) {
                            setState(() => isLoading = true);
                            final newAddress = Address(
                              houseNumber: houseController.text,
                              street: streetController.text,
                              locality: localityController.text,
                              city: cityController.text,
                              state: stateController.text,
                              pincode: pincodeController.text,
                              landmark: landmarkController.text.isNotEmpty
                                  ? landmarkController.text
                                  : null,
                            );

                            try {
                              await ref
                                  .read(addressProvider.notifier)
                                  .addAddress(newAddress);
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
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAddress,
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No addresses found'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(addr.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (addr.id != null) {
                      try {
                        await ref
                            .read(addressProvider.notifier)
                            .deleteAddress(addr.id!);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting address: $e')),
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
                onPressed: () => ref.refresh(addressProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
