import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class AdminTasksScreen extends StatelessWidget {
  const AdminTasksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.go('/dashboard'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Admin - Tugas Anda'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _AdminTabs(),
        const SizedBox(height: 18),
        const _TaskTile(
          title: 'Verifikasi Dokumen PSB',
          detail: 'Ahmad Fauzi • KTP, KK, Akta',
          time: '2 jam lalu',
          color: AppColors.error,
          action: 'Verifikasi',
        ),
        const _TaskTile(
          title: 'Konfirmasi Pembayaran',
          detail: 'Budi Santoso • SPP September',
          time: '4 jam lalu',
          color: AppColors.success,
          action: 'Konfirmasi',
        ),
        const _TaskTile(
          title: 'Approve Pendaftar',
          detail: 'Siti Rahma • Pendaftaran PSB',
          time: '6 jam lalu',
          color: Color(0xFF2563EB),
          action: 'Approve',
        ),
      ],
    ),
  );
}

class _AdminTabs extends StatelessWidget {
  const _AdminTabs();

  @override
  Widget build(BuildContext context) => Row(
    children: ['Semua', 'PSB', 'Keuangan', 'Pembayaran']
        .map(
          (label) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(label),
                selected: label == 'Semua',
                onSelected: (_) {},
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: label == 'Semua'
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
                side: BorderSide.none,
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
    required this.action,
  });
  final String title;
  final String detail;
  final String time;
  final Color color;
  final String action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.assignment_outlined, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(detail),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: Text(action)),
        ],
      ),
    ),
  );
}
