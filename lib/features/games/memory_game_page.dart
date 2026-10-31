import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class _GameCard {
  final IconData icon;
  final Color color;
  bool faceUp = false;
  bool matched = false;
  _GameCard(this.icon, this.color);
}

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const _bestKey = 'memory_game_best_moves';

  static const _faces = <IconData, Color>{
    Icons.settings: Color(0xFF2563EB),
    Icons.bolt: Color(0xFFF59E0B),
    Icons.engineering: Color(0xFF7C3AED),
    Icons.science: Color(0xFF0D9488),
    Icons.calculate: Color(0xFF16A34A),
    Icons.memory: Color(0xFFE11D48),
    Icons.rocket_launch: Color(0xFF0EA5E9),
    Icons.menu_book: Color(0xFFEA580C),
  };

  late List<_GameCard> _cards;
  int? _first;
  bool _busy = false;
  int _moves = 0;
  int _matches = 0;
  int _seconds = 0;
  int? _best;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _newGame();
    _loadBest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _best = prefs.getInt(_bestKey));
  }

  void _newGame() {
    _timer?.cancel();
    _timer = null;
    final cards = <_GameCard>[];
    _faces.forEach((icon, color) {
      cards.add(_GameCard(icon, color));
      cards.add(_GameCard(icon, color));
    });
    cards.shuffle(Random());
    setState(() {
      _cards = cards;
      _first = null;
      _busy = false;
      _moves = 0;
      _matches = 0;
      _seconds = 0;
    });
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  void _onTap(int i) {
    final card = _cards[i];
    if (_busy || card.faceUp || card.matched) return;

    _startTimer();
    setState(() => card.faceUp = true);

    if (_first == null) {
      _first = i;
      return;
    }

    final a = _cards[_first!];
    final b = card;
    setState(() => _moves++);

    if (a.icon == b.icon) {
      setState(() {
        a.matched = true;
        b.matched = true;
        _matches++;
      });
      _first = null;
      if (_matches == _faces.length) _onWin();
    } else {
      _busy = true;
      final firstIndex = _first!;
      _first = null;
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        setState(() {
          _cards[firstIndex].faceUp = false;
          _cards[i].faceUp = false;
          _busy = false;
        });
      });
    }
  }

  Future<void> _onWin() async {
    _timer?.cancel();
    _timer = null;

    final prefs = await SharedPreferences.getInstance();
    final isBest = _best == null || _moves < _best!;
    if (isBest) {
      await prefs.setInt(_bestKey, _moves);
      _best = _moves;
    }
    if (!mounted) return;
    setState(() {});

    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E293B) : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isBest ? '🏆 New best!' : '🎉 You won!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : AppColors.text)),
        content: Text(
          'Solved in $_moves moves and ${_fmt(_seconds)}.',
          style: TextStyle(
              fontSize: 14,
              color: dark ? const Color(0xFF94A3B8) : AppColors.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _newGame();
            },
            child: const Text('Play again',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0F172A) : AppColors.bg,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, top + 10, 20, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF1E293B), const Color(0xFF1E3A8A)]
                    : [const Color(0xFF1D4ED8), const Color(0xFF0A84FF)],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const Spacer(),
                    const Text('Memory Match',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _newGame,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Stat(label: 'MOVES', value: '$_moves'),
                    const SizedBox(width: 10),
                    _Stat(label: 'TIME', value: _fmt(_seconds)),
                    const SizedBox(width: 10),
                    _Stat(label: 'BEST', value: _best == null ? '—' : '$_best'),
                  ],
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, i) => _FlipCard(
                    card: _cards[i],
                    dark: dark,
                    onTap: () => _onTap(i),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16),
            child: Text('Find all 8 pairs in the fewest moves',
                style: TextStyle(
                    fontSize: 12,
                    color:
                        dark ? const Color(0xFF64748B) : AppColors.textTert)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final _GameCard card;
  final bool dark;
  final VoidCallback onTap;
  const _FlipCard(
      {required this.card, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final up = card.faceUp || card.matched;

    final back = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF0A84FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.help_outline_rounded,
          color: Colors.white.withOpacity(0.55), size: 26),
    );

    final front = Container(
      decoration: BoxDecoration(
        color: card.matched
            ? card.color.withOpacity(dark ? 0.25 : 0.15)
            : (dark ? const Color(0xFF1E293B) : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.matched
              ? card.color
              : (dark ? const Color(0xFF334155) : AppColors.border),
          width: card.matched ? 2 : 1,
        ),
      ),
      child: Icon(card.icon, color: card.color, size: 30),
    );

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: up ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (_, v, __) {
          final showFront = v > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(v * pi),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: front,
                  )
                : back,
          );
        },
      ),
    );
  }
}
