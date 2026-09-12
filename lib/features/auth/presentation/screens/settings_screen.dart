import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Notifikasi', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Semua notifikasi'),
                  subtitle: const Text('Terima pemberitahuan dari IKHLAS'),
                  value: provider.allNotificationsEnabled,
                  onChanged: (value) => provider.updatePreferences(
                    allNotificationsEnabled: value,
                    doNotDisturbEnabled: provider.doNotDisturbEnabled,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('Jangan ganggu'),
                  subtitle: const Text(
                    'Matikan notifikasi pada waktu tertentu',
                  ),
                  value: provider.doNotDisturbEnabled,
                  onChanged: (value) => provider.updatePreferences(
                    allNotificationsEnabled: provider.allNotificationsEnabled,
                    doNotDisturbEnabled: value,
                  ),
                ),
              ],
            ),
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 20),
          Text('Akun', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Keamanan Akun'),
              subtitle: const Text('Pengaturan password dan akses akun'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                   context.go('/change-password'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
