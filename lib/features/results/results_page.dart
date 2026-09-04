import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import 'result_codes_page.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _ResultStatus {
  static const String examSession = 'Apr / May 2026';

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

    final bgColor     = isDark ? const Color(0xFF0B1220) : const Color(0xFFF1F5F9);
    final cardColor    = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary  = isDark ? Colors.white            : const Color(0xFF0F172A);
    final textSec      = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor  = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
                        border: Border.all(color: borderColor),
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
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 11, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            '${_ResultStatus.examSession} · Anna University',
                            style: TextStyle(fontSize: 12, color: textSec),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── Portal Section Label ──────────────────────────────────────
              Text('CHECK YOUR RESULT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textSec,
                    letterSpacing: 1.0,
                  )),

              const SizedBox(height: 10),

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

              const SizedBox(height: 22),

              // ── WH Codes Card ─────────────────────────────────────────────
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResultCodesPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
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
              ),

              const SizedBox(height: 12),

              // ── Share Button ──────────────────────────────────────────────
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, size: 16, color: textSec),
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
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
