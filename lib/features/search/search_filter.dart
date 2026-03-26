import '../../data/models/job_application.dart';

class SearchFilter {
  SearchFilter._();

  static List<JobApplication> filter({
    required List<JobApplication> jobs,
    String query = '',
    required Set<ApplicationStatus> statuses,
    JobPlatform? platform,
    DateTime? updatedAfter,
  }) {
    final normalizedQuery = query.toLowerCase();

    return jobs.where((job) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          job.companyName.toLowerCase().contains(normalizedQuery) ||
          job.role.toLowerCase().contains(normalizedQuery);

      final matchesStatus =
          statuses.isEmpty || statuses.contains(job.status);

      final matchesPlatform =
          platform == null || job.platform == platform;

      final matchesDate =
          updatedAfter == null || job.updatedAt.isAfter(updatedAfter);

      return matchesQuery && matchesStatus && matchesPlatform && matchesDate;
    }).toList();
  }
}
