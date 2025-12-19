import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/data/models/job_application.dart';

void main() {
  group('JobApplication Model', () {
    test('create() should create a new job with Applied status', () {
      final job = JobApplication.create(
        companyName: 'Test Company',
        role: 'Flutter Developer',
        platform: JobPlatform.linkedin,
        salary: 15000000,
        notes: 'Via referral',
      );

      expect(job.companyName, 'Test Company');
      expect(job.role, 'Flutter Developer');
      expect(job.platform, JobPlatform.linkedin);
      expect(job.salary, 15000000);
      expect(job.status, ApplicationStatus.applied);
      expect(job.logs.length, 1);
      expect(job.logs.first.notes, 'Via referral');
      expect(job.isSynced, false);
      expect(job.isDeleted, false);
    });

    test('updateStatus() should add new log entry', () {
      final job = JobApplication.create(
        companyName: 'Test Company',
        role: 'Developer',
        platform: JobPlatform.linkedin,
      );

      expect(job.logs.length, 1);

      job.updateStatus(ApplicationStatus.interviewHR, notes: 'HR call');

      expect(job.status, ApplicationStatus.interviewHR);
      expect(job.logs.length, 2);
      expect(job.logs.last.status, 'interviewHR');
      expect(job.logs.last.notes, 'HR call');
      expect(job.isSynced, false);
    });

    test('sortedLogs should return logs newest first', () {
      final job = JobApplication.create(
        companyName: 'Test Company',
        role: 'Developer',
        platform: JobPlatform.linkedin,
      );

      job.updateStatus(ApplicationStatus.interviewHR);
      job.updateStatus(ApplicationStatus.interviewUser);

      final sorted = job.sortedLogs;

      expect(sorted.first.status, 'interviewUser');
      expect(sorted.last.status, 'applied');
    });

    test('toFirebaseMap() should return correct map structure', () {
      final job = JobApplication.create(
        companyName: 'Firebase Test',
        role: 'Backend Dev',
        platform: JobPlatform.jobstreet,
        salary: 20000000,
      );

      final map = job.toFirebaseMap();

      expect(map['companyName'], 'Firebase Test');
      expect(map['role'], 'Backend Dev');
      expect(map['platform'], 'jobstreet');
      expect(map['salary'], 20000000);
      expect(map['status'], 'applied');
      expect(map['logs'], isA<List>());
    });

    test('fromFirebaseMap() should create job from map', () {
      final map = {
        'companyName': 'Cloud Company',
        'role': 'Cloud Engineer',
        'platform': 'glints',
        'salary': 25000000,
        'status': 'interviewHR',
        'createdAt': '2024-01-01T10:00:00.000Z',
        'updatedAt': '2024-01-05T14:00:00.000Z',
        'logs': [
          {
            'status': 'applied',
            'timestamp': '2024-01-01T10:00:00.000Z',
            'notes': 'Initial',
          },
          {
            'status': 'interviewHR',
            'timestamp': '2024-01-05T14:00:00.000Z',
            'notes': 'HR scheduled',
          },
        ],
      };

      final job = JobApplication.fromFirebaseMap('doc123', map);

      expect(job.firebaseDocId, 'doc123');
      expect(job.companyName, 'Cloud Company');
      expect(job.role, 'Cloud Engineer');
      expect(job.platform, JobPlatform.glints);
      expect(job.status, ApplicationStatus.interviewHR);
      expect(job.logs.length, 2);
      expect(job.isSynced, true);
    });
  });

  group('ApplicationStatus Enum', () {
    test('displayName should return correct names', () {
      expect(ApplicationStatus.applied.displayName, 'Applied');
      expect(ApplicationStatus.interviewHR.displayName, 'Interview HR');
      expect(ApplicationStatus.accepted.displayName, 'Accepted');
      expect(ApplicationStatus.rejected.displayName, 'Rejected');
    });

    test('isPositive should identify positive statuses', () {
      expect(ApplicationStatus.offering.isPositive, true);
      expect(ApplicationStatus.accepted.isPositive, true);
      expect(ApplicationStatus.applied.isPositive, false);
      expect(ApplicationStatus.rejected.isPositive, false);
    });

    test('isNegative should identify negative statuses', () {
      expect(ApplicationStatus.rejected.isNegative, true);
      expect(ApplicationStatus.withdrawn.isNegative, true);
      expect(ApplicationStatus.accepted.isNegative, false);
    });

    test('isInterview should identify interview statuses', () {
      expect(ApplicationStatus.interviewHR.isInterview, true);
      expect(ApplicationStatus.interviewUser.isInterview, true);
      expect(ApplicationStatus.applied.isInterview, false);
    });
  });

  group('JobPlatform Enum', () {
    test('displayName should return correct names', () {
      expect(JobPlatform.linkedin.displayName, 'LinkedIn');
      expect(JobPlatform.jobstreet.displayName, 'JobStreet');
      expect(JobPlatform.glints.displayName, 'Glints');
      expect(JobPlatform.website.displayName, 'Website Perusahaan');
    });
  });

  group('StatusLog', () {
    test('statusEnum should return correct enum', () {
      final log = StatusLog()
        ..status = 'interviewHR'
        ..timestamp = DateTime.now();

      expect(log.statusEnum, ApplicationStatus.interviewHR);
    });

    test('statusEnum should return applied for unknown status', () {
      final log = StatusLog()
        ..status = 'unknownStatus'
        ..timestamp = DateTime.now();

      expect(log.statusEnum, ApplicationStatus.applied);
    });
  });
}
