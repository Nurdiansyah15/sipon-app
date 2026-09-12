class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.activityName,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  final String id;
  final String activityName;
  final String startTime;
  final String endTime;
  final String type;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.present,
    required this.excused,
    required this.absent,
  });

  final int present;
  final int excused;
  final int absent;
}
