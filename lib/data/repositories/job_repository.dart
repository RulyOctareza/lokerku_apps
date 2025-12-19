import 'package:isar/isar.dart';

import '../models/job_application.dart';
import '../services/isar_service.dart';

/// Job Application Repository
/// CRUD operations for job applications
class JobRepository {
  // ==================== CREATE ====================

  /// Create a new job application
  static Future<int> create({
    required String companyName,
    required String role,
    required JobPlatform platform,
    double? salary,
    String? notes,
  }) async {
    final isar = await IsarService.db;
    final job = JobApplication.create(
      companyName: companyName,
      role: role,
      platform: platform,
      salary: salary,
      notes: notes,
    );

    return await isar.writeTxn(() async {
      return await isar.jobApplications.put(job);
    });
  }

  // ==================== READ ====================

  /// Get all job applications (not deleted)
  static Future<List<JobApplication>> getAll() async {
    final isar = await IsarService.db;
    return await isar.jobApplications
        .filter()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Get job application by ID
  static Future<JobApplication?> getById(int id) async {
    final isar = await IsarService.db;
    return await isar.jobApplications.get(id);
  }

  /// Get jobs by status
  static Future<List<JobApplication>> getByStatus(
    ApplicationStatus status,
  ) async {
    final isar = await IsarService.db;
    return await isar.jobApplications
        .filter()
        .isDeletedEqualTo(false)
        .statusEqualTo(status)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Watch all jobs (stream for reactive UI)
  static Stream<List<JobApplication>> watchAll() async* {
    final isar = await IsarService.db;
    yield* isar.jobApplications
        .filter()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get job count
  static Future<int> getCount() async {
    final isar = await IsarService.db;
    return await isar.jobApplications.filter().isDeletedEqualTo(false).count();
  }

  /// Get count by status
  static Future<int> getCountByStatus(ApplicationStatus status) async {
    final isar = await IsarService.db;
    return await isar.jobApplications
        .filter()
        .isDeletedEqualTo(false)
        .statusEqualTo(status)
        .count();
  }

  /// Get jobs needing sync
  static Future<List<JobApplication>> getUnsynced() async {
    final isar = await IsarService.db;
    return await isar.jobApplications
        .filter()
        .isSyncedEqualTo(false)
        .isDeletedEqualTo(false)
        .findAll();
  }

  // ==================== UPDATE ====================

  /// Update job application
  static Future<void> update(JobApplication job) async {
    final isar = await IsarService.db;
    job.updatedAt = DateTime.now();
    job.isSynced = false;

    await isar.writeTxn(() async {
      await isar.jobApplications.put(job);
    });
  }

  /// Update job status
  static Future<void> updateStatus(
    int id,
    ApplicationStatus newStatus, {
    String? notes,
  }) async {
    final isar = await IsarService.db;
    final job = await isar.jobApplications.get(id);

    if (job != null) {
      job.updateStatus(newStatus, notes: notes);
      await isar.writeTxn(() async {
        await isar.jobApplications.put(job);
      });
    }
  }

  /// Mark job as synced
  static Future<void> markSynced(int id, String firebaseDocId) async {
    final isar = await IsarService.db;
    final job = await isar.jobApplications.get(id);

    if (job != null) {
      job.isSynced = true;
      job.firebaseDocId = firebaseDocId;
      await isar.writeTxn(() async {
        await isar.jobApplications.put(job);
      });
    }
  }

  // ==================== DELETE ====================

  /// Soft delete job application
  static Future<void> delete(int id) async {
    final isar = await IsarService.db;
    final job = await isar.jobApplications.get(id);

    if (job != null) {
      job.isDeleted = true;
      job.isSynced = false;
      job.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.jobApplications.put(job);
      });
    }
  }

  /// Hard delete job application (permanent)
  static Future<bool> hardDelete(int id) async {
    final isar = await IsarService.db;
    return await isar.writeTxn(() async {
      return await isar.jobApplications.delete(id);
    });
  }

  /// Delete all jobs (for testing/reset)
  static Future<void> deleteAll() async {
    final isar = await IsarService.db;
    await isar.writeTxn(() async {
      await isar.jobApplications.clear();
    });
  }

  // ==================== SEARCH ====================

  /// Search jobs by company name or role
  static Future<List<JobApplication>> search(String query) async {
    final isar = await IsarService.db;
    final lowerQuery = query.toLowerCase();

    return await isar.jobApplications
        .filter()
        .isDeletedEqualTo(false)
        .group(
          (q) => q
              .companyNameContains(lowerQuery, caseSensitive: false)
              .or()
              .roleContains(lowerQuery, caseSensitive: false),
        )
        .sortByUpdatedAtDesc()
        .findAll();
  }

  // ==================== STATISTICS ====================

  /// Get status breakdown for statistics
  static Future<Map<ApplicationStatus, int>> getStatusBreakdown() async {
    final isar = await IsarService.db;
    final map = <ApplicationStatus, int>{};

    for (final status in ApplicationStatus.values) {
      map[status] = await isar.jobApplications
          .filter()
          .isDeletedEqualTo(false)
          .statusEqualTo(status)
          .count();
    }

    return map;
  }

  /// Get platform breakdown for statistics
  static Future<Map<JobPlatform, int>> getPlatformBreakdown() async {
    final isar = await IsarService.db;
    final map = <JobPlatform, int>{};

    for (final platform in JobPlatform.values) {
      map[platform] = await isar.jobApplications
          .filter()
          .isDeletedEqualTo(false)
          .platformEqualTo(platform)
          .count();
    }

    return map;
  }
}
