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
  final String type; // result, exam, notes, alert

  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'time': time, 'isNew': isNew, 'type': type,
  };

  factory NotifItem.fromJson(Map<String, dynamic> j) => NotifItem(
    id:    j['id'] ?? '',
    title: j['title'] ?? '',
    body:  j['body'] ?? '',
    time:  j['time'] ?? '',
    isNew: j['isNew'] ?? false,
    type:  j['type'] ?? 'alert',
  );

  IconData get icon {
    switch (type) {
      case 'result':  return Icons.emoji_events_outlined;
      case 'exam':    return Icons.calendar_month_outlined;
      case 'notes':   return Icons.book_outlined;
      case 'arrear':  return Icons.warning_amber_rounded;
      default:        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'result':  return const Color(0xFF16A34A);
      case 'exam':    return const Color(0xFF2563EB);
      case 'notes':   return const Color(0xFFD97706);
      case 'arrear':  return const Color(0xFFDC2626);
      default:        return const Color(0xFF7C3AED);
    }
  }
}

// ── Background message handler (top-level required) ───────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._showLocal(message);
}

class NotificationService {
  static final _messaging         = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _prefKey           = 'notifications_enabled';
  static const _storedNotifsKey   = 'stored_notifications';
  static const _channelId         = 'au_notifications';
  static const _channelName       = 'AU Result Alerts';
  static const _baseUrl           = 'https://eduhub-tau-rosy.vercel.app';

  // ── Initialize ──────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    // Android notification channel WITH custom sound
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description:    'Anna University result and exam alerts',
      importance:     Importance.high,
      // Custom sound — file must be at android/app/src/main/res/raw/au_alert.mp3
      sound:          RawResourceAndroidNotificationSound('au_alert'),
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Init local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification clicked");
      },

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Opened from background");
      });
      
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      
      if (initialMessage != null) {
        print("Opened from terminated");
      }
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((message) async {
      final enabled = await isEnabled();
      if (!enabled) return;
      await _showLocal(message);
      await _storeNotification(message);
    });

    // Check saved pref and subscribe/unsubscribe accordingly
    final enabled = await isEnabled();
    if (enabled) {
      await _subscribe();
    }
  }

  // ── Permission request ──────────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // ── Enable notifications ────────────────────────────────────────────────────
  static Future<void> enable() async {
    final granted = await requestPermission();
    if (!granted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    await _subscribe();
  }

  // ── Disable notifications ───────────────────────────────────────────────────
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
    await _unsubscribe();
  }

  // ── Check if enabled ────────────────────────────────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  // ── Subscribe to FCM topic ──────────────────────────────────────────────────
  static Future<void> _subscribe() async {
    await _messaging.subscribeToTopic('au_alerts');
    await _registerToken();
  }

  // ── Unsubscribe from FCM topic ──────────────────────────────────────────────
  static Future<void> _unsubscribe() async {
    await _messaging.unsubscribeFromTopic('au_alerts');
  }

  // ── Register token with backend ─────────────────────────────────────────────
  static Future<void> _registerToken() async {
    try {
      final token     = await _messaging.getToken();
      if (token == null) return;

      final prefs     = await SharedPreferences.getInstance();
      final email     = prefs.getString('user_email') ?? '';
      final savedToken = prefs.getString('fcm_token');
      if (token == savedToken) return;

      await http.put(
        Uri.parse('$_baseUrl/api/au-alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endpoint':  token,
          'userEmail': email,
          'keys': {'p256dh': token, 'auth': token},
        }),
      );

      await prefs.setString('fcm_token', token);
    } catch (_) {}
  }

  // ── Show local notification with custom sound ───────────────────────────────
  static Future<void> _showLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? 'alert';

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'AU Alert',
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Anna University alerts',
          importance:         Importance.high,
          priority:           Priority.high,
          icon:               '@mipmap/ic_launcher',
          // Custom sound
          sound:              const RawResourceAndroidNotificationSound('au_alert'),
          enableVibration:    true,
          color:              const Color(0xFF2563EB),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert:  true,
          presentBadge:  true,
          presentSound:  true,
          // Custom sound — file must be at ios/Runner/au_alert.aiff
          sound:         'au_alert.aiff',
        ),
      ),
    );
  }

  // ── Store notification locally ──────────────────────────────────────────────
  static Future<void> _storeNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final prefs    = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storedNotifsKey) ?? [];

    final item = NotifItem(
      id:    DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'AU Alert',
      body:  notification.body  ?? '',
      time:  _formatTime(DateTime.now()),
      isNew: true,
      type:  message.data['type'] ?? 'alert',
    );

    existing.insert(0, jsonEncode(item.toJson()));

    // Keep only last 50 notifications
    if (existing.length > 50) existing.removeRange(50, existing.length);

    await prefs.setStringList(_storedNotifsKey, existing);
  }

  // ── Load stored notifications ───────────────────────────────────────────────
  static Future<List<NotifItem>> loadNotifications() async {
    final prefs    = await SharedPreferences.getInstance();
    final stored   = prefs.getStringList(_storedNotifsKey) ?? [];
    return stored.map((s) => NotifItem.fromJson(jsonDecode(s))).toList();
  }

  // ── Mark all as read ────────────────────────────────────────────────────────
  static Future<void> markAllRead() async {
    final prefs   = await SharedPreferences.getInstance();
    final stored  = prefs.getStringList(_storedNotifsKey) ?? [];
    final updated = stored.map((s) {
      final map    = jsonDecode(s) as Map<String, dynamic>;
      map['isNew'] = false;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_storedNotifsKey, updated);
  }

  // ── Format time ────────────────────────────────────────────────────────────
  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
