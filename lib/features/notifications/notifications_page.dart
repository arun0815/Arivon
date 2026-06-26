import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Stored notification model ─────────────────────────────────────────────────
class NotifItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isNew;
  final String type; // result, arrear, news, general

  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time,
        'isNew': isNew,
        'type': type,
      };

  factory NotifItem.fromJson(Map<String, dynamic> j) => NotifItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        time: j['time'] ?? '',
        isNew: j['isNew'] ?? false,
        type: j['type'] ?? 'general',
      );

  IconData get icon {
    switch (type) {
      case 'result':
        return Icons.emoji_events_outlined;
      case 'arrear':
        return Icons.warning_amber_rounded;
      case 'news':
        return Icons.newspaper_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'result':
        return const Color(0xFF16A34A);
      case 'arrear':
        return const Color(0xFFDC2626);
      case 'news':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF7C3AED);
    }
  }
}

// ── Background handler — must be top-level ────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // When app is terminated/background, Android auto-shows the system
  // notification using the data in the FCM payload.
  // We just store it here for the in-app list.
  await NotificationService._storeNotification(message);
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _prefKey = 'notifications_enabled';
  static const _storedNotifsKey = 'stored_notifications';
  static const _channelId = 'au_notifications';
  static const _channelName = 'AU Result Alerts';
  static const _baseUrl = 'https://eduhub-tau-rosy.vercel.app';

  // ── Global navigator key ──────────────────────────────────────────────────
  // Register this in your MaterialApp.router (see app_router.dart)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ── Initialize ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    // Android notification channel with custom sound
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Anna University result and exam alerts',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('au_alert'),
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Init flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    // ✅ FIXED: initialize() only gets onDidReceiveNotificationResponse.
    // onMessageOpenedApp and getInitialMessage are set up AFTER this call.
    await _localNotifications.initialize(
      initSettings,
      // Case 3: App FOREGROUND — user taps the local notification
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _openNotificationsPage();
      },
    );

    // Register background handler — must be before other FCM setup
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ✅ Case 1: App was TERMINATED — notification tap launched the app
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Delay so navigator is ready after app finishes initializing
        Future.delayed(const Duration(milliseconds: 800), () {
          _openNotificationsPage();
        });
      }
    });

    // ✅ Case 2: App was in BACKGROUND — notification tap brought app to foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _openNotificationsPage();
    });

    // ✅ Case 4: App is FOREGROUND — FCM won't auto-show system notification,
    // so we show a local one manually and store it
    FirebaseMessaging.onMessage.listen((message) async {
      final enabled = await isEnabled();
      if (!enabled) return;
      await _showLocal(message);
      await _storeNotification(message);
    });

    // Subscribe or unsubscribe based on saved preference
    final enabled = await isEnabled();
    if (enabled) await _subscribe();
  }

  // ── Open notifications page via global navigator key ──────────────────────
  // Works regardless of where the app currently is (home, tools, updates, etc.)
  static void _openNotificationsPage() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsPage(),
      ),
    );
  }

  // ── Permission request ────────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // ── Enable ────────────────────────────────────────────────────────────────
  static Future<void> enable() async {
    final granted = await requestPermission();
    if (!granted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    await _subscribe();
  }

  // ── Disable ───────────────────────────────────────────────────────────────
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
    await _unsubscribe();
  }

  // ── Check if enabled ──────────────────────────────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  // ── Subscribe ─────────────────────────────────────────────────────────────
  static Future<void> _subscribe() async {
    await _messaging.subscribeToTopic('au_alerts');
    await _registerToken();
  }

  // ── Unsubscribe ───────────────────────────────────────────────────────────
  static Future<void> _unsubscribe() async {
    await _messaging.unsubscribeFromTopic('au_alerts');
  }

  // ── Register FCM token with backend ──────────────────────────────────────
  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final savedToken = prefs.getString('fcm_token');
      if (token == savedToken) return; // unchanged, skip

      await http.put(
        Uri.parse('$_baseUrl/api/au-alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endpoint': token,
          'userEmail': email,
          'keys': {'p256dh': token, 'auth': token},
        }),
      );

      await prefs.setString('fcm_token', token);
    } catch (_) {}
  }

  // ── Show local notification (foreground) ──────────────────────────────────
  static Future<void> _showLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'AU Alert',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Anna University alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('au_alert'),
          enableVibration: true,
          color: Color(0xFF2563EB),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'au_alert.aiff',
        ),
      ),
    );
  }

  // ── Store notification in SharedPreferences ───────────────────────────────
  static Future<void> _storeNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storedNotifsKey) ?? [];

    final item = NotifItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'AU Alert',
      body: notification.body ?? '',
      time: _formatTime(DateTime.now()),
      isNew: true,
      type: message.data['type'] ?? 'general',
    );

    existing.insert(0, jsonEncode(item.toJson()));

    // Keep only latest 50
    if (existing.length > 50) existing.removeRange(50, existing.length);

    await prefs.setStringList(_storedNotifsKey, existing);
  }

  // ── Load stored notifications ─────────────────────────────────────────────
  static Future<List<NotifItem>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storedNotifsKey) ?? [];
    return stored.map((s) => NotifItem.fromJson(jsonDecode(s))).toList();
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storedNotifsKey) ?? [];
    final updated = stored.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      map['isNew'] = false;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_storedNotifsKey, updated);
  }

  // ── Format relative time ──────────────────────────────────────────────────
  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
