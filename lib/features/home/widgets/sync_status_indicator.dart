import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/auth_service.dart';
import '../providers/providers.dart';

/// Displays connectivity, sync status, and a manual sync action.
class SyncStatusIndicator extends ConsumerWidget {
  final bool? isLoggedInOverride;

  const SyncStatusIndicator({super.key, this.isLoggedInOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final connectivity = ref.watch(connectivityProvider);
    final unsynced = ref.watch(unsyncedCountProvider);
    final theme = Theme.of(context);
    final isLoggedIn = isLoggedInOverride ?? AuthService.isLoggedIn;

    final connectivityValue = connectivity.asData?.value;
    final isOnline = connectivityValue == null
        ? null
        : connectivityValue != ConnectivityResult.none;
    final statusText = !isLoggedIn
        ? 'Masuk untuk mengaktifkan sinkronisasi cloud'
        : syncState.lastSyncedAt != null
        ? 'Terakhir sync ${DateFormatter.toRelativeTime(syncState.lastSyncedAt!)}'
        : (isOnline == null
              ? 'Memeriksa status sinkron...'
              : syncState.message);

    final unsyncedText = !isLoggedIn
        ? null
        : unsynced.maybeWhen(
            data: (count) => count > 0 ? '$count belum sinkron' : null,
            orElse: () => null,
          );

    final statusColor = !isLoggedIn
        ? AppColors.secondary
        : isOnline == null
        ? AppColors.textSecondary
        : (isOnline ? AppColors.success : AppColors.error);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                !isLoggedIn
                    ? Icons.lock_outline
                    : isOnline == null
                    ? Icons.cloud_queue
                    : (isOnline ? Icons.cloud_done : Icons.cloud_off),
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: Text(
                  statusText ?? 'Menunggu status sinkron',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              if (unsyncedText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    unsyncedText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (syncState.isSyncing)
            const Padding(
              padding: EdgeInsets.only(top: AppSizes.spacing8),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacing8),
            child: Row(
              children: [
                TextButton(
                  onPressed: syncState.isSyncing
                      ? null
                      : () {
                          if (!isLoggedIn) {
                            context.go(AppRouter.login);
                            return;
                          }
                          ref.read(syncProvider.notifier).syncToCloud();
                        },
                  child: Text(
                    isLoggedIn ? 'Sinkron sekarang' : 'Masuk untuk sync',
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),
                Text(
                  !isLoggedIn
                      ? 'Mode lokal'
                      : isOnline == null
                      ? 'Memeriksa jaringan'
                      : (isOnline ? 'Terhubung' : 'Offline'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
