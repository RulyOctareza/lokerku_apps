import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/core/constants/app_strings.dart';
import 'package:lokerku_apps/data/models/job_application.dart';
import 'package:lokerku_apps/data/services/app_preferences.dart';
import 'package:lokerku_apps/features/job_detail/job_detail_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    await AppPreferences.clearAll();
  });

  testWidgets('job detail timeline and update status flow', (
    WidgetTester tester,
  ) async {
    final job = JobApplication.create(
      companyName: 'Integration Co',
      role: 'Product Flutter Engineer',
      platform: JobPlatform.glints,
      salary: 14000000,
      notes: 'Integration run',
    );
    job.updateStatus(ApplicationStatus.interviewUser);

    final updates = <ApplicationStatus>[];

    final reminderAt = DateTime(2026, 4, 1, 10, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobDetailScreen(
            jobId: job.id,
            jobLoader: (_) async => job,
            statusUpdater: (id, status, {notes}) async {
              updates.add(status);
            },
            reminderPicker: (_, __, ___) async => reminderAt,
            reminderScheduler: (_, __, ___) async {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Integration Co'), findsOneWidget);
    expect(find.text('Interview User'), findsOneWidget);

    await tester.tap(find.text('Update Status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Technical Test'));
    await tester.enterText(find.byType(TextFormField), 'Integration note');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan Status'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(updates, [ApplicationStatus.technicalTest]);

    await tester.tap(find.text(AppStrings.reminderAddAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.reminderSaved), findsOneWidget);
    expect(
      AppPreferences.getJobReminder(job.id)?.toIso8601String(),
      reminderAt.toIso8601String(),
    );
  });
}
