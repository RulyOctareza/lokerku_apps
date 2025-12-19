import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/timeline_item.dart';

/// Job Detail Screen
/// Shows detailed information and timeline for a job application
class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    // Demo data
    final job = {
      'company': 'PT ABC Technology',
      'role': 'Flutter Developer',
      'status': 'Interview',
      'statusColor': AppColors.secondary,
      'salary': 'Rp 15.000.000',
      'platform': 'LinkedIn',
      'appliedDate': '20 Okt 2023',
    };

    final timeline = [
      TimelineData(
        status: 'Interview User',
        time: 'Baru saja',
        notes: 'Interview dengan CTO, jadwal Senin 10:00',
        isFirst: true,
        isActive: true,
      ),
      TimelineData(
        status: 'Interview HR',
        time: '2 hari lalu',
        notes: 'HRD namanya Bu Ani, baik sekali',
        isFirst: false,
        isActive: false,
      ),
      TimelineData(
        status: 'Applied',
        time: '5 hari lalu',
        notes: 'Via LinkedIn, referral dari Budi',
        isFirst: false,
        isActive: false,
        isLast: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.detailTitle),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // TODO: Handle menu actions
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              margin: const EdgeInsets.all(AppSizes.spacing16),
              padding: const EdgeInsets.all(AppSizes.spacing20),
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
                  // Company Icon
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['company'] as String,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              job['role'] as String,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing12,
                      vertical: AppSizes.spacing6,
                    ),
                    decoration: BoxDecoration(
                      color: (job['statusColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      job['status'] as String,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: job['statusColor'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Details
                  _buildDetailRow(
                    context,
                    Icons.payments_outlined,
                    job['salary'] as String,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  _buildDetailRow(
                    context,
                    Icons.launch_outlined,
                    'Via ${job['platform']}',
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today_outlined,
                    'Dilamar ${job['appliedDate']}',
                  ),
                ],
              ),
            ),

            // Update Status Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showUpdateStatusSheet(context);
                  },
                  icon: const Icon(Icons.update),
                  label: const Text(AppStrings.updateStatus),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // Timeline Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Text(
                AppStrings.timelineTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Timeline List
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Column(
                children: timeline
                    .map((item) => TimelineItem(data: item))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),
          ],
        ),
      ),
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

  void _showUpdateStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UpdateStatusSheet(),
    );
  }
}

/// Update Status Bottom Sheet
class _UpdateStatusSheet extends StatefulWidget {
  const _UpdateStatusSheet();

  @override
  State<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<_UpdateStatusSheet> {
  String _selectedStatus = 'Interview User';
  final _notesController = TextEditingController();

  final List<String> _statuses = [
    'Applied',
    'Interview HR',
    'Interview User',
    'Technical Test',
    'Offering',
    'Accepted',
    'Rejected',
    'Withdrawn',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.bottomSheetRadius),
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          // Title
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

          // Status Options
          Text(
            'Pilih Status Baru',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSizes.spacing12),
          ...List.generate(_statuses.length, (index) {
            final status = _statuses[index];
            return RadioListTile<String>(
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
              title: Text(status),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              dense: true,
            );
          }),
          const SizedBox(height: AppSizes.spacing16),

          // Notes
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

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Save status update
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status berhasil diupdate!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Simpan Status'),
            ),
          ),
        ],
      ),
    );
  }
}
