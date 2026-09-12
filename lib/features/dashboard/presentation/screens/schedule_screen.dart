import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../akademik/domain/entities/schedule_item.dart';
import '../../../akademik/presentation/providers/akademik_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  late DateTime _visibleMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = now.day;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AkademikProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final akademik = context.watch<AkademikProvider>();
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leadingDays = firstDay.weekday - 1;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final isCurrentMonth =
        today.year == _visibleMonth.year && today.month == _visibleMonth.month;
    final selectedDay = _selectedDay > daysInMonth ? daysInMonth : _selectedDay;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Jadwal Akademik'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthHeader(
              month: _months[_visibleMonth.month - 1],
              year: _visibleMonth.year,
              onPrevious: _goToPreviousMonth,
              onNext: _goToNextMonth,
            ),
            const SizedBox(height: 12),
            _Calendar(
              today: isCurrentMonth ? today.day : null,
              selectedDay: selectedDay,
              leadingDays: leadingDays,
              daysInMonth: daysInMonth,
              onDaySelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCurrentMonth && selectedDay == today.day
                      ? 'Jadwal Hari Ini'
                      : 'Jadwal $selectedDay ${_months[_visibleMonth.month - 1]}',
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  '${akademik.schedules.length} kegiatan',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (akademik.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (akademik.schedules.isEmpty)
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      akademik.error ?? 'Belum ada jadwal akademik.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              for (final item in akademik.schedules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ScheduleTile(
                    time: '${item.startTime} - ${item.endTime}',
                    title: item.activityName,
                    room: item.type,
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                    status: 'Terjadwal',
                  ),
                ),
            ],
            const SizedBox(height: 20),
            Text('Riwayat Kehadiran', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            _AttendanceCard(summary: akademik.attendance),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 2) context.go('/finance');
          if (index == 3) context.go('/notifications');
          if (index == 4) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
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

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
      _selectedDay = 1;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
      _selectedDay = 1;
    });
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.year,
    required this.onPrevious,
    required this.onNext,
  });
  final String month;
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        tooltip: 'Bulan sebelumnya',
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Text('$month $year', style: AppTextStyles.titleMedium),
      IconButton(
        tooltip: 'Bulan berikutnya',
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.today,
    required this.selectedDay,
    required this.leadingDays,
    required this.daysInMonth,
    required this.onDaySelected,
  });
  final int? today;
  final int selectedDay;
  final int leadingDays;
  final int daysInMonth;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Column(
        children: [
          Row(
            children: _ScheduleScreenState._days
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingDays + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              if (index < leadingDays) return const SizedBox.shrink();
              final day = index - leadingDays + 1;
              final isToday = day == today;
              final isSelected = day == selectedDay;
              return Center(
                child: InkWell(
                  onTap: () => onDaySelected(day),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : null,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      '$day',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.time,
    required this.title,
    required this.room,
    required this.icon,
    required this.color,
    required this.status,
  });
  final String time;
  final String title;
  final String room;
  final IconData icon;
  final Color color;
  final String status;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 19),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text('$time  •  $room'),
        trailing: _StatusTag(
          label: status,
          color: status == 'Hadir' ? AppColors.success : AppColors.textMuted,
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

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.summary});
  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AttendanceStat(
              label: 'Hadir',
              value: '${summary.present}',
              color: AppColors.success,
            ),
            _AttendanceStat(
              label: 'Izin',
              value: '${summary.excused}',
              color: AppColors.warning,
            ),
            _AttendanceStat(
              label: 'Alpha',
              value: '${summary.absent}',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AttendanceStat extends StatelessWidget {
  const _AttendanceStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
      const SizedBox(height: 2),
      Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}
