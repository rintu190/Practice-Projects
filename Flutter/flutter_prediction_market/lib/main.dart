import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const PolymarketCloneApp());
}

class PolymarketCloneApp extends StatelessWidget {
  const PolymarketCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediction Market',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
