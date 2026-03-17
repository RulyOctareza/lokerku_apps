import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/job_detail/job_detail_screen.dart';
import '../../features/templates/templates_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';

/// App Router Configuration
/// Uses GoRouter for declarative navigation
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String jobDetail = '/job/:id';
  static const String editJob = '/job/:id/edit';
  static const String templates = '/templates';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String allApplications = '/applications';
  static const String search = '/search';

  // Navigator keys
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Profile (outside shell)
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Search (outside shell)
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: home,
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),

          // Templates
          GoRoute(
            path: templates,
            name: 'templates',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TemplatesScreen()),
          ),

          // Stats
          GoRoute(
            path: stats,
            name: 'stats',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatsScreen()),
          ),

          // Settings
          GoRoute(
            path: settings,
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // Job Detail (outside shell - no bottom nav)
      GoRoute(
        path: jobDetail,
        name: 'jobDetail',
        builder: (context, state) {
          final rawId = state.pathParameters['id'];
          final jobId = rawId != null ? int.tryParse(rawId) : null;
          if (jobId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Lamaran tidak ditemukan')),
              body: const Center(child: Text('ID lamaran tidak valid')),
            );
          }
          return JobDetailScreen(jobId: jobId);
        },
      ),
    ],
  );
}

/// Main Shell with Bottom Navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const AppBottomNavBar());
  }
}

/// Bottom Navigation Bar Widget
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/templates')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.templates);
        break;
      case 2:
        context.go(AppRouter.stats);
        break;
      case 3:
        context.go(AppRouter.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Template',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
