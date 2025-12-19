import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/features/add_job/add_job_sheet.dart';
import 'package:lokerku_apps/core/constants/app_strings.dart';
import 'package:lokerku_apps/data/models/job_application.dart';

/// Helper to wrap widget in MaterialApp with proper sizing
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(540, 1200)),
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('AddJobSheet Widget Tests', () {
    testWidgets('should display form with required fields', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      // Check for title
      expect(find.text(AppStrings.addApplicationTitle), findsOneWidget);

      // Check for required field labels
      expect(find.text('${AppStrings.companyNameLabel} *'), findsOneWidget);
      expect(find.text('${AppStrings.roleLabel} *'), findsOneWidget);
      expect(find.text('${AppStrings.platformLabel} *'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should have text input fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      // Should have TextFormField widgets (company, role, salary, notes)
      expect(find.byType(TextFormField), findsNWidgets(4));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should have platform dropdown', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      // Should have dropdown
      expect(find.byType(DropdownButtonFormField<JobPlatform>), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should accept text input in company name field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      // Find company name field and enter text
      final companyField = find.byType(TextFormField).first;
      await tester.enterText(companyField, 'Test Company');
      await tester.pump();

      expect(find.text('Test Company'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should have close button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      expect(find.byIcon(Icons.close), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display optional fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestableWidget(const AddJobSheet()));

      expect(find.text(AppStrings.salaryLabel), findsOneWidget);
      expect(find.text(AppStrings.notesLabel), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
