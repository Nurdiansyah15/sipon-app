import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/psb_provider.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _documents = <String, bool>{
    'KTP Orang Tua': false,
    'Kartu Keluarga': false,
    'Akta Kelahiran': false,
  };

  @override
  Widget build(BuildContext context) {
    final psb = context.watch<PsbProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/admission'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Upload Dokumen'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _StepHeader(current: 2),
          const SizedBox(height: 20),
          Text('Dokumen Persyaratan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Pastikan dokumen terlihat jelas dan tidak buram.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ..._documents.keys.map(
            (name) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentTile(
                name: name,
                uploaded: _documents[name]!,
                onTap: () => _pickDocument(name),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/admission'),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      psb.isSaving || !_documents.values.every((value) => value)
                      ? null
                      : () => context.go('/admission-timeline'),
                  child: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocument(String name) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final kind = name.toLowerCase().replaceAll(' ', '_');
    final uploaded = await context.read<PsbProvider>().uploadDocument(
      kind: kind,
      file: file,
    );
    if (uploaded && mounted) setState(() => _documents[name] = true);
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.name,
    required this.uploaded,
    required this.onTap,
  });
  final String name;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: uploaded ? AppColors.successBg : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                uploaded ? Icons.check_rounded : Icons.upload_file_rounded,
                color: uploaded ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    uploaded
                        ? 'Dokumen berhasil diunggah'
                        : 'Ketuk untuk memilih dokumen',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              uploaded ? Icons.edit_outlined : Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    ),
  );
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 1; index <= 4; index++) ...[
        CircleAvatar(
          radius: 15,
          backgroundColor: index <= current
              ? AppColors.primary
              : AppColors.border,
          child: Text(
            '$index',
            style: TextStyle(
              color: index <= current ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (index != 4)
          Expanded(
            child: Container(
              height: 2,
              color: index < current ? AppColors.primary : AppColors.border,
            ),
          ),
      ],
    ],
  );
}
