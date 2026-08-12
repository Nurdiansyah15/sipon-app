import 'package:dio/dio.dart';

import 'app_exception.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  factory NetworkFailure.fromDioException(DioException e) {
    // Prefer the server's own message when the response carried one, so a
    // real API error (e.g. 422 validation) surfaces instead of a generic
    // string.
    final serverMessage = extractApiErrorMessage(e.response?.data);
    if (serverMessage != null) return NetworkFailure(serverMessage);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        'Koneksi bermasalah. Periksa jaringan internet Anda.',
      );
    }
    return const NetworkFailure('Terjadi kesalahan jaringan.');
  }
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// HTTP 404 — the referenced resource does not exist (e.g. the current user
/// has no santri record yet).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// HTTP 409 — conflicting state (e.g. email/username already registered).
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
