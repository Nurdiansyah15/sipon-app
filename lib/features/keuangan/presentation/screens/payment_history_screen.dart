import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/keuangan_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<KeuanganProvider>().loadPayments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeuanganProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/finance'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Riwayat Pembayaran'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadPayments,
              child: provider.payments.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 180),
                        Center(
                          child: Text(
                            provider.error ?? 'Belum ada riwayat pembayaran.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: provider.payments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final payment = provider.payments[index];
                        final isSuccess =
                            payment.status.toLowerCase() == 'verified' ||
                            payment.status.toLowerCase() == 'paid';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (isSuccess
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withValues(alpha: 0.12),
                              child: Icon(
                                isSuccess
                                    ? Icons.check_rounded
                                    : Icons.pending_outlined,
                                color: isSuccess
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                            title: Text(
                              payment.paymentNumber,
                              style: AppTextStyles.titleMedium,
                            ),
                            subtitle: Text(
                              '${payment.paymentDate} • ${payment.method}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _currency.format(payment.amount),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  payment.status,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSuccess
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
