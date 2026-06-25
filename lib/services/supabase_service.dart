import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase data-layer service (profiles, matches, etc.).
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Profiles ────────────────────────────────────────────────────────

  /// Fetches the profile row for [userId]. Returns `null` when no row exists.
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Creates a new profile row.
  Future<void> createProfile({
    required String userId,
    required String username,
    required String country,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'username': username,
      'country': country,
      'points': 0,
      'wins': 0,
      'losses': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Returns `true` when the user already has a row in the profiles table.
  Future<bool> isReturningUser(String userId) async {
    final profile = await getProfile(userId);
    return profile != null;
  }

  /// Updates a specific column in the user's profile.
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _client.from('profiles').update(updates).eq('id', userId);
  }
}
