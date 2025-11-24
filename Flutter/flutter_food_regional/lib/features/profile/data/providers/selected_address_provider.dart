import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';

class SelectedAddressNotifier extends Notifier<Address?> {
  @override
  Address? build() {
    return null;
  }

  void selectAddress(Address address) {
    state = address;
  }

  void clearAddress() {
    state = null;
  }
}

final selectedAddressProvider = NotifierProvider<SelectedAddressNotifier, Address?>(SelectedAddressNotifier.new);
