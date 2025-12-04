import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/providers/auth_provider.dart';
import 'features/dashboard/data/providers/dashboard_provider.dart';
import 'features/admin_web/presentation/screens/admin_web_login_screen.dart';
import 'features/admin_web/presentation/screens/admin_web_dashboard.dart';

void main() {
  runApp(const AdminWebApp());
}

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'MLM Investment - Admin Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Check if user is logged in and is admin
            if (authProvider.isAuthenticated && authProvider.isAdmin) {
              return const AdminWebDashboard();
            }
            return const AdminWebLoginScreen();
          },
        ),
      ),
    );
  }
}
