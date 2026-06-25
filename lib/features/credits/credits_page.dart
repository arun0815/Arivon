import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';

class Subject {
  final String code;
  final String name;
  final String department;
  final double credit;

  Subject({
    required this.code,
    required this.name,
    required this.department,
    required this.credit,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      code: json['subject_code'] ?? '',
      name: json['subject_name'] ?? '',
      department: json['department'] ?? '',
      credit: (json['credits'] as num).toDouble(),
    );
  }
}

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  String _selectedDept = 'All';
  String _query = '';

  final List<String> _departments = [
    'All',
    'Mech',
    'ECE',
    'CSE',
    'Civil',
    'EEE',
  ];

  List<Subject> _subjects = [];
  bool _isLoading = true;

  // ── Data source ────────────────────────────────────────────────────────
  // Currently pointed at a Google Drive hosted JSON file. Swap this for your
  // own endpoint once the dataset is finalized — the shape expected per
  // subject is:
  // {
  //   "subject_code": "CS101",
  //   "subject_name": "Programming Fundamentals",
  //   "department": "CSE",
  //   "credits": 4
  // }
  static const String apiUrl =
      'https://drive.google.com/uc?export=download&id=1jGVCHnOvN8_PncQjXSg4VDIv9ctBi5OL';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _subjects =
              data.map((e) => Subject.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      debugPrint('Error: $e');

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Subject> get _filtered {
    return _subjects.where((s) {
      final matchesDept =
          _selectedDept == 'All' || s.department == _selectedDept;

      final q = _query.toLowerCase();

      final matchesQuery =
          q.isEmpty ||
          s.code.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q);

      return matchesDept && matchesQuery;
    }).toList();
  }

  // ── Department badge colors (light / dark aware) ────────────────────────
  Color _badgeColor(String dept, bool isDark) {
    if (isDark) {
      switch (dept) {
        case 'CSE':
        case 'ECE':
          return const Color(0xFF3A2E1A);
        case 'Mech':
          return const Color(0xFF1E2A40);
        case 'Civil':
          return const Color(0xFF1B3326);
        case 'EEE':
          return const Color(0xFF3A1E30);
        default:
          return const Color(0xFF1E293B);
      }
    }
    switch (dept) {
      case 'CSE':
        return const Color(0xFFFFE3CC);
      case 'ECE':
        return const Color(0xFFFFE9CC);
      case 'Mech':
        return const Color(0xFFD9E8FF);
      case 'Civil':
        return const Color(0xFFE6F4EA);
      case 'EEE':
        return const Color(0xFFFCE4F0);
      default:
        return const Color(0xFFEFEFEF);
    }
  }

  Color _badgeTextColor(String dept, bool isDark) {
    if (isDark) {
      switch (dept) {
        case 'CSE':
        case 'ECE':
          return const Color(0xFFF5A949);
        case 'Mech':
          return const Color(0xFF6FA3FF);
        case 'Civil':
          return const Color(0xFF5FD08C);
        case 'EEE':
          return const Color(0xFFF06FB8);
        default:
          return const Color(0xFF94A3B8);
      }
    }
    switch (dept) {
      case 'CSE':
      case 'ECE':
        return const Color(0xFFE08A2C);
      case 'Mech':
        return const Color(0xFF2C6FE0);
      case 'Civil':
        return const Color(0xFF2E9E5B);
      case 'EEE':
        return const Color(0xFFD13E8C);
      default:
        return Colors.black87;
    }
  }

  String _formatCredit(double credit) {
    return credit % 1 == 0
        ? credit.toInt().toString()
        : credit.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8FA);
    final card   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tp     = isDark ? Colors.white : const Color(0xFF0F172A);
    final ts     = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final border = isDark ? const Color(0xFF334155) : Colors.grey.shade300;
    final chipBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final chipSelected =
        isDark ? const Color(0xFF3730A3) : const Color(0xFFD9D9FB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: bg,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: tp,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Credits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: tp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      style: TextStyle(color: tp),
                      decoration: InputDecoration(
                        hintText: 'Search subject code or name...',
                        hintStyle: TextStyle(color: ts),
                        prefixIcon: Icon(Icons.search, color: ts),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _departments.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        final selected = dept == _selectedDept;

                        return ChoiceChip(
                          label: Text(
                            dept,
                            style: TextStyle(
                              color: selected
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : tp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedDept = dept;
                            });
                          },
                          selectedColor: chipSelected,
                          backgroundColor: chipBg,
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : border,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No subjects found',
                            style: TextStyle(color: ts),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final subject = _filtered[index];

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _badgeColor(
                                          subject.department, isDark),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      subject.code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _badgeTextColor(
                                            subject.department, isDark),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: tp,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          subject.department,
                                          style: TextStyle(color: ts),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        _formatCredit(subject.credit),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: tp,
                                        ),
                                      ),
                                      Text(
                                        'Credits',
                                        style: TextStyle(color: ts),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
