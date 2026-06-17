import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PercentagePage extends StatefulWidget {
  const PercentagePage({super.key});

  @override
  State<PercentagePage> createState() => _PercentagePageState();
}

class _PercentagePageState extends State<PercentagePage> {
  final _cgpaCtrl = TextEditingController();

  // 0 = Anna Univ formula, 1 = Simple formula
  int _formulaIndex = 0;
  double? _result;
  String? _error;

  static const _formulas = [
    _Formula(
      label: 'Anna Univ Formula',
      desc: '(CGPA − 0.75) × 10',
      hint: 'Used for official transcripts & job applications',
    ),
    _Formula(
      label: 'Simple Formula',
      desc: 'CGPA × 10',
      hint: 'General reference — not the official AU formula',
    ),
  ];

  @override
  void dispose() {
    _cgpaCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final raw = _cgpaCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() { _error = 'Enter your CGPA'; _result = null; });
      return;
    }
    final val = double.tryParse(raw);
    if (val == null || val < 0 || val > 10) {
      setState(() { _error = 'CGPA must be between 0 and 10'; _result = null; });
      return;
    }
    final pct = _formulaIndex == 0 ? (val - 0.75) * 10 : val * 10;
    setState(() { _error = null; _result = pct.clamp(0, 100); });
  }

  void _reset() {
    _cgpaCtrl.clear();
    setState(() { _result = null; _error = null; });
  }

  Color _resultColor(double pct) {
    if (pct >= 75) return const Color(0xFF16A34A);
    if (pct >= 60) return const Color(0xFF2563EB);
    if (pct >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _grade(double pct) {
    if (pct >= 75) return 'First Class with Distinction';
    if (pct >= 60) return 'First Class';
    if (pct >= 50) return 'Second Class';
    return 'Pass Class';
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
                      Text('Percentage', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: tp)),
                      Text('CGPA → Percentage converter',
                          style: TextStyle(fontSize: 12, color: ts)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Formula Selector ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card, borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose Formula',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: tp)),
                    const SizedBox(height: 12),
                    ...List.generate(_formulas.length, (i) {
                      final f = _formulas[i];
                      final selected = _formulaIndex == i;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _formulaIndex = i;
                          _result = null;
                        }),
                        child: Container(
                          margin: EdgeInsets.only(bottom: i == 0 ? 8 : 0),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2563EB).withOpacity(0.08)
                                : isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF2563EB)
                                  : border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18, height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF2563EB)
                                        : border,
                                    width: 2,
                                  ),
                                  color: selected
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                ),
                                child: selected
                                    ? const Icon(Icons.check_rounded,
                                        size: 11, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(f.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? const Color(0xFF2563EB)
                                              : tp,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(f.desc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: selected
                                              ? const Color(0xFF2563EB)
                                              : ts,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(f.hint,
                                        style: TextStyle(
                                            fontSize: 11, color: ts)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    Text('Enter CGPA',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w700, color: tp)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cgpaCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onChanged: (_) => setState(() => _error = null),
                      style: TextStyle(fontSize: 15, color: tp,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. 8.45',
                        hintStyle: TextStyle(color: ts, fontSize: 14),
                        prefixIcon: Icon(Icons.school_outlined,
                            size: 18, color: ts),
                        suffixText: '/ 10',
                        suffixStyle: TextStyle(color: ts, fontSize: 13),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 1.5),
                        ),
                        errorText: _error,
                        errorStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _calculate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Calculate',
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

              // ── Result Card ───────────────────────────────────────
              if (_result != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _resultColor(_result!).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Your Percentage',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w600, color: ts)),
                      const SizedBox(height: 8),
                      Text('${_result!.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: _resultColor(_result!),
                            letterSpacing: -1,
                          )),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _resultColor(_result!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_grade(_result!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _resultColor(_result!),
                            )),
                      ),
                      const SizedBox(height: 16),
                      // Formula used
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formulaIndex == 0
                              ? '(${_cgpaCtrl.text} − 0.75) × 10 = ${_result!.toStringAsFixed(2)}%'
                              : '${_cgpaCtrl.text} × 10 = ${_result!.toStringAsFixed(2)}%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: ts,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ── Info note ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF2563EB).withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anna University officially uses (CGPA − 0.75) × 10 '
                        'for percentage calculation in transcripts and job applications.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1D4ED8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Formula {
  final String label, desc, hint;
  const _Formula({required this.label, required this.desc, required this.hint});
}
