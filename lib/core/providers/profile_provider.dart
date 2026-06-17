import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// On app open — load cache instantly, then refresh from API in background
  Future<void> loadProfile() async {
    _error = null;

    // Step 1: Load from cache immediately (no loading spinner)
    final cached = await ProfileService.loadCachedProfile();
    if (cached != null) {
      _profile = cached;
      notifyListeners(); // UI shows instantly
    } else {
      // No cache — show loading
      _isLoading = true;
      notifyListeners();
    }

    // Step 2: Fetch fresh data from API in background
    final fresh = await ProfileService.fetchProfile();
    if (fresh != null) {
      _profile = fresh;
      _error = null;
    } else if (_profile == null) {
      _error = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update profile and refresh
  Future<bool> updateProfile({
    String? name,
    String? institute,
    String? department,
    String? semester,
  }) async {
    if (_profile == null) return false;

    final updated = await ProfileService.updateProfile(
      email:      _profile!.email,
      name:       name,
      institute:  institute,
      department: department,
      semester:   semester,
    );

    if (updated != null) {
      _profile = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Save avatar selection locally and update UI
  Future<void> updateAvatar(String? assetPath) async {
    await ProfileService.saveAvatar(assetPath);
    if (_profile != null) {
      _profile = _profile!.copyWith(selectedAvatar: assetPath);
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
