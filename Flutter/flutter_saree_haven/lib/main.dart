import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'features/cart/cart_service.dart';
import 'features/navigation/main_navigation.dart';

import 'features/auth/auth_service.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const SareeHavenApp(),
    ),
  );
}

class SareeHavenApp extends StatelessWidget {
  const SareeHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saree Haven',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isAuthenticated 
              ? const MainNavigation() 
              : const LoginScreen();
        },
      ),
    );
  }
}
