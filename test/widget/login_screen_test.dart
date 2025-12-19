import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/features/auth/login_screen.dart';
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
  group('LoginScreen Widget Tests', () {
    testWidgets('should display app name and logo', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));

      // Check for app name
      expect(find.text(AppStrings.appName), findsOneWidget);

      // Check for work icon (logo)
      expect(find.byIcon(Icons.work_rounded), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display login title and subtitle', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));

      expect(find.text(AppStrings.loginTitle), findsOneWidget);
      expect(find.text(AppStrings.loginSubtitle), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display Google Sign-In button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Verify Google Sign-In button text is visible
      expect(find.text(AppStrings.loginWithGoogle), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display Guest mode option', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));

      expect(find.text(AppStrings.continueAsGuest), findsOneWidget);
      expect(find.text(AppStrings.guestModeNote), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display terms agreement', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const LoginScreen()));

      expect(find.text(AppStrings.termsAgreement), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
