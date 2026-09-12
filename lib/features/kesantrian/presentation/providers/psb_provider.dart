import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/psb_remote_data_source.dart';

class PsbProvider extends ChangeNotifier {
  PsbProvider(DioClient dioClient)
    : _remoteDataSource = PsbRemoteDataSource(dioClient);

  final PsbRemoteDataSource _remoteDataSource;
  var _isSaving = false;
  String? _error;

  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<bool> saveRegistration({
    required String gender,
    required String name,
    required String birthPlace,
    required String birthDate,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _remoteDataSource.saveRegistration(
        gender: gender,
        name: name,
        birthPlace: birthPlace,
        birthDate: birthDate,
      );
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String kind,
    required XFile file,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final bytes = await file.readAsBytes();
      final contentType = file.mimeType ?? 'image/jpeg';
      final presigned = await _remoteDataSource.presignDocument(
        kind: kind,
        filename: file.name,
        contentType: contentType,
      );
      final parts = presigned.split('|');
      await _remoteDataSource.uploadBytes(
        url: parts[0],
        bytes: bytes,
        contentType: contentType,
      );
      await _remoteDataSource.confirmDocument(kind: kind, key: parts[1]);
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
