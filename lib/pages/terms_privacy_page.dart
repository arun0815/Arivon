import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../features/auth/terms_page.dart';
import '../features/auth/privacy_page.dart';

bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;
Color _scaffold(BuildContext ctx) => _isDark(ctx) ? AppColors.darkBg : AppColors.bg;
Color _surface(BuildContext ctx) => _isDark(ctx) ? AppColors.darkCard : AppColors.white;
Color _border(BuildContext ctx) => _isDark(ctx) ? AppColors.darkBorder : AppColors.border;
Color _text(BuildContext ctx) => _isDark(ctx) ? AppColors.darkText : AppColors.text;
Color _textSec(BuildContext ctx) => _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  static final List<_DocItem> _docs = [
  _DocItem(
    icon: Icons.gavel_rounded,
    title: 'Terms & Conditions',
    desc: 'Usage rules, limitations & user responsibilities',
    color: const Color(0xFF6366F1),
    page:  TermsPage(),
  ),
  _DocItem(
    icon: Icons.privacy_tip_rounded,
    title: 'Privacy Policy',
    desc: 'How we collect, store & protect your data',
    color: const Color(0xFF0EA5E9),
    page:  PrivacyPage(),
  ),
];

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Scaffold(
      backgroundColor: _scaffold(context),
      body: Column(
        children: [
          // ── Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [AppColors.darkSurface, const Color(0xFF1E3A8A)]
                    : [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Terms & Privacy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Doc cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEGAL DOCUMENTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textSec(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: _surface(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border(context)),
                  ),
                  child: Column(
                    children: _docs
                        .asMap()
                        .entries
                        .map((e) => _DocRow(
                              doc: e.value,
                              isLast: e.key == _docs.length - 1,
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark
                        ? AppColors.darkPrimarySoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'By using Arivon, you agree to our Terms & Conditions and Privacy Policy. Last updated: June 2025.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSec(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocItem {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final Widget page;

  const _DocItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.page,
  });
}

class _DocRow extends StatelessWidget {
  final _DocItem doc;
  final bool isLast;

  const _DocRow({
    required this.doc,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => doc.page,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: doc.color.withOpacity(
                      dark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    doc.icon,
                    color: doc.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _text(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doc.desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSec(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: dark
                      ? AppColors.darkTextTert
                      : AppColors.textTert,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: _border(context),
            indent: 74,
          ),
      ],
    );
  }
}
