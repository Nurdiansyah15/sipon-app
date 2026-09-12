import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/security_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Keamanan Akun'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text('Ubah Password', style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _PasswordField(controller: _currentController, label: 'Password saat ini'),
            const SizedBox(height: 12),
            _PasswordField(controller: _newController, label: 'Password baru', validator: (value) => (value?.length ?? 0) < 8 ? 'Minimal 8 karakter' : null),
            const SizedBox(height: 12),
            _PasswordField(controller: _confirmController, label: 'Konfirmasi password', validator: (value) => value != _newController.text ? 'Password tidak sama' : null),
            if (security.error != null) ...[
              const SizedBox(height: 12),
              Text(security.error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: security.isSaving ? null : _submit,
              child: security.isSaving ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('Simpan Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await context.read<SecurityProvider>().changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
    context.go('/settings');
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.label, this.validator});
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: true,
    validator: validator ?? (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock_outline_rounded)),
  );
}
