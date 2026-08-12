import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shared shell for the dashboard's three sections: a titled card with an
/// optional inert trailing label (e.g. "Lihat Semua") — no destination
/// screen exists yet, so it's rendered as a static label, not a link.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.trailingLabel,
  });

  final String title;
  final Widget child;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (trailingLabel != null)
                Text(
                  trailingLabel!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
