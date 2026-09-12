import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/psb_provider.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ahmad Fauzi');
  final _birthPlaceController = TextEditingController(text: 'Cirebon');
  final _birthDateController = TextEditingController(text: '12 Jan 2010');
  var _gender = 'Laki-laki';

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final psb = context.watch<PsbProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Pendaftaran Santri Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _StepHeader(current: 1),
            const SizedBox(height: 20),
            Text('Data Diri Santri', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap *'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _birthPlaceController,
              decoration: const InputDecoration(labelText: 'Tempat Lahir *'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir *',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Jenis Kelamin *'),
              items: const [
                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
              ],
              onChanged: (value) => setState(() => _gender = value ?? _gender),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Simpan Draft'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: psb.isSaving ? null : _continue,
                    child: psb.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Lanjut'),
                  ),
                ),
              ],
            ),
            if (psb.error != null) ...[
              const SizedBox(height: 12),
              Text(psb.error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await context.read<PsbProvider>().saveRegistration(
      gender: _gender,
      name: _nameController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim(),
    );
    if (saved && mounted) context.go('/documents');
  }
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
