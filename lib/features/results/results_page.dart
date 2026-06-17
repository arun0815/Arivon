import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import 'result_codes_page.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _ResultStatus {
  static const String examSession = 'Apr / May 2026';

  static const List<Map<String, dynamic>> ugResults = [
    {'label': 'Final Year – Project Work', 'status': 'Published', 'live': true},
    {'label': 'All Other Semesters', 'status': 'Awaited', 'live': false},
  ];

  static const List<Map<String, dynamic>> pgResults = [
    {'label': 'All Semesters', 'status': 'Not Published', 'live': false},
  ];

  static const bool anyLive = true;
  static const String announcementText =
      'UG Final Year (Project) results for Apr/May 2026 are now live. '
      'Tap a portal below to check your result.';
}

// ─── URL launcher helper ──────────────────────────────────────────────────────
Future<void> _openInAppBrowser(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the portal. Try again.')),
      );
    }
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor    = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor  = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white           : const Color(0xFF0F172A);
    final textSec    = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semester Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          )),
                      Text('Anna University – Official Portal',
                          style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Hero Status Card ──────────────────────────────────────────
              _HeroStatusCard(isDark: isDark),

              const SizedBox(height: 16),

              // ── Announcement Banner ───────────────────────────────────────
              if (_ResultStatus.anyLive)
                _AnnouncementBanner(text: _ResultStatus.announcementText),

              if (_ResultStatus.anyLive) const SizedBox(height: 16),

              // ── Portal Buttons ────────────────────────────────────────────
              _PortalButton(
                label: 'Result Portal  I',
                subtitle: 'Primary server – try this first',
                isPrimary: true,
                onTap: () => _openInAppBrowser(
                    context, 'https://coe.annauniv.edu'),
              ),

              const SizedBox(height: 10),

              _PortalButton(
                label: 'Result Portal  II',
                subtitle: 'Use if Portal I is slow or down',
                isPrimary: false,
                isDark: isDark,
                onTap: () => _openInAppBrowser(
                    context, 'https://aucoe.annauniv.edu'),
              ),

              const SizedBox(height: 16),

              // ── WH Codes Card ─────────────────────────────────────────────
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultCodesPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WH Codes & Result Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                )),
                            const SizedBox(height: 2),
                            Text('Understand what WH, RA, SA mean',
                                style: TextStyle(
                                    fontSize: 12, color: textSec)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: textSec),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Share Button ──────────────────────────────────────────────
              GestureDetector(
                onTap: () => Share.share(
                  '🎓 Arivon App – Check Anna University Results\n\n'
                  '${_ResultStatus.examSession} results are out!\n\n'
                  'Use Arivon to check results and calculate your GPA/CGPA.\n\n'
                  '🌐 Official Portal: https://coe.annauniv.edu',
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_rounded,
                          size: 16,
                          color: textSec),
                      const SizedBox(width: 8),
                      Text('Share with classmates',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSec,
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Disclaimer ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Arivon does not host or manage Anna University result servers. '
                        'We redirect you to the official portal. '
                        'Slow loading is due to high traffic on Anna University servers — please try again later.',
                        style: TextStyle(
                            fontSize: 12, color: textSec, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Status Card ─────────────────────────────────────────────────────────
class _HeroStatusCard extends StatelessWidget {
  final bool isDark;
  const _HeroStatusCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white            : const Color(0xFF0F172A);
    final textSec     = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session label strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(isDark ? 0.15 : 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: Color(0xFF2563EB)),
                const SizedBox(width: 7),
                Text(
                  _ResultStatus.examSession,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Text('Examinations',
                    style: TextStyle(fontSize: 11, color: textSec)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
            child: Text('UG Results',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textSec,
                  letterSpacing: 0.8,
                )),
          ),

          ..._ResultStatus.ugResults.map((r) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                child: _StatusRow(
                  label: r['label'],
                  status: r['status'],
                  isLive: r['live'],
                  isDark: isDark,
                ),
              )),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(color: dividerColor),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
            child: Text('PG Results',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textSec,
                  letterSpacing: 0.8,
                )),
          ),

          ..._ResultStatus.pgResults.map((r) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                child: _StatusRow(
                  label: r['label'],
                  status: r['status'],
                  isLive: r['live'],
                  isDark: isDark,
                ),
              )),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ─── Status Row ───────────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final bool isLive;
  final bool isDark;

  const _StatusRow({
    required this.label,
    required this.status,
    required this.isLive,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    Color chipBg;
    Color chipText;

    switch (status) {
      case 'Published':
        chipBg   = const Color(0xFF16A34A).withOpacity(0.12);
        chipText = const Color(0xFF16A34A);
        break;
      case 'Awaited':
        chipBg   = const Color(0xFFD97706).withOpacity(0.12);
        chipText = const Color(0xFFD97706);
        break;
      default:
        chipBg   = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);
        chipText = isDark
            ? const Color(0xFF64748B)
            : const Color(0xFF94A3B8);
    }

    return Row(
      children: [
        if (isLive)
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF4ADE80),
                shape: BoxShape.circle,
              ),
            ),
          )
        else
          const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              )),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: chipText,
              )),
        ),
      ],
    );
  }
}

// ─── Announcement Banner ──────────────────────────────────────────────────────
class _AnnouncementBanner extends StatelessWidget {
  final String text;
  const _AnnouncementBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎓 Results Published',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
                const SizedBox(height: 4),
                Text(text,
                    style: const TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 12,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Portal Button ────────────────────────────────────────────────────────────
class _PortalButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _PortalButton({
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Material(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                            color: Color(0xFFBFDBFE),
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.open_in_browser_rounded,
                      color: Colors.white, size: 17),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Secondary
    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.open_in_browser_rounded,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    size: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
