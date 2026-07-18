import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../contactus/contact_us_page.dart';
import '../notes/departments_page.dart';
import '../calculators/percentage_page.dart';
import '../calculators/cut_off_page.dart';
import '../calculators/marks_page.dart';
import '../results/results_page.dart';
import '../feedback/feedback_tab.dart';
import '../credits/credits_page.dart';
import '../updates/updates_tab.dart';
import '../../pages/filtered_updates_page.dart';
import '../webview/webview_screen.dart';
import '../../pages/syllabus_page.dart';

// ─── Theme helpers ────────────────────────────────────────────────────────────
bool _isDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;

Color _surface(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkCard : AppColors.white;

Color _scaffold(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : AppColors.bg;

Color _header(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSurface : AppColors.white;

Color _border(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.border;

Color _text(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkText : AppColors.text;

Color _textSec(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;

Color _label(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextTert : AppColors.textTert;

Color _iconBg(BuildContext ctx, Color iconColor, Color lightBg, Color? darkBg) {
  if (!_isDark(ctx)) return lightBg;
  if (darkBg != null) return darkBg;
  return iconColor.withOpacity(0.15);
}

// ─── WebView Page ─────────────────────────────────────────────────────────────
class ToolWebViewPage extends StatelessWidget {
  final String title;
  final String url;
  const ToolWebViewPage({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _text(context))),
        backgroundColor: _header(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _text(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border(context)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_browser_rounded,
                size: 56, color: _textSec(context).withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('WebView: $title',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textSec(context))),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(url,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _label(context))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Static Placeholder Page ──────────────────────────────────────────────────
class ToolStaticPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color lightBg;
  final Color? darkBg;

  const ToolStaticPage({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.lightBg,
    this.darkBg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _text(context))),
        backgroundColor: _header(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _text(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border(context)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _iconBg(context, color, lightBg, darkBg),
                  borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _text(context),
                    letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Coming soon',
                style: TextStyle(fontSize: 13, color: _textSec(context))),
          ],
        ),
      ),
    );
  }
}

// ─── Tools Tab ────────────────────────────────────────────────────────────────
class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  static final _tools = [
    // ── Calculators ──
    _Tool('GPA',           Icons.bar_chart_rounded,          AppColors.primary, AppColors.primarySoft, AppColors.darkPrimarySoft),
    _Tool('CGPA',          Icons.trending_up_rounded,        AppColors.violet,  AppColors.violetSoft,  AppColors.darkVioletSoft),
    _Tool('Attendance',    Icons.calendar_today_outlined,    AppColors.success, AppColors.successSoft, AppColors.darkSuccessSoft),
    _Tool('Internal',      Icons.description_outlined,       AppColors.amber,   AppColors.amberSoft,   AppColors.darkAmberSoft),
    _Tool('Credits',       Icons.emoji_events_outlined,      AppColors.teal,    AppColors.tealSoft,    AppColors.darkTealSoft),
    _Tool('Timetable',     Icons.access_time_outlined,       AppColors.rose,    AppColors.roseSoft,    AppColors.darkRoseSoft),

    // ── Academics ──
    _Tool('Result',        Icons.workspace_premium_rounded,  AppColors.teal,    AppColors.tealSoft,    AppColors.darkTealSoft),
    _Tool('Syllabus',      Icons.menu_book_rounded,          AppColors.violet,  AppColors.violetSoft,  AppColors.darkVioletSoft),
    _Tool('Question Paper',Icons.quiz_rounded,               AppColors.rose,    AppColors.roseSoft,    AppColors.darkRoseSoft),
    _Tool('Notes',         Icons.sticky_note_2_rounded,      AppColors.primary, AppColors.primarySoft, AppColors.darkPrimarySoft),
    _Tool('Percentage',    Icons.pie_chart_rounded,          AppColors.success, AppColors.successSoft, AppColors.darkSuccessSoft),
    _Tool('Cutoff',        Icons.cut_rounded,                AppColors.amber,   AppColors.amberSoft,   AppColors.darkAmberSoft),

    // ── Campus ──
    _Tool('Feedback',      Icons.rate_review_rounded,        AppColors.violet,  AppColors.violetSoft,  AppColors.darkVioletSoft),
    _Tool('Updates',       Icons.campaign_rounded,           AppColors.amber,   AppColors.amberSoft,   AppColors.darkAmberSoft),
    _Tool('Contact Us',    Icons.mail_rounded,               AppColors.teal,    AppColors.tealSoft,    AppColors.darkTealSoft),
  ];

  static const _sections = [
    _Section('Calculators', 0, 6),
    _Section('Academics',   6, 12),
    _Section('Campus',      12, 15),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ToolsHeaderDelegate(
              height: MediaQuery.of(context).padding.top + 90,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final s = _sections[i];
                  final tools = _tools.sublist(s.start, s.end);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 12),
                          child: Text(s.title.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _label(ctx),
                                  letterSpacing: 0.8)),
                        ),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                          children: tools
                              .map((t) => _ToolCard(tool: t))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky Header Delegate ───────────────────────────────────────────────────
class _ToolsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  const _ToolsHeaderDelegate({required this.height});

  @override double get minExtent => height;
  @override double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: _header(context),
        border: Border(bottom: BorderSide(color: _border(context), width: 1)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tools',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _text(context),
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text('Academic calculators & utilities',
              style: TextStyle(fontSize: 13, color: _textSec(context))),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ToolsHeaderDelegate oldDelegate) =>
      oldDelegate.height != height;
}

// ─── Section descriptor ───────────────────────────────────────────────────────
class _Section {
  final String title;
  final int start, end;
  const _Section(this.title, this.start, this.end);
}

// ─── Tool Card ────────────────────────────────────────────────────────────────
class _ToolCard extends StatelessWidget {
  final _Tool tool;
  const _ToolCard({super.key, required this.tool});

  void _navigate(BuildContext context) {
    switch (tool.label) {
      case 'Contact Us':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ContactUsPage()));
      case 'Notes':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DepartmentsPage()));
      case 'Result':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ResultsPage()));
      case 'Percentage':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PercentagePage()));
      case 'Cutoff':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => CutOffPage()));
      case 'Marks':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => MarksPage()));
      case 'Feedback':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => FeedbackTab()));
      case 'Credits':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => CreditsPage()));
      case 'Updates':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => UpdatesTab()));
      case 'Syllabus':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => SyllabusPage()));
      case 'Attendance':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => FilteredUpdatesPage(
                    type: 'attendance', title: 'Attendance')));
      case 'Internal':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => FilteredUpdatesPage(
                    type: 'internal', title: 'Internal')));
      case 'Timetable':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => FilteredUpdatesPage(
                    type: 'timetable', title: 'Timetable')));
      case 'Question Paper':
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => WebViewScreen(
                    title: tool.label,
                    url: 'https://myarivon.in/question-papers')));
      default:
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => ToolStaticPage(
                    title: tool.label,
                    icon: tool.icon,
                    color: tool.color,
                    lightBg: tool.lightBg,
                    darkBg: tool.darkBg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _iconBg(context, tool.color, tool.lightBg, tool.darkBg),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(tool.icon, color: tool.color, size: 26),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                tool.label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _text(context)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _Tool {
  final String label;
  final IconData icon;
  final Color color;
  final Color lightBg;
  final Color? darkBg;
  const _Tool(this.label, this.icon, this.color, this.lightBg, this.darkBg);
}
