import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Data class for timeline item
class TimelineData {
  final String status;
  final String time;
  final String? notes;
  final bool isFirst;
  final bool isActive;
  final bool isLast;

  TimelineData({
    required this.status,
    required this.time,
    this.notes,
    this.isFirst = false,
    this.isActive = false,
    this.isLast = false,
  });
}

/// Timeline Item Widget
/// Displays a single item in the status timeline
class TimelineItem extends StatelessWidget {
  final TimelineData data;

  const TimelineItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dotColor = data.isActive ? AppColors.primary : AppColors.border;
    final lineColor = AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Dot
                Container(
                  width: data.isActive ? 16 : 12,
                  height: data.isActive ? 16 : 12,
                  decoration: BoxDecoration(
                    color: data.isActive ? dotColor : Colors.transparent,
                    border: Border.all(color: dotColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),

                // Line
                if (!data.isLast)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.status,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: data.isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: data.isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        data.time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  // Notes
                  if (data.notes != null && data.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacing4),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.spacing12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Text(
                        data.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
