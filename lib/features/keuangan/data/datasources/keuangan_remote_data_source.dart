import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class KeuanganRemoteDataSource {
  final DioClient _dioClient;

  KeuanganRemoteDataSource(this._dioClient);

  /// `GET /web/keuangan/summary`.
  Future<Map<String, dynamic>> getMySummary() async {
    try {
      final response = await _dioClient.get(ApiConstants.keuanganSummary);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat tagihan keuangan.');
    }
  }
}
