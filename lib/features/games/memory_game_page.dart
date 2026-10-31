import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/profile_provider.dart';

// Put this file in a folder next to home/ and profile/,
// e.g. features/games/memory_game_page.dart, so the imports above match.

// ── Data ──────────────────────────────────────────────────────────────────────
const _palette = <Color>[
  Color(0xFF2563EB),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFF0D9488),
  Color(0xFF16A34A),
  Color(0xFFE11D48),
  Color(0xFF0EA5E9),
  Color(0xFFEA580C),
];

class _Deck {
  final String name;
  final IconData icon;
  final List<IconData>? icons; // icon deck
  final List<List<String>>? pairs; // [term, meaning] study deck
  const _Deck(this.name, this.icon, {this.icons, this.pairs});

  bool get isText => pairs != null;
}

const _decks = <_Deck>[
  _Deck('Icons', Icons.extension, icons: [
    Icons.settings,
    Icons.bolt,
    Icons.engineering,
    Icons.science,
    Icons.calculate,
    Icons.memory,
    Icons.rocket_launch,
    Icons.menu_book,
  ]),
  _Deck('Mechanical', Icons.precision_manufacturing, pairs: [
    ['Stress', 'Force / Area'],
    ['Strain', 'ΔL / L'],
    ['Density', 'Mass / Volume'],
    ['Power', 'Work / Time'],
    ['Work', 'Force × Distance'],
    ['Torque', 'Force × Radius'],
    ['Momentum', 'Mass × Velocity'],
    ['Efficiency', 'Output / Input'],
  ]),
  _Deck('Electrical', Icons.electrical_services, pairs: [
    ["Ohm's Law", 'V = I × R'],
    ['Power', 'P = V × I'],
    ['Frequency', 'f = 1 / T'],
    ['Capacitance', 'C = Q / V'],
    ['Unit of resistance', 'Ohm (Ω)'],
    ['Unit of inductance', 'Henry (H)'],
    ['Unit of capacitance', 'Farad (F)'],
    ['Unit of frequency', 'Hertz (Hz)'],
  ]),
  _Deck('Computer', Icons.computer, pairs: [
    ['RAM', 'Temporary memory'],
    ['ROM', 'Permanent memory'],
    ['OS', 'Manages hardware'],
    ['IP address', 'Network address'],
    ['SQL', 'Database language'],
    ['HTML', 'Web page structure'],
    ['Compiler', 'Translates whole code'],
    ['Stack', 'LIFO structure'],
  ]),
];

class _GameCard {
  final int pairId;
  final Color color;
  final IconData? icon;
  final String? text;
  final bool isTerm;
  bool faceUp = false;
  bool matched = false;
  _GameCard(this.pairId, this.color,
      {this.icon, this.text, this.isTerm = false});
}

