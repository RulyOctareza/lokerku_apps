import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokerku_apps/core/constants/app_strings.dart';
import 'package:lokerku_apps/core/utils/formatters.dart';
import 'package:lokerku_apps/data/models/job_application.dart';
import 'package:lokerku_apps/data/services/app_preferences.dart';
import 'package:lokerku_apps/features/job_detail/job_detail_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(540, 1170)),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    await initializeDateFormatting('id_ID', null);
  });

  late JobApplication job;

  setUp(() async {
    await AppPreferences.clearAll();
    job = JobApplication.create(
      companyName: 'PT Flutter Labs',
      role: 'Senior Flutter Developer',
      platform: JobPlatform.linkedin,
      salary: 18000000,
      notes: 'Initial submission',
    );
    job.updateStatus(ApplicationStatus.interviewHR, notes: 'HR call scheduled');
  });

  group('JobDetailScreen', () {
    testWidgets('renders header and timeline', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        _wrap(
          JobDetailScreen(
            jobId: job.id,
            jobLoader: (_) async => job,
            reminderScheduler: (_, __, ___) async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PT Flutter Labs'), findsOneWidget);
      expect(find.text('Senior Flutter Developer'), findsOneWidget);
      expect(find.text('Interview HR'), findsNWidgets(2));
      expect(find.text('Applied'), findsOneWidget);
    });

    testWidgets('updates status from bottom sheet', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final updates = <ApplicationStatus>[];
      String? capturedNotes;

      await tester.pumpWidget(
        _wrap(
          JobDetailScreen(
            jobId: job.id,
            jobLoader: (_) async => job,
            statusUpdater: (id, status, {notes}) async {
              updates.add(status);
              capturedNotes = notes;
            },
            reminderScheduler: (_, __, ___) async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('job-detail-update-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accepted'));
      await tester.enterText(find.byType(TextFormField), 'Catatan tambahan');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Status'));
      await tester.pumpAndSettle();

      expect(updates, [ApplicationStatus.accepted]);
      expect(capturedNotes, 'Catatan tambahan');
      expect(find.text('Status berhasil diupdate!'), findsOneWidget);
    });

    testWidgets('updates reminder section', (WidgetTester tester) async {
      final reminder = DateTime(2026, 4, 1, 9, 30);

      await tester.pumpWidget(
        _wrap(
          JobDetailScreen(
            jobId: job.id,
            jobLoader: (_) async => job,
            reminderPicker: (_, __, ___) async => reminder,
            reminderScheduler: (_, __, ___) async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(AppStrings.reminderNone), findsOneWidget);

      await tester.tap(find.text(AppStrings.reminderAddAction));
      await tester.pumpAndSettle();

      expect(
        find.text(DateFormatter.toReadableDateTime(reminder)),
        findsOneWidget,
      );
      expect(find.text(AppStrings.reminderEditAction), findsOneWidget);
      expect(find.text(AppStrings.delete), findsOneWidget);

      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.reminderNone), findsOneWidget);
      expect(AppPreferences.getJobReminder(job.id), isNull);
    });

    testWidgets('keeps reminder unset when scheduler fails', (
      WidgetTester tester,
    ) async {
      final reminder = DateTime(2026, 4, 2, 14, 0);

      await tester.pumpWidget(
        _wrap(
          JobDetailScreen(
            jobId: job.id,
            jobLoader: (_) async => job,
            reminderPicker: (_, __, ___) async => reminder,
            reminderScheduler: (_, __, ___) async {
              throw Exception('scheduler failed');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.reminderAddAction));
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal menyimpan pengingat'), findsOneWidget);
      expect(AppPreferences.getJobReminder(job.id), isNull);
      expect(find.text(AppStrings.reminderNone), findsOneWidget);
    });
  });
}
