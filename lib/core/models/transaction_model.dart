// lib/core/models/transaction_model.dart

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final TransactionType type;
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
}

enum TransactionType { income, expense }
