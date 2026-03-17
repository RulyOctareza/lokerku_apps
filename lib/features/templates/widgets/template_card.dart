import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Data class for template card
class TemplateCardData {
  final String title;
  final String description;
  final bool isPremium;
  final String? content;

  TemplateCardData({
    required this.title,
    required this.description,
    required this.isPremium,
    this.content,
  });
}

/// Template Card Widget
class TemplateCard extends StatelessWidget {
  final TemplateCardData data;
  final VoidCallback? onTap;

  const TemplateCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.isPremium
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: data.isPremium
                      ? AppColors.secondary
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing2),
                    Text(
                      data.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.isPremium)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.spacing4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall,
                            ),
                          ),
                          child: Text(
                            'Premium',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Lock/Unlock Icon
              Icon(
                data.isPremium ? Icons.lock_outline : Icons.lock_open,
                color: data.isPremium
                    ? AppColors.textTertiary
                    : AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
