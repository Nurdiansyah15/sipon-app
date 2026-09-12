import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';

class KeuanganPortalRemoteDataSource {
  KeuanganPortalRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<Map<String, dynamic>>> getMyInvoices() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.keuanganInvoices,
        queryParameters: {'page': 1, 'limit': 20},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      final message = extractApiErrorMessage(e.response?.data);
      throw ServerException(message ?? 'Gagal memuat daftar tagihan.');
    }
  }

  Future<List<Map<String, dynamic>>> getMyPayments() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.payments,
        queryParameters: {'page': 1, 'limit': 30},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal memuat riwayat pembayaran.',
      );
    }
  }

  Future<Map<String, dynamic>> getInvoice(String id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.keuanganInvoices}/$id',
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      return Map<String, dynamic>.from(body['data'] as Map);
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal memuat detail tagihan.',
      );
    }
  }

  Future<String> presignProof(XFile file) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.paymentProofPresign,
        data: {
          'filename': file.name,
          'content_type': file.mimeType ?? 'image/jpeg',
        },
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      return '${data['presign_url']}|${data['key']}';
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal menyiapkan bukti pembayaran.',
      );
    }
  }

  Future<void> uploadProof({
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

  Future<void> submitPayment({
    required String invoiceId,
    required double amount,
    required String reference,
    required String proofKey,
  }) async {
    try {
      await _dioClient.post(
        ApiConstants.payments,
        data: {
          'invoice_id': invoiceId,
          'amount': amount,
          'method': 'transfer',
          'reference_number': reference,
          'payment_date': DateTime.now().toIso8601String().substring(0, 10),
          'proof_key': proofKey,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        extractApiErrorMessage(e.response?.data) ??
            'Gagal mengirim pembayaran.',
      );
    }
  }
}
