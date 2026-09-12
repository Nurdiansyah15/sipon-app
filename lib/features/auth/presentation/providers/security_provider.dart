import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class SecurityProvider extends ChangeNotifier {
  SecurityProvider(this._dioClient);
  final DioClient _dioClient;

  bool _isSaving = false;
  String? _error;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _dioClient.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (error) {
      _error = extractApiErrorMessage(error.response?.data) ?? 'Gagal mengubah password.';
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
