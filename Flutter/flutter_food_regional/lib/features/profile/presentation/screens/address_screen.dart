import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/address.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/providers/address_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  
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
        bool isDefault = false;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
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
                      const SizedBox(height: 8),
                      // GPS location display & pin button
                      if (_latitude != null && _longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF6C63FF), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  dialogSetState(() {
                                    _latitude = null;
                                    _longitude = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isGettingLocation ? null : () => _getCurrentLocation(dialogSetState: dialogSetState),
                          icon: _isGettingLocation
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location),
                          label: Text(_isGettingLocation ? 'Getting Location...' : 'Pin Current Location'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Set as default address'),
                        value: isDefault,
                        onChanged: (value) {
                          dialogSetState(() => isDefault = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
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
                            dialogSetState(() => isLoading = true);
                            final newAddress = Address(
                              houseNumber: houseController.text,
                              street: streetController.text,
                              locality: localityController.text,
                              city: cityController.text,
                              state: stateController.text,
                              pincode: pincodeController.text,
                              landmark: landmarkController.text.isNotEmpty ? landmarkController.text : null,
                              latitude: _latitude,
                              longitude: _longitude,
                              isDefault: isDefault,
                            );
                            try {
                              await ref.read(addressProvider.notifier).addAddress(newAddress);
                              if (context.mounted) context.pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                dialogSetState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) {
        final houseController = TextEditingController(text: address.houseNumber);
        final streetController = TextEditingController(text: address.street);
        final localityController = TextEditingController(text: address.locality);
        final cityController = TextEditingController(text: address.city);
        final stateController = TextEditingController(text: address.state);
        final pincodeController = TextEditingController(text: address.pincode);
        final landmarkController = TextEditingController(text: address.landmark ?? '');
        bool isLoading = false;
        bool isDefault = address.isDefault;
        double? editLatitude = address.latitude;
        double? editLongitude = address.longitude;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Edit Address'),
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
                        decoration: const InputDecoration(labelText: 'Pincode'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: landmarkController,
                        decoration: const InputDecoration(labelText: 'Landmark (Optional)'),
                      ),
                      const SizedBox(height: 16),
                      if (editLatitude != null && editLongitude != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Lat: ${editLatitude!.toStringAsFixed(6)}, Lng: ${editLongitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isGettingLocation
                              ? null
                              : () async {
                                  dialogSetState(() => _isGettingLocation = true);
                                  try {
                                    final position = await Geolocator.getCurrentPosition();
                                    dialogSetState(() {
                                      editLatitude = position.latitude;
                                      editLongitude = position.longitude;
                                      _isGettingLocation = false;
                                    });
                                  } catch (e) {
                                    dialogSetState(() => _isGettingLocation = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                          icon: _isGettingLocation
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location),
                          label: Text(_isGettingLocation ? 'Getting Location...' : 'Update Location'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Set as default address'),
                        value: isDefault,
                        onChanged: (value) {
                          dialogSetState(() => isDefault = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
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
                            dialogSetState(() => isLoading = true);
                            final updatedAddress = Address(
                              id: address.id,
                              houseNumber: houseController.text,
                              street: streetController.text,
                              locality: localityController.text,
                              city: cityController.text,
                              state: stateController.text,
                              pincode: pincodeController.text,
                              landmark: landmarkController.text.isNotEmpty ? landmarkController.text : null,
                              latitude: editLatitude,
                              longitude: editLongitude,
                              isDefault: isDefault,
                            );
                            try {
                              await ref.read(addressProvider.notifier).updateAddress(address.id!, updatedAddress);
                              if (context.mounted) context.pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                dialogSetState(() => isLoading = false);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields')),
                            );
                          }
                        },
                  child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getCurrentLocation({Function(void Function())? dialogSetState}) async {
    if (dialogSetState != null) {
      dialogSetState(() => _isGettingLocation = true);
    } else {
      setState(() => _isGettingLocation = true);
    }
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
        if (dialogSetState != null) {
          dialogSetState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
          });
        } else {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
          });
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    } finally {
      if (mounted) {
        if (dialogSetState != null) {
          dialogSetState(() => _isGettingLocation = false);
        } else {
          setState(() => _isGettingLocation = false);
        }
      }
    }
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    addr.isDefault ? Icons.location_on : Icons.location_on_outlined,
                    color: addr.isDefault ? const Color(0xFF6C63FF) : null,
                  ),
                  title: Text(
                    addr.toString(),
                    style: TextStyle(
                      fontWeight: addr.isDefault ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: addr.isDefault ? const Text('Default', style: TextStyle(color: Color(0xFF6C63FF))) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editAddress(addr),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (addr.id != null) {
                            try {
                              await ref.read(addressProvider.notifier).deleteAddress(addr.id!);
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
                    ],
                  ),
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
