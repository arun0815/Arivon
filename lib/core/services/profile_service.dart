import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Subscription model ────────────────────────────────────────────────────────
class UserSubscription {
  final String plan;
  final String status;

  const UserSubscription({required this.plan, required this.status});

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan:   json['plan']   ?? 'free',
      status: json['status'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() => {'plan': plan, 'status': status};

  bool get isPremium => plan == 'premium' && status == 'active';

  static const UserSubscription free =
      UserSubscription(plan: 'free', status: 'inactive');
}

// ── UserProfile model ─────────────────────────────────────────────────────────
class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String? profileImg;
  final String? department;
  final String? semester;
  final String? institute;
  final String? dateOfBirth;
  final String? selectedAvatar;
  final UserSubscription subscription;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImg,
    this.department,
    this.semester,
    this.institute,
    this.dateOfBirth,
    this.selectedAvatar,
    UserSubscription? subscription,
  }) : subscription = subscription ?? UserSubscription.free;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId:         json['userId'] ?? '',
      name:           json['name'] ?? '',
      email:          json['email'] ?? '',
      profileImg:     json['profileimg'],
      department:     json['department'],
      semester:       json['semester'],
      institute:      json['institute'],
      dateOfBirth:    json['dateOfBirth'],
      selectedAvatar: json['selectedAvatar'],
      subscription:   json['subscription'] != null
          ? UserSubscription.fromJson(
              json['subscription'] as Map<String, dynamic>)
          : UserSubscription.free,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId':         userId,
    'name':           name,
    'email':          email,
    'profileimg':     profileImg,
    'department':     department,
    'semester':       semester,
    'institute':      institute,
    'dateOfBirth':    dateOfBirth,
    'selectedAvatar': selectedAvatar,
    'subscription':   subscription.toJson(),
  };

  UserProfile copyWith({
    String? name,
    String? profileImg,
    String? department,
    String? semester,
    String? institute,
    String? dateOfBirth,
    String? selectedAvatar,
    UserSubscription? subscription,
  }) {
    return UserProfile(
      userId:         userId,
      name:           name          ?? this.name,
      email:          email,
      profileImg:     profileImg    ?? this.profileImg,
      department:     department    ?? this.department,
      semester:       semester      ?? this.semester,
      institute:      institute     ?? this.institute,
      dateOfBirth:    dateOfBirth   ?? this.dateOfBirth, // ✅ fixed
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      subscription:   subscription  ?? this.subscription,
    );
  }

  String get initial   => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  String get firstName => name.split(' ').first;

  // ✅ Birthday check helper
  bool get isBirthdayToday {
    if (dateOfBirth == null) return false;
    try {
      final dob = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      return dob.day == now.day && dob.month == now.month;
    } catch (_) {
      return false;
    }
  }
}

// ── ProfileService ────────────────────────────────────────────────────────────
class ProfileService {
  static const String _baseUrl  = 'https://myarivon.in/api/profile';
  static const String _cacheKey = 'cached_profile';
  static const String _avatarKey = 'selected_avatar';

  static Future<UserProfile?> loadCachedProfile() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;
      final json = jsonDecode(cached) as Map<String, dynamic>;
      json['selectedAvatar'] = prefs.getString(_avatarKey);
      return UserProfile.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _cacheProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  static Future<void> saveAvatar(String? assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    if (assetPath == null) {
      await prefs.remove(_avatarKey);
    } else {
      await prefs.setString(_avatarKey, assetPath);
    }
  }

  static Future<UserProfile?> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      if (email == null || email.isEmpty) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final profile = UserProfile.fromJson(data['data']);
        final avatar  = prefs.getString(_avatarKey);
        final merged  = profile.copyWith(selectedAvatar: avatar);
        await _cacheProfile(merged);
        return merged;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ dateOfBirth added
  static Future<UserProfile?> updateProfile({
    required String email,
    String? name,
    String? institute,
    String? department,
    String? semester,
    String? dateOfBirth,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl?email=$email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (name != null)        'name': name,
          if (institute != null)   'institute': institute,
          if (department != null)  'department': department,
          if (semester != null)    'semester': semester,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs   = await SharedPreferences.getInstance();
        final avatar  = prefs.getString(_avatarKey);
        final profile = UserProfile.fromJson(data['data'])
            .copyWith(selectedAvatar: avatar);
        await _cacheProfile(profile);
        return profile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
