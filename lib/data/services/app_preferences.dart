import 'package:shared_preferences/shared_preferences.dart';

/// App Preferences Service
/// Handles persistent app state using SharedPreferences
class AppPreferences {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keyIsGuestMode = 'is_guest_mode';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyUserDisplayName = 'user_display_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhotoUrl = 'user_photo_url';
  static const String _keyUserWhatsapp = 'user_whatsapp';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserGender = 'user_gender';

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('AppPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== ONBOARDING ====================

  /// Check if onboarding has been completed
  static bool get hasCompletedOnboarding {
    return _prefs?.getBool(_keyHasCompletedOnboarding) ?? false;
  }

  /// Set onboarding completed
  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool(_keyHasCompletedOnboarding, value);
  }

  // ==================== AUTH STATE ====================

  /// Check if user is in guest mode
  static bool get isGuestMode {
    return _prefs?.getBool(_keyIsGuestMode) ?? false;
  }

  /// Set guest mode
  static Future<void> setGuestMode(bool value) async {
    await _prefs?.setBool(_keyIsGuestMode, value);
  }

  // ==================== THEME ====================

  /// Check if dark mode is enabled
  static bool get isDarkMode {
    return _prefs?.getBool(_keyIsDarkMode) ?? false;
  }

  /// Set dark mode
  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(_keyIsDarkMode, value);
  }

  // ==================== NOTIFICATIONS ====================

  /// Check if notifications are enabled
  static bool get notificationsEnabled {
    return _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Set notifications enabled
  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_keyNotificationsEnabled, value);
  }

  // ==================== LANGUAGE ====================

  /// Get current language
  static String get language {
    return _prefs?.getString(_keyLanguage) ?? 'id';
  }

  /// Set language
  static Future<void> setLanguage(String value) async {
    await _prefs?.setString(_keyLanguage, value);
  }

  // ==================== USER PROFILE ====================

  /// Get user display name
  static String? get userDisplayName {
    return _prefs?.getString(_keyUserDisplayName);
  }

  /// Set user display name
  static Future<void> setUserDisplayName(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserDisplayName);
    } else {
      await _prefs?.setString(_keyUserDisplayName, value);
    }
  }

  /// Get user email
  static String? get userEmail {
    return _prefs?.getString(_keyUserEmail);
  }

  /// Set user email
  static Future<void> setUserEmail(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserEmail);
    } else {
      await _prefs?.setString(_keyUserEmail, value);
    }
  }

  /// Get user photo URL
  static String? get userPhotoUrl {
    return _prefs?.getString(_keyUserPhotoUrl);
  }

  /// Set user photo URL
  static Future<void> setUserPhotoUrl(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserPhotoUrl);
    } else {
      await _prefs?.setString(_keyUserPhotoUrl, value);
    }
  }

  /// Get user WhatsApp number
  static String? get userWhatsapp {
    return _prefs?.getString(_keyUserWhatsapp);
  }

  /// Set user WhatsApp number
  static Future<void> setUserWhatsapp(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserWhatsapp);
    } else {
      await _prefs?.setString(_keyUserWhatsapp, value);
    }
  }

  /// Get user age
  static int? get userAge {
    return _prefs?.getInt(_keyUserAge);
  }

  /// Set user age
  static Future<void> setUserAge(int? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserAge);
    } else {
      await _prefs?.setInt(_keyUserAge, value);
    }
  }

  /// Get user gender
  static String? get userGender {
    return _prefs?.getString(_keyUserGender);
  }

  /// Set user gender
  static Future<void> setUserGender(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserGender);
    } else {
      await _prefs?.setString(_keyUserGender, value);
    }
  }

  // ==================== CLEAR ====================

  /// Clear all preferences (for logout)
  static Future<void> clearUserData() async {
    await _prefs?.remove(_keyUserDisplayName);
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyUserPhotoUrl);
    await _prefs?.remove(_keyUserWhatsapp);
    await _prefs?.remove(_keyUserAge);
    await _prefs?.remove(_keyUserGender);
    await _prefs?.remove(_keyIsGuestMode);
  }

  /// Clear all preferences (full reset)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // ==================== REMINDERS ====================

  static String _reminderKey(int jobId) => 'job_reminder_$jobId';

  /// Get reminder timestamp for a job
  static DateTime? getJobReminder(int jobId) {
    final iso = _prefs?.getString(_reminderKey(jobId));
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  /// Set reminder timestamp for a job
  static Future<void> setJobReminder(int jobId, DateTime? value) async {
    if (value == null) {
      await _prefs?.remove(_reminderKey(jobId));
    } else {
      await _prefs?.setString(_reminderKey(jobId), value.toIso8601String());
    }
  }
}
