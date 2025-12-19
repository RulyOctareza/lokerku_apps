import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/data/models/template.dart';
import 'package:lokerku_apps/data/models/user_settings.dart';

void main() {
  group('Template Model', () {
    test('TemplateCategory displayName should return correct names', () {
      expect(TemplateCategory.whatsapp.displayName, 'WhatsApp');
      expect(TemplateCategory.email.displayName, 'Email');
      expect(TemplateCategory.tips.displayName, 'Tips');
    });
  });

  group('DefaultTemplates', () {
    test('getAll() should return non-empty list', () {
      final templates = DefaultTemplates.getAll();

      expect(templates, isNotEmpty);
      expect(templates.length, greaterThan(5));
    });

    test('should have at least one free template', () {
      final templates = DefaultTemplates.getAll();
      final freeTemplates = templates.where((t) => !t.isPremium);

      expect(freeTemplates, isNotEmpty);
    });

    test('all templates should have required fields', () {
      final templates = DefaultTemplates.getAll();

      for (final template in templates) {
        expect(template.title, isNotEmpty);
        expect(template.description, isNotEmpty);
        expect(template.content, isNotEmpty);
      }
    });

    test('templates should have correct categories', () {
      final templates = DefaultTemplates.getAll();

      final whatsappTemplates = templates.where(
        (t) => t.category == TemplateCategory.whatsapp,
      );
      final emailTemplates = templates.where(
        (t) => t.category == TemplateCategory.email,
      );

      expect(whatsappTemplates, isNotEmpty);
      expect(emailTemplates, isNotEmpty);
    });
  });

  group('UserSettings Model', () {
    test('getDefault() should return settings with correct defaults', () {
      final settings = UserSettings.getDefault();

      expect(settings.isDarkMode, false);
      expect(settings.isNotificationEnabled, true);
      expect(settings.language, 'id');
      expect(settings.isPremium, false);
      expect(settings.hasCompletedOnboarding, false);
    });

    test('isLoggedIn should return false for guest user', () {
      final settings = UserSettings.getDefault();

      expect(settings.isLoggedIn, false);
    });

    test('isLoggedIn should return true when firebaseUserId is set', () {
      final settings = UserSettings.getDefault()..firebaseUserId = 'user123';

      expect(settings.isLoggedIn, true);
    });

    test('isPremiumActive should return false when not premium', () {
      final settings = UserSettings.getDefault();

      expect(settings.isPremiumActive, false);
    });

    test('isPremiumActive should return true when premium without expiry', () {
      final settings = UserSettings.getDefault()..isPremium = true;

      expect(settings.isPremiumActive, true);
    });

    test('isPremiumActive should check expiry date', () {
      final settings = UserSettings.getDefault()
        ..isPremium = true
        ..premiumExpiry = DateTime.now().add(const Duration(days: 30));

      expect(settings.isPremiumActive, true);

      settings.premiumExpiry = DateTime.now().subtract(const Duration(days: 1));
      expect(settings.isPremiumActive, false);
    });
  });
}
