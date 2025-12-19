import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import 'auth_service.dart';
import 'isar_service.dart';

/// Firebase Sync Service
/// Handles syncing local data with Firestore
class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's applications collection reference
  static CollectionReference<Map<String, dynamic>> _getUserApplications() {
    final userId = AuthService.userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('applications');
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sync all unsynced jobs to Firebase
  static Future<void> syncToCloud() async {
    if (!AuthService.isLoggedIn) return;
    if (!await isOnline()) return;

    final unsyncedJobs = await JobRepository.getUnsynced();

    for (final job in unsyncedJobs) {
      try {
        if (job.firebaseDocId != null) {
          // Update existing document
          await _getUserApplications()
              .doc(job.firebaseDocId)
              .update(job.toFirebaseMap());
        } else {
          // Create new document
          final docRef = await _getUserApplications().add(job.toFirebaseMap());
          await JobRepository.markSynced(job.id, docRef.id);
        }
      } catch (e) {
        // Log error but continue with other jobs
        debugPrint('Error syncing job ${job.id}: $e');
      }
    }
  }

  /// Download all jobs from Firebase to local database
  static Future<void> syncFromCloud() async {
    if (!AuthService.isLoggedIn) return;
    if (!await isOnline()) return;

    try {
      final snapshot = await _getUserApplications().get();
      final isar = await IsarService.db;

      await isar.writeTxn(() async {
        for (final doc in snapshot.docs) {
          final job = JobApplication.fromFirebaseMap(doc.id, doc.data());

          // Check if already exists locally
          final existingJobs = await isar.jobApplications
              .filter()
              .firebaseDocIdEqualTo(doc.id)
              .findAll();

          if (existingJobs.isNotEmpty) {
            // Update existing local record
            final existing = existingJobs.first;
            // Only update if cloud is newer
            if (job.updatedAt.isAfter(existing.updatedAt)) {
              job.id = existing.id;
              await isar.jobApplications.put(job);
            }
          } else {
            // Insert new record
            await isar.jobApplications.put(job);
          }
        }
      });
    } catch (e) {
      debugPrint('Error syncing from cloud: $e');
      rethrow;
    }
  }

  /// Full sync (bidirectional)
  static Future<void> fullSync() async {
    // First pull from cloud (so we have latest)
    await syncFromCloud();
    // Then push local changes
    await syncToCloud();
  }

  /// Delete job from Firebase
  static Future<void> deleteFromCloud(String firebaseDocId) async {
    if (!AuthService.isLoggedIn) return;
    if (!await isOnline()) return;

    try {
      await _getUserApplications().doc(firebaseDocId).delete();
    } catch (e) {
      debugPrint('Error deleting from cloud: $e');
    }
  }

  /// Listen for connectivity changes
  /// Returns a stream of connectivity results
  static Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}
