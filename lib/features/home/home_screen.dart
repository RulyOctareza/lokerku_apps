import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/job_application.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notification_service.dart';
import 'widgets/stats_card.dart';
import 'widgets/job_card.dart';
import 'widgets/sync_status_indicator.dart';
import '../add_job/add_job_sheet.dart';

/// Home Screen - Dashboard
/// Shows stats summary and recent job applications
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<JobApplication> _recentJobs = [];
  Map<ApplicationStatus, int> _statusCounts = {};
  bool _isLoading = true;
  bool _isMultiSelectMode = false;
  final Set<int> _selectedIds = {};

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
      final jobs = await JobRepository.getAll();
      final breakdown = await JobRepository.getStatusBreakdown();

      if (mounted) {
        setState(() {
          _recentJobs = jobs.take(10).toList();
          _statusCounts = breakdown;
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

  int get _totalCount => _statusCounts.values.fold(0, (a, b) => a + b);

  int get _pendingCount =>
      (_statusCounts[ApplicationStatus.applied] ?? 0) +
      (_statusCounts[ApplicationStatus.interviewHR] ?? 0) +
      (_statusCounts[ApplicationStatus.interviewUser] ?? 0) +
      (_statusCounts[ApplicationStatus.technicalTest] ?? 0);

  int get _interviewCount =>
      (_statusCounts[ApplicationStatus.interviewHR] ?? 0) +
      (_statusCounts[ApplicationStatus.interviewUser] ?? 0);

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.interviewHR:
      case ApplicationStatus.interviewUser:
      case ApplicationStatus.technicalTest:
        return AppColors.secondary;
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lamaran'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${_selectedIds.length} lamaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedIds) {
        await JobRepository.delete(id);
      }
      setState(() {
        _isMultiSelectMode = false;
        _selectedIds.clear();
      });
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lamaran berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        AppPreferences.userDisplayName ?? AuthService.displayName ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Row(
                    children: [
                      // Avatar - tap to go to profile
                      GestureDetector(
                        onTap: () => context.push(AppRouter.profile),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: AuthService.photoUrl != null
                              ? NetworkImage(AuthService.photoUrl!)
                              : null,
                          child: AuthService.photoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing12),

                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppStrings.homeGreeting} $userName! 👋',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Semangat cari kerja!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      IconButton(
                        onPressed: () {
                          context.push(AppRouter.search);
                        },
                        icon: const Icon(Icons.search_rounded),
                      ),
                      IconButton(
                        onPressed: () async {
                          final notificationService = NotificationService();
                          final granted = await notificationService
                              .requestPermission(context);
                          if (!context.mounted) return;
                          NotificationService.showPermissionResult(
                            context,
                            granted,
                          );
                        },
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                  ),
                  child: const SyncStatusIndicator(),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total',
                          value: _totalCount.toString(),
                          subtitle: 'Lamaran',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: StatsCard(
                          title: 'Menunggu',
                          value: _pendingCount.toString(),
                          subtitle: 'Proses',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: StatsCard(
                          title: 'Interview',
                          value: _interviewCount.toString(),
                          subtitle: 'Jadwal',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Multi-select actions bar
              if (_isMultiSelectMode)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedIds.length} dipilih',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isMultiSelectMode = false;
                              _selectedIds.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Batal'),
                        ),
                        const SizedBox(width: AppSizes.spacing8),
                        ElevatedButton.icon(
                          onPressed: _deleteSelected,
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.homeRecentApplications,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all applications
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur lihat semua akan segera hadir',
                              ),
                            ),
                          );
                        },
                        child: const Text(AppStrings.homeViewAll),
                      ),
                    ],
                  ),
                ),
              ),

              // Job List
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.spacing32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_recentJobs.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.spacing32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSizes.spacing16),
                          Text(
                            'Belum ada lamaran',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSizes.spacing8),
                          Text(
                            'Tekan tombol + untuk menambah lamaran baru',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = _recentJobs[index];
                      final isSelected = _selectedIds.contains(job.id);

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.spacing12,
                        ),
                        child: Dismissible(
                          key: Key('job_${job.id}'),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(
                              left: AppSizes.spacing16,
                            ),
                            color: AppColors.secondary,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSizes.spacing16,
                            ),
                            color: AppColors.error,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Edit - navigate to detail
                              context.push('/job/${job.id}');
                              return false;
                            } else {
                              // Delete
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Lamaran'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus lamaran ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await JobRepository.delete(job.id);
                              _loadData();
                            }
                          },
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _isMultiSelectMode = true;
                                _selectedIds.add(job.id);
                              });
                            },
                            child: Stack(
                              children: [
                                JobCard(
                                  companyName: job.companyName,
                                  role: job.role,
                                  status: job.status.displayName,
                                  statusColor: _getStatusColor(job.status),
                                  timeAgo: _getTimeAgo(job.updatedAt),
                                  onTap: _isMultiSelectMode
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedIds.remove(job.id);
                                              if (_selectedIds.isEmpty) {
                                                _isMultiSelectMode = false;
                                              }
                                            } else {
                                              _selectedIds.add(job.id);
                                            }
                                          });
                                        }
                                      : () => context.push('/job/${job.id}'),
                                ),
                                if (_isMultiSelectMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: _recentJobs.length),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.spacing100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddJobSheet(),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
