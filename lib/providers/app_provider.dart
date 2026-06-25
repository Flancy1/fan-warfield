import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

/// Global app state managed via ChangeNotifier (Provider pattern).
class AppProvider extends ChangeNotifier {
  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  /// Loads the profile for the given user ID from Supabase.
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final data = await SupabaseService.instance.getProfile(userId);
    if (data != null) {
      _profile = ProfileModel.fromJson(data);
    } else {
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sets the profile after creation (avoids a second fetch).
  void setProfile(ProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Clears profile on sign-out.
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
