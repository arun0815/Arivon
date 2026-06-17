import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../webview/webview_screen.dart'; // reuse your existing ToolWebViewPage

// ─── Theme helpers ────────────────────────────────────────────────────────────
bool _isDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;
Color _scaffold(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBg : AppColors.bg;
Color _surface(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkCard : AppColors.white;
Color _border(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkBorder : AppColors.border;
Color _text(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkText : AppColors.text;
Color _textSec(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextSec : AppColors.textSec;
Color _textTert(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkTextTert : AppColors.textTert;
Color _header(BuildContext ctx) =>
    _isDark(ctx) ? AppColors.darkSurface : AppColors.white;

// ─── Department model ─────────────────────────────────────────────────────────
class _Dept {
  final String name;
  final String fullName;
  final IconData icon;
  final Color color;
  final Color lightBg;
  final Color darkBg;
  final String url; // swap in your real notes URLs

  const _Dept({
    required this.name,
    required this.fullName,
    required this.icon,
    required this.color,
    required this.lightBg,
    required this.darkBg,
    required this.url,
  });
}

// ─── Departments list ─────────────────────────────────────────────────────────
const _departments = [
  _Dept(
    name: 'CSE',
    fullName: 'Computer Science & Engineering',
    icon: Icons.computer_rounded,
    color: AppColors.primary,
    lightBg: AppColors.primarySoft,
    darkBg: AppColors.darkPrimarySoft,
    url: 'https://www.enggtree.com/anna-university-lecture-notes-2021-regulation-cse-department/',
  ),
  _Dept(
    name: 'ECE',
    fullName: 'Electronics & Communication Engineering',
    icon: Icons.memory_rounded,
    color: AppColors.violet,
    lightBg: AppColors.violetSoft,
    darkBg: AppColors.darkVioletSoft,
    url: 'https://www.brainkart.com/materials/ece---anna-university-2021-regulation-1003/',
  ),
  _Dept(
    name: 'EEE',
    fullName: 'Electrical & Electronics Engineering',
    icon: Icons.bolt_rounded,
    color: AppColors.amber,
    lightBg: AppColors.amberSoft,
    darkBg: AppColors.darkAmberSoft,
    url: 'https://www.brainkart.com/materials/eee---anna-university-2021-regulation-1002/',
  ),
  _Dept(
    name: 'Mech',
    fullName: 'Mechanical Engineering',
    icon: Icons.settings_rounded,
    color: AppColors.teal,
    lightBg: AppColors.tealSoft,
    darkBg: AppColors.darkTealSoft,
    url: 'https://www.brainkart.com/materials/engineering-mechanics---me3351-2034/notes/',
  ),
  _Dept(
    name: 'Civil',
    fullName: 'Civil Engineering',
    icon: Icons.domain_rounded,
    color: AppColors.success,
    lightBg: AppColors.successSoft,
    darkBg: AppColors.darkSuccessSoft,
    url: 'https://www.brainkart.com/materials/civil---anna-university-2021-regulation-1005/',
  ),
  _Dept(
    name: 'IT',
    fullName: 'Information Technology',
    icon: Icons.terminal_rounded,
    color: AppColors.indigo,
    lightBg: AppColors.indigoSoft,
    darkBg: AppColors.darkIndigoSoft,
    url: 'https://www.brainkart.com/materials/it---anna-university-2021-regulation-1007/',
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────
class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold(context),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            color: _header(context),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _scaffold(context),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _border(context)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: _text(context)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: _text(context),
                            letterSpacing: -0.4)),
                    Text('Select your department',
                        style: TextStyle(
                            fontSize: 11, color: _textSec(context))),
                  ],
                ),
              ],
            ),
          ),

          Container(height: 1, color: _border(context)),

          // ── Department list ───────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _DeptRow(dept: _departments[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Department Row ───────────────────────────────────────────────────────────
class _DeptRow extends StatelessWidget {
  final _Dept dept;
  const _DeptRow({super.key, required this.dept});

  @override
  Widget build(BuildContext context) {
    final iconBg =
        _isDark(context) ? dept.darkBg : dept.lightBg;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(
            title: '${dept.name} Notes',
            url: dept.url,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(dept.icon, color: dept.color, size: 24),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dept.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _text(context))),
                  const SizedBox(height: 3),
                  Text(dept.fullName,
                      style: TextStyle(
                          fontSize: 12, color: _textSec(context))),
                ],
              ),
            ),

            // Chevron
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: dept.color),
            ),
          ],
        ),
      ),
    );
  }
}
