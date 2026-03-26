import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

/// Header for the recent applications section that exposes a callback for
/// seeing all applications.
class RecentApplicationsHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const RecentApplicationsHeader({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.homeRecentApplications,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              AppStrings.homeViewAll,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
