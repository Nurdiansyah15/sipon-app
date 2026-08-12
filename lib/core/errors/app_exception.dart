abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message);
}

class CacheException extends AppException {
  CacheException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Thrown on HTTP 404 — the referenced resource was not found.
class NotFoundException extends AppException {
  NotFoundException(super.message);
}

/// Thrown on HTTP 409 — conflicting state (e.g. email/username already taken).
class ConflictException extends AppException {
  ConflictException(super.message);
}

/// Pulls a human-readable message out of sipon-be's error envelope:
/// `{"status":"error","status_code":422,"error_code":"ERR_...","errors":...}`.
/// `errors` may be a plain string, or a field->messages map for validation
/// failures (`ERR_UNPROCESSABLE_ENTITY`). Falls back to `message` if present.
String? extractApiErrorMessage(dynamic data) {
  if (data is! Map) return null;
  final errors = data['errors'];
  if (errors is String && errors.trim().isNotEmpty) return errors.trim();
  if (errors is List && errors.isNotEmpty) {
    final first = errors.first;
    if (first != null && first.toString().trim().isNotEmpty) {
      return first.toString().trim();
    }
  }
  if (errors is Map && errors.isNotEmpty) {
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) return first.first.toString();
    if (first != null && first.toString().trim().isNotEmpty) {
      return first.toString().trim();
    }
  }
  final msg = data['message'];
  if (msg is String && msg.trim().isNotEmpty) return msg.trim();
  return null;
}
