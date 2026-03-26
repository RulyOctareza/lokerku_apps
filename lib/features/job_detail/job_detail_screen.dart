import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job_application.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/notification_service.dart';
import 'widgets/timeline_item.dart';

typedef ReminderPicker =
    Future<DateTime?> Function(
      BuildContext context,
      JobApplication job,
      DateTime? currentReminder,
    );

typedef ReminderScheduler =
    Future<void> Function(int jobId, String title, DateTime scheduledAt);

/// Job Detail Screen
/// Renders a full view of a job application plus timeline updates
class JobDetailScreen extends StatefulWidget {
  final int jobId;
  final Future<JobApplication?> Function(int id) jobLoader;
  final Future<void> Function(int id, ApplicationStatus status, {String? notes})
  statusUpdater;
  final Future<void> Function(int id) jobDeleter;
  final ReminderPicker? reminderPicker;
  final ReminderScheduler? reminderScheduler;

  const JobDetailScreen({
    super.key,
    required this.jobId,
    this.jobLoader = JobRepository.getById,
    this.statusUpdater = JobRepository.updateStatus,
    this.jobDeleter = JobRepository.delete,
    this.reminderPicker,
    this.reminderScheduler,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobApplication? _job;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isUpdatingReminder = false;
  DateTime? _reminder;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    setState(() => _isLoading = true);
    try {
      final job = await widget.jobLoader(widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
        });
        if (job != null) {
          _loadReminder(job.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    await _loadJob();
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

  void _showUpdateStatusSheet() async {
    if (_job == null) return;
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UpdateStatusSheet(
        currentStatus: _job!.status,
        onSave: (status, {String? notes}) async {
          await widget.statusUpdater(widget.jobId, status, notes: notes);
        },
      ),
    );

    if (updated == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diupdate!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      await _loadJob();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    if (_job == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text('Apakah Anda yakin ingin menghapus lamaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: const ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColors.error),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await widget.jobDeleter(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lamaran berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _loadReminder(int jobId) async {
    final reminder = AppPreferences.getJobReminder(jobId);
    if (!mounted) return;
    setState(() {
      _reminder = reminder;
    });
  }

  Future<DateTime?> _pickReminder(JobApplication job) {
    final picker = widget.reminderPicker ?? _defaultReminderPicker;
    return picker(context, job, _reminder);
  }

  Future<void> _setReminder() async {
    final job = _job;
    if (job == null) return;
    final picked = await _pickReminder(job);
    if (picked == null) return;

    setState(() => _isUpdatingReminder = true);

    try {
      final scheduler = widget.reminderScheduler ?? _defaultReminderScheduler;
      await scheduler(job.id, '${job.companyName} - ${job.role}', picked);
      await AppPreferences.setJobReminder(job.id, picked);

      if (!mounted) return;
      setState(() {
        _reminder = picked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.reminderSaved),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      await AppPreferences.setJobReminder(job.id, null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengingat: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingReminder = false);
      }
    }
  }

  Future<void> _clearReminder() async {
    final job = _job;
    if (job == null) return;
    setState(() => _isUpdatingReminder = true);
    try {
      await AppPreferences.setJobReminder(job.id, null);
      if (!mounted) return;
      setState(() {
        _reminder = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.reminderCleared),
          backgroundColor: AppColors.textTertiary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pengingat: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingReminder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.detailTitle),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: AppSizes.spacing8),
                    Text(
                      AppStrings.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _job == null
            ? const Center(child: Text('Data lamaran tidak ditemukan'))
            : RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSizes.spacing24),
                      _buildActionRow(context),
                      _buildReminderSection(context),
                      const SizedBox(height: AppSizes.spacing24),
                      Text(
                        AppStrings.timelineTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      _buildTimeline(),
                      const SizedBox(height: AppSizes.spacing40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final job = _job!;
    final salaryText = job.salary != null
        ? CurrencyFormatter.toRupiah(job.salary)
        : '—';

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      job.role,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(job.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              job.status.displayName,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _getStatusColor(job.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          _buildDetailRow(context, Icons.payments_outlined, salaryText),
          const SizedBox(height: AppSizes.spacing8),
          _buildDetailRow(
            context,
            Icons.launch_outlined,
            job.platform.displayName,
          ),
          const SizedBox(height: AppSizes.spacing8),
          _buildDetailRow(
            context,
            Icons.calendar_today_outlined,
            DateFormatter.toReadableDate(job.createdAt),
          ),
          const SizedBox(height: AppSizes.spacing8),
          _buildDetailRow(
            context,
            Icons.update,
            'Terakhir diperbarui ${DateFormatter.toRelativeTime(job.updatedAt)}',
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        key: const Key('job-detail-update-button'),
        onPressed: _isDeleting ? null : _showUpdateStatusSheet,
        icon: const Icon(Icons.update),
        label: const Text(AppStrings.updateStatus),
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    if (_job == null) return const SizedBox.shrink();

    final hasReminder = _reminder != null;
    final reminderText = hasReminder
        ? DateFormatter.toReadableDateTime(_reminder!)
        : AppStrings.reminderNone;
    final actionLabel = hasReminder
        ? AppStrings.reminderEditAction
        : AppStrings.reminderAddAction;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacing8),
              Text(
                AppStrings.reminderTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (hasReminder)
                TextButton(
                  onPressed: _isUpdatingReminder ? null : _clearReminder,
                  child: const Text(AppStrings.delete),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            reminderText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: hasReminder
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: (_isDeleting || _isUpdatingReminder)
                  ? null
                  : _setReminder,
              child: Text(actionLabel),
            ),
          ),
          if (_isUpdatingReminder)
            const Padding(
              padding: EdgeInsets.only(top: AppSizes.spacing12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  static Future<DateTime?> _defaultReminderPicker(
    BuildContext context,
    JobApplication job,
    DateTime? currentReminder,
  ) async {
    final now = DateTime.now();
    final initialDate = currentReminder ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return null;

    if (!context.mounted) return null;

    final initialTime = TimeOfDay.fromDateTime(currentReminder ?? now);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  static Future<void> _defaultReminderScheduler(
    int jobId,
    String title,
    DateTime scheduledAt,
  ) {
    return NotificationService().scheduleJobReminder(jobId, title, scheduledAt);
  }

  Widget _buildTimeline() {
    final logs = _job!.sortedLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'Belum ada log status',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: logs.asMap().entries.map((entry) {
        final index = entry.key;
        final log = entry.value;
        final isLast = index == logs.length - 1;

        return TimelineItem(
          data: TimelineData(
            status: log.statusEnum.displayName,
            time: DateFormatter.toRelativeTime(log.timestamp),
            notes: log.notes,
            isFirst: index == 0,
            isActive: index == 0,
            isLast: isLast,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.spacing8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _UpdateStatusSheet extends StatefulWidget {
  final ApplicationStatus currentStatus;
  final Future<void> Function(ApplicationStatus status, {String? notes}) onSave;

  const _UpdateStatusSheet({required this.currentStatus, required this.onSave});

  @override
  State<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<_UpdateStatusSheet> {
  late ApplicationStatus _selectedStatus = widget.currentStatus;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _selectedStatus,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.bottomSheetRadius),
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: AppSizes.bottomSheetHandleWidth,
                  height: AppSizes.bottomSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.updateStatus,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing16),
              Text(
                'Pilih status baru',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSizes.spacing12),
              RadioGroup<ApplicationStatus>(
                groupValue: _selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
                child: Column(
                  children: ApplicationStatus.values.map((status) {
                    return RadioListTile<ApplicationStatus>(
                      value: status,
                      title: Text(status.displayName),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
              Text(
                '${AppStrings.notesLabel} (Opsional)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSizes.spacing8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Interview dengan Bu Ani',
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Status'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
