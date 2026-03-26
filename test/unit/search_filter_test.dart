import 'package:flutter_test/flutter_test.dart';
import 'package:lokerku_apps/data/models/job_application.dart';
import 'package:lokerku_apps/features/search/search_filter.dart';

List<JobApplication> _buildJobs() {
  final jobA = JobApplication.create(
    companyName: 'Alpha Labs',
    role: 'Flutter Dev',
    platform: JobPlatform.linkedin,
  );
  jobA.updatedAt = DateTime(2026, 3, 20);

  final jobB = JobApplication.create(
    companyName: 'Beta Systems',
    role: 'Backend Dev',
    platform: JobPlatform.glints,
  );
  jobB.updateStatus(ApplicationStatus.interviewHR);
  jobB.updatedAt = DateTime(2026, 3, 22);

  final jobC = JobApplication.create(
    companyName: 'Gamma Works',
    role: 'Fullstack Engineer',
    platform: JobPlatform.jobstreet,
  );
  jobC.updatedAt = DateTime(2026, 3, 25);

  return [jobA, jobB, jobC];
}

void main() {
  test('filters by query text case-insensitively', () {
    final jobs = _buildJobs();
    final result = SearchFilter.filter(
      jobs: jobs,
      query: 'alpha',
      statuses: ApplicationStatus.values.toSet(),
    );

    expect(result.length, 1);
    expect(result.first.companyName, 'Alpha Labs');
  });

  test('filters by selected statuses', () {
    final jobs = _buildJobs();
    final result = SearchFilter.filter(
      jobs: jobs,
      statuses: {ApplicationStatus.interviewHR},
    );

    expect(result.length, 1);
    expect(result.first.companyName, 'Beta Systems');
  });

  test('filters by platform and updated date', () {
    final jobs = _buildJobs();

    final result = SearchFilter.filter(
      jobs: jobs,
      statuses: ApplicationStatus.values.toSet(),
      platform: JobPlatform.jobstreet,
      updatedAfter: DateTime(2026, 3, 23),
    );

    expect(result, hasLength(1));
    expect(result.single.companyName, 'Gamma Works');
  });
}
