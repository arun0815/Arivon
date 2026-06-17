
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage>
    with SingleTickerProviderStateMixin {

  static const String websiteUrl = 'https://eduhub-tau-rosy.vercel.app';

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    await launchUrl(
      Uri.parse(websiteUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _buy,
              child: const Text('Unlock Premium • ₹299/year'),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: const Color(0xFF111827),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '🔥 New AI Features Added',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, -10 * _controller.value),
                          child: child,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 90,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unlock Arivon Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _section('Pricing'),
                  _priceCard('Monthly', '₹49'),
                  _priceCard('Yearly ⭐ Most Popular', '₹299'),
                  _priceCard('Lifetime', '₹799'),
                  const SizedBox(height: 20),
                  _section('Premium Features'),
                  _feature(Icons.smart_toy, 'AI Study Assistant'),
                  _feature(Icons.calculate, 'GPA Predictor'),
                  _feature(Icons.school, 'Premium Question Bank'),
                  _feature(Icons.work, 'Placement Hub'),
                  _feature(Icons.track_changes, 'Study Streak'),
                  _feature(Icons.cloud_done, 'Cloud Sync'),
                  _feature(Icons.block, 'Ad-Free Experience'),
                  const SizedBox(height: 20),
                  _section('Statistics'),
                  Row(
                    children: const [
                      Expanded(child: _StatCard('50K+', 'Downloads')),
                      SizedBox(width: 10),
                      Expanded(child: _StatCard('10K+', 'Daily Users')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _StatCard('200+', 'Subjects')),
                      SizedBox(width: 10),
                      Expanded(child: _StatCard('100K+', 'PDF Downloads')),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _section(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget _priceCard(String title, String price) => Card(
        child: ListTile(
          title: Text(title),
          trailing: Text(price),
        ),
      );

  Widget _feature(IconData icon, String title) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold,fontSize:22)),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
