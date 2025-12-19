import 'package:isar/isar.dart';

import '../models/template.dart';
import '../models/user_settings.dart';
import '../services/isar_service.dart';

/// Template Repository
/// CRUD operations for templates
class TemplateRepository {
  /// Get all templates
  static Future<List<Template>> getAll() async {
    final isar = await IsarService.db;
    return await isar.templates.where().sortBySortOrder().findAll();
  }

  /// Get templates by category
  static Future<List<Template>> getByCategory(TemplateCategory category) async {
    final isar = await IsarService.db;
    return await isar.templates
        .filter()
        .categoryEqualTo(category)
        .sortBySortOrder()
        .findAll();
  }

  /// Get free templates only
  static Future<List<Template>> getFreeTemplates() async {
    final isar = await IsarService.db;
    return await isar.templates
        .filter()
        .isPremiumEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Check if user can access template
  static Future<bool> canAccess(Template template) async {
    if (!template.isPremium) return true;

    final isar = await IsarService.db;
    final settings = await isar.userSettings.get(1);
    return settings?.isPremiumActive ?? false;
  }
}

/// Settings Repository
/// CRUD operations for user settings
class SettingsRepository {
  /// Get current settings
  static Future<UserSettings> get() async {
    final isar = await IsarService.db;
    final settings = await isar.userSettings.get(1);
    return settings ?? UserSettings.getDefault();
  }

  /// Update settings
  static Future<void> update(UserSettings settings) async {
    final isar = await IsarService.db;
    await isar.writeTxn(() async {
      await isar.userSettings.put(settings);
    });
  }

  /// Update dark mode
  static Future<void> setDarkMode(bool value) async {
    final settings = await get();
    settings.isDarkMode = value;
    await update(settings);
  }

  /// Update notification setting
  static Future<void> setNotificationEnabled(bool value) async {
    final settings = await get();
    settings.isNotificationEnabled = value;
    await update(settings);
  }

  /// Update onboarding status
  static Future<void> setOnboardingCompleted(bool value) async {
    final settings = await get();
    settings.hasCompletedOnboarding = value;
    await update(settings);
  }

  /// Update user info after login
  static Future<void> setUserInfo({
    required String? firebaseUserId,
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    final settings = await get();
    settings.firebaseUserId = firebaseUserId;
    settings.displayName = displayName;
    settings.email = email;
    settings.photoUrl = photoUrl;
    await update(settings);
  }

  /// Set premium status
  static Future<void> setPremium(bool value, {DateTime? expiry}) async {
    final settings = await get();
    settings.isPremium = value;
    settings.premiumExpiry = expiry;
    await update(settings);
  }

  /// Clear all settings (for logout)
  static Future<void> clear() async {
    final isar = await IsarService.db;
    await isar.writeTxn(() async {
      await isar.userSettings.clear();
      await isar.userSettings.put(UserSettings.getDefault());
    });
  }
}
