import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/features/onboarding/onboarding_screen.dart';
import 'package:lokerku_apps/core/constants/app_strings.dart';

/// Helper to wrap widget in MaterialApp with proper sizing
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(540, 1200)),
      child: child,
    ),
  );
}

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('should display first onboarding page initially', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));

      // Check for first page title
      expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);

      // Check for skip button
      expect(find.text(AppStrings.onboardingSkip), findsOneWidget);

      // Check for next button
      expect(find.text(AppStrings.onboardingNext), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should show page indicators', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));

      // There should be 3 page indicators
      expect(find.byType(AnimatedContainer), findsNWidgets(3));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should navigate to next page on button tap', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));

      // Tap next button
      await tester.tap(find.text(AppStrings.onboardingNext));
      await tester.pumpAndSettle();

      // Should now show second page
      expect(find.text(AppStrings.onboardingTitle2), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should show "Mulai Sekarang" on last page', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));

      // Navigate to last page
      await tester.tap(find.text(AppStrings.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.onboardingNext));
      await tester.pumpAndSettle();

      // Should show "Mulai Sekarang" button
      expect(find.text(AppStrings.onboardingGetStarted), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
