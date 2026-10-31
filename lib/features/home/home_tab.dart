import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/models/update_models.dart';
import '../webview/webview_screen.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_tab.dart';
import '../games/memory_game_page.dart';
import '../facts/fact_page.dart';
import '../results/results_page.dart';
import '../notes/departments_page.dart';
import '../updates/updates_tab.dart';
import '../../pages/syllabus_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isProfileComplete(dynamic profile) {
    if (profile == null) return false;
    return profile.name != null && profile.name!.isNotEmpty &&
           profile.semester != null && profile.semester!.isNotEmpty &&
           profile.department != null && profile.department!.isNotEmpty &&
           profile.institute != null && profile.institute!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.bg,
      body: Stack(
        children: [
          // ── Scrollable body ──────────────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Space for top bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 80,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    if (_isProfileComplete(profile)) ...[
                      const _SemesterCard(),
                      const SizedBox(height: 22),
                    ],
                    _QuickAccess(context: context),
                    const SizedBox(height: 22),
                    const _DailyCards(),
                    const SizedBox(height: 22),
                    const _RecentUpdates(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),

          // ── Sticky top bar with blur bottom edge ─────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _TopBar(isScrolled: _isScrolled),
          ),
        ],
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isScrolled;
  const _TopBar({required this.isScrolled});

  String getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 0  && hour < 1)  return 'The moon is working overtime 🌙';
    if (hour >= 1  && hour < 2)  return 'Sleep called. You ignored it 😴';
    if (hour >= 2  && hour < 3)  return 'Even owls are getting concerned 🦉';
    if (hour >= 3  && hour < 4)  return 'Plot twist: it\'s still night 🌌';
    if (hour >= 4  && hour < 5)  return 'Who wakes up this early? 😳';
    if (hour >= 5  && hour < 6)  return 'The early bird is showing off 🐦';
    if (hour >= 6  && hour < 7)  return 'Good Morning, sunshine ☀️';
    if (hour >= 7  && hour < 8)  return 'Time to pretend you\'re fully awake 😅';
    if (hour >= 8  && hour < 9)  return 'Breakfast first, world domination later 🍳';
    if (hour >= 9  && hour < 10) return 'Productivity.exe has started 🚀';
    if (hour >= 10 && hour < 11) return 'Looking busy is half the job 😎';
    if (hour >= 11 && hour < 12) return 'Almost lunch. Stay strong 💪';
    if (hour >= 12 && hour < 13) return 'Lunch acquired? 🍱';
    if (hour >= 13 && hour < 14) return 'Afternoon mode activated 🎯';
    if (hour >= 14 && hour < 15) return 'A nap sounds amazing right now 😴';
    if (hour >= 15 && hour < 16) return 'Coffee is carrying the team ☕';
    if (hour >= 16 && hour < 17) return 'You survived another hour 🎉';
    if (hour >= 17 && hour < 18) return 'Evening vibes loading 🌇';
    if (hour >= 18 && hour < 19) return 'The sun is clocking out 🌅';
    if (hour >= 19 && hour < 20) return 'Time to relax... or procrastinate 😏';
    if (hour >= 20 && hour < 21) return 'Today was something, wasn\'t it? 🤔';
    if (hour >= 21 && hour < 22) return 'Your bed is sending invitations 🛏️';
    if (hour >= 22 && hour < 23) return 'Night mode activated 🌙';
    return 'Still awake? That\'s between you and your sleep schedule 👀';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final name    = profile?.firstName ?? '';
    final bool hasUnreadNotifications = false; // get from DB/provider

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main bar
        Container(
          color: bgColor,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20, right: 20, bottom: 14,
          ),
          child: Row(
            children: [
              // Greeting + name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(name),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSec,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.firstName ?? 'Guest',
                      style: TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification bell
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(),
                  ),
                ),
                child: Stack(
                  children: [
                    _IconBtn(
                      icon: Icons.notifications_outlined,
                      isDark: isDark,
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.rose,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: bgColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 9),

              // Avatar — tapping opens profile
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileTab()),
                ),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.violet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildAvatar(profile),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(dynamic profile) {
    // Show local asset avatar if selected
    if (profile?.selectedAvatar != null &&
        profile!.selectedAvatar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          profile.selectedAvatar!,
          width: 38, height: 38,
          fit: BoxFit.cover,
        ),
      );
    }
    // Show network avatar
    if (profile?.profileImg != null && profile!.profileImg!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          profile.profileImg!,
          width: 38, height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(profile.initial,
              style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      );
    }
    // Initial fallback
    return Center(
      child: Text(
        profile?.initial ?? 'U',
        style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

// ── Semester card ─────────────────────────────────────────────────────────────
class _SemesterCard extends StatefulWidget {
  const _SemesterCard();

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _Bubble {
  final Offset pos;
  final AnimationController ctrl;
  _Bubble(this.pos, this.ctrl);
}

class _SemesterCardState extends State<_SemesterCard>
    with TickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  bool _pressed = false;

  void _spawn(Offset pos) {
    final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    final b = _Bubble(pos, c);
    setState(() => _bubbles.add(b));
    c.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _bubbles.remove(b));
      c.dispose();
    });
  }

  @override
  void dispose() {
    for (final b in _bubbles) {
      b.ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return MouseRegion(
      onEnter: (e) => _spawn(e.localPosition), // hover (web/desktop)
      child: GestureDetector(
        onTapDown: (d) {
          setState(() => _pressed = true);
          _spawn(d.localPosition);
        },
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8), Color(0xFF0A84FF)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    right: 40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),

                  // Bubble ripples
                  for (final b in _bubbles)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: b.ctrl,
                          builder: (_, __) => CustomPaint(
                            painter: _BubblePainter(b.pos, b.ctrl.value),
                          ),
                        ),
                      ),
                    ),

                  // Illustration
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/human.png',
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.school_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT SEMESTER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile?.semester ?? '—',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.18),
                          margin: const EdgeInsets.only(bottom: 12, right: 8),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 96),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.account_tree_outlined,
                                label: 'Department',
                                value: profile?.department ?? '—',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.location_city_rounded,
                                label: 'Institute',
                                value: profile?.institute ?? '—',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bubble painter ────────────────────────────────────────────────────────────
