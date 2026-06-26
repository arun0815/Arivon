import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  /// When true, only shows a short list of the most recent notifications
  /// (used when opened from the home page "alert" card) with no
  /// pagination and a "View all" shortcut into the full page.
  /// When false (default), shows the full paginated notification feed
  /// (used when opened from the notification bell icon).
  final bool recentOnly;

  const NotificationsPage({super.key, this.recentOnly = false});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const int _recentLimit = 5;
  static const int _pageLimit = 10;

  final List<NotifItem> _notifications = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _hasError = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _load();
    if (!widget.recentOnly) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await NotificationService.fetchNotifications(
        page: 1,
        limit: widget.recentOnly ? _recentLimit : _pageLimit,
      );
      setState(() {
        _notifications
          ..clear()
          ..addAll(result.items);
        _currentPage = result.page;
        _hasMore = widget.recentOnly ? false : result.hasMore;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await NotificationService.fetchNotifications(
        page: _currentPage + 1,
        limit: _pageLimit,
      );
      setState(() {
        _notifications.addAll(result.items);
        _currentPage = result.page;
        _hasMore = result.hasMore;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllFeedItemsRead(_notifications);
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        _notifications[i] = NotifItem(
          id: n.id, title: n.title, body: n.body, time: n.time,
          isNew: false, type: n.type, link: n.link, timestamp: n.timestamp,
        );
      }
    });
  }

  Future<void> _openDetail(NotifItem item) async {
    if (item.isNew) {
      await NotificationService.markFeedItemRead(item.id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == item.id);
        if (idx != -1) {
          _notifications[idx] = NotifItem(
            id: item.id, title: item.title, body: item.body, time: item.time,
            isNew: false, type: item.type, link: item.link, timestamp: item.timestamp,
          );
        }
      });
    }
    if (!mounted) return;
    _showDetailSheet(item);
  }

  void _showDetailSheet(NotifItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationDetailSheet(item: item, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : AppColors.bg;
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
        title: Text(widget.recentOnly ? 'Recent Notifications' : 'Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.text,
              letterSpacing: -0.4,
            )),
        actions: [
          if (!widget.recentOnly && newNotifs.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : _hasError
              ? _ErrorState(isDark: isDark, onRetry: _load)
              : _notifications.isEmpty
                  ? _EmptyState(isDark: isDark)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _load,
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        children: [
                          if (widget.recentOnly) ...[
                            ..._notifications.map(
                                (n) => _NotifTile(
                                    item: n,
                                    isDark: isDark,
                                    onTap: () => _openDetail(n))),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationsPage()),
                                  );
                                },
                                child: const Text('View all notifications',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary)),
                              ),
                            ),
                          ] else ...[
                            if (newNotifs.isNotEmpty) ...[
                              _SectionLabel('NEW', isDark),
                              const SizedBox(height: 8),
                              ...newNotifs.map((n) => _NotifTile(
                                  item: n,
                                  isDark: isDark,
                                  onTap: () => _openDetail(n))),
                              const SizedBox(height: 16),
                            ],
                            if (oldNotifs.isNotEmpty) ...[
                              _SectionLabel('EARLIER', isDark),
                              const SizedBox(height: 8),
                              ...oldNotifs.map((n) => _NotifTile(
                                  item: n,
                                  isDark: isDark,
                                  onTap: () => _openDetail(n))),
                            ],
                            if (_isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2),
                                ),
                              ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
    );
  }
}

// ── Detail bottom sheet ──────────────────────────────────────────────────
class _NotificationDetailSheet extends StatelessWidget {
  final NotifItem item;
  final bool isDark;
  const _NotificationDetailSheet({required this.item, required this.isDark});

  Future<void> _openLink(BuildContext context) async {
    final url = item.link;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  void _share() {
    final buffer = StringBuffer()
      ..writeln(item.title)
      ..writeln()
      ..writeln(item.body);
    if (item.link != null) {
      buffer
        ..writeln()
        ..writeln(item.link);
    }
    Share.share(buffer.toString(), subject: item.title);
  }

  @override
  Widget build(BuildContext context) {
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.text;
    final secColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSec;
    final tertColor = isDark ? const Color(0xFF64748B) : AppColors.textTert;

    final fullDate = item.timestamp != null
        ? DateFormat('EEEE, d MMM yyyy • h:mm a').format(item.timestamp!)
        : item.time;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: tertColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.3,
                          )),
                      const SizedBox(height: 5),
                      Text(fullDate,
                          style: TextStyle(fontSize: 12, color: tertColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(item.body,
                style: TextStyle(fontSize: 14, color: secColor, height: 1.6)),
            if (item.link != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openLink(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────
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
            width: 72,
            height: 72,
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.text,
              )),
          const SizedBox(height: 6),
          Text('AU result alerts will appear here',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSec,
              )),
        ],
      ),
    );
  }
}

// ── Error state ─────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: isDark ? const Color(0xFF64748B) : AppColors.textTert,
              size: 40),
          const SizedBox(height: 12),
          Text('Could not load notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.text,
              )),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: isDark ? const Color(0xFF64748B) : AppColors.textTert,
        ));
  }
}

// ── Notification tile ────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final NotifItem item;
  final bool isDark;
  final VoidCallback onTap;
  const _NotifTile(
      {required this.item, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
            color:
                item.isNew ? AppColors.primary.withOpacity(0.2) : border,
            width: item.isNew ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.text,
                            )),
                      ),
                      if (item.isNew)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSec,
                        height: 1.5,
                      )),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(item.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : AppColors.textTert,
                          )),
                      if (item.link != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.link_rounded,
                            size: 12,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : AppColors.textTert),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
