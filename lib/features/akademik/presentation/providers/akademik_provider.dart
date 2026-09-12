import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/akademik_remote_data_source.dart';
import '../../domain/entities/schedule_item.dart';

class AkademikProvider extends ChangeNotifier {
  AkademikProvider(DioClient dioClient)
    : _remoteDataSource = AkademikRemoteDataSource(dioClient);

  final AkademikRemoteDataSource _remoteDataSource;
  var _schedules = <ScheduleItem>[];
  var _attendance = const AttendanceSummary(present: 0, excused: 0, absent: 0);
  var _isLoading = false;
  String? _error;

  List<ScheduleItem> get schedules => List.unmodifiable(_schedules);
  AttendanceSummary get attendance => _attendance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _remoteDataSource.getMySchedules(),
        _remoteDataSource.getMyAttendance(),
      ]);
      _schedules = (results[0] as List<Map<String, dynamic>>)
          .map(_mapSchedule)
          .toList();
      _attendance = _mapAttendance(results[1] as Map<String, dynamic>);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleItem _mapSchedule(Map<String, dynamic> json) => ScheduleItem(
    id: json['id']?.toString() ?? '',
    activityName: json['activity_name'] as String? ?? 'Kegiatan Akademik',
    startTime: json['start_time'] as String? ?? '--:--',
    endTime: json['end_time'] as String? ?? '--:--',
    type: json['type'] as String? ?? 'academic',
  );

  AttendanceSummary _mapAttendance(Map<String, dynamic> json) {
    final summary = json['summary'];
    if (summary is! Map) {
      return const AttendanceSummary(present: 0, excused: 0, absent: 0);
    }
    int value(String key) => (summary[key] as num?)?.toInt() ?? 0;
    return AttendanceSummary(
      present: value('present'),
      excused: value('excused'),
      absent: value('absent'),
    );
  }
}
