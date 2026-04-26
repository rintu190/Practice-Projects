import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Placeholder for Logo/Illustration
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_up_rounded, size: 80, color: AppTheme.accentPurple),
                ),
              ),
              const SizedBox(height: 60),
              
              const Text(
                'Predict & Earn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Trade on the world\'s most highly-debated topics. Real news, real returns.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: AppTheme.accentPurple.withOpacity(0.4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Get Started', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
