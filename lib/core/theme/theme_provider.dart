import 'package:flutter/material.dart';

import '../../data/services/app_preferences.dart';

/// Theme Provider for managing app theme
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal() {
    _isDarkMode = AppPreferences.isDarkMode;
  }

  late bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await AppPreferences.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await AppPreferences.setDarkMode(_isDarkMode);
      notifyListeners();
    }
  }

  // ==============================
  // LIGHT THEME
  // ==============================
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Primary Colors
    primaryColor: const Color(0xFF2BAD7F), // Green
    // Background & Surface (LIGHT)
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2BAD7F),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF9F43),
      onSecondary: Colors.white,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1A1A2E),
      background: Color(0xFFF5F7FA),
      onBackground: Color(0xFF1A1A2E),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      foregroundColor: Color(0xFF1A1A2E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2BAD7F),
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // List Tile
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF1A1A2E),
      iconColor: Color(0xFF6B7280),
    ),

    // Text Theme (DARK TEXT on light bg)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF1A1A2E)),
      headlineMedium: TextStyle(color: Color(0xFF1A1A2E)),
      headlineSmall: TextStyle(color: Color(0xFF1A1A2E)),
      titleLarge: TextStyle(color: Color(0xFF1A1A2E)),
      titleMedium: TextStyle(color: Color(0xFF1A1A2E)),
      titleSmall: TextStyle(color: Color(0xFF1A1A2E)),
      bodyLarge: TextStyle(color: Color(0xFF1A1A2E)),
      bodyMedium: TextStyle(color: Color(0xFF4A5568)),
      bodySmall: TextStyle(color: Color(0xFF6B7280)),
      labelLarge: TextStyle(color: Color(0xFF1A1A2E)),
      labelMedium: TextStyle(color: Color(0xFF4A5568)),
      labelSmall: TextStyle(color: Color(0xFF6B7280)),
    ),

    // Divider
    dividerColor: const Color(0xFFE5E7EB),

    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFF6B7280)),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2BAD7F), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2BAD7F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Dialog
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: Color(0xFF4A5568), fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2BAD7F);
        }
        return const Color(0xFF9CA3AF);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2BAD7F).withOpacity(0.5);
        }
        return const Color(0xFFE5E7EB);
      }),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1A2E),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==============================
  // DARK THEME
  // ==============================
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Primary Colors
    primaryColor: const Color(0xFF2BAD7F), // Green stays the same
    // Background & Surface (DARK - inverted from light)
    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2BAD7F),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF9F43),
      onSecondary: Colors.white,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE5E7EB),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE5E7EB),
    ),

    // AppBar Theme (DARK)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Color(0xFFE5E7EB),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE5E7EB)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE5E7EB),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme (DARK)
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Bottom Navigation (DARK)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF2BAD7F),
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // List Tile (DARK)
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFFE5E7EB),
      iconColor: Color(0xFF9CA3AF),
    ),

    // Text Theme (LIGHT TEXT on dark bg - inverted!)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFFFFFFFF)),
      headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
      headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFE5E7EB)),
      titleMedium: TextStyle(color: Color(0xFFE5E7EB)),
      titleSmall: TextStyle(color: Color(0xFFE5E7EB)),
      bodyLarge: TextStyle(color: Color(0xFFE5E7EB)),
      bodyMedium: TextStyle(color: Color(0xFFB8BCC4)),
      bodySmall: TextStyle(color: Color(0xFF9CA3AF)),
      labelLarge: TextStyle(color: Color(0xFFE5E7EB)),
      labelMedium: TextStyle(color: Color(0xFFB8BCC4)),
      labelSmall: TextStyle(color: Color(0xFF9CA3AF)),
    ),

    // Divider (DARK)
    dividerColor: const Color(0xFF2D2D2D),

    // Icon Theme (DARK)
    iconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),

    // Input Decoration (DARK)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2BAD7F), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
    ),

    // Buttons (same green)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2BAD7F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Dialog (DARK)
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      titleTextStyle: TextStyle(
        color: Color(0xFFE5E7EB),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: Color(0xFFB8BCC4), fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2BAD7F);
        }
        return const Color(0xFF6B7280);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2BAD7F).withOpacity(0.5);
        }
        return const Color(0xFF3D3D3D);
      }),
    ),

    // Snackbar (DARK)
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D2D2D),
      contentTextStyle: const TextStyle(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
