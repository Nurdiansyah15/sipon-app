import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_logo_mark.dart';

/// Gradient band at the top of the dashboard carrying the "IKHLAS" wordmark,
/// mirroring sipon-ui's `HeroBanner.vue`.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primaryDarker,
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogoMark(size: 56, filled: true),
          const SizedBox(height: 16),
          Text(
            'I K H L A S',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Integrated Kyai Galang Sewu Administration System',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
