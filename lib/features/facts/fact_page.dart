import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FactPage extends StatefulWidget {
  const FactPage({super.key});

  @override
  State<FactPage> createState() => _FactPageState();
}

class _FactPageState extends State<FactPage> {
  String? _fact;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyFact();
  }

  Future<void> _loadDailyFact() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // 'YYYY-MM-DD'
    final savedDate = prefs.getString('fact_date');
    final savedFact = prefs.getString('fact_text');

    if (savedDate == today && savedFact != null) {
      setState(() {
        _fact = savedFact;
        _loading = false;
      });
      return;
    }

    // Load JSON and pick a new random fact
    final jsonStr = await rootBundle.loadString('../../../assets/data/facts.json');
    final data = json.decode(jsonStr);
    final List<dynamic> facts = data['facts'];
    final randomFact = facts[Random().nextInt(facts.length)] as String;

    await prefs.setString('fact_date', today);
    await prefs.setString('fact_text', randomFact);

    setState(() {
      _fact = randomFact;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        title: Text(
          'Did You Know?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const CircularProgressIndicator()
              : Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 50,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _fact!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
