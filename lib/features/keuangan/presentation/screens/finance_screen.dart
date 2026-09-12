import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/keuangan_provider.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      if (provider.billingSummary == null && !provider.isLoadingBilling) {
        provider.loadAll();
      }
      context.read<KeuanganProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final keuangan = context.watch<KeuanganProvider>();
    final summary = dashboard.billingSummary;
    final total = summary?.totalTagihan ?? 1800000;
    final paid = summary?.totalTerbayar ?? 0;
    final outstanding = summary?.totalTunggakan ?? total;
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Keuangan'),
        actions: [
          IconButton(
            tooltip: 'Riwayat pembayaran',
            onPressed: () => context.go('/payment-history'),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dashboard.loadAll();
          await keuangan.load();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BalanceCard(
                total: _currency.format(total),
                paid: _currency.format(paid),
                outstanding: _currency.format(outstanding),
                progress: progress,
              ),
              const SizedBox(height: 20),
              Text('Tagihan Aktif', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              if (keuangan.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (keuangan.invoices.isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        keuangan.error ?? 'Belum ada tagihan.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                for (final invoice in keuangan.invoices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _InvoiceTile(
                      title: invoice.title,
                      amount: _currency.format(invoice.amount),
                      due: 'Jatuh tempo ${invoice.dueDate}',
                      status: invoice.status,
                      statusColor:
                          invoice.status.toLowerCase() == 'paid' ||
                              invoice.status.toLowerCase() == 'lunas'
                          ? AppColors.success
                          : AppColors.error,
                      onTap: () => context.go('/invoice/${invoice.id}'),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              Text('Aksi Cepat', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/payment-upload'),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload Bukti'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text('Bayar'),
                    ),
                  ),
                ],
              ),
              if (dashboard.billingError != null) ...[
                const SizedBox(height: 12),
                Text(
                  dashboard.billingError!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/schedule');
          if (index == 3) context.go('/notifications');
          if (index == 4) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Keuangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.progress,
  });
  final String total;
  final String paid;
  final String outstanding;
  final double progress;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.primaryDarker,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Tagihan Aktif',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            outstanding,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_percent(progress)}% sudah dibayar dari $total',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              Expanded(
                child: _Amount(label: 'Total', value: total),
              ),
              Expanded(
                child: _Amount(label: 'Terbayar', value: paid),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  static String _percent(double value) => (value * 100).round().toString();
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({
    required this.title,
    required this.amount,
    required this.due,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });
  final String title;
  final String amount;
  final String due;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.12),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: statusColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      due,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusTag(label: status, color: statusColor),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
  );
}
