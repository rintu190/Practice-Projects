import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier extends Notifier<bool> {
  final _googleSignIn = GoogleSignIn();

  @override
  bool build() {
    return false; // Default to not logged in
  }

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    state = true;
  }

  Future<void> signUp(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    state = true;
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        state = true;
      }
    } catch (error) {
      // Handle error
      debugPrint('Google Sign In Error: $error');
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    state = false;
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
