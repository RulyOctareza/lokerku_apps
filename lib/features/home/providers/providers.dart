import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/job_application.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/template_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/sync_service.dart';

// ==================== AUTH PROVIDERS ====================

/// Auth state notifier
class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(AuthService.currentUser) {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((user) {
      state = user;
    });
  }

  Future<void> signInWithGoogle() async {
    await AuthService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

// ==================== JOB PROVIDERS ====================

/// Job list stream provider
final jobListProvider = StreamProvider<List<JobApplication>>((ref) {
  return JobRepository.watchAll();
});

/// Single job provider
final jobProvider = FutureProvider.family<JobApplication?, int>((ref, id) {
  return JobRepository.getById(id);
});

/// Job count provider
final jobCountProvider = FutureProvider<int>((ref) {
  return JobRepository.getCount();
});

/// Job stats providers
final waitingCountProvider = FutureProvider<int>((ref) async {
  final applied = await JobRepository.getCountByStatus(
    ApplicationStatus.applied,
  );
  final interviewHR = await JobRepository.getCountByStatus(
    ApplicationStatus.interviewHR,
  );
  final interviewUser = await JobRepository.getCountByStatus(
    ApplicationStatus.interviewUser,
  );
  final technicalTest = await JobRepository.getCountByStatus(
    ApplicationStatus.technicalTest,
  );
  return applied + interviewHR + interviewUser + technicalTest;
});

final interviewCountProvider = FutureProvider<int>((ref) async {
  final interviewHR = await JobRepository.getCountByStatus(
    ApplicationStatus.interviewHR,
  );
  final interviewUser = await JobRepository.getCountByStatus(
    ApplicationStatus.interviewUser,
  );
  return interviewHR + interviewUser;
});

/// Status breakdown for statistics
final statusBreakdownProvider = FutureProvider<Map<ApplicationStatus, int>>((
  ref,
) {
  return JobRepository.getStatusBreakdown();
});

/// Platform breakdown for statistics
final platformBreakdownProvider = FutureProvider<Map<JobPlatform, int>>((ref) {
  return JobRepository.getPlatformBreakdown();
});

// ==================== JOB ACTIONS ====================

/// Job actions notifier for mutations
class JobActionsNotifier extends StateNotifier<AsyncValue<void>> {
  JobActionsNotifier() : super(const AsyncValue.data(null));

  Future<int?> createJob({
    required String companyName,
    required String role,
    required JobPlatform platform,
    double? salary,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await JobRepository.create(
        companyName: companyName,
        role: role,
        platform: platform,
        salary: salary,
        notes: notes,
      );
      state = const AsyncValue.data(null);

      // Trigger sync in background
      SyncService.syncToCloud();

      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> updateStatus(
    int id,
    ApplicationStatus status, {
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await JobRepository.updateStatus(id, status, notes: notes);
      state = const AsyncValue.data(null);

      // Trigger sync
      SyncService.syncToCloud();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteJob(int id) async {
    state = const AsyncValue.loading();
    try {
      await JobRepository.delete(id);
      state = const AsyncValue.data(null);

      // Trigger sync
      SyncService.syncToCloud();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final jobActionsProvider =
    StateNotifierProvider<JobActionsNotifier, AsyncValue<void>>((ref) {
      return JobActionsNotifier();
    });

// ==================== SETTINGS PROVIDERS ====================

/// User settings provider
final settingsProvider = FutureProvider<UserSettings>((ref) {
  return SettingsRepository.get();
});

/// Dark mode provider
final isDarkModeProvider = FutureProvider<bool>((ref) async {
  final settings = await SettingsRepository.get();
  return settings.isDarkMode;
});

/// Premium status provider
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final settings = await SettingsRepository.get();
  return settings.isPremiumActive;
});

/// Onboarding completed provider
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final settings = await SettingsRepository.get();
  return settings.hasCompletedOnboarding;
});

// ==================== SYNC PROVIDERS ====================

class SyncState {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? message;

  const SyncState({required this.isSyncing, this.lastSyncedAt, this.message});

  factory SyncState.initial() =>
      const SyncState(isSyncing: false, message: 'Belum ada sinkronisasi');

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(SyncState.initial());

  Future<void> _performSync(
    Future<void> Function() syncAction,
    String successMessage,
  ) async {
    state = state.copyWith(isSyncing: true, message: 'Menyinkronkan...');
    try {
      await syncAction();
      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
        message: successMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        message: 'Sinkronisasi gagal: $e',
      );
    }
  }

  Future<void> syncAll() async {
    await _performSync(
      () => SyncService.fullSync(),
      'Sinkronisasi cloud terbaru selesai',
    );
  }

  Future<void> syncToCloud() async {
    await _performSync(
      () => SyncService.syncToCloud(),
      'Data berhasil disinkronkan ke cloud',
    );
  }

  Future<void> syncFromCloud() async {
    await _performSync(
      () => SyncService.syncFromCloud(),
      'Data cloud berhasil diunduh',
    );
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});

final unsyncedCountProvider = FutureProvider<int>((ref) async {
  final jobs = await JobRepository.getUnsynced();
  return jobs.length;
});

/// Connectivity status provider
final connectivityProvider = StreamProvider((ref) {
  return SyncService.connectivityStream;
});
