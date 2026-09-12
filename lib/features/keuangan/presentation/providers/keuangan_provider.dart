import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/keuangan_portal_remote_data_source.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/payment_item.dart';

class KeuanganProvider extends ChangeNotifier {
  KeuanganProvider(DioClient dioClient)
    : _remoteDataSource = KeuanganPortalRemoteDataSource(dioClient);

  final KeuanganPortalRemoteDataSource _remoteDataSource;
  var _invoices = <InvoiceItem>[];
  var _payments = <PaymentItem>[];
  InvoiceItem? _detailInvoice;
  var _isLoading = false;
  String? _error;

  List<InvoiceItem> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentItem> get payments => List.unmodifiable(_payments);
  InvoiceItem? get detailInvoice => _detailInvoice;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _remoteDataSource.getMyInvoices();
      _invoices = raw.map(_mapInvoice).toList();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _remoteDataSource.getMyPayments();
      _payments = raw.map(_mapPayment).toList();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInvoice(String id) async {
    _isLoading = true;
    _error = null;
    _detailInvoice = null;
    notifyListeners();
    try {
      _detailInvoice = _mapInvoice(await _remoteDataSource.getInvoice(id));
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  InvoiceItem _mapInvoice(Map<String, dynamic> json) {
    final fee = json['fee_component'];
    final feeMap = fee is Map
        ? Map<String, dynamic>.from(fee)
        : const <String, dynamic>{};
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return InvoiceItem(
      id: json['id']?.toString() ?? '',
      title:
          feeMap['name'] as String? ??
          json['invoice_number']?.toString() ??
          'Tagihan',
      amount: number('amount'),
      paidAmount: number('paid_amount'),
      dueDate: json['due_date']?.toString() ?? '-',
      status: json['status'] as String? ?? 'unpaid',
    );
  }

  PaymentItem _mapPayment(Map<String, dynamic> json) => PaymentItem(
    id: json['id']?.toString() ?? '',
    paymentNumber: json['payment_number']?.toString() ?? '-',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    paymentDate: json['payment_date']?.toString() ?? '-',
    status: json['status'] as String? ?? 'pending',
    method: json['method'] as String? ?? 'transfer',
    referenceNumber: json['reference_number']?.toString(),
  );

  Future<bool> submitPayment({
    required InvoiceItem invoice,
    required XFile proof,
    required String reference,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final bytes = await proof.readAsBytes();
      final contentType = proof.mimeType ?? 'image/jpeg';
      final presigned = await _remoteDataSource.presignProof(proof);
      final parts = presigned.split('|');
      await _remoteDataSource.uploadProof(
        url: parts[0],
        bytes: bytes,
        contentType: contentType,
      );
      await _remoteDataSource.submitPayment(
        invoiceId: invoice.id,
        amount: invoice.amount - invoice.paidAmount,
        reference: reference,
        proofKey: parts[1],
      );
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
