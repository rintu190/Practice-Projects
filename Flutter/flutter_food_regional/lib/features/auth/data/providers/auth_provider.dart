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
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // TODO: Implement Google Sign-In backend integration
        // For now, just mark as authenticated
        state = state.copyWith(
          isAuthenticated: true,
          error: 'Google Sign-In not yet integrated with backend',
        );
      }
    } catch (error) {
      debugPrint('Google Sign In Error: $error');
      state = state.copyWith(
        error: 'Google Sign-In failed',
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
