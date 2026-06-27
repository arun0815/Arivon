import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';
import '../services/notification_service.dart';
import '../../features/notifications/notifications_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    navigatorKey: NotificationService.navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final location = state.matchedLocation;

      // Always let splash through — it handles its own navigation
      if (location == '/splash') return null;

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final profileDone = prefs.getBool('profile_done') ?? false;

      // Not logged in → login
      if (!isLoggedIn) return '/login';

      // Logged in + profile done → skip login & onboarding
      if (isLoggedIn && profileDone) {
        if (location == '/login' || location == '/onboarding') return '/home';
        return null;
      }

      // Logged in + profile not done → stay on onboarding
      if (!profileDone && location == '/onboarding') return null;

      // Logged in + profile not done → go to onboarding
      if (!profileDone) return '/onboarding';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => NotificationsPage(),
      ),
    ],
  );

  static Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final profileDone = prefs.getBool('profile_done') ?? false;

    if (!isLoggedIn) return '/login';
    if (!profileDone) return '/onboarding';
    return '/home';
  }
}
