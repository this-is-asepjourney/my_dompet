// lib/core/models/transaction_model.dart

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type;
  final String? receiptImageUrl;
  final String? ocrText;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    this.receiptImageUrl,
    this.ocrText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'amount': amount,
    'category': category,
    'description': description,
    'date': date.toIso8601String(),
    'type': type.toString(),
    'receiptImageUrl': receiptImageUrl,
    'ocrText': ocrText,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      type: json['type'] as String? ?? 'expense',
      receiptImageUrl: json['receiptImageUrl'] as String?,
      ocrText: json['ocrText'] as String?,
    );
  }
}

enum TransactionType { income, expense }
