import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../firebase_options.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await NotificationService.initialize();

      if (mounted) {
        await context.read<ThemeProvider>().load();
      }
    } catch (e) {
      debugPrint('Init error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;
    final route = await AppRouter.getInitialRoute();
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1E),
      body: Center(
        child: Image.asset(
          'assets/logo/app_icon.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
