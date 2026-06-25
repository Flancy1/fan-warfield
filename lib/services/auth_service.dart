import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps all Supabase authentication operations in a clean API.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  // ── Getters ─────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Session? get currentSession => _auth.currentSession;

  /// Emits whenever the auth state changes (login, logout, token refresh…).
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ── Email sign-up ───────────────────────────────────────────────────
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  // ── Email sign-in ───────────────────────────────────────────────────
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final response = await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  // ── Google OAuth ────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    final success = await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.fanwarfield://login-callback/',
    );
    return success;
  }

  // ── Anonymous sign-in (guest) ───────────────────────────────────────
  Future<AuthResponse> signInAnonymously() async {
    final response = await _auth.signInAnonymously();
    return response;
  }

  // ── Sign out ────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
