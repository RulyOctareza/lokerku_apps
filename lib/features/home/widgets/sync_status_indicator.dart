import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../providers/providers.dart';

/// Displays connectivity, sync status, and a manual sync action.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final connectivity = ref.watch(connectivityProvider);
    final unsynced = ref.watch(unsyncedCountProvider);

    final isOnline = connectivity.asData?.value != ConnectivityResult.none;
    final statusText = syncState.lastSyncedAt != null
        ? 'Terakhir sync ${DateFormatter.toRelativeTime(syncState.lastSyncedAt!)}'
        : syncState.message;

    final unsyncedText = unsynced.maybeWhen(
      data: (count) => count > 0 ? '$count belum sinkron' : null,
      orElse: () => null,
    );

    final statusColor = isOnline ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: Text(
                  statusText ?? 'Menunggu status sinkron',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
                      : () => ref.read(syncProvider.notifier).syncToCloud(),
                  child: const Text('Sinkron sekarang'),
                ),
                const SizedBox(width: AppSizes.spacing12),
                Text(
                  isOnline ? 'Terhubung' : 'Offline',
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
