import 'dart:math';
import 'package:flutter/material.dart';

class BirthdayOverlay extends StatefulWidget {
  final Widget child;
  final bool isBirthday;

  const BirthdayOverlay({
    super.key,
    required this.child,
    required this.isBirthday,
  });

  @override
  State<BirthdayOverlay> createState() => _BirthdayOverlayState();
}

class _BirthdayOverlayState extends State<BirthdayOverlay>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _bannerController;
  late Animation<double> _bannerAnim;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random();
  bool _showBanner = true;

  final _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.blue,
    Colors.cyan, Colors.green, Colors.yellow, Colors.orange,
    const Color(0xFF6C63FF),
  ];

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bannerAnim = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutBack,
    );

    if (widget.isBirthday) {
      _generateConfetti();
      _confettiController.forward();
      _bannerController.forward();

      // Auto hide banner after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _bannerController.reverse().then((_) {
            if (mounted) setState(() => _showBanner = false);
          });
        }
      });
    }
  }

  void _generateConfetti() {
    for (int i = 0; i < 80; i++) {
      _pieces.add(_ConfettiPiece(
        x: _random.nextDouble(),
        delay: _random.nextDouble() * 2.0,
        color: _colors[_random.nextInt(_colors.length)],
        size: _random.nextDouble() * 8 + 5,
        rotation: _random.nextDouble() * 2 * pi,
        speed: _random.nextDouble() * 0.4 + 0.3,
        isCircle: _random.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBirthday) return widget.child;

    return Stack(
      children: [
        widget.child,

        // Confetti layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, _) {
            return IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  pieces: _pieces,
                  progress: _confettiController.value,
                ),
                size: Size.infinite,
              ),
            );
          },
        ),

        // Birthday banner
        if (_showBanner)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: ScaleTransition(
              scale: _bannerAnim,
              child: GestureDetector(
                onTap: () {
                  _bannerController.reverse().then((_) {
                    if (mounted) setState(() => _showBanner = false);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFEC4899)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🎂', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Happy Birthday! 🎉',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Wishing you an amazing day ahead!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Confetti data ─────────────────────────────────────────────────────────────
class _ConfettiPiece {
  final double x;
  final double delay;
  final Color color;
  final double size;
  final double rotation;
  final double speed;
  final bool isCircle;

  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.isCircle,
  });
}

// ── Confetti painter ──────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final t = ((progress - piece.delay * 0.3) / piece.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = piece.x * size.width + sin(t * pi * 2) * 30;
      final y = -20 + t * (size.height + 40);
      final opacity = t < 0.8 ? 1.0 : (1.0 - t) / 0.2;

      final paint = Paint()
        ..color = piece.color.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + t * pi * 3);

      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: piece.size,
              height: piece.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
