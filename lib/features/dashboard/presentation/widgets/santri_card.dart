import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../kesantrian/domain/entities/santri_profile.dart';
import 'dashboard_card.dart';

class SantriCard extends StatelessWidget {
  const SantriCard({
    super.key,
    required this.isLoading,
    required this.profile,
    this.error,
  });

  final bool isLoading;
  final SantriProfile? profile;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Status Kesantrian',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (error != null) {
      return Text(error!, style: const TextStyle(color: AppColors.error));
    }
    final p = profile;
    if (p == null) {
      return const Text(
        'Anda belum terdaftar sebagai santri.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    p.fullname ?? '-',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: p.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'NIS: ${p.nis}${p.program != null ? ' · ${p.program}' : ''}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isActive = normalized == 'aktif' || normalized == 'active';
    final bg = isActive ? AppColors.successBg : const Color(0xFFF1F5F9);
    final fg = isActive ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: fg)),
    );
  }
}
