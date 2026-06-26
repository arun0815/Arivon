import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotifItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await NotificationService.loadNotifications();
    setState(() {
      _notifications = items;
      _isLoading     = false;
    });
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllRead();
    setState(() {
      _notifications = _notifications
          .map((n) => NotifItem(
                id:    n.id,
                title: n.title,
                body:  n.body,
                time:  n.time,
                isNew: false,
                type:  n.type,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? const Color(0xFF0F172A) : AppColors.bg;
    final newNotifs = _notifications.where((n) => n.isNew).toList();
    final oldNotifs = _notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications',
          style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.text,
            letterSpacing: -0.4,
          )),
        actions: [
          if (newNotifs.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2))
          : _notifications.isEmpty
              ? _EmptyState(isDark: isDark)
              : ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  children: [
                    if (newNotifs.isNotEmpty) ...[
                      _SectionLabel('NEW', isDark),
                      const SizedBox(height: 8),
                      ...newNotifs.map((n) =>
                          _NotifTile(item: n, isDark: isDark)),
                      const SizedBox(height: 16),
                    ],
                    if (oldNotifs.isNotEmpty) ...[
                      _SectionLabel('EARLIER', isDark),
                      const SizedBox(height: 8),
                      ...oldNotifs.map((n) =>
                          _NotifTile(item: n, isDark: isDark)),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications_off_outlined,
              color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text('No notifications yet',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.text,
            )),
          const SizedBox(height: 6),
          Text('AU result alerts will appear here',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : AppColors.textSec,
            )),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1,
        color: isDark ? const Color(0xFF64748B) : AppColors.textTert,
      ));
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final NotifItem item;
  final bool isDark;
  const _NotifTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isNew
            ? (isDark
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.primarySoft)
            : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isNew
              ? AppColors.primary.withOpacity(0.2)
              : border,
          width: item.isNew ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.text,
                        )),
                    ),
                    if (item.isNew)
                      Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSec,
                    height: 1.5,
                  )),
                const SizedBox(height: 6),
                Text(item.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : AppColors.textTert,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
