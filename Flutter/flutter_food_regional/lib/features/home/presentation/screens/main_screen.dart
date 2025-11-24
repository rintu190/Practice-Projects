import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';
import '../../../rider/presentation/screens/rider_home_screen.dart';
import '../../../restaurant/presentation/screens/restaurant_home_screen.dart';
import 'home_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Future<String?> _getUserRole() async {
    final userData = await StorageService.getUserData();
    return userData['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        switch (role) {
          case 'admin':
            return const AdminHomeScreen();
          case 'rider':
            return const RiderHomeScreen();
          case 'restaurant':
            return const RestaurantHomeScreen();
          case 'customer':
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
