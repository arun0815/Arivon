import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_tab.dart';
import '../tools/tools_tab.dart';
import '../updates/updates_tab.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../widgets/birthday_overlay.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _tabs = const [
    HomeTab(),
    ToolsTab(),
    UpdatesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isBirthday = context.watch<ProfileProvider>().isBirthdayToday;

    return BirthdayOverlay(
      isBirthday: isBirthday,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,     activeIcon: Icons.home_rounded,     label: 'Home'),
    _NavItem(icon: Icons.build_outlined,    activeIcon: Icons.build_rounded,    label: 'Tools'),
    _NavItem(icon: Icons.timeline_outlined, activeIcon: Icons.timeline_rounded, label: 'Updates'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : AppColors.white;
    final border = isDark ? const Color(0xFF1E293B) : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item   = _items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52, height: 34,
                        decoration: BoxDecoration(
                          color: active
                              ? (isDark
                                  ? AppColors.primary.withOpacity(0.18)
                                  : AppColors.primarySoft)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: active
                              ? AppColors.primary
                              : (isDark
                                  ? const Color(0xFF64748B)
                                  : AppColors.textTert),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active
                              ? AppColors.primary
                              : (isDark
                                  ? const Color(0xFF64748B)
                                  : AppColors.textTert),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
