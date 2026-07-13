import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Stored notification model ─────────────────────────────────────────────────
class NotifItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isNew;
  final String type; // result, exam, notes, alert, news, general
  final String? link;
  final DateTime? timestamp; // full datetime, when available (API items)

  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.type,
    this.link,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'time': time, 'isNew': isNew, 'type': type,
    'link': link, 'timestamp': timestamp?.toIso8601String(),
  };

  factory NotifItem.fromJson(Map<String, dynamic> j) => NotifItem(
    id:        j['id'] ?? '',
    title:     j['title'] ?? '',
    body:      j['body'] ?? '',
    time:      j['time'] ?? '',
    isNew:     j['isNew'] ?? false,
    type:      j['type'] ?? 'alert',
    link:      j['link'],
    timestamp: j['timestamp'] != null ? DateTime.tryParse(j['timestamp']) : null,
  );

  /// Builds an item from the COE notifier API's notification shape.
  factory NotifItem.fromApi(Map<String, dynamic> j, {required bool isNew}) {
    final ts = DateTime.tryParse(j['timestamp'] as String? ?? '')?.toLocal();
    return NotifItem(
      id:        j['id']?.toString() ?? '',
      title:     (j['title'] as String?)?.trim() ?? 'Notification',
      body:      (j['message'] as String?)?.trim() ?? '',
      time:      ts != null ? _formatTime(ts) : '',
      isNew:     isNew,
      type:      (j['type'] as String?) ?? 'general',
      link:      (j['link'] as String?)?.trim().isNotEmpty == true ? j['link'] as String : null,
      timestamp: ts,
    );
  }

  IconData get icon {
    switch (type) {
      case 'result':  return Icons.emoji_events_outlined;
      case 'exam':    return Icons.calendar_month_outlined;
      case 'notes':   return Icons.book_outlined;
      case 'arrear':  return Icons.warning_amber_rounded;
      case 'news':    return Icons.campaign_outlined;
      default:        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'result':  return const Color(0xFF16A34A);
      case 'exam':    return const Color(0xFF2563EB);
      case 'notes':   return const Color(0xFFD97706);
      case 'arrear':  return const Color(0xFFDC2626);
      case 'news':    return const Color(0xFF2563EB);
      default:        return const Color(0xFF7C3AED);
    }
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// One page of results from the remote notification feed.
class NotificationFetchResult {
  final List<NotifItem> items;
  final bool hasMore;
  final int page;
  NotificationFetchResult({required this.items, required this.hasMore, required this.page});
}

// ── Background message handler (top-level required) ───────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._showLocal(message);
}

class NotificationService {
  /// Global navigator key, used so the app router can navigate (e.g. open
  /// the Notifications page) when a push notification is tapped, even from
  /// the background handler where there's no BuildContext available.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final _messaging         = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _prefKey           = 'notifications_enabled';
  static const _storedNotifsKey   = 'stored_notifications';
  static const _channelId         = 'au_alerts';
  static const _channelName       = 'AU Result Alerts';
  static const _baseUrl           = 'https://myarivon.in';

  // Remote notification feed (shown in the in-app Notifications page)
  static const _feedBaseUrl       = 'https://coe-notifier.vercel.app/api/notifications';
  static const _readIdsKey        = 'au_feed_read_ids';

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
        // Navigate to the notifications route when a push is tapped.
        // Uses go_router's path-based push since the app router has no
        // named routes (see app_router.dart's '/notifications' GoRoute).
        final ctx = navigatorKey.currentContext;
        if (ctx != null) ctx.push('/notifications');
      },
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
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      title:     notification.title ?? 'AU Alert',
      body:      notification.body  ?? '',
      time:      _formatTimeRelative(DateTime.now()),
      isNew:     true,
      type:      message.data['type'] ?? 'alert',
      link:      message.data['link'],
      timestamp: DateTime.now(),
    );

    existing.insert(0, jsonEncode(item.toJson()));

    // Keep only last 50 notifications
    if (existing.length > 50) existing.removeRange(50, existing.length);

    await prefs.setStringList(_storedNotifsKey, existing);
  }

  // ── Load stored (push-triggered) notifications ──────────────────────────────
  static Future<List<NotifItem>> loadNotifications() async {
    final prefs    = await SharedPreferences.getInstance();
    final stored   = prefs.getStringList(_storedNotifsKey) ?? [];
    return stored.map((s) => NotifItem.fromJson(jsonDecode(s))).toList();
  }

  // ── Mark all stored (push-triggered) notifications as read ─────────────────
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
  static String _formatTimeRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ════════════════════════════════════════════════════════════════════════
  // Remote notification feed (powers the Notifications page / alert card).
  // Read status isn't provided by the API, so it's tracked locally by id.
  // ════════════════════════════════════════════════════════════════════════

  static Future<Set<String>> _getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_readIdsKey) ?? const []).toSet();
  }

  static Future<void> _saveReadIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, ids.toList());
  }

  /// Fetches one page of notifications from the COE notifier API.
  /// Use a small [limit] (e.g. 5) for a "recent only" preview.
  static Future<NotificationFetchResult> fetchNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$_feedBaseUrl?page=$page&limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception('Notification API returned an error');
    }

    final readIds = await _getReadIds();
    final rawList = (json['data'] as List<dynamic>? ?? const []);
    final items = rawList
        .map((e) => NotifItem.fromApi(
              e as Map<String, dynamic>,
              isNew: !readIds.contains(e['id']?.toString()),
            ))
        .toList();

    final pagination = json['pagination'] as Map<String, dynamic>? ?? const {};
    final hasMore = pagination['hasMore'] as bool? ?? false;

    return NotificationFetchResult(items: items, hasMore: hasMore, page: page);
  }

  /// Marks one feed notification as read.
  static Future<void> markFeedItemRead(String id) async {
    final ids = await _getReadIds();
    ids.add(id);
    await _saveReadIds(ids);
  }

  /// Marks every given feed notification as read ("Mark all read" button).
  static Future<void> markAllFeedItemsRead(List<NotifItem> notifications) async {
    final ids = await _getReadIds();
    ids.addAll(notifications.map((n) => n.id));
    await _saveReadIds(ids);
  }
}
