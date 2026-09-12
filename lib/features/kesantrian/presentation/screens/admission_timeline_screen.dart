import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class AdmissionTimelineScreen extends StatelessWidget {
  const AdmissionTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.go('/dashboard'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Riwayat Pendaftaran'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: AppColors.successBg,
              child: Icon(Icons.check_rounded, color: AppColors.success),
            ),
            title: const Text(
              'Status Pendaftaran',
              style: AppTextStyles.titleMedium,
            ),
            subtitle: const Text('Diterima'),
            trailing: const _StatusTag(),
          ),
        ),
        const SizedBox(height: 20),
        Text('Status Pendaftaran', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        const _TimelineItem(
          title: 'Pendaftaran Dibuat',
          date: '12 Sep 2026',
          detail: 'Formulir telah dikirim',
          isDone: true,
        ),
        const _TimelineItem(
          title: 'Dokumen Diverifikasi',
          date: '13 Sep 2026',
          detail: 'Semua dokumen lengkap',
          isDone: true,
        ),
        const _TimelineItem(
          title: 'Pendaftaran Diterima',
          date: '14 Sep 2026',
          detail: 'Dinyatakan diterima',
          isDone: true,
          isLast: true,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catatan Revisi', style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                const Text(
                  'Tidak ada catatan revisi. Dokumen Anda sudah lengkap.',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.successBg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      'Diterima',
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
    ),
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.date,
    required this.detail,
    required this.isDone,
    this.isLast = false,
  });
  final String title;
  final String date;
  final String detail;
  final bool isDone;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isDone ? AppColors.success : AppColors.border,
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.successBg),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
