// lib/core/models/budget_model.dart

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final DateTime month;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      category: json['category'],
      amount: json['amount'],
      month: DateTime.parse(json['month']),
    );
  }
}