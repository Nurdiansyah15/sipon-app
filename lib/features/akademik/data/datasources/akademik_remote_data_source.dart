import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class AkademikRemoteDataSource {
  AkademikRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<Map<String, dynamic>>> getMySchedules() async {
    try {
      final response = await _dioClient.get(ApiConstants.mySchedules);
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat jadwal akademik.');
    }
  }

  Future<Map<String, dynamic>> getMyAttendance() async {
    try {
      final response = await _dioClient.get(ApiConstants.myAttendance);
      final body = Map<String, dynamic>.from(response.data as Map);
      return body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return <String, dynamic>{};
      }
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat riwayat kehadiran.');
    }
  }
}
