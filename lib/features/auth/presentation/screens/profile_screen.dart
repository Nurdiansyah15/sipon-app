import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_state_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthStateProvider>().currentUser;
    final profile = context.watch<DashboardProvider>().santriProfile;
    final name = user?.displayName ?? 'Ahmad Fauzi';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            _ProfileHeader(name: name, username: user?.username ?? 'santri'),
            const SizedBox(height: 16),
            _DigitalCard(
              name: name,
              nis: profile?.nis ?? '2026001234',
              program: profile?.program ?? 'Sains Islami',
            ),
            const SizedBox(height: 20),
            _MenuSection(
              children: [
                _MenuTile(
                  icon: Icons.description_outlined,
                  title: 'Dokumen Pribadi',
                ),
                _MenuTile(
                  icon: Icons.phone_outlined,
                  title: 'Kontak Pesantren',
                ),
                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Keamanan Akun',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MenuSection(
              children: [
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan',
                  subtitle: 'FAQ & kontak',
                ),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang IKHLAS',
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/schedule');
          if (index == 2) context.go('/finance');
          if (index == 3) context.go('/notifications');
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
            icon: Icon(Icons.account_balance_wallet_outlined),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.username});
  final String name;
  final String username;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const CircleAvatar(
        radius: 34,
        backgroundColor: Color(0xFFCCFBF1),
        child: Icon(
          Icons.person_rounded,
          size: 38,
          color: AppColors.primaryDark,
        ),
      ),
      const SizedBox(height: 10),
      Text(name, style: AppTextStyles.titleLarge),
      const SizedBox(height: 2),
      Text(
        '@$username',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

class _DigitalCard extends StatelessWidget {
  const _DigitalCard({
    required this.name,
    required this.nis,
    required this.program,
  });
  final String name;
  final String nis;
  final String program;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryDarker,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.qr_code_2_rounded, size: 86, color: Colors.white),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kartu Santri Digital',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NIS $nis',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
              Text(
                program,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Tunjukkan QR untuk presensi',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 1),
        ],
      ],
    ),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textMuted,
    ),
  );
}
