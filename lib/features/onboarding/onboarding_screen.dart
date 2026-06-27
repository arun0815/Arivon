import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/profile_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _instituteCtrl = TextEditingController();
  String _department   = '';
  String _semester     = '';
  DateTime? _dob;
  bool _isSaving       = false;

  final _departments = [
    'Computer Science', 'Information Technology', 'ECE',
    'Mechanical', 'Civil', 'EEE', 'AIDS', 'CSBS',
  ];
  final _semesters = ['1','2','3','4','5','6','7','8'];

  @override
  void dispose() {
    _instituteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year - 15, now.month, now.day),
      helpText: 'SELECT YOUR BIRTHDAY',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String _formatDOB(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_done', true);
    if (mounted) context.go('/home');
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_done', true);

    final email = prefs.getString('user_email') ?? '';

    if (_instituteCtrl.text.trim().isNotEmpty)
      await prefs.setString('institute', _instituteCtrl.text.trim());
    if (_department.isNotEmpty)
      await prefs.setString('department', _department);
    if (_semester.isNotEmpty)
      await prefs.setString('semester', _semester);
    if (_dob != null)
      await prefs.setString('dob', _dob!.toIso8601String());

    // Save to DB
    if (email.isNotEmpty) {
      await ProfileService.updateProfile(
        email:       email,
        institute:   _instituteCtrl.text.trim().isNotEmpty
                         ? _instituteCtrl.text.trim() : null,
        department:  _department.isNotEmpty ? _department : null,
        semester:    _semester.isNotEmpty ? _semester : null,
        dateOfBirth: _dob?.toIso8601String(),
      );
    }

    setState(() => _isSaving = false);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg  = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final border  = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text    = isDark ? Colors.white : AppColors.text;
    final textSec = isDark ? const Color(0xFF94A3B8) : AppColors.textSec;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile',
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: text, letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill what you know — you can always edit later',
                          style: TextStyle(fontSize: 13, color: textSec),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B) : AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: textSec,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Institute
                    _Label('Institute', isDark),
                    const SizedBox(height: 8),
                    _InputBox(
                      controller: _instituteCtrl,
                      hint: 'eg. Anna University, Chennai',
                      icon: Icons.business_outlined,
                      cardBg: cardBg, border: border, isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // Date of Birth
                    _Label('Date of Birth', isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDOB,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _dob != null
                              ? AppColors.primary.withOpacity(0.08)
                              : cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _dob != null ? AppColors.primary : border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              color: _dob != null
                                  ? AppColors.primary
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : AppColors.textTert),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dob != null
                                    ? _formatDOB(_dob!)
                                    : 'Select your birthday',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _dob != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _dob != null
                                      ? (isDark ? Colors.white : AppColors.text)
                                      : (isDark
                                          ? const Color(0xFF64748B)
                                          : AppColors.textTert),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: _dob != null
                                  ? AppColors.primary
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : AppColors.textTert),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Department
                    _Label('Department', isDark),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _departments.map((dept) {
                        final sel = _department == dept;
                        return GestureDetector(
                          onTap: () => setState(() => _department = dept),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel ? AppColors.primary : border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              dept,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.w700 : FontWeight.w500,
                                color: sel
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70 : AppColors.text),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Semester
                    _Label('Semester', isDark),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.4,
                      children: _semesters.map((sem) {
                        final sel = _semester == sem;
                        return GestureDetector(
                          onTap: () => setState(() => _semester = sem),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel ? AppColors.primary : border,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sem,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white : AppColors.text),
                                  ),
                                ),
                                Text(
                                  'Sem',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: sel ? Colors.white70 : textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Save button ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Save & Continue →",
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF94A3B8) : AppColors.textTert,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color cardBg, border;
  final bool isDark;

  const _InputBox({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.cardBg,
    required this.border,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.text,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : AppColors.textTert,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? const Color(0xFF64748B) : AppColors.textTert,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
