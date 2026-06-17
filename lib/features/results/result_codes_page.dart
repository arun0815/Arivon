import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ResultCodesPage extends StatefulWidget {
  const ResultCodesPage({super.key});

  @override
  State<ResultCodesPage> createState() => _ResultCodesPageState();
}

class _ResultCodesPageState extends State<ResultCodesPage> {
  String search = '';
  String selectedCategory = 'All';

  final List<ResultCode> codes = [
    ResultCode('WH99', 'Results will be published later', 'WH'),
    ResultCode('WH10', 'In Process', 'WH'),
    ResultCode('WHR', 'Re Examination', 'WH'),
    ResultCode('WH1', 'Suspected Malpractice', 'WH'),
    ResultCode('WH13', 'Exam Fee Not Paid', 'WH'),
    ResultCode('WHE', 'Practical Mark Withheld', 'WH'),

    ResultCode('AB', 'Absent', 'General'),
    ResultCode('WD', 'Withdrawal', 'General'),
    ResultCode('SA', 'Shortage of Attendance', 'General'),
    ResultCode('RA', 'Re Appearance', 'General'),
    ResultCode('NR', 'Not Registered', 'General'),
    ResultCode('UA', 'Unauthorized Absence', 'General'),
    ResultCode('BK', 'Break', 'General'),
    ResultCode('DIS', 'Discontinued', 'General'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = codes.where((item) {
      final matchesSearch =
          item.code.toLowerCase().contains(search.toLowerCase()) ||
          item.description.toLowerCase().contains(search.toLowerCase());

      final matchesCategory =
          selectedCategory == 'All' ||
          item.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Result Codes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search code or meaning...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 42,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('All'),
                  _chip('WH'),
                  _chip('General'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final item = filtered[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 72,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: item.category == 'WH'
                                ? Colors.orange
                                    .withOpacity(0.15)
                                : Colors.green
                                    .withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.code,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  item.category == 'WH'
                                      ? Colors.orange
                                      : Colors.green,
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
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textSec,
                                ),
                              ),
                            ],
                          ),
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

  Widget _chip(String label) {
    final selected = selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedCategory = label;
          });
        },
      ),
    );
  }
}

class ResultCode {
  final String code;
  final String description;
  final String category;

  ResultCode(
    this.code,
    this.description,
    this.category,
  );
}
