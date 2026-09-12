class PaymentItem {
  const PaymentItem({
    required this.id,
    required this.paymentNumber,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.method,
    this.referenceNumber,
  });

  final String id;
  final String paymentNumber;
  final double amount;
  final String paymentDate;
  final String status;
  final String method;
  final String? referenceNumber;
}
