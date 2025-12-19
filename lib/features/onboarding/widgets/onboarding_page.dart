import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Data class for onboarding page content
class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String>? features;

  OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.features,
  });
}

/// Single onboarding page widget
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.spacing24),
            // Illustration Container - use responsive sizing
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: data.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 80, color: data.iconColor),
            ),
            const SizedBox(height: AppSizes.spacing32),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Description or Features
            if (data.description.isNotEmpty)
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

            if (data.features != null && data.features!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacing8),
              ...data.features!.map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacing8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacing24),
          ],
        ),
      ),
    );
  }
}
