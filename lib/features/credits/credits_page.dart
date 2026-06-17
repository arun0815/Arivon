import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Color _badgeColor(String dept) {
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

  Color _badgeTextColor(String dept) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF7F8FA),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Credits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText:
                            'Search subject code or name...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
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
                        final selected =
                            dept == _selectedDept;

                        return ChoiceChip(
                          label: Text(dept),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedDept = dept;
                            });
                          },
                          selectedColor:
                              const Color(0xFFD9D9FB),
                          backgroundColor: Colors.white,
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
                      child:
                          CircularProgressIndicator(),
                    )
                  : _filtered.isEmpty
                      ? const Center(
                          child:
                              Text('No subjects found'),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            16,
                          ),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(
                            height: 12,
                          ),
                          itemBuilder:
                              (context, index) {
                            final subject =
                                _filtered[index];

                            return Container(
                              padding:
                                  const EdgeInsets.all(
                                      16),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          14,
                                      vertical:
                                          10,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          _badgeColor(
                                        subject
                                            .department,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                    child: Text(
                                      subject.code,
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                        color:
                                            _badgeTextColor(
                                          subject
                                              .department,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            fontSize:
                                                16,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                4),
                                        Text(
                                          subject
                                              .department,
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        _formatCredit(
                                          subject
                                              .credit,
                                        ),
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              20,
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                        ),
                                      ),
                                      const Text(
                                        'Credits',
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
