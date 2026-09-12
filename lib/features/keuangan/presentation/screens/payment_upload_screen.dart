import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/keuangan_provider.dart';

class PaymentUploadScreen extends StatefulWidget {
  const PaymentUploadScreen({this.invoiceId, super.key});
  final String? invoiceId;

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  XFile? _file;
  final _referenceController = TextEditingController(text: '1234567890');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeuanganProvider>().load();
      _recoverLostImage();
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keuangan = context.watch<KeuanganProvider>();
    final invoice =
        keuangan.invoices
            .where((item) => item.id == widget.invoiceId)
            .firstOrNull ??
        (keuangan.invoices.isEmpty ? null : keuangan.invoices.first);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/finance'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Upload Pembayaran'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Pilih Metode Upload', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _UploadMethod(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  selected: _file != null,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _UploadMethod(
                  icon: Icons.image_outlined,
                  label: 'Galeri',
                  selected: _file != null,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: _file != null
                  ? const _ReceiptPreview()
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 42,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 8),
                        Text('Ketuk untuk upload bukti pembayaran'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Detail Pembayaran', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Tagihan'),
            child: Text(invoice?.title ?? 'Belum ada tagihan'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: '16 Sep 2026',
            decoration: const InputDecoration(
              labelText: 'Tanggal Transfer',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Nomor Referensi / Keterangan',
            ),
          ),
          const SizedBox(height: 20),
          if (keuangan.error != null)
            Text(
              keuangan.error!,
              style: const TextStyle(color: AppColors.error),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _file != null && invoice != null && !keuangan.isLoading
                ? _submit
                : null,
            icon: const Icon(Icons.send_rounded),
            label: Text(
              keuangan.isLoading ? 'Mengirim...' : 'Kirim Bukti Pembayaran',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null && mounted) setState(() => _file = file);
    } catch (error) {
      if (mounted) _showPickerError(error);
    }
  }

  Future<void> _recoverLostImage() async {
    try {
      final response = await ImagePicker().retrieveLostData();
      if (response.isEmpty || !mounted) return;
      final file = response.files?.firstOrNull;
      if (file != null) setState(() => _file = file);
      if (response.exception != null) _showPickerError(response.exception!);
    } catch (error) {
      if (mounted) _showPickerError(error);
    }
  }

  void _showPickerError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tidak dapat memilih gambar: $error')),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<KeuanganProvider>();
    final invoice =
        provider.invoices
            .where((item) => item.id == widget.invoiceId)
            .firstOrNull ??
        provider.invoices.first;
    final submitted = await provider.submitPayment(
      invoice: invoice,
      proof: _file!,
      reference: _referenceController.text.trim(),
    );
    if (!submitted || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran berhasil dikirim')),
    );
    context.go('/finance');
  }
}

class _UploadMethod extends StatelessWidget {
  const _UploadMethod({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: selected ? AppColors.primary : AppColors.textSecondary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    ),
  );
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Center(
        child: Container(
          width: 220,
          height: 120,
          color: Colors.white,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 36,
              ),
              SizedBox(height: 6),
              Text('bukti-transfer.jpg'),
            ],
          ),
        ),
      ),
      const Positioned(
        right: 8,
        top: 8,
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.black54,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
        ),
      ),
    ],
  );
}
