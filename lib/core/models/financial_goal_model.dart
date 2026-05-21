// lib/core/models/financial_goal_model.dart

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String category;
  final DateTime createdAt;
  final DateTime? targetDate;
  final bool isCompleted;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.category = 'Penghematan',
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0.0;

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? category,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      name: json['name'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      category: json['category'] ?? 'Penghematan',
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
