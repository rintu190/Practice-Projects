import 'package:flutter/material.dart';
import 'package:flutter_freelance_job_portal/screens/splash_screen.dart';
import 'package:flutter_freelance_job_portal/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelance Job Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Starts with device theme
      home: const SplashScreen(),
    );
  }
}
