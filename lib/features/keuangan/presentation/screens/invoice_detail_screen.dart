import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/keuangan_provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({required this.invoiceId, super.key});
  final String invoiceId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<KeuanganProvider>().loadInvoice(widget.invoiceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeuanganProvider>();
    final invoice = provider.detailInvoice;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/finance'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detail Tagihan'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoice == null
          ? Center(
              child: Text(provider.error ?? 'Detail tagihan tidak tersedia.'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(invoice.title, style: AppTextStyles.titleLarge),
                        const SizedBox(height: 14),
                        _Row(
                          label: 'Total Tagihan',
                          value: _currency.format(invoice.amount),
                        ),
                        _Row(
                          label: 'Sudah Dibayar',
                          value: _currency.format(invoice.paidAmount),
                        ),
                        _Row(
                          label: 'Sisa Tagihan',
                          value: _currency.format(
                            invoice.amount - invoice.paidAmount,
                          ),
                        ),
                        _Row(label: 'Jatuh Tempo', value: invoice.dueDate),
                        _Row(label: 'Status', value: invoice.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go(
                    '/payment-upload?invoiceId=${widget.invoiceId}',
                  ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload Bukti Pembayaran'),
                ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
