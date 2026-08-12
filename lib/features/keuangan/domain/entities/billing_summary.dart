class BillingSummary {
  final double totalTagihan;
  final double totalTerbayar;
  final double totalTunggakan;
  final int jumlahInvoice;
  final int jumlahLunas;
  final int jumlahBelum;

  BillingSummary({
    required this.totalTagihan,
    required this.totalTerbayar,
    required this.totalTunggakan,
    required this.jumlahInvoice,
    required this.jumlahLunas,
    required this.jumlahBelum,
  });
}
