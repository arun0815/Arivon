import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Birthday check — use this anywhere in the app
  bool get isBirthdayToday => _profile?.isBirthdayToday ?? false;

  Future<void> loadProfile() async {
    _error = null;

    final cached = await ProfileService.loadCachedProfile();
    if (cached != null) {
      _profile = cached;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

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

  Future<bool> updateProfile({
    String? name,
    String? institute,
    String? department,
    String? semester,
    String? dateOfBirth, // ✅ added
  }) async {
    if (_profile == null) return false;

    final updated = await ProfileService.updateProfile(
      email:       _profile!.email,
      name:        name,
      institute:   institute,
      department:  department,
      semester:    semester,
      dateOfBirth: dateOfBirth, // ✅ added
    );

    if (updated != null) {
      _profile = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

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
