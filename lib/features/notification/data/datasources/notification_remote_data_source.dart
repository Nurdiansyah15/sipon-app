import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<Map<String, dynamic>>> getInbox({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.notificationsInbox,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat notifikasi.');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dioClient.post(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal menandai notifikasi.');
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dioClient.post('/web/notifications/$id/read');
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal menandai notifikasi.',
      );
    }
  }

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.notificationsPreferences,
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      return body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal memuat pengaturan notifikasi.',
      );
    }
  }

  Future<void> updatePreferences({
    required bool allNotificationsEnabled,
    required bool doNotDisturbEnabled,
  }) async {
    try {
      await _dioClient.put(
        ApiConstants.notificationsPreferences,
        data: {
          'all_notifications_enabled': allNotificationsEnabled,
          'do_not_disturb_enabled': doNotDisturbEnabled,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal menyimpan pengaturan notifikasi.',
      );
    }
  }
}
