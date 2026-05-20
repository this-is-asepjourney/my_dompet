// lib/core/models/user_model.dart (update)
class UserModel {
  final String id;
  final String email;
  final String name;
  final int xp;
  final int level;
  final String badge;
  final List<String> achievements;
  final double totalSavings;
  final List<FinancialGoal> goals;
  final String? lastDailyClaim; // Add this
  final DateTime? createdAt; // Add this
  final DateTime? updatedAt; // Add this

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.xp = 0,
    this.level = 1,
    this.badge = '🌱 Pemula',
    this.achievements = const [],
    this.totalSavings = 0,
    this.goals = const [],
    this.lastDailyClaim,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? xp,
    int? level,
    String? badge,
    List<String>? achievements,
    double? totalSavings,
    List<FinancialGoal>? goals,
    String? lastDailyClaim,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badge: badge ?? this.badge,
      achievements: achievements ?? this.achievements,
      totalSavings: totalSavings ?? this.totalSavings,
      goals: goals ?? this.goals,
      lastDailyClaim: lastDailyClaim ?? this.lastDailyClaim,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'xp': xp,
    'level': level,
    'badge': badge,
    'achievements': achievements,
    'totalSavings': totalSavings,
    'goals': goals.map((g) => g.toJson()).toList(),
    'lastDailyClaim': lastDailyClaim,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}