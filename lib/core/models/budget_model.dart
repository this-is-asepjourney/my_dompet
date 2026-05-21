// lib/core/models/budget_model.dart

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;
  final DateTime month;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.spent = 0,
    required this.month,
  });

  bool get isExceeded => spent > amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'spent': spent,
      'month': month.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] != null ? DateTime.parse(json['month']) : DateTime.now(),
    );
  }
}