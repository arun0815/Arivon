import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SyllabusPage extends StatelessWidget {
  const SyllabusPage({super.key});

 
  static const List<Map<String, dynamic>> departments = [
    {
      'name': 'Mechanical Engineering',
      'short': 'MECH',
      'icon': Icons.settings,
      'color': Color(0xFF1565C0),
      'pdfUrl': 'https://cac.annauniv.edu/aidetails/afug_2025_fu/Mech/B.E.%20Mechanical%20Engineering.pdf',
    },
    {
      'name': 'Electronics & Communication',
      'short': 'ECE',
      'icon': Icons.electrical_services,
      'color': Color(0xFF6A1B9A),
      'pdfUrl': 'https://cac.annauniv.edu/aidetails/afug_2025_fu/ECE/B.E%20ECE.pdf',
    },
    {
      'name': 'Computer Science',
      'short': 'CSE',
      'icon': Icons.computer,
      'color': Color(0xFF00695C),
      'pdfUrl': 'https://cac.annauniv.edu/aidetails/afug_2025_fu/CSIE/BE%20CSE.pdf',
    },
    {
      'name': 'Civil Engineering',
      'short': 'CIVIL',
      'icon': Icons.apartment,
      'color': Color(0xFFE65100),
      'pdfUrl': 'https://cac.annauniv.edu/aidetails/afug_2025_fu/Civil/B.E.%20Civil%20Engineering%20.pdf',
    },
    {
      'name': 'Electrical & Electronics',
      'short': 'EEE',
      'icon': Icons.bolt,
      'color': Color(0xFFC62828),
      'pdfUrl': 'https://cac.annauniv.edu/aidetails/afug_2025_fu/EEE/B.E.%20EEE.pdf',
    },
  ];

  Future<void> _openPdf(BuildContext context, String url, String dept) async {
    final uri = Uri.parse(url);

    // Try to open in native app (PDF viewer / browser)
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Opens in native PDF reader / browser
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $dept syllabus. Check the URL.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Syllabus',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            width: double.infinity,
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              'Anna University Regulation 2021',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Department cards
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dept = departments[index];
                final color = dept['color'] as Color;

                return _DeptCard(
                  name: dept['name'] as String,
                  short: dept['short'] as String,
                  icon: dept['icon'] as IconData,
                  color: color,
                  isDark: isDark,
                  onTap: () => _openPdf(context, dept['pdfUrl'] as String, dept['short'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptCard extends StatelessWidget {
  final String name;
  final String short;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _DeptCard({
    required this.name,
    required this.short,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(color: Colors.white10)
                : null,
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      short,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow + PDF badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
