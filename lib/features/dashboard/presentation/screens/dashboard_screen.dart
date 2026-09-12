import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final user = auth.currentUser;
    final profile = dashboard.santriProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ikhlas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => context.go('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          PopupMenuButton<String>(
            icon: _Avatar(url: user?.avatarUrl),
            onSelected: (value) async {
              if (value == 'profile') {
                context.go('/profile');
              }
              if (value == 'logout') {
                await context.read<AuthStateProvider>().logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Text(user?.displayName ?? 'Pengguna'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Keluar', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: dashboard.loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeBanner(name: user?.displayName ?? 'Santri'),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Status Pendaftaran PSB',
                  action: 'Detail',
                ),
                const SizedBox(height: 8),
                _StatusCard(
                  status: profile?.status ?? 'Diterima',
                  subtitle: profile == null
                      ? 'Data pendaftaran sedang dimuat'
                      : 'Data telah diterima sebagai santri baru',
                  onTap: () => context.go('/admission-timeline'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Tagihan Aktif',
                        value: 'Rp 1.800.000',
                        accent: AppColors.error,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'Kehadiran Hari Ini',
                        value: '3 / 4',
                        accent: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Jadwal Hari Ini', action: 'Lihat semua'),
                const SizedBox(height: 8),
                const _ScheduleCard(),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Shortcut'),
                const SizedBox(height: 8),
                _ShortcutRow(
                  onTap: (label) {
                    if (label == 'Bayar') {
                      context.go('/finance');
                    }
                    if (label == 'Dokumen') {
                      context.go('/documents');
                    }
                    if (label == 'Feedback') {
                      _showMessage(context, 'Feedback belum tersedia');
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (dashboard.billingError != null)
                  Text(
                    dashboard.billingError!,
                    style: const TextStyle(color: AppColors.error),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        onTap: (label) {
          if (label == 'Jadwal') {
            context.go('/schedule');
          } else if (label == 'Keuangan') {
            context.go('/finance');
          } else if (label == 'Notifikasi') {
            context.go('/notifications');
          } else if (label == 'Lainnya') {
            context.go('/profile');
          } else if (label != 'Beranda') {
            _showMessage(context, '$label belum tersedia');
          }
        },
      ),
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 16,
    backgroundColor: const Color(0xFFCCFBF1),
    backgroundImage: url != null && url!.isNotEmpty ? NetworkImage(url!) : null,
    child: url == null || url!.isEmpty
        ? const Icon(
            Icons.person_rounded,
            size: 18,
            color: AppColors.primaryDark,
          )
        : null,
  );
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primaryDarker,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assalamu\'alaikum,',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Selamat datang di IKHLAS',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppTextStyles.titleMedium),
      if (action != null)
        Text(
          action!,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
        ),
    ],
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.subtitle,
    required this.onTap,
  });
  final String status;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: const CircleAvatar(
        backgroundColor: AppColors.successBg,
        child: Icon(Icons.check_rounded, color: AppColors.success),
      ),
      title: Text(status, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 19),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: accent)),
        ],
      ),
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tafsir Al-Qur\'an', style: AppTextStyles.titleMedium),
                SizedBox(height: 4),
                Text('07:00 - 08:30  •  Aula Utama'),
              ],
            ),
          ),
          const _Tag(label: 'Hadir', color: AppColors.success),
        ],
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
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

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Shortcut(icon: Icons.payments_outlined, label: 'Bayar', onTap: onTap),
      _Shortcut(
        icon: Icons.description_outlined,
        label: 'Dokumen',
        onTap: onTap,
      ),
      _Shortcut(
        icon: Icons.support_agent_rounded,
        label: 'Feedback',
        onTap: onTap,
      ),
    ],
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 23),
            const SizedBox(height: 5),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: 0,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textMuted,
    onTap: (index) => onTap(
      ['Beranda', 'Jadwal', 'Keuangan', 'Notifikasi', 'Lainnya'][index],
    ),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
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
      BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Lainnya'),
    ],
  );
}
