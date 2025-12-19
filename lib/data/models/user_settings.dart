import 'package:isar/isar.dart';

part 'user_settings.g.dart';

/// User Settings Collection
@collection
class UserSettings {
  Id id = Isar.autoIncrement;

  /// Whether dark mode is enabled
  bool isDarkMode = false;

  /// Whether notifications are enabled
  bool isNotificationEnabled = true;

  /// Current language (default: id for Indonesian)
  String language = 'id';

  /// Whether user is premium subscriber
  bool isPremium = false;

  /// Premium subscription expiry date
  DateTime? premiumExpiry;

  /// Whether onboarding has been completed
  bool hasCompletedOnboarding = false;

  /// Firebase user ID (null if guest mode)
  String? firebaseUserId;

  /// User display name
  String? displayName;

  /// User email
  String? email;

  /// User photo URL
  String? photoUrl;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Check if premium is currently active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiry == null) return true;
    return premiumExpiry!.isAfter(DateTime.now());
  }

  /// Check if user is logged in (not guest mode)
  bool get isLoggedIn => firebaseUserId != null;

  /// Get default settings
  static UserSettings getDefault() {
    return UserSettings()
      ..isDarkMode = false
      ..isNotificationEnabled = true
      ..language = 'id'
      ..isPremium = false
      ..hasCompletedOnboarding = false;
  }
}
