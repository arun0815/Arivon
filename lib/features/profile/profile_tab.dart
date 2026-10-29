import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/profile_provider.dart';
import '../../features/settings/settings_page.dart';
import '../../pages/edit_profile_page.dart';
import '../../pages/terms_privacy_page.dart';

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
Color _dangerColor(BuildContext ctx) =>
    _isDark(ctx) ? const Color(0xFFF87171) : AppColors.rose;

// ── ProfileTab ────────────────────────────────────────────────────────────────
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const _ProfileHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: const [
                  _AcademicSection(),
                  SizedBox(height: 18),
                  _AccountSection(),
                  SizedBox(height: 8),
                  _DeleteAccountLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header (rounded gradient + avatar + actions) ──────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  void _share(BuildContext context, String? name) {
    final who = (name != null && name.isNotEmpty) ? name : 'I';
    Share.share(
      '$who ${who == 'I' ? 'am' : 'is'} using Arivon for notes, results, '
      'question papers and GPA calculation. Try it: https://myarivon.in',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final dark = _isDark(context);
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 10, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.darkSurface, const Color(0xFF1E3A8A)]
              : [const Color(0xFF1D4ED8), const Color(0xFF0A84FF)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: back + title
          Row(
            children: [
              if (Navigator.of(context).canPop())
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              const Spacer(),
              const Text('Profile',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3)),
              const Spacer(),
              const SizedBox(width: 38),
            ],
          ),
          const SizedBox(height: 18),

          // Rounded-corner avatar
          Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: _avatar(profile),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            profile?.name ?? 'Guest',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 3),
          Text(
            profile?.email ?? '',
            style: TextStyle(
                fontSize: 12.5, color: Colors.white.withOpacity(0.75)),
          ),
          const SizedBox(height: 20),

          // Edit + Share
          Row(
            children: [
              Expanded(
                child: _HeaderButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  filled: true,
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderButton(
                  icon: Icons.ios_share_rounded,
                  label: 'Share',
                  filled: false,
                  onTap: () => _share(context, profile?.name),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(dynamic profile) {
    final initialWidget = Container(
      color: Colors.white.withOpacity(0.2),
      alignment: Alignment.center,
      child: Text(
        profile?.initial ?? 'U',
        style: const TextStyle(
            fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );

    if (profile?.selectedAvatar != null &&
        profile!.selectedAvatar!.isNotEmpty) {
      return Image.asset(profile.selectedAvatar!,
          width: 98, height: 98, fit: BoxFit.cover);
    }
    if (profile?.profileImg != null && profile!.profileImg!.isNotEmpty) {
      return Image.network(
        profile.profileImg!,
        width: 98,
        height: 98,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => initialWidget,
      );
    }
    return initialWidget;
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? const Color(0xFF1D4ED8) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

// ── Academic info ─────────────────────────────────────────────────────────────
class _AcademicSection extends StatelessWidget {
  const _AcademicSection();

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
        children: [
          for (var i = 0; i < items.length; i++)
            _InfoRow(item: items[i], isLast: i == items.length - 1),
        ],
      ),
    );
  }
}

// ── Account ───────────────────────────────────────────────────────────────────
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
        _ActionRow(
          icon: Icons.gavel_rounded,
          label: 'Terms & Privacy',
          sub: 'Terms of service & privacy policy',
          color: _text(context),
          isLast: false,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TermsPrivacyPage())),
        ),
        _ActionRow(
          icon: Icons.logout_rounded,
          label: 'Sign Out',
          sub: '',
          color: danger,
          iconBg: _roseSoft(context),
          isLast: true,
          onTap: () => _handleSignOut(context),
        ),
      ]),
    );
  }
}

// ── Delete account (small text link) ──────────────────────────────────────────
class _DeleteAccountLink extends StatelessWidget {
  const _DeleteAccountLink();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _showDeleteConfirm(context),
      child: Text('Delete Account',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _dangerColor(context).withOpacity(0.85))),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                      // TODO: call your delete-account API here
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: danger,
                          borderRadius: BorderRadius.circular(14),
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
  final Widget child;
  const _SectionWidget({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _textTert(context),
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
        borderRadius: BorderRadius.circular(22),
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
              border:
                  Border(bottom: BorderSide(color: _borderLight(context)))),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withOpacity(_isDark(context) ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
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
      behavior: HitTestBehavior.opaque,
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
                borderRadius: BorderRadius.circular(12),
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

class _InfoItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _InfoItem(this.label, this.value, this.icon, this.color);
}