class _BubblePainter extends CustomPainter {
  final Offset center;
  final double t;
  _BubblePainter(this.center, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = size.longestSide * 0.9;
    // Two rings, the second one starts slightly later
    for (final delay in [0.0, 0.18]) {
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final r = Curves.easeOut.transform(p) * maxR;
      final fade = 1 - p;

      canvas.drawCircle(
        center,
        r,
        Paint()..color = Colors.white.withOpacity(0.18 * fade),
      );
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withOpacity(0.45 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.t != t || old.center != center;
}

// ── Info row (fixed width, marquee on overflow) ───────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ),
        Expanded(
          child: _MarqueeText(
            text: value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Marquee: static if it fits, scrolls right → left if it doesn't ───────────
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _MarqueeText({required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
  }

  Future<void> _loop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_controller.hasClients) return;

      final max = _controller.position.maxScrollExtent;
      if (max <= 0) continue; // fits, nothing to scroll

      // ~40 px per second
      await _controller.animateTo(
        max,
        duration: Duration(milliseconds: (max * 25).round()),
        curve: Curves.linear,
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        maxLines: 1,
        softWrap: false,
        style: widget.style,
      ),
    );
  }
}

// ── Daily cards (Game + Did You Know) ─────────────────────────────────────────
class _DailyCards extends StatelessWidget {
  const _DailyCards();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            isDark: isDark,
            title: 'Play Game',
            icon: Icons.sports_esports_outlined,
            iconColor: AppColors.violet,
            iconBg: AppColors.violetSoft,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MemoryGamePage(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _MiniCard(
            isDark: isDark,
            title: 'Did You Know?',
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.amber,
            iconBg: AppColors.amberSoft,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FactPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _MiniCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B)
              : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : AppColors.text,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : AppColors.textTert,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Access ──────────────────────────────────────────────────────────────
class _QuickAccess extends StatelessWidget {
  final BuildContext context;
  const _QuickAccess({required this.context});

  static final _items = [
    const _QAItem('Notes',    'Study material', AppColors.primary, AppColors.primarySoft,
      Icons.book_outlined),
    const _QAItem('Results',  'Check results',  AppColors.violet,  AppColors.violetSoft,
      Icons.emoji_events_outlined),
    // Full URL with https:// — WebView needs the scheme
    const _QAItem('QP',       'Past papers',    AppColors.teal,    AppColors.tealSoft,
      Icons.description_outlined, url: 'https://myarivon.in/question-papers'),
    const _QAItem('Syllabus', 'R2021',          AppColors.amber,   AppColors.amberSoft,
      Icons.format_align_left_rounded),
    const _QAItem('GPA Calc', 'Calculate',      AppColors.success, AppColors.successSoft,
      Icons.calculate_outlined),
    const _QAItem('Alerts',   '3 new',          AppColors.rose,    AppColors.roseSoft,
      Icons.notifications_outlined),
  ];

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Access',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.text,
            letterSpacing: -0.2)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: _items.map((item) => GestureDetector(
            onTap: () {
              if (item.label == 'Results') {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const ResultsPage(),
                  ),
                );
                return;
              }
              if (item.label == 'Alerts') {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(),
                  ),
                );
                return;
              }
              if (item.label == 'Notes') {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const DepartmentsPage(),
                  ),
                );
                return;
              }
              if (item.label == 'Syllabus') {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const SyllabusPage(),
                  ),
                );
                return;
              }

              if (item.url != null) {
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      title: item.label,
                      url: item.url!,
                    ),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: item.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(item.label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.text)),
                  const SizedBox(height: 2),
                  Text(item.sub,
                    style: TextStyle(fontSize: 10,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : AppColors.textTert)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _QAItem {
  final String label, sub;
  final Color color, bg;
  final IconData icon;
  final String? url;
  const _QAItem(this.label, this.sub, this.color, this.bg, this.icon,
      {this.url});
}

// ── Recent updates ────────────────────────────────────────────────────────────
class _RecentUpdates extends StatefulWidget {
  const _RecentUpdates();

  @override
  State<_RecentUpdates> createState() => _RecentUpdatesState();
}

class _RecentUpdatesState extends State<_RecentUpdates> {
  late Future<List<UpdateItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  void _reload() {
    setState(() => _future = _fetch());
  }

  Future<List<UpdateItem>> _fetch() async {
    final res = await http
        .get(Uri.parse(updatesApiUrl))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Failed to load updates (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? [])
        .map((e) => UpdateItem.fromJson(e as Map<String, dynamic>))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.text;
    final textSec = isDark ? const Color(0xFF94A3B8) : AppColors.textSec;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Updates',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: textColor, letterSpacing: -0.2)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdatesTab()),
              ),
              child: const Text('See all',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<UpdateItem>>(
          future: _future,
          builder: (context, snapshot) {
            // Loading → skeleton rows instead of a spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  _SkeletonRow(isDark: isDark),
                  _SkeletonRow(isDark: isDark),
                ],
              );
            }

            // Failed to load → friendly message + retry
            if (snapshot.hasError) {
              return _UpdatesStateCard(
                isDark: isDark,
                icon: Icons.wifi_off_rounded,
                color: AppColors.amber,
                title: 'Couldn\'t load updates',
                subtitle: 'Check your internet connection and try again.',
                actionLabel: 'Retry',
                onAction: _reload,
              );
            }

            // Loaded but nothing to show
            if (snapshot.data?.isEmpty ?? true) {
              return _UpdatesStateCard(
                isDark: isDark,
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                title: 'You\'re all caught up',
                subtitle: 'No new updates right now. Check back later.',
              );
            }

            final items = snapshot.data!;
            return Column(
              children: items.map((item) {
                final style = typeStyleFor(item.type);
                final tagBg = isDark
                    ? (style.darkBg ?? style.color.withOpacity(0.15))
                    : style.lightBg;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UpdateDetailPage(update: item)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(style.icon, color: style.color, size: 17),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                  color: textColor)),
                              const SizedBox(height: 2),
                              Text(item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: textSec)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : AppColors.textTert),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── Updates: empty / error card ───────────────────────────────────────────────
class _UpdatesStateCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _UpdatesStateCard({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.text;
    final textSec = isDark ? const Color(0xFF94A3B8) : AppColors.textSec;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.4, color: textSec)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(actionLabel!,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Updates: loading skeleton row ─────────────────────────────────────────────
class _SkeletonRow extends StatelessWidget {
  final bool isDark;
  const _SkeletonRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final border = isDark ? const Color(0xFF334155) : AppColors.border;
    final bar = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    Widget block(double w, double h, double r) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: bar,
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          block(36, 36, 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                block(140, 10, 5),
                const SizedBox(height: 8),
                block(double.infinity, 8, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  const _IconBtn({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: Icon(icon,
        color: isDark ? Colors.white70 : AppColors.text, size: 18),
    );
  }
}
