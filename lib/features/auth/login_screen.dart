import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ← ADD
import '../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/profile_provider.dart';
import 'terms_page.dart';
import 'privacy_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── FCM token helper ──────────────────────────────────────────────────────
  Future<String?> _getFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (important for iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        return await messaging.getToken();
      }
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
    return null; // non-fatal — login still proceeds
  }
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }

      // ── Fetch FCM token alongside Google sign-in ──────────────────────
      final fcmToken = await _getFcmToken();
      // ─────────────────────────────────────────────────────────────────

      final response = await http.post(
        Uri.parse('https://eduhub-tau-rosy.vercel.app/api/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'username': account.displayName,
          'profileimg': account.photoUrl,
          // ── Send FCM token to backend ─────────────────────────────────
          if (fcmToken != null) 'fcmToken': fcmToken,
          'device': _getDevicePlatform(),
          // ─────────────────────────────────────────────────────────────
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', account.email);
        await prefs.setString('user_name', account.displayName ?? '');
        await prefs.setString('user_photo', account.photoUrl ?? '');
        // ── Cache FCM token locally for refresh checks later ──────────
        if (fcmToken != null) {
          await prefs.setString('fcm_token', fcmToken);
        }
        // ─────────────────────────────────────────────────────────────

        if (context.mounted) {
          await context.read<ProfileProvider>().loadProfile();
          context.go(data['isNewUser'] == true ? '/onboarding' : '/home');
        }
      } else {
        _showError('Sign in failed. Please try again.');
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Detect platform for device field ─────────────────────────────────────
  String _getDevicePlatform() {
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'ios';
    if (Theme.of(context).platform == TargetPlatform.android) return 'android';
    return 'web';
  }
  // ─────────────────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── build() is unchanged ──────────────────────────────────────────────────
  @override
 Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

return Scaffold(
  backgroundColor:
      isDark ? const Color(0xFF0F172A) : AppColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // ── Top illustration ──────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: AppColors.primaryMid, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.14),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                           padding: const EdgeInsets.all(12),
                           child: Image.asset(
                             'assets/logo/app_icon.png',
                              fit: BoxFit.contain,
                           ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Headline — clean, short
                         Text(
                           'Arivon',
                            style: TextStyle(
                            color: isDark ? Colors.white : AppColors.text,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                         'Your campus, one tap away.',
                         style: TextStyle(
                         color: isDark
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSec,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom section ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        // ── Google Sign-In Button (official style) ──────
                        _GoogleSignInButton(
                          isLoading: _isLoading,
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                        ),
                        const SizedBox(height: 20),

                        // ── Terms & Privacy ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(
                              'By continuing, you agree to our ',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                 ? const Color(0xFF94A3B8)
                                 : AppColors.textTert
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TermsPage()),
                              ),
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Text(
                              ' & ',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textTert),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PrivacyPage()),
                              ),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Official Google Sign-In Button ────────────────────────────────────────────
// Follows Google's branding guidelines exactly.

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4), // Google uses 4px radius
          border: Border.all(color: const Color(0xFFDADCE0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Google G SVG rendered as a custom painter
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleGPainter()),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3C4043), // Google's exact label color
                      letterSpacing: 0.25,
                      fontFamily: 'Roboto', // Google uses Roboto
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Google G Logo Painter ─────────────────────────────────────────────────────
// Accurate Google "G" logo with official brand colors.

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()..style = PaintingStyle.fill;

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, w, h)));

    // White background
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    final rect = Rect.fromLTWH(0, 0, w, h);
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue segment (right top)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.52, 1.57, true, paint);

    // Red segment (left top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.09, 1.57, true, paint);

    // Yellow segment (left bottom)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.62, 1.05, true, paint);

    // Green segment (right bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.05, 1.57, true, paint);

    // White center circle (donut hole)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, paint);

    // Blue right bar of the G
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.38, w * 0.5, h * 0.24),
      paint,
    );

    // White cutout (inner donut hole restore)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
