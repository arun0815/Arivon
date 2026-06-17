import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  final List<_SubjectEntry> _subjects = List.generate(
    6,
    (i) => _SubjectEntry(name: 'Subject ${i + 1}'),
  );

  bool _calculated = false;

  static _GradeResult _grade(double internal, double external) {
    final total = internal + external;
    if (external < 45 || internal < 15) {
      return _GradeResult(grade: 'F', point: 0, color: const Color(0xFFDC2626), status: 'Fail');
    }
    if (total >= 91) return _GradeResult(grade: 'O',  point: 10, color: const Color(0xFF16A34A), status: 'Pass');
    if (total >= 81) return _GradeResult(grade: 'A+', point: 9,  color: const Color(0xFF2563EB), status: 'Pass');
    if (total >= 71) return _GradeResult(grade: 'A',  point: 8,  color: const Color(0xFF0891B2), status: 'Pass');
    if (total >= 61) return _GradeResult(grade: 'B+', point: 7,  color: const Color(0xFF7C3AED), status: 'Pass');
    if (total >= 57) return _GradeResult(grade: 'B',  point: 6,  color: const Color(0xFFD97706), status: 'Pass');
    if (total >= 50) return _GradeResult(grade: 'C',  point: 5,  color: const Color(0xFFCA8A04), status: 'Pass');
    return _GradeResult(grade: 'F', point: 0, color: const Color(0xFFDC2626), status: 'Fail');
  }

  void _calculate() {
    bool anyError = false;
    for (final s in _subjects) {
      s.internalError = null;
      s.externalError = null;
      final i = double.tryParse(s.internalCtrl.text.trim());
      final e = double.tryParse(s.externalCtrl.text.trim());
      if (i == null || i < 0 || i > 50) {
        s.internalError = 'Enter 0–50';
        anyError = true;
      }
      if (e == null || e < 0 || e > 100) {
        s.externalError = 'Enter 0–100';
        anyError = true;
      }
    }
    setState(() => _calculated = !anyError);
  }

  void _reset() {
    for (final s in _subjects) {
      s.internalCtrl.clear();
      s.externalCtrl.clear();
      s.internalError = null;
      s.externalError = null;
      s.nameCtrl.text = s.name;
    }
    setState(() => _calculated = false);
  }

  void _addSubject() {
    if (_subjects.length >= 12) return;
    setState(() => _subjects.add(
        _SubjectEntry(name: 'Subject ${_subjects.length + 1}')));
  }

  void _removeSubject(int index) {
    if (_subjects.length <= 1) return;
    setState(() {
      _subjects[index].dispose();
      _subjects.removeAt(index);
      _calculated = false;
    });
  }

  double _gpa() {
    if (!_calculated) return 0;
    double totalPoints = 0;
    for (final s in _subjects) {
      final i = double.tryParse(s.internalCtrl.text) ?? 0;
      final e = double.tryParse(s.externalCtrl.text) ?? 0;
      totalPoints += _grade(i, e).point;
    }
    return totalPoints / _subjects.length;
  }

  @override
  void dispose() {
    for (final s in _subjects) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final card   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tp     = isDark ? Colors.white : const Color(0xFF0F172A);
    final ts     = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final gpa = _gpa();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ─────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: card, borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: tp),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marks Calculator', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800, color: tp)),
                      Text('Grade & GPA per subject',
                          style: TextStyle(fontSize: 12, color: ts)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── GPA Result Banner ──────────────────────────────────
              if (_calculated) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gpa >= 7
                          ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                          : gpa >= 5
                              ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                              : [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Semester GPA',
                                style: TextStyle(color: Colors.white70,
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(gpa.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                )),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${_subjects.length} Subjects',
                              style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            gpa >= 7 ? '🎉 Great work!' : gpa >= 5 ? '👍 Keep it up!' : '💪 You can do it!',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Grade Reference Card ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: card, borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GradeChip(grade: 'O',  pts: '10', range: '91+', color: Color(0xFF16A34A)),
                    _GradeChip(grade: 'A+', pts: '9',  range: '81+', color: Color(0xFF2563EB)),
                    _GradeChip(grade: 'A',  pts: '8',  range: '71+', color: Color(0xFF0891B2)),
                    _GradeChip(grade: 'B+', pts: '7',  range: '61+', color: Color(0xFF7C3AED)),
                    _GradeChip(grade: 'B',  pts: '6',  range: '57+', color: Color(0xFFD97706)),
                    _GradeChip(grade: 'C',  pts: '5',  range: '50+', color: Color(0xFFCA8A04)),
                    _GradeChip(grade: 'F',  pts: '0',  range: '<50', color: Color(0xFFDC2626)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Subject Cards ──────────────────────────────────────
              ...List.generate(_subjects.length, (i) {
                final s = _subjects[i];
                final hasResult = _calculated &&
                    s.internalCtrl.text.isNotEmpty &&
                    s.externalCtrl.text.isNotEmpty;
                _GradeResult? result;
                if (hasResult) {
                  final internal = double.tryParse(s.internalCtrl.text) ?? 0;
                  final external = double.tryParse(s.externalCtrl.text) ?? 0;
                  result = _grade(internal, external);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: result != null ? result.color.withOpacity(0.3) : border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800,
                                      color: Color(0xFF059669),
                                    )),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: s.nameCtrl,
                                style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w700, color: tp),
                                decoration: InputDecoration(
                                  hintText: 'Subject name',
                                  hintStyle: TextStyle(color: ts, fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (result != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: result.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(result.grade,
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                      color: result.color,
                                    )),
                              ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeSubject(i),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.close_rounded,
                                    size: 14, color: Colors.red.shade400),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MarksField(
                                label: 'Internal',
                                hint: '/ 50',
                                controller: s.internalCtrl,
                                error: s.internalError,
                                isDark: isDark,
                                color: const Color(0xFF2563EB),
                                onChanged: (_) => setState(() => s.internalError = null),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MarksField(
                                label: 'External',
                                hint: '/ 100',
                                controller: s.externalCtrl,
                                error: s.externalError,
                                isDark: isDark,
                                color: const Color(0xFF7C3AED),
                                onChanged: (_) => setState(() => s.externalError = null),
                              ),
                            ),
                            if (result != null) ...[
                              const SizedBox(width: 10),
                              Column(
                                children: [
                                  Text(
                                    '${(double.parse(s.internalCtrl.text) + double.parse(s.externalCtrl.text)).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w800,
                                      color: result.color,
                                    ),
                                  ),
                                  Text('${result.point} pts',
                                      style: TextStyle(fontSize: 10, color: ts)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Add Subject ───────────────────────────────────────
              if (_subjects.length < 12)
                GestureDetector(
                  onTap: _addSubject,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            size: 16, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text('Add Subject',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            )),
                      ],
                    ),
                  ),
                ),

              // ── Buttons ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Calculate Grades',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50, width: 50,
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Icon(Icons.refresh_rounded, color: ts, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Pass Criteria Note ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pass criteria: Internal ≥ 15/50 AND External ≥ 45/100. '
                        'Even if total ≥ 50, failing either component gives F grade.',
                        style: TextStyle(fontSize: 12, color: ts, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Classes ─────────────────────────────────────────────────────────

class _SubjectEntry {
  final String name;
  late final TextEditingController nameCtrl;
  final TextEditingController internalCtrl = TextEditingController();
  final TextEditingController externalCtrl = TextEditingController();
  String? internalError;
  String? externalError;

  _SubjectEntry({required this.name}) {
    nameCtrl = TextEditingController(text: name);
  }

  void dispose() {
    nameCtrl.dispose();
    internalCtrl.dispose();
    externalCtrl.dispose();
  }
}

class _GradeResult {
  final String grade;
  final int point;
  final Color color;
  final String status;

  const _GradeResult({
    required this.grade,
    required this.point,
    required this.color,
    required this.status,
  });
}

class _GradeChip extends StatelessWidget {
  final String grade;
  final String pts;
  final String range;
  final Color color;

  const _GradeChip({
    required this.grade,
    required this.pts,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(grade,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        Text(pts,
            style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
        Text(range,
            style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
      ],
    );
  }
}

class _MarksField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? error;
  final bool isDark;
  final Color color;
  final ValueChanged<String> onChanged;

  const _MarksField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.error,
    required this.isDark,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final ts = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: error != null ? Colors.red : color.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: ts),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 8),
            ),
            onChanged: onChanged,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(error!,
                style: const TextStyle(fontSize: 9, color: Colors.red)),
          ),
      ],
    );
  }
}
