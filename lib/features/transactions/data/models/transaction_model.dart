import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  TransactionModel({
    required super.id,
    super.fundId,
    super.fundName,
    required super.date,
    required super.amount,
    required super.type,
    super.notificationMethod,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      fundId: json['fundId'],
      fundName: json['fundName'],
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      notificationMethod: json['notificationMethod'] != null 
          ? NotificationMethod.values.firstWhere((e) => e.name == json['notificationMethod']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (fundId != null) 'fundId': fundId,
      if (fundName != null) 'fundName': fundName,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type.name,
      if (notificationMethod != null) 'notificationMethod': notificationMethod!.name,
    };
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      fundId: entity.fundId,
      fundName: entity.fundName,
      date: entity.date,
      amount: entity.amount,
      type: entity.type,
      notificationMethod: entity.notificationMethod,
    );
  }
}
