import '../../domain/entities/billing_summary.dart';

class BillingSummaryModel extends BillingSummary {
  BillingSummaryModel({
    required super.totalTagihan,
    required super.totalTerbayar,
    required super.totalTunggakan,
    required super.jumlahInvoice,
    required super.jumlahLunas,
    required super.jumlahBelum,
  });

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory BillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BillingSummaryModel(
      totalTagihan: _num(json['total_tagihan']),
      totalTerbayar: _num(json['total_terbayar']),
      totalTunggakan: _num(json['total_tunggakan']),
      jumlahInvoice: _int(json['jumlah_invoice']),
      jumlahLunas: _int(json['jumlah_lunas']),
      jumlahBelum: _int(json['jumlah_belum']),
    );
  }
}
