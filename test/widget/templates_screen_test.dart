import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/models/template.dart';
import 'package:lokerku_apps/features/templates/providers/template_providers.dart';
import 'package:lokerku_apps/features/templates/templates_screen.dart';

void main() {
  Template buildTemplate({required String title, bool isPremium = false}) {
    return Template()
      ..title = title
      ..description = 'Tes'
      ..category = TemplateCategory.whatsapp
      ..content = 'Halo HR'
      ..isPremium = isPremium
      ..sortOrder = 1;
  }

  testWidgets('shows snackbar and closes loading when template access fails', (
    WidgetTester tester,
  ) async {
    final template = buildTemplate(title: 'Follow Up HRD (Sopan)');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          templatesProvider.overrideWith((ref) async => [template]),
        ],
        child: MaterialApp(
          home: TemplatesScreen(
            canAccessChecker: (_) async => throw Exception('db error'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Follow Up HRD (Sopan)'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat template'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'launches paywall from root context after premium dialog closes',
    (WidgetTester tester) async {
      final template = buildTemplate(
        title: 'Konfirmasi Interview',
        isPremium: true,
      );
      var paywallOpened = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            templatesProvider.overrideWith((ref) async => [template]),
          ],
          child: MaterialApp(
            home: TemplatesScreen(
              canAccessChecker: (_) async => false,
              paywallLauncher: (_) async => paywallOpened = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Konfirmasi Interview'));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade ke Premium'), findsOneWidget);

      await tester.tap(find.text('Langganan Sekarang'));
      await tester.pumpAndSettle();

      expect(paywallOpened, isTrue);
      expect(find.text('Upgrade ke Premium'), findsNothing);
    },
  );

  testWidgets('shows copied snackbar after closing template bottom sheet', (
    WidgetTester tester,
  ) async {
    final template = buildTemplate(title: 'Follow Up HRD (Sopan)');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          templatesProvider.overrideWith((ref) async => [template]),
        ],
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Follow Up HRD (Sopan)'));
    await tester.pumpAndSettle();

    expect(find.text('Salin Template'), findsOneWidget);

    await tester.tap(find.text('Salin Template'));
    await tester.pumpAndSettle();

    expect(find.text('Template disalin!'), findsOneWidget);
  });
}
