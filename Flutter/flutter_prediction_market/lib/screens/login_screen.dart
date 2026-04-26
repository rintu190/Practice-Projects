import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('Welcome Back', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1, color: AppTheme.textColor)),
              const SizedBox(height: 8),
              const Text('Enter your details to pick up right where you left off.', style: TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.5)),
              const SizedBox(height: 48),
              
              const Text('Mobile Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textColor)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: '+91 0000 0000',
                    hintStyle: const TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.phone_android, color: AppTheme.accentPurple),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppTheme.accentPurple.withOpacity(0.4),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  child: const Text('Send OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 32),
              const Center(child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold))),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, color: AppTheme.textColor, size: 32),
                  label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
