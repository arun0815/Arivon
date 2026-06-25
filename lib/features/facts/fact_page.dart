import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FactPage extends StatefulWidget {
  const FactPage({super.key});
  @override
  State<FactPage> createState() => _FactPageState();
}

class _FactPageState extends State<FactPage> {
  static const String _factsUrl =
      'https://raw.githubusercontent.com/arun0815/Arivon/refs/heads/main/assets/data/facts.json';

  // ── Built-in fallback ────────────────────────────────────────────────
  // Used only when the remote fetch fails AND there's no cached fact yet
  // (e.g. first launch with no internet). Keeps the page from ever
  // showing a blank error state on a fresh install.
  static const List<String> _fallbackFacts = [
    'Honey never spoils — archaeologists have found 3,000-year-old honey in Egyptian tombs that was still edible.',
    'A bolt of lightning is roughly five times hotter than the surface of the sun.',
    'Octopuses have three hearts and blue blood.',
    'Bananas are botanically classified as berries, but strawberries are not.',
    'The Eiffel Tower grows about 6 inches taller in summer due to thermal expansion of the metal.',
    'A group of flamingos is called a "flamboyance".',
    'There are more stars in the universe than grains of sand on every beach on Earth.',
    'Sharks existed before trees — sharks are around 400 million years old, trees about 350 million.',
  ];

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

    try {
      // ── Fetch the JSON over the network (NOT rootBundle — that's only
      // for assets bundled into the app, not remote URLs) ───────────────
      final response = await http
          .get(Uri.parse(_factsUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load facts (${response.statusCode})');
      }

      final data = json.decode(response.body);
      final List<dynamic> facts = data['facts'];

      if (facts.isEmpty) throw Exception('Facts list is empty');

      final randomFact = facts[Random().nextInt(facts.length)] as String;

      await prefs.setString('fact_date', today);
      await prefs.setString('fact_text', randomFact);

      setState(() {
        _fact = randomFact;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Fact load error: $e');

      // Prefer yesterday's cached fact if we have one. Otherwise fall
      // back to the built-in list so the page never shows a blank error
      // state on a fresh install with no internet.
      setState(() {
        _fact = savedFact ??
            _fallbackFacts[Random().nextInt(_fallbackFacts.length)];
        _loading = false;
      });
    }
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
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
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
