import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  var _approved = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.go('/admin-tasks'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Verifikasi Dokumen'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Color(0xFFCCFBF1),
            child: Icon(Icons.person_rounded, color: AppColors.primaryDark),
          ),
          title: Text('Ahmad Fauzi', style: AppTextStyles.titleMedium),
          subtitle: Text('PSB - 2026'),
        ),
        const SizedBox(height: 12),
        Text('Dokumen', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        const _DocumentRow(name: 'KTP Orang Tua', valid: true),
        const _DocumentRow(name: 'Kartu Keluarga', valid: true),
        const _DocumentRow(name: 'Akta Kelahiran', valid: true),
        const SizedBox(height: 20),
        Text('Catatan Admin', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan verifikasi...',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close_rounded),
                label: const Text('Tolak'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _approved = true),
                icon: const Icon(Icons.check_rounded),
                label: Text(_approved ? 'Terverifikasi' : 'Verifikasi'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.name, required this.valid});
  final String name;
  final bool valid;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: valid ? AppColors.success : AppColors.error,
      ),
      title: Text(name),
      trailing: TextButton(onPressed: () {}, child: const Text('Lihat')),
    ),
  );
}
