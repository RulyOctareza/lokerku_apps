import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'data/services/app_preferences.dart';

/// LokerKu App
/// Job Application Tracker with Offline-First Architecture
class LokerKuApp extends StatefulWidget {
  const LokerKuApp({super.key});

  // Static notifier to trigger rebuilds
  static final ValueNotifier<int> _rebuildNotifier = ValueNotifier<int>(0);

  static void rebuildApp() {
    _rebuildNotifier.value++;
  }

  @override
  State<LokerKuApp> createState() => _LokerKuAppState();
}

class _LokerKuAppState extends State<LokerKuApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    // Initialize localization from preferences
    AppLocalizations.setLocale(AppPreferences.language);
    // Listen to theme changes
    _themeProvider.addListener(_onThemeChanged);
    // Listen to rebuild requests
    LokerKuApp._rebuildNotifier.addListener(_onRebuildRequested);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    LokerKuApp._rebuildNotifier.removeListener(_onRebuildRequested);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onRebuildRequested() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeProvider.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: isDarkMode
            ? const Color(0xFF121212)
            : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'LokerKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
