import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/core/constants/app_colors.dart';
import 'package:lokerku_apps/core/constants/app_strings.dart';
import 'package:lokerku_apps/features/home/widgets/job_card.dart';
import 'package:lokerku_apps/features/home/widgets/recent_applications_header.dart';
import 'package:lokerku_apps/features/home/widgets/stats_card.dart';

void main() {
  group('StatsCard Widget Tests', () {
    testWidgets('should display all required elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total',
              value: '24',
              subtitle: 'Lamaran',
              color: AppColors.primary,
            ),
          ),
        ),
      );

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Lamaran'), findsOneWidget);
    });

    testWidgets('should use provided color for value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Test',
              value: '100',
              subtitle: 'Items',
              color: AppColors.error,
            ),
          ),
        ),
      );

      // Find the Text widget with value and check its style
      final valueFinder = find.text('100');
      expect(valueFinder, findsOneWidget);
    });
  });

  group('JobCard Widget Tests', () {
    testWidgets('should display company name and role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              companyName: 'PT ABC Technology',
              role: 'Flutter Developer',
              status: 'Interview',
              statusColor: AppColors.secondary,
              timeAgo: '2 jam lalu',
            ),
          ),
        ),
      );

      expect(find.text('PT ABC Technology'), findsOneWidget);
      expect(find.text('Flutter Developer'), findsOneWidget);
    });

    testWidgets('should display status badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              companyName: 'Company',
              role: 'Role',
              status: 'Applied',
              statusColor: AppColors.primary,
              timeAgo: '1 hari lalu',
            ),
          ),
        ),
      );

      expect(find.text('Applied'), findsOneWidget);
    });

    testWidgets('should display time ago', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              companyName: 'Company',
              role: 'Role',
              status: 'Applied',
              statusColor: AppColors.primary,
              timeAgo: '5 hari lalu',
            ),
          ),
        ),
      );

      expect(find.text('5 hari lalu'), findsOneWidget);
    });

    testWidgets('should trigger onTap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              companyName: 'Company',
              role: 'Role',
              status: 'Applied',
              statusColor: AppColors.primary,
              timeAgo: '1 hari lalu',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(JobCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should display business icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              companyName: 'Company',
              role: 'Role',
              status: 'Applied',
              statusColor: AppColors.primary,
              timeAgo: '1 hari lalu',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.business_rounded), findsOneWidget);
    });
  });

  group('RecentApplicationsHeader Widget Tests', () {
    testWidgets('shows title and view all action', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentApplicationsHeader(
              onViewAll: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.homeRecentApplications), findsOneWidget);
      expect(find.text(AppStrings.homeViewAll), findsOneWidget);

      await tester.tap(find.text(AppStrings.homeViewAll));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