// ── Page ──────────────────────────────────────────────────────────────────────
class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const _soundKey = 'memory_game_sound';
  static const _deckKey = 'memory_game_deck';

  // Deck 0 keeps the original key so old best scores are not lost
  String _bestKeyFor(int deck) =>
      deck == 0 ? 'memory_game_best_moves' : 'memory_game_best_$deck';

  int _deckIndex = 0;
  late List<_GameCard> _cards;
  int? _first;
  bool _busy = false;
  int _moves = 0;
  int _matches = 0;
  int _seconds = 0;
  int? _best;
  bool _sound = true;
  Timer? _timer;

  _Deck get _deck => _decks[_deckIndex];

  @override
  void initState() {
    super.initState();
    _newGame();
    _loadPrefs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Prefs ───────────────────────────────────────────────────────────────────
  int _deckForDepartment(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('mech')) return 1;
    if (d.contains('electr') || RegExp(r'\b(eee|ece|eie)\b').hasMatch(d)) {
      return 2;
    }
    if (d.contains('comput') ||
        d.contains('informat') ||
        RegExp(r'\b(cse|it|ai|ads)\b').hasMatch(d)) {
      return 3;
    }
    return 0;
  }

  Future<void> _loadPrefs() async {
    final dept = context.read<ProfileProvider>().profile?.department ?? '';
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedDeck = prefs.getInt(_deckKey);
    final deck = (savedDeck != null && savedDeck >= 0 && savedDeck < _decks.length)
        ? savedDeck
        : _deckForDepartment(dept);

    setState(() {
      _sound = prefs.getBool(_soundKey) ?? true;
      _best = prefs.getInt(_bestKeyFor(deck));
    });
    if (deck != _deckIndex) {
      _deckIndex = deck;
      _newGame();
    }
  }

  Future<void> _selectDeck(int i) async {
    if (i == _deckIndex) return;
    _deckIndex = i;
    _newGame();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_deckKey, i);
    if (!mounted) return;
    setState(() => _best = prefs.getInt(_bestKeyFor(i)));
  }

  Future<void> _toggleSound() async {
    setState(() => _sound = !_sound);
    if (_sound) HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, _sound);
  }

  // ── Sound & haptics ─────────────────────────────────────────────────────────
  void _tick() {
    if (!_sound) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void _goodMatch() {
    if (!_sound) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void _badMatch() {
    if (!_sound) return;
    HapticFeedback.heavyImpact();
  }

  void _winBuzz() {
    if (!_sound) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 180), () {
      HapticFeedback.heavyImpact();
    });
  }

  // ── Game logic ──────────────────────────────────────────────────────────────
  void _newGame() {
    _timer?.cancel();
    _timer = null;

    final deck = _deck;
    final cards = <_GameCard>[];
    final count = deck.isText ? deck.pairs!.length : deck.icons!.length;

    for (var i = 0; i < count; i++) {
      final color = _palette[i % _palette.length];
      if (deck.isText) {
        cards.add(_GameCard(i, color, text: deck.pairs![i][0], isTerm: true));
        cards.add(_GameCard(i, color, text: deck.pairs![i][1]));
      } else {
        cards.add(_GameCard(i, color, icon: deck.icons![i]));
        cards.add(_GameCard(i, color, icon: deck.icons![i]));
      }
    }
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
    _tick();
    setState(() => card.faceUp = true);

    if (_first == null) {
      _first = i;
      return;
    }

    final a = _cards[_first!];
    final b = card;
    setState(() => _moves++);

    if (a.pairId == b.pairId) {
      _goodMatch();
      setState(() {
        a.matched = true;
        b.matched = true;
        _matches++;
      });
      _first = null;
      if (_matches == _cards.length ~/ 2) _onWin();
    } else {
      _badMatch();
      _busy = true;
      final firstIndex = _first!;
      _first = null;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[firstIndex].faceUp = false;
          _cards[i].faceUp = false;
          _busy = false;
        });
      });
    }
  }

  int get _stars => _moves <= 12 ? 3 : (_moves <= 18 ? 2 : 1);

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _onWin() async {
    _timer?.cancel();
    _timer = null;
    _winBuzz();

    final prefs = await SharedPreferences.getInstance();
    final key = _bestKeyFor(_deckIndex);
    final isBest = _best == null || _moves < _best!;
    if (isBest) {
      await prefs.setInt(key, _moves);
      _best = _moves;
    }
    if (!mounted) return;
    setState(() {});
    _showWinDialog(isBest);
  }

  // ── Sharing ─────────────────────────────────────────────────────────────────
  String _shareMessage(int moves, int seconds, int stars) {
    final starText = List.filled(stars, '⭐').join();
    return '🧠 I solved Memory Match (${_deck.name}) in $moves moves '
        'and ${_fmt(seconds)} $starText on Arivon! Can you beat me? '
        '👉 https://myarivon.in';
  }

  Future<void> _shareImage(
      BuildContext ctx, GlobalKey key, String message) async {
    try {
      final box = ctx.findRenderObject() as RenderBox?;
      final origin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final bytes = data.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          text: message,
          files: [XFile.fromData(bytes, mimeType: 'image/png')],
          fileNameOverrides: ['arivon_memory_score.png'],
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share the image')),
      );
    }
  }

  Future<void> _shareWhatsApp(String message) async {
    final uri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    // Fallback: normal share sheet (WhatsApp is listed there too)
    await SharePlus.instance.share(ShareParams(text: message));
  }

  void _showWinDialog(bool isBest) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final moves = _moves;
    final seconds = _seconds;
    final stars = _stars;
    final deckName = _deck.name;
    final message = _shareMessage(moves, seconds, stars);
    final boundaryKey = GlobalKey();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E293B) : AppColors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // This card is what gets shared as an image
                RepaintBoundary(
                  key: boundaryKey,
                  child: _ScoreCard(
                    deckName: deckName,
                    moves: moves,
                    time: _fmt(seconds),
                    stars: stars,
                    isBest: isBest,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ShareButton(
                      icon: Icons.image_outlined,
                      label: 'Share image',
                      color: AppColors.primary,
                      onTap: () => _shareImage(ctx, boundaryKey, message),
                    ),
                    const SizedBox(width: 10),
                    _ShareButton(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _shareWhatsApp(message),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────
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
                    SizedBox(
                      width: 84,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _HeaderIcon(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Memory Match',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3)),
                      ),
                    ),
                    SizedBox(
                      width: 84,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _HeaderIcon(
                            icon: _sound
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            size: 20,
                            onTap: _toggleSound,
                          ),
                          const SizedBox(width: 8),
                          _HeaderIcon(
                            icon: Icons.refresh_rounded,
                            size: 20,
                            onTap: _newGame,
                          ),
                        ],
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

          // Deck chips
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: _decks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _DeckChip(
                deck: _decks[i],
                selected: i == _deckIndex,
                dark: dark,
                onTap: () => _selectDeck(i),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: _deck.isText ? 0.85 : 1,
                ),
                itemBuilder: (_, i) => _FlipCard(
                  card: _cards[i],
                  dark: dark,
                  onTap: () => _onTap(i),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 14, top: 4),
            child: Text(
              _deck.isText
                  ? 'Match each term with its meaning'
                  : 'Find all 8 pairs in the fewest moves',
              style: TextStyle(
                  fontSize: 12,
                  color: dark ? const Color(0xFF64748B) : AppColors.textTert),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  const _HeaderIcon(
      {required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: size),
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

class _DeckChip extends StatelessWidget {
  final _Deck deck;
  final bool selected, dark;
  final VoidCallback onTap;
  const _DeckChip({
    required this.deck,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Colors.white
        : (dark ? Colors.white70 : AppColors.text);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (dark ? const Color(0xFF1E293B) : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (dark ? const Color(0xFF334155) : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Icon(deck.icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(deck.name,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score card (shown in the win dialog and shared as an image) ───────────────
class _ScoreCard extends StatelessWidget {
  final String deckName, time;
  final int moves, stars;
  final bool isBest;
  const _ScoreCard({
    required this.deckName,
    required this.time,
    required this.moves,
    required this.stars,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF0A84FF)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Memory Match',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('$deckName deck',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              ),
              if (isBest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('NEW BEST',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  Icons.star_rounded,
                  size: 40,
                  color: i < stars
                      ? const Color(0xFFFBBF24)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScoreStat(label: 'MOVES', value: '$moves'),
              const SizedBox(width: 10),
              _ScoreStat(label: 'TIME', value: time),
            ],
          ),
          const SizedBox(height: 14),
          Text('Can you beat me? Play on Arivon · myarivon.in',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label, value;
  const _ScoreStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── Flip card ─────────────────────────────────────────────────────────────────
class _FlipCard extends StatelessWidget {
  final _GameCard card;
  final bool dark;
  final VoidCallback onTap;
  const _FlipCard(
      {required this.card, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final up = card.faceUp || card.matched;
    final surface = dark ? const Color(0xFF1E293B) : AppColors.white;
    final isMeaning = card.text != null && !card.isTerm;

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

    Color frontBg;
    if (card.matched) {
      frontBg = Color.alphaBlend(
          card.color.withOpacity(dark ? 0.25 : 0.15), surface);
    } else if (isMeaning) {
      frontBg = Color.alphaBlend(
          card.color.withOpacity(dark ? 0.12 : 0.07), surface);
    } else {
      frontBg = surface;
    }

    final Widget face = card.icon != null
        ? Icon(card.icon, color: card.color, size: 30)
        : Padding(
            padding: const EdgeInsets.all(5),
            child: Center(
              child: Text(
                card.text!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: card.isTerm ? 11.5 : 10.5,
                  fontWeight: card.isTerm ? FontWeight.w800 : FontWeight.w600,
                  height: 1.15,
                  color: card.isTerm
                      ? card.color
                      : (dark ? Colors.white : AppColors.text),
                ),
              ),
            ),
          );

    final front = Container(
      decoration: BoxDecoration(
        color: frontBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.matched
              ? card.color
              : (dark ? const Color(0xFF334155) : AppColors.border),
          width: card.matched ? 2 : 1,
        ),
      ),
      child: Center(child: face),
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
