import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../keuangan/domain/entities/billing_summary.dart';
import 'dashboard_card.dart';

class BillingCard extends StatelessWidget {
  const BillingCard({
    super.key,
    required this.isLoading,
    required this.summary,
    this.error,
  });

  final bool isLoading;
  final BillingSummary? summary;
  final String? error;

  static final _currency = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Tagihan Keuangan',
      trailingLabel: 'Lihat Detail',
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
    final s = summary;
    if (s == null) {
      return const Text(
        'Tidak ada data tagihan.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Stat(label: 'Total Tagihan', value: _currency.format(s.totalTagihan)),
            ),
            Expanded(
              child: _Stat(
                label: 'Total Dibayar',
                value: _currency.format(s.totalTerbayar),
                color: AppColors.success,
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Total Tunggakan',
                value: _currency.format(s.totalTunggakan),
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${s.jumlahLunas} lunas · ${s.jumlahBelum} belum lunas dari ${s.jumlahInvoice} invoice',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
