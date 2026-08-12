import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  /// `POST /web/auth/login` — body `{identifier, password}`.
  /// Response `data`: `{token, refresh_token, user}`.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'identifier': identifier, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// `POST /web/auth/register` — body `{username, email, password}`.
  /// Response `data`: `{user_id, token, refresh_token, user}` (registering
  /// signs the user in immediately, unlike a plain account-creation flow).
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(
          extractApiErrorMessage(e.response?.data) ??
              'Username atau email sudah digunakan.',
        );
      }
      _handleDioError(e);
    }
  }

  /// `GET /web/auth/me` (JWT) — response `data`: the user object directly.
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.me);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// `POST /auth/logout` (JWT) — revokes the current session server-side.
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    final message = extractApiErrorMessage(e.response?.data);
    if (message != null) throw ServerException(message);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw ServerException('Koneksi bermasalah. Periksa jaringan internet Anda.');
    }
    throw ServerException('Terjadi kesalahan yang tidak terduga.');
  }
}
