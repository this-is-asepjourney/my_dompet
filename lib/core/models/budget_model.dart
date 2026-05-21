// lib/core/models/budget_model.dart

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final double spent;
  final DateTime month;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    this.spent = 0,
    required this.month,
  });

  bool get isExceeded => spent > amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'spent': spent,
      'month': month.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      category: json['category'],
      amount: json['amount'],
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      month: DateTime.parse(json['month']),
    );
  }
}