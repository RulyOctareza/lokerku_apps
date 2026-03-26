import 'package:flutter_test/flutter_test.dart';

import 'package:lokerku_apps/data/models/job_application.dart';

void main() {
  group('JobApplication model', () {
    test('create initializes status and baby log', () {
      final job = JobApplication.create(
        companyName: 'Example Corp',
        role: 'Flutter Engineer',
        platform: JobPlatform.linkedin,
        salary: 15000000,
        notes: 'Initial notes',
      );

      expect(job.status, ApplicationStatus.applied);
      expect(job.logs, isNotEmpty);
      expect(job.logs.first.statusEnum, ApplicationStatus.applied);
      expect(job.logs.first.notes, 'Initial notes');
      expect(job.isSynced, false);
      expect(job.isDeleted, false);
    });

    test('updateStatus appends timeline and resets sync flag', () {
      final job = JobApplication.create(
        companyName: 'Example Corp',
        role: 'Flutter Engineer',
        platform: JobPlatform.linkedin,
        salary: 15000000,
      );

      job.updateStatus(ApplicationStatus.interviewHR, notes: 'Scheduled HR');

      expect(job.status, ApplicationStatus.interviewHR);
      expect(job.isSynced, false);
      expect(job.logs.length, 2);
      expect(job.logs.last.statusEnum, ApplicationStatus.interviewHR);
      expect(job.logs.last.notes, 'Scheduled HR');
      expect(job.sortedLogs.first.statusEnum, ApplicationStatus.interviewHR);
    });

    test('updateStatus works even when logs came from a fixed-length list', () {
      final job = JobApplication.create(
        companyName: 'Example Corp',
        role: 'Flutter Engineer',
        platform: JobPlatform.linkedin,
      );
      job.logs = List<StatusLog>.unmodifiable(job.logs);

      expect(
        () => job.updateStatus(
          ApplicationStatus.technicalTest,
          notes: 'Fixed list safe',
        ),
        returnsNormally,
      );
      expect(job.logs.length, 2);
      expect(job.logs.last.statusEnum, ApplicationStatus.technicalTest);
    });

    test('toFirebaseMap and fromFirebaseMap roundtrip', () {
      final job = JobApplication.create(
        companyName: 'Data Corp',
        role: 'Engineer',
        platform: JobPlatform.jobstreet,
        salary: 20000000,
        notes: 'Sync test',
      );
      job.firebaseDocId = 'doc-A1';
      job.updateStatus(ApplicationStatus.technicalTest, notes: 'Test passed');

      final map = job.toFirebaseMap();
      final restored = JobApplication.fromFirebaseMap('doc-A1', map);

      expect(restored.companyName, job.companyName);
      expect(restored.role, job.role);
      expect(restored.platform, job.platform);
      expect(restored.status, job.status);
      expect(restored.logs.length, job.logs.length);
      expect(restored.logs.first.statusEnum, ApplicationStatus.applied);
      expect(restored.logs.last.statusEnum, ApplicationStatus.technicalTest);
    });
  });
}
