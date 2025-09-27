import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final _client = SupabaseService.instance.client;

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'employee',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null && response.session != null) {
        // User profile will be created automatically by database trigger
      }

      return response;
    } catch (error) {
      throw Exception('Failed to sign up: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Failed to sign in: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Failed to sign out: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Failed to reset password: $error');
    }
  }

  // Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to update password: $error');
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? role,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (role != null) updateData['role'] = role;

      if (updateData.isNotEmpty) {
        final response = await _client.auth.updateUser(
          UserAttributes(data: updateData),
        );

        // Also update the user_profiles table
        await _client.from('user_profiles').update({
          if (fullName != null) 'full_name': fullName,
          if (role != null) 'role': role,
        }).eq('id', currentUser!.id);

        return response;
      }

      throw Exception('No data provided to update');
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if current user is manager or admin
  Future<bool> isManagerOrAdmin() async {
    try {
      if (!isAuthenticated) return false;

      final profile = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .single();

      final role = profile['role'] as String;
      return role == 'manager' || role == 'admin';
    } catch (error) {
      return false;
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      if (!isAuthenticated) return 'employee';

      final profile = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .single();

      return profile['role'] as String;
    } catch (error) {
      return 'employee';
    }
  }

  // Validate session and refresh if needed
  Future<bool> validateSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return false;

      // Check if session is expired
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      if (session.expiresAt != null && session.expiresAt! < now) {
        // Try to refresh the session
        final response = await _client.auth.refreshSession();
        return response.session != null;
      }

      return true;
    } catch (error) {
      return false;
    }
  }
}
