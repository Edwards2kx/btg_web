enum TransactionType { deposit, subscription, cancellation }
enum NotificationMethod { email, sms }

class Transaction {
  final String id;
  final String? fundId;
  final String? fundName;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final NotificationMethod? notificationMethod;

  Transaction({
    required this.id,
    this.fundId,
    this.fundName,
    required this.date,
    required this.amount,
    required this.type,
    this.notificationMethod,
  });
}
