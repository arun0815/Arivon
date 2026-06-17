import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  String _cacheSize = 'Calculating...';
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
    _calculateCacheSize();
  }

  // ── Load real notification state from NotificationService ─────────────────
  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationService.isEnabled();
    setState(() => _notificationsEnabled = enabled);
  }

  // ── Toggle: enable/disable real FCM push notifications ───────────────────
  Future<void> _toggleNotification(bool value) async {
    setState(() => _notificationsEnabled = value);

    if (value) {
      await NotificationService.enable();
      // Verify permission was actually granted
      final enabled = await NotificationService.isEnabled();
      if (!enabled && mounted) {
        setState(() => _notificationsEnabled = false);
        _showSnack(
          'Please allow notifications in device settings',
          isSuccess: false,
          isWarning: true,
        );
      } else if (mounted) {
        _showSnack('Notifications enabled', isSuccess: true);
      }
    } else {
      await NotificationService.disable();
      if (mounted) _showSnack('Notifications disabled');
    }
  }

  Future<void> _calculateCacheSize() async {
    try {
      final dir = await getTemporaryDirectory();
      int totalBytes = 0;
      if (dir.existsSync()) {
        dir.listSync(recursive: true).forEach((e) {
          if (e is File) totalBytes += e.lengthSync();
        });
      }
      setState(() => _cacheSize = _formatBytes(totalBytes));
    } catch (_) {
      setState(() => _cacheSize = '0 KB');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024)    return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  Future<void> _clearCache() async {
    setState(() => _isClearing = true);
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) {
        dir.listSync().forEach((e) {
          try { e.deleteSync(recursive: true); } catch (_) {}
        });
      }
      await _calculateCacheSize();
      if (mounted) _showSnack('Cache cleared successfully', isSuccess: true);
    } catch (_) {
      if (mounted) _showSnack('Failed to clear cache');
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  void _showSnack(String msg,
      {bool isSuccess = false, bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isWarning
            ? AppColors.amber
            : isSuccess
                ? AppColors.success
                : AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAboutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimarySoft
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Arivon',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AboutRow('Version',   '1.0.0',          isDark),
            _AboutRow('Build',     '2025.01',         isDark),
            _AboutRow('Developer', 'Arivon Team',     isDark),
            _AboutRow('Contact',   'support@arivon.app', isDark),
            const SizedBox(height: 12),
            Text(
              'Smart Academic Companion.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSec
                    : AppColors.textSec,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final provider  = context.watch<ThemeProvider>();
    final bgColor   = isDark ? AppColors.darkBg      : AppColors.bg;
    final cardColor = isDark ? AppColors.darkSurface  : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark ? AppColors.darkText     : AppColors.text;
    final subColor  = isDark ? AppColors.darkTextSec  : AppColors.textSec;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── APPEARANCE ───────────────────────────────────────────────
          _SectionLabel('Appearance', isDark),
          _Card(
            color: cardColor,
            border: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TileHeader(
                  icon: Icons.brightness_6_rounded,
                  iconBg: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.primarySoft,
                  iconColor: AppColors.primary,
                  title: 'Theme',
                  subtitle: 'Auto, Light or Dark',
                  textColor: textColor,
                  subColor: subColor,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ThemeChip(
                      label: 'Auto',
                      icon: Icons.brightness_auto_rounded,
                      selected: provider.mode == AppThemeMode.auto,
                      onTap: () => provider.setMode(AppThemeMode.auto),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _ThemeChip(
                      label: 'Light',
                      icon: Icons.wb_sunny_rounded,
                      selected: provider.mode == AppThemeMode.light,
                      onTap: () => provider.setMode(AppThemeMode.light),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _ThemeChip(
                      label: 'Dark',
                      icon: Icons.nights_stay_rounded,
                      selected: provider.mode == AppThemeMode.dark,
                      onTap: () => provider.setMode(AppThemeMode.dark),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── NOTIFICATIONS ────────────────────────────────────────────
          _SectionLabel('Notifications', isDark),
          _Card(
            color: cardColor,
            border: borderColor,
            child: Column(
              children: [
                Row(
                  children: [
                    _TileHeader(
                      icon: Icons.notifications_outlined,
                      iconBg: isDark
                          ? AppColors.darkAmberSoft
                          : AppColors.amberSoft,
                      iconColor: AppColors.amber,
                      title: 'Push Notifications',
                      subtitle: _notificationsEnabled
                          ? 'AU result alerts enabled'
                          : 'Tap to enable alerts',
                      textColor: textColor,
                      subColor: subColor,
                      expanded: true,
                    ),
                    Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotification,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),

                // Info hint shown when enabled
                if (_notificationsEnabled) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimarySoft
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will receive notifications when Anna University publishes results.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── STORAGE ──────────────────────────────────────────────────
          _SectionLabel('Storage', isDark),
          _Card(
            color: cardColor,
            border: borderColor,
            child: GestureDetector(
              onTap: _isClearing ? null : _clearCache,
              child: Row(
                children: [
                  _TileHeader(
                    icon: Icons.cleaning_services_rounded,
                    iconBg: isDark
                        ? AppColors.darkSuccessSoft
                        : AppColors.successSoft,
                    iconColor: AppColors.success,
                    title: 'Clear Cache',
                    subtitle: _cacheSize,
                    textColor: textColor,
                    subColor: subColor,
                    expanded: true,
                  ),
                  _isClearing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary),
                        )
                      : Icon(Icons.chevron_right_rounded,
                          color: subColor, size: 22),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── ABOUT ────────────────────────────────────────────────────
          _SectionLabel('About', isDark),
          _Card(
            color: cardColor,
            border: borderColor,
            child: GestureDetector(
              onTap: _showAboutDialog,
              child: Row(
                children: [
                  _TileHeader(
                    icon: Icons.info_outline_rounded,
                    iconBg: isDark
                        ? AppColors.darkIndigoSoft
                        : AppColors.indigoSoft,
                    iconColor: AppColors.indigo,
                    title: 'About Arivon',
                    subtitle: 'Version, developer info',
                    textColor: textColor,
                    subColor: subColor,
                    expanded: true,
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: subColor, size: 22),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel(this.label, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: isDark ? AppColors.darkTextSec : AppColors.textSec,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color border;
  const _Card(
      {required this.child, required this.color, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subColor;
  final bool expanded;

  const _TileHeader({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
    this.expanded = false,
  });

  Widget _content() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: subColor)),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) =>
      expanded ? Expanded(child: _content()) : _content();
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final unselBg     = isDark ? AppColors.darkCard    : AppColors.bg;
    final unselBorder = isDark ? AppColors.darkBorder  : AppColors.border;
    final unselText   = isDark ? AppColors.darkTextSec : AppColors.textSec;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : unselBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : unselBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : unselText),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color:
                          selected ? Colors.white : unselText)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _AboutRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label  ',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSec
                      : AppColors.textSec)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.text)),
        ],
      ),
    );
  }
}
