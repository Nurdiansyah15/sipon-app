import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../constants/prefs_keys.dart';

/// Attaches the bearer token to every request and, on a 401, refreshes it
/// once via `POST /web/auth/refresh-token` — queuing any other requests that
/// fail with 401 while the refresh is in flight so they all retry with the
/// new token instead of each triggering their own refresh.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SharedPreferences _prefs;
  final VoidCallback? onTokenExpired;
  bool _isRefreshing = false;
  final List<_RequestQueueItem> _queue = [];

  AuthInterceptor(this.dio, this._prefs, {this.onTokenExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _prefs.getString(PrefsKey.accessToken.value);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = _prefs.getString(PrefsKey.refreshToken.value);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearAuthData();
      return handler.next(err);
    }

    // Avoid an infinite loop if the refresh call itself 401s.
    if (err.requestOptions.path.contains(ApiConstants.refreshToken)) {
      await _clearAuthData();
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    if (_isRefreshing) {
      _queue.add(_RequestQueueItem(requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(
            milliseconds: ApiConstants.connectionTimeout,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiConstants.receiveTimeout,
          ),
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final rawData = response.data as Map<String, dynamic>;
      final data = rawData['data'] is Map
          ? Map<String, dynamic>.from(rawData['data'] as Map)
          : <String, dynamic>{};
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw DioException(requestOptions: requestOptions, response: response);
      }
      await _prefs.setString(PrefsKey.accessToken.value, token);

      final newRefreshToken = data['refresh_token'] as String?;
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _prefs.setString(PrefsKey.refreshToken.value, newRefreshToken);
      }

      requestOptions.headers['Authorization'] = 'Bearer $token';
      final retryResponse = await dio.fetch(requestOptions);
      handler.resolve(retryResponse);

      for (final item in _queue) {
        item.options.headers['Authorization'] = 'Bearer $token';
        final queuedResponse = await dio.fetch(item.options);
        item.handler.resolve(queuedResponse);
      }
      _queue.clear();
    } catch (_) {
      await _clearAuthData();
      handler.next(err);
      for (final item in _queue) {
        item.handler.reject(
          DioException(
            requestOptions: item.options,
            error: 'Failed to refresh token, logged out.',
          ),
        );
      }
      _queue.clear();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearAuthData() async {
    await _prefs.remove(PrefsKey.accessToken.value);
    await _prefs.remove(PrefsKey.refreshToken.value);
    await _prefs.remove(PrefsKey.userProfile.value);
    onTokenExpired?.call();
  }
}

class _RequestQueueItem {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RequestQueueItem(this.options, this.handler);
}
