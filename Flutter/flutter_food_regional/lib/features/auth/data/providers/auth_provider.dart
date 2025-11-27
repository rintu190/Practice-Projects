import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';
import '../../../../core/exceptions/api_exception.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final _googleSignIn = GoogleSignIn();
  final _authService = AuthService();

  @override
  AuthState build() {
    _checkAuthStatus();
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        isAuthenticated: user != null,
        user: user,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      final user = User.fromJson(response['user']);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password, {String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      
      final user = User.fromJson(response['user']);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> updateProfile(String name, String phone, {double? latitude, double? longitude}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.updateProfile(
        name: name,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> uploadProfilePicture(File file) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.uploadProfilePicture(file);
      
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to upload profile picture',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User canceled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // Get the authentication details
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      debugPrint('Google Sign-In: Got ID token, sending to backend...');

      // Send to backend
      final response = await _authService.googleSignIn(idToken);
      
      debugPrint('Google Sign-In: Backend response received');
      
      final user = User.fromJson(response['user']);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
    } on ApiException catch (e) {
      await _googleSignIn.signOut();
      debugPrint('Google Sign-In API Error: ${e.message} (Status: ${e.statusCode})');
      state = state.copyWith(
        isLoading: false,
        error: 'Sign-in failed: ${e.message}',
      );
    } catch (error) {
      await _googleSignIn.signOut();
      debugPrint('Google Sign-In Error: $error');
      
      // Development mode: If Google Sign-In fails, offer to use email/password instead
      state = state.copyWith(
        isLoading: false,
        error: 'Google Sign-In requires setup. Please use email/password login or configure Google Cloud Console.',
      );
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
