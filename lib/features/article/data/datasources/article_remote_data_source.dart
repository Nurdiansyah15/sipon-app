import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class ArticleRemoteDataSource {
  final DioClient _dioClient;

  ArticleRemoteDataSource(this._dioClient);

  /// `GET /web/articles?page=1&limit=6&status=published&sort_by=published_at&sort_type=DESC`
  Future<Map<String, dynamic>> getRecentArticles({int limit = 6}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.articles,
        queryParameters: {
          'page': 1,
          'limit': limit,
          'status': 'published',
          'sort_by': 'published_at',
          'sort_type': 'DESC',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat artikel.');
    }
  }
}
