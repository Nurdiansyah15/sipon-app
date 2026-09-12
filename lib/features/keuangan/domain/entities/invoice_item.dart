class InvoiceItem {
  const InvoiceItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final String title;
  final double amount;
  final double paidAmount;
  final String dueDate;
  final String status;
}
