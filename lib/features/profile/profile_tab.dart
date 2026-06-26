import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/profile_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/settings_page.dart';
import '../../pages/edit_profile_page.dart';
import '../../pages/terms_privacy_page.dart';
import '../../pages/premium_page.dart';

// ── Theme helpers ─────────────────────────────────────────────────────────────
bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;

Color _scaffold(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : AppColors.bg;
Color _surface(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkCard : AppColors.white;
Color _border(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.border;
Color _borderLight(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.borderLight;
Color _text(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkText : AppColors.text;
Color _textSec(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;
Color _textTert(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextTert : AppColors.textTert;
Color _iconRowBg(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSurface : AppColors.bg;
Color _roseSoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkRoseSoft : AppColors.roseSoft;
Color _primarySoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkPrimarySoft : AppColors.primarySoft;
Color _successSoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSuccessSoft : AppColors.successSoft;
Color _dangerColor(BuildContext ctx) =>
    _isDark(ctx) ? const Color(0xFFF87171) : AppColors.rose;
Color _dangerSubText(BuildContext ctx) =>
    _isDark(ctx) ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444);

// ── ProfileTab ────────────────────────────────────────────────────────────────
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final dark = _isDark(context);

    return Scaffold(
      backgroundColor: _scaffold(context),
      body: Column(
        children: [
          // ── Fixed gradient header (never scrolls away) ──
          Container(
            height: top + 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [AppColors.darkSurface, const Color(0xFF1E3A8A)]
                    : [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
              ),
            ),
            padding: EdgeInsets.only(top: top, left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                // Plan badge from provider
                Consumer<ProfileProvider>(
                  builder: (ctx, pp, _) {
                    final plan = pp.profile?.subscription?.plan ?? 'free';
                    final isPremium = plan == 'premium';
                    return isPremium
                        ? _PremiumBadge()
                        : _FreeBadge();
                  },
                ),
              ],
            ),
          ),

          // ── Body — fixed height, no scroll ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  _AvatarCard(),
                  const SizedBox(height: 12),
                  _AcademicSection(),
                  const SizedBox(height: 12),
                  _AccountSection(),
                  const SizedBox(height: 12),
                  _DangerSection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan badges ───────────────────────────────────────────────────────────────
class _FreeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_outline_rounded, color: Colors.white70, size: 13),
          SizedBox(width: 4),
          Text('Free',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 13),
          SizedBox(width: 4),
          Text('Premium',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

// ── Avatar card ───────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final dark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: profile?.profileImg != null &&
                    profile!.profileImg!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      profile.profileImg!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(profile.initial,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      profile?.initial ?? 'U',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 13),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? 'Guest',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _text(context),
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  profile?.email ?? '',
                  style: TextStyle(fontSize: 11.5, color: _textSec(context)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (profile?.department != null &&
                        profile!.department!.isNotEmpty)
                      _Tag(
                          profile.department!.length > 8
                              ? profile.department!.substring(0, 8)
                              : profile.department!,
                          AppColors.primary,
                          _primarySoft(context)),
                    if (profile?.semester != null &&
                        profile!.semester!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _Tag(profile.semester!, AppColors.success,
                          _successSoft(context)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () {
              if (profile == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(
                    profile: ProfileModel(
                      name: profile.name,
                      email: profile.email,
                      institute: profile.institute ?? '',
                      department: profile.department ?? '',
                      semester: profile.semester ?? '',
                      selectedAvatar: profile.selectedAvatar,
                      profileImg: profile.profileImg,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _surface(context),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _border(context), width: 1.5),
              ),
              child: Text('Edit',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _text(context))),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Academic info ─────────────────────────────────────────────────────────────
class _AcademicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    final items = [
      _InfoItem('Institute', profile?.institute ?? 'Not set',
          Icons.business_outlined, AppColors.primary),
      _InfoItem('Department', profile?.department ?? 'Not set',
          Icons.book_outlined, AppColors.violet),
      _InfoItem('Semester', profile?.semester ?? 'Not set',
          Icons.school_outlined, AppColors.success),
    ];

    return _SectionWidget(
      label: 'ACADEMIC',
      child: _CardWidget(
        children: items
            .asMap()
            .entries
            .map((e) =>
                _InfoRow(item: e.value, isLast: e.key == items.length - 1))
            .toList(),
      ),
    );
  }
}

// ── Account options ───────────────────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  Future<void> _handleSignOut(BuildContext context) async {
    final dark = _isDark(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? AppColors.darkCard : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _text(ctx))),
        content: Text('Are you sure you want to sign out?',
            style: TextStyle(fontSize: 14, color: _textSec(ctx))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(fontSize: 15, color: _textSec(ctx))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out',
                style: TextStyle(
                    fontSize: 15,
                    color: _dangerColor(ctx),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await GoogleSignIn().signOut();
      if (context.mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final danger = _dangerColor(context);

    // Check plan to decide what to show for Premium row
    final plan = context.watch<ProfileProvider>().profile?.subscription?.plan ?? 'free';
    final isPremium = plan == 'premium';

    return _SectionWidget(
      label: 'ACCOUNT',
      child: _CardWidget(children: [
        _ActionRow(
          icon: Icons.settings_outlined,
          label: 'Settings',
          sub: 'App preferences & notifications',
          color: _text(context),
          isLast: false,
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => SettingsPage())),
        ),
        _ActionRow(
          icon: Icons.gavel_rounded,
          label: 'Terms & Privacy',
          sub: 'Terms of service & privacy policy',
          color: _text(context),
          isLast: false,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPrivacyPage())),
        ),
        // Premium row — luxury design
        _PremiumActionRow(
          isPremium: isPremium,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumPage())),
        ),
        // Sign out
        GestureDetector(
          onTap: () => _handleSignOut(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _roseSoft(context),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.logout_rounded, color: danger, size: 19),
                ),
                const SizedBox(width: 14),
                Text('Sign Out',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: danger)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Premium action row (luxury card design) ───────────────────────────────────
class _PremiumActionRow extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onTap;

  const _PremiumActionRow({required this.isPremium, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gem icon with gold ring
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Arivon Premium',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2)),
                      const SizedBox(width: 6),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFF59E0B).withOpacity(0.4)),
                          ),
                          child: const Text('ACTIVE',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFBBF24),
                                  letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isPremium
                        ? 'All features unlocked ✦'
                        : 'Unlock everything · No limits',
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Arrow or stars indicator
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPremium ? '✦ Pro' : 'Upgrade',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Danger zone ───────────────────────────────────────────────────────────────
class _DangerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final danger = _dangerColor(context);
    final dangerSub = _dangerSubText(context);
    final dangerBg = dark ? AppColors.darkRoseSoft : AppColors.roseSoft;
    final dangerBorder =
        dark ? danger.withOpacity(0.35) : const Color(0xFFFECACA);
    final innerIconBg =
        dark ? danger.withOpacity(0.18) : const Color(0xFFFEE2E2);

    return GestureDetector(
      onTap: () => _showDeleteConfirm(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dangerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dangerBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: innerIconBg,
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(Icons.delete_outline_rounded,
                  color: danger, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete Account',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: danger)),
                  const SizedBox(height: 2),
                  Text('Permanently remove your account & data',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: dangerSub,
                          height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.warning_amber_rounded, color: danger, size: 18),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final dark = _isDark(sheetCtx);
        final danger = _dangerColor(sheetCtx);

        return Container(
          padding: EdgeInsets.only(
            top: 8,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 36,
          ),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : AppColors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: _border(sheetCtx),
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: dark
                        ? danger.withOpacity(0.18)
                        : _roseSoft(sheetCtx),
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.delete_outline_rounded,
                    color: danger, size: 30),
              ),
              const SizedBox(height: 16),
              Text('Delete Account?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _text(sheetCtx),
                      letterSpacing: -0.4)),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete your profile, saved notes, GPA history, '
                'and all app data. This action cannot be undone.',
                style: TextStyle(
                    fontSize: 14,
                    color: _textSec(sheetCtx),
                    height: 1.65),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _surface(sheetCtx),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _border(sheetCtx), width: 1.5),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _text(sheetCtx))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: danger,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: danger.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Yes, Delete',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _SectionWidget extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final Widget child;

  const _SectionWidget({
    required this.label,
    required this.child,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: labelColor ?? _textTert(context),
                  letterSpacing: 1.1)),
        ),
        child,
      ],
    );
  }
}

class _CardWidget extends StatelessWidget {
  final List<Widget> children;
  const _CardWidget({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  final bool isLast;
  const _InfoRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: _borderLight(context)))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(_isDark(context) ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: TextStyle(
                        fontSize: 10.5,
                        color: _textTert(context),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Text(item.value,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _text(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final bool isLast;
  final Color? iconBg;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.isLast,
    this.iconBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: _borderLight(context)))),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg ?? _iconRowBg(context),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(sub,
                        style: TextStyle(
                            fontSize: 11.5, color: _textTert(context))),
                  ],
                ],
              ),
            ),
            if (!isLast)
              Icon(Icons.chevron_right_rounded,
                  color: _textTert(context), size: 19),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Tag(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _InfoItem(this.label, this.value, this.icon, this.color);
}
