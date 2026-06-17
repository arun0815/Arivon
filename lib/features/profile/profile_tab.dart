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


bool _isDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;

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

// Semantic soft backgrounds
Color _roseSoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkRoseSoft : AppColors.roseSoft;

Color _primarySoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkPrimarySoft : AppColors.primarySoft;

Color _successSoft(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSuccessSoft : AppColors.successSoft;

// ── FIX: brighter rose for dark mode so Sign Out / Delete Account stay
// readable on dark surfaces (AppColors.rose is too muted on dark bg).
Color _dangerColor(BuildContext ctx) =>
    _isDark(ctx) ? const Color(0xFFF87171) : AppColors.rose;

Color _dangerSubText(BuildContext ctx) =>
    _isDark(ctx) ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444);

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header — stays the same in both modes (dark-on-dark looks great)
            Container(
              height: MediaQuery.of(context).padding.top + 100,
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
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
              ),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text('Profile',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5)),
              ),
            ),

            // Avatar card overlapping header
            Transform.translate(
              offset: const Offset(0, -48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    _AvatarCard(),
                    const SizedBox(height: 14),
                    _AcademicSection(),
                    const SizedBox(height: 14),
                    _AccountSection(),
                    const SizedBox(height: 14),
                    _DangerSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar card ───────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark(context) ? 0.3 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: profile?.profileImg != null &&
                    profile!.profileImg!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      profile.profileImg!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(profile.initial,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      profile?.initial ?? 'U',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? 'Guest',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _text(context),
                      letterSpacing: -0.4),
                ),
                const SizedBox(height: 3),
                Text(
                  profile?.email ?? '',
                  style: TextStyle(fontSize: 12, color: _textSec(context)),
                ),
                const SizedBox(height: 10),
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border(context), width: 1.5),
              ),
              child: Text('Edit',
                  style: TextStyle(
                      fontSize: 14,
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
      _InfoItem('Institute',  profile?.institute  ?? 'Not set', Icons.business_outlined, AppColors.primary),
      _InfoItem('Department', profile?.department ?? 'Not set', Icons.book_outlined,      AppColors.violet),
      _InfoItem('Semester',   profile?.semester   ?? 'Not set', Icons.school_outlined,    AppColors.success),
    ];

    return _SectionWidget(
      label: 'ACADEMIC',
      child: _CardWidget(
        children: items
            .asMap()
            .entries
            .map((e) => _InfoRow(item: e.value, isLast: e.key == items.length - 1))
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

        // Terms & Privacy
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

        // Premium
        _ActionRow(
          icon: Icons.workspace_premium_rounded,
          label: 'Premium',
          sub: 'Unlock all features',
          color: _text(context),
          isLast: false,
          iconBg: _isDark(context)
              ? const Color(0xFFFBBF24).withOpacity(0.18)
              : const Color(0xFFFEF3C7),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumPage())),
        ),

        // Sign out row
        GestureDetector(
          onTap: () => _handleSignOut(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _roseSoft(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.logout_rounded,
                      color: danger, size: 20),
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

// ── Danger zone ───────────────────────────────────────────────────────────────
class _DangerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final danger = _dangerColor(context);
    final dangerSub = _dangerSubText(context);

    // In dark mode use darkRoseSoft; light mode keeps the original roseSoft
    final dangerBg = dark ? AppColors.darkRoseSoft : AppColors.roseSoft;
    final dangerBorder = dark
        ? danger.withOpacity(0.35)
        : const Color(0xFFFECACA);
    final innerIconBg = dark
        ? danger.withOpacity(0.18)
        : const Color(0xFFFEE2E2);

    return _SectionWidget(
      label: 'DANGER ZONE',
      labelColor: danger,
      child: GestureDetector(
        onTap: () => _showDeleteConfirm(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: dangerBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dangerBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: innerIconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.delete_outline_rounded,
                    color: danger, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete Account',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: danger)),
                    const SizedBox(height: 2),
                    Text('Permanently remove your account & data',
                        style: TextStyle(
                            fontSize: 12,
                            color: dangerSub,
                            height: 1.4)),
                  ],
                ),
              ),
              Icon(Icons.warning_amber_rounded,
                  color: danger, size: 20),
            ],
          ),
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _border(sheetCtx),
                    borderRadius: BorderRadius.circular(3),
                  ),
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
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
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
                  // Delete
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
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
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
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
        borderRadius: BorderRadius.circular(18),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: _borderLight(context)))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(_isDark(context) ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: _textTert(context),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(item.value,
                    style: TextStyle(
                        fontSize: 14,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: _borderLight(context)))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? _iconRowBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(sub,
                        style: TextStyle(
                            fontSize: 12, color: _textTert(context))),
                  ],
                ],
              ),
            ),
            if (!isLast)
              Icon(Icons.chevron_right_rounded,
                  color: _textTert(context), size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _InfoItem(this.label, this.value, this.icon, this.color);
}
