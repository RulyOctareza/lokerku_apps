import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/job_application.dart';
import '../../data/repositories/job_repository.dart';

/// Stats Screen
/// Shows statistics and analytics about job applications
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<ApplicationStatus, int> _statusBreakdown = {};
  Map<JobPlatform, int> _platformBreakdown = {};
  int _totalCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statusBreakdown = await JobRepository.getStatusBreakdown();
      final platformBreakdown = await JobRepository.getPlatformBreakdown();
      final totalCount = await JobRepository.getCount();

      if (mounted) {
        setState(() {
          _statusBreakdown = statusBreakdown;
          _platformBreakdown = platformBreakdown;
          _totalCount = totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.interviewHR:
      case ApplicationStatus.interviewUser:
        return AppColors.secondary;
      case ApplicationStatus.technicalTest:
        return AppColors.info;
      case ApplicationStatus.offering:
        return AppColors.primary;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.withdrawn:
        return AppColors.textTertiary;
    }
  }

  int get _interviewCount =>
      (_statusBreakdown[ApplicationStatus.interviewHR] ?? 0) +
      (_statusBreakdown[ApplicationStatus.interviewUser] ?? 0);

  int get _appliedCount => _statusBreakdown[ApplicationStatus.applied] ?? 0;
  int get _offeringCount => _statusBreakdown[ApplicationStatus.offering] ?? 0;

  String get _appliedToInterviewRate {
    if (_appliedCount == 0) return '0%';
    final rate = (_interviewCount / _appliedCount * 100).toStringAsFixed(0);
    return '$rate%';
  }

  String get _interviewToOfferRate {
    if (_interviewCount == 0) return '0%';
    final rate = (_offeringCount / _interviewCount * 100).toStringAsFixed(0);
    return '$rate%';
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    // Sort platforms by count for display
    final sortedPlatforms = _platformBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.statsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.spacing24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLarge,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bar_chart_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: AppSizes.spacing12),
                            Text(
                              'Total: $_totalCount Lamaran',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Periode: $currentMonth',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing24),

                      // Empty state
                      if (_totalCount == 0) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.spacing32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: AppSizes.spacing16),
                                Text(
                                  'Belum ada data statistik',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: AppSizes.spacing8),
                                Text(
                                  'Tambahkan lamaran pertama Anda untuk melihat statistik',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Status Breakdown
                        Text(
                          AppStrings.statsBreakdown,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: ApplicationStatus.values
                                .where(
                                  (status) =>
                                      (_statusBreakdown[status] ?? 0) > 0,
                                )
                                .map((status) {
                                  final count = _statusBreakdown[status] ?? 0;
                                  final progress = _totalCount > 0
                                      ? count / _totalCount
                                      : 0.0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSizes.spacing8,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            status.displayName,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              backgroundColor: AppColors.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    _getStatusColor(status),
                                                  ),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppSizes.spacing12,
                                        ),
                                        Text(
                                          count.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing24),

                        // Platform Stats
                        Text(
                          AppStrings.statsPlatform,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(sortedPlatforms.length, (
                              index,
                            ) {
                              final item = sortedPlatforms[index];
                              if (item.value == 0) {
                                return const SizedBox.shrink();
                              }
                              final percentage = _totalCount > 0
                                  ? (item.value / _totalCount * 100)
                                        .toStringAsFixed(0)
                                  : '0';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.spacing8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.spacing12),
                                    Expanded(
                                      child: Text(
                                        item.key.displayName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing24),

                        // Conversion Rates
                        Text(
                          AppStrings.statsConversion,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildConversionCard(
                                context,
                                'Applied → Interview',
                                _appliedToInterviewRate,
                                Icons.trending_up,
                                AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            Expanded(
                              child: _buildConversionCard(
                                context,
                                'Interview → Offer',
                                _interviewToOfferRate,
                                Icons.workspace_premium,
                                AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSizes.spacing100),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildConversionCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
