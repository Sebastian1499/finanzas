class Transaction {
  final String label;
  final double amount;
  final bool isIncome;

  const Transaction({
    required this.label,
    required this.amount,
    required this.isIncome,
  });
}
