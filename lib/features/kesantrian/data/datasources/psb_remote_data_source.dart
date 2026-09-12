import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class PsbRemoteDataSource {
  PsbRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<void> saveRegistration({
    required String gender,
    required String name,
    required String birthPlace,
    required String birthDate,
  }) async {
    try {
      await _dioClient.put(
        ApiConstants.psbRegistration,
        data: {
          'gender': gender == 'Laki-laki' ? 'male' : 'female',
          'nickname': name,
          'pob': birthPlace,
          'dob': _toIsoDate(birthDate),
        },
      );
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal menyimpan pendaftaran PSB.');
    }
  }

  String _toIsoDate(String value) {
    final parts = value.split(' ');
    if (parts.length != 3) return value;
    const months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'Mei': '05',
      'Jun': '06',
      'Jul': '07',
      'Agu': '08',
      'Sep': '09',
      'Okt': '10',
      'Nov': '11',
      'Des': '12',
    };
    return '${parts[2]}-${months[parts[1]] ?? '01'}-${parts[0].padLeft(2, '0')}T00:00:00Z';
  }

  Future<String> presignDocument({
    required String kind,
    required String filename,
    required String contentType,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.psbDocumentPresign,
        data: {
          'stage': 'psb',
          'kind': kind,
          'filename': filename,
          'content_type': contentType,
        },
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      final url = data['presign_url'] as String?;
      final key = data['key'] as String?;
      if (url == null || key == null) {
        throw ServerException('Response upload dokumen tidak lengkap.');
      }
      return '$url|$key';
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal menyiapkan upload dokumen.');
    }
  }

  Future<void> uploadBytes({
    required String url,
    required List<int> bytes,
    required String contentType,
  }) async {
    await Dio().put(
      url,
      data: bytes,
      options: Options(headers: {'Content-Type': contentType}),
    );
  }

  Future<void> confirmDocument({
    required String kind,
    required String key,
  }) async {
    try {
      await _dioClient.post(
        ApiConstants.psbDocuments,
        data: {'stage': 'psb', 'kind': kind, 'key': key},
      );
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal mengonfirmasi dokumen.');
    }
  }
}
