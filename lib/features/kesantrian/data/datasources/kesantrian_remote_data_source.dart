import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class KesantrianRemoteDataSource {
  final DioClient _dioClient;

  KesantrianRemoteDataSource(this._dioClient);

  /// `GET /web/santri/profile`. Returns `null` on 404 (not a santri yet).
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dioClient.get(ApiConstants.santriProfile);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat status kesantrian.');
    }
  }
}
