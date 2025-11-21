import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/address.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final List<Address> _addresses = [];

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
        return AlertDialog(
          title: const Text('Add Address'),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: houseController,
                    decoration: const InputDecoration(labelText: 'House/Flat No.'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Street / Road'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: localityController,
                    decoration: const InputDecoration(labelText: 'Locality / Area'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: landmarkController,
                    decoration: const InputDecoration(labelText: 'Landmark (optional)'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (houseController.text.isNotEmpty &&
                    streetController.text.isNotEmpty &&
                    cityController.text.isNotEmpty &&
                    stateController.text.isNotEmpty &&
                    pincodeController.text.isNotEmpty) {
                  final newAddress = Address(
                    houseNumber: houseController.text,
                    street: streetController.text,
                    locality: localityController.text,
                    city: cityController.text,
                    state: stateController.text,
                    pincode: pincodeController.text,
                    landmark: landmarkController.text.isNotEmpty ? landmarkController.text : null,
                  );
                  setState(() {
                    _addresses.add(newAddress);
                  });
                  context.pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final addr = _addresses[index];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(addr.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _addresses.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
