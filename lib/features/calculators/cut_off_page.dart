import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CutOffPage extends StatefulWidget {
  const CutOffPage({super.key});

  @override
  State<CutOffPage> createState() => _CutOffPageState();
}

class _CutOffPageState extends State<CutOffPage> {
  final _mathsCtrl   = TextEditingController();
  final _physicsCtrl = TextEditingController();
  final _chemCtrl    = TextEditingController();

  double? _result;
  Map<String, String?> _errors = {};

  @override
  void dispose() {
    _mathsCtrl.dispose();
    _physicsCtrl.dispose();
    _chemCtrl.dispose();
    super.dispose();
  }

  double? _parse(String v) {
    final d = double.tryParse(v.trim());
    if (d == null || d < 0 || d > 200) return null;
    return d;
  }

  void _calculate() {
    final maths   = _parse(_mathsCtrl.text);
    final physics = _parse(_physicsCtrl.text);
    final chem    = _parse(_chemCtrl.text);

    setState(() {
      _errors = {
        'maths':   maths   == null ? 'Enter marks (0–200)' : null,
        'physics': physics == null ? 'Enter marks (0–200)' : null,
        'chem':    chem    == null ? 'Enter marks (0–200)' : null,
      };
    });

    if (maths == null || physics == null || chem == null) return;

    setState(() {
      // ── Corrected formula: (Maths/2 + Physics/2 + Chemistry/2) ──────
      _result = (maths + (physics/2) + (chem/2));
    });
  }

  void _reset() {
    _mathsCtrl.clear();
    _physicsCtrl.clear();
    _chemCtrl.clear();
    setState(() { _result = null; _errors = {}; });
  }

  Color _cutOffColor(double val) {
    if (val >= 170) return const Color(0xFF16A34A);
    if (val >= 150) return const Color(0xFF2563EB);
    if (val >= 120) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _cutOffRemark(double val) {
    if (val >= 170) return 'Excellent — Top colleges possible';
    if (val >= 150) return 'Good — Government colleges possible';
    if (val >= 120) return 'Average — Aided colleges range';
    return 'Below average — Self-finance range';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final card   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tp     = isDark ? Colors.white : const Color(0xFF0F172A);
    final ts     = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: tp),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cut Off', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: tp)),
                      Text('HSC Cut Off calculator',
                          style: TextStyle(fontSize: 12, color: ts)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Formula banner ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HSC Cut Off Formula',
                              style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            '(Maths + (Physics/2) + (Chemistry/2)',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 1),
                          Text('Max cut off = 200',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Input Card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card, borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter HSC Marks',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w700, color: tp)),
                    Text('Out of 100 for each subject',
                        style: TextStyle(fontSize: 11, color: ts)),
                    const SizedBox(height: 14),

                    _SubjectField(
                      label: 'Mathematics',
                      icon: Icons.functions_rounded,
                      color: const Color(0xFF2563EB),
                      controller: _mathsCtrl,
                      error: _errors['maths'],
                      isDark: isDark,
                      onChanged: (_) =>
                          setState(() => _errors['maths'] = null),
                    ),
                    const SizedBox(height: 12),

                    _SubjectField(
                      label: 'Physics',
                      icon: Icons.science_outlined,
                      color: const Color(0xFF7C3AED),
                      controller: _physicsCtrl,
                      error: _errors['physics'],
                      isDark: isDark,
                      onChanged: (_) =>
                          setState(() => _errors['physics'] = null),
                    ),
                    const SizedBox(height: 12),

                    _SubjectField(
                      label: 'Chemistry',
                      icon: Icons.biotech_outlined,
                      color: const Color(0xFF059669),
                      controller: _chemCtrl,
                      error: _errors['chem'],
                      isDark: isDark,
                      onChanged: (_) =>
                          setState(() => _errors['chem'] = null),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _calculate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0891B2),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Calculate Cut Off',
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48, width: 48,
                          child: OutlinedButton(
                            onPressed: _reset,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Icon(Icons.refresh_rounded,
                                color: ts, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Result ────────────────────────────────────────────
              if (_result != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card, borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: _cutOffColor(_result!).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('Your Cut Off',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w600, color: ts)),
                      const SizedBox(height: 8),
                      Text(_result!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: _cutOffColor(_result!),
                            letterSpacing: -1,
                          )),
                      const SizedBox(height: 4),
                      Text('out of 200',
                          style: TextStyle(fontSize: 12, color: ts)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _cutOffColor(_result!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_cutOffRemark(_result!),
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: _cutOffColor(_result!),
                            )),
                      ),
                      const SizedBox(height: 16),

                      // Breakdown
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _BreakdownRow(
                              label: 'Maths',
                              value: double.parse(_mathsCtrl.text)
                                  .toStringAsFixed(2),
                              color: const Color(0xFF2563EB),
                              ts: ts,
                            ),
                            const SizedBox(height: 6),
                            _BreakdownRow(
                              label: 'Physics',
                              value: double.parse(_physicsCtrl.text)
                                  .toStringAsFixed(2),
                              color: const Color(0xFF7C3AED),
                              ts: ts,
                            ),
                            const SizedBox(height: 6),
                            _BreakdownRow(
                              label: 'Chemistry',
                              value: double.parse(_chemCtrl.text)
                                  .toStringAsFixed(2),
                              color: const Color(0xFF059669),
                              ts: ts,
                            ),
                            const SizedBox(height: 6),
                            _BreakdownRow(
                              label: 'Sum',
                              value: _result!.toStringAsFixed(2),
                              color: ts,
                              ts: ts,
                            ),
                            Divider(color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                                height: 16),
                            _BreakdownRow(
                              label: 'Total Cut Off',
                              value: _result!.toStringAsFixed(2),
                              color: _cutOffColor(_result!),
                              ts: ts,
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Subject Input Field ──────────────────────────────────────────────────────
class _SubjectField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final TextEditingController controller;
  final String? error;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _SubjectField({
    required this.label,
    required this.icon,
    required this.color,
    required this.controller,
    required this.error,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final fill = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final ts = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final tp = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: tp)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: tp,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter marks out of 200',
            hintStyle: TextStyle(color: ts, fontSize: 13),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null
                  ? Colors.red.shade400 : border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null
                  ? Colors.red.shade400 : border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null
                  ? Colors.red.shade400 : color, width: 1.5),
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final Color ts;
  final bool bold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
    required this.ts,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize: 12, color: ts,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              )),
        ),
        Text(value,
            style: TextStyle(
              fontSize: 13, color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ],
    );
  }
}
