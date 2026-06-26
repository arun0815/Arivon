import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';
import '../services/notification_service.dart';
// NOTE: adjust this import path to match where notifications_page.dart
// actually lives in your project (based on the relative imports inside
// that file, it looked like lib/features/notifications/pages/).
import '../../features/notifications/pages/notifications_page.dart';

class AppRouter {
  AppRouter._();
  static final router = GoRouter(
    navigatorKey: NotificationService.navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final prefs       = await SharedPreferences.getInstance();
      final isLoggedIn  = prefs.getBool('is_logged_in')  ?? false;
      final profileDone = prefs.getBool('profile_done')  ?? false;
      final location    = state.matchedLocation;
      // Splash handles itself
      if (location == '/splash') return null;
      // Not logged in → login
      if (!isLoggedIn) return '/login';
      // Logged in + profile done → skip login & onboarding
      if (isLoggedIn && profileDone) {
        if (location == '/login' || location == '/onboarding') return '/home';
        return null;
      }
      // Logged in + profile NOT done → only first time show onboarding
      // If already on onboarding, let them stay (skip/save will set profile_done)
      if (!profileDone && location == '/onboarding') return null;
      // Logged in + not done + going anywhere else → onboarding
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
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );

  static Future<String> getInitialRoute() async {
    final prefs       = await SharedPreferences.getInstance();
    final isLoggedIn  = prefs.getBool('is_logged_in')  ?? false;
    final profileDone = prefs.getBool('profile_done')  ?? false;
    if (!isLoggedIn)  return '/login';
    if (!profileDone) return '/onboarding';
    return '/home';
  }
}
