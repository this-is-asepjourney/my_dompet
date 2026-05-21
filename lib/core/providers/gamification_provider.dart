// lib/core/providers/gamification_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dompet/core/providers/transaction_provider.dart';
import 'package:my_dompet/core/providers/budget_provider.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart';

// Provider untuk gamification state
final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref);
});

// Provider untuk membaca user data saja
final userProvider = Provider<UserModel>((ref) {
  final state = ref.watch(gamificationProvider);
  return state.user;
});

// Provider untuk membaca achievements
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(gamificationProvider);
  return state.unlockedAchievements;
});

// Provider untuk membaca streak
final streakProvider = Provider<int>((ref) {
  final state = ref.watch(gamificationProvider);
  return state.currentStreak;
});

// State class untuk gamification
class GamificationState {
  final UserModel user;
  final List<Achievement> unlockedAchievements;
  final List<Badge> unlockedBadges;
  final int currentStreak;
  final DateTime? lastActivityDate;
  final Map<String, int> weeklyXP;
  final List<Challenge> activeChallenges;
  final List<Reward> availableRewards;

  GamificationState({
    required this.user,
    required this.unlockedAchievements,
    required this.unlockedBadges,
    required this.currentStreak,
    this.lastActivityDate,
    required this.weeklyXP,
    required this.activeChallenges,
    required this.availableRewards,
  });

  GamificationState copyWith({
    UserModel? user,
    List<Achievement>? unlockedAchievements,
    List<Badge>? unlockedBadges,
    int? currentStreak,
    DateTime? lastActivityDate,
    Map<String, int>? weeklyXP,
    List<Challenge>? activeChallenges,
    List<Reward>? availableRewards,
  }) {
    return GamificationState(
      user: user ?? this.user,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      availableRewards: availableRewards ?? this.availableRewards,
    );
  }
}

// Notifier untuk mengelola gamification logic
class GamificationNotifier extends StateNotifier<GamificationState> {
  final Ref _ref;
  final NotificationService _notificationService = NotificationService();
  
  // Constants for XP rewards
  static const Map<String, int> xpRewards = {
    'add_transaction': 10,
    'scan_receipt': 5,
    'voice_input': 5,
    'budget_target_achieved': 50,
    'streak_7_days': 100,
    'streak_30_days': 500,
    'complete_challenge': 150,
    'save_1_million': 200,
    'save_5_million': 500,
    'save_10_million': 1000,
    'refer_friend': 50,
    'daily_login': 5,
  };

  GamificationNotifier(this._ref) : super(GamificationState(
    user: UserModel(
      id: '',
      email: '',
      name: '',
      xp: 0,
      level: 1,
      badge: '🌱 Pemula',
      achievements: [],
      totalSavings: 0,
      goals: [],
    ),
    unlockedAchievements: [],
    unlockedBadges: [],
    currentStreak: 0,
    lastActivityDate: null,
    weeklyXP: {},
    activeChallenges: _getInitialChallenges(),
    availableRewards: _getInitialRewards(),
  ));

  // Initialize user data from Firestore
  void initializeUser(UserModel user) {
    final lastActivity = state.lastActivityDate;
    final streak = _calculateStreak(lastActivity);
    
    state = state.copyWith(
      user: user,
      currentStreak: streak,
      lastActivityDate: DateTime.now(),
    );
    
    _checkAndUpdateBadges();
    _checkAchievements();
  }

  // Add XP and handle level up
  Future<void> addXP(String action, {int? customAmount}) async {
    final xpAmount = customAmount ?? xpRewards[action] ?? 0;
    if (xpAmount == 0) return;
    
    final newXP = state.user.xp + xpAmount;
    final oldLevel = state.user.level;
    final newLevel = _calculateLevel(newXP);
    
    // Update weekly XP
    final weekKey = _getCurrentWeekKey();
    final weeklyXP = Map<String, int>.from(state.weeklyXP);
    weeklyXP[weekKey] = (weeklyXP[weekKey] ?? 0) + xpAmount;
    
    // Update user
    final updatedUser = state.user.copyWith(
      xp: newXP,
      level: newLevel,
    );
    
    state = state.copyWith(
      user: updatedUser,
      weeklyXP: weeklyXP,
    );
    
    // Check for level up
    if (newLevel > oldLevel) {
      await _handleLevelUp(oldLevel, newLevel);
    }
    
    // Check for streak bonus
    await _checkStreakBonus();
    
    // Check achievements after adding XP
    await _checkAchievements();
    
    // Update badges
    await _checkAndUpdateBadges();
    
    // Save to Firestore
    await _saveUserProgress();
  }

  // Handle level up event
  Future<void> _handleLevelUp(int oldLevel, int newLevel) async {
    final newBadge = _getBadgeForLevel(newLevel);
    
    // Update user with new badge
    final updatedUser = state.user.copyWith(
      badge: newBadge,
    );
    
    state = state.copyWith(user: updatedUser);
    
    // Show level up notification
    await _notificationService.showLocalNotification(
      '🎉 Level Up!',
      'Selamat! Anda naik ke Level $newLevel dan mendapatkan badge "$newBadge"',
      'level_up',
    );
    
    // Add bonus XP for level up
    final bonusXP = newLevel * 50;
    final userWithBonus = state.user.copyWith(
      xp: state.user.xp + bonusXP,
    );
    
    state = state.copyWith(user: userWithBonus);
    
    // Confetti animation can be triggered from the UI when a level-up event is observed.
  }

  // Add transaction and update stats
  Future<void> onTransactionAdded(TransactionModel transaction) async {
    // Add XP for transaction
    await addXP('add_transaction');
    
    // Update total savings if income
    if (transaction.type == 'income') {
      final newSavings = state.user.totalSavings + transaction.amount;
      final updatedUser = state.user.copyWith(
        totalSavings: newSavings,
      );
      state = state.copyWith(user: updatedUser);
      
      // Check savings achievements
      await _checkSavingsAchievements(newSavings);
    }
    
    // Update streak
    await _updateStreak();
    
    // Check daily challenge progress
    await _updateChallengeProgress('add_transaction');
  }

  // Update streak based on activity
  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final lastDate = state.lastActivityDate;
    
    if (lastDate == null) {
      // First activity
      state = state.copyWith(
        currentStreak: 1,
        lastActivityDate: now,
      );
    } else {
      final difference = now.difference(lastDate).inDays;
      
      if (difference == 1) {
        // Consecutive day
        final newStreak = state.currentStreak + 1;
        state = state.copyWith(
          currentStreak: newStreak,
          lastActivityDate: now,
        );
        
        // Check streak achievements
        await _checkStreakAchievements(newStreak);
      } else if (difference > 1) {
        // Streak broken
        state = state.copyWith(
          currentStreak: 1,
          lastActivityDate: now,
        );
      }
    }
  }

  // Check streak bonus
  Future<void> _checkStreakBonus() async {
    if (state.currentStreak == 7) {
      await addXP('streak_7_days');
      await _notificationService.showLocalNotification(
        '🔥 Streak 7 Hari!',
        'Luarr biasaa! Kamu konsisten selama 7 hari. +100 XP',
        'streak_bonus',
      );
    } else if (state.currentStreak == 30) {
      await addXP('streak_30_days');
      await _notificationService.showLocalNotification(
        '🏆 Streak 30 Hari!',
        'Wow! Kamu sudah konsisten sebulan penuh. +500 XP',
        'streak_bonus',
      );
    }
  }

  // Check and unlock achievements
  Future<void> _checkAchievements() async {
    final transactions = _ref.read(transactionProvider);
    final newlyUnlocked = <Achievement>[];
    
    // Check each achievement
    for (var achievement in _allAchievements) {
      if (!state.unlockedAchievements.contains(achievement)) {
        bool isUnlocked = false;
        
        switch (achievement.id) {
          case 'first_transaction':
            isUnlocked = transactions.isNotEmpty;
            break;
          case 'save_1m':
            isUnlocked = state.user.totalSavings >= 1000000;
            break;
          case 'save_5m':
            isUnlocked = state.user.totalSavings >= 5000000;
            break;
          case 'save_10m':
            isUnlocked = state.user.totalSavings >= 10000000;
            break;
          case 'streak_7':
            isUnlocked = state.currentStreak >= 7;
            break;
          case 'streak_30':
            isUnlocked = state.currentStreak >= 30;
            break;
          case 'budget_master':
            isUnlocked = await _checkBudgetMaster();
            break;
          case 'ocr_expert':
            isUnlocked = await _checkOCRMaster();
            break;
          case 'voice_master':
            isUnlocked = await _checkVoiceMaster();
            break;
          case 'transaction_100':
            isUnlocked = transactions.length >= 100;
            break;
          case 'level_5':
            isUnlocked = state.user.level >= 5;
            break;
          case 'level_10':
            isUnlocked = state.user.level >= 10;
            break;
          case 'category_master':
            isUnlocked = await _checkCategoryMaster();
            break;
          case 'early_bird':
            isUnlocked = await _checkEarlyBird();
            break;
          case 'night_owl':
            isUnlocked = await _checkNightOwl();
            break;
          case 'perfect_month':
            isUnlocked = await _checkPerfectMonth();
            break;
        }
        
        if (isUnlocked) {
          newlyUnlocked.add(achievement);
          // Add XP reward for achievement
          await addXP('achievement_unlocked', customAmount: achievement.xpReward);
          await _notificationService.showLocalNotification(
            '🏅 Achievement Unlocked!',
            'Kamu mendapatkan achievement "${achievement.name}"! +${achievement.xpReward} XP',
            'achievement',
          );
        }
      }
    }
    
    if (newlyUnlocked.isNotEmpty) {
      final updatedAchievements = [...state.unlockedAchievements, ...newlyUnlocked];
      state = state.copyWith(
        unlockedAchievements: updatedAchievements,
      );
      
      // Update user model
      final updatedUser = state.user.copyWith(
        achievements: updatedAchievements.map((a) => a.id).toList(),
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  // Check savings achievements
  Future<void> _checkSavingsAchievements(double savings) async {
    if (savings >= 1000000 && !state.user.achievements.contains('save_1m')) {
      await _checkAchievements();
    }
    if (savings >= 5000000 && !state.user.achievements.contains('save_5m')) {
      await _checkAchievements();
    }
    if (savings >= 10000000 && !state.user.achievements.contains('save_10m')) {
      await _checkAchievements();
    }
  }

  // Check streak achievements
  Future<void> _checkStreakAchievements(int streak) async {
    if (streak >= 7 && !state.user.achievements.contains('streak_7')) {
      await _checkAchievements();
    }
    if (streak >= 30 && !state.user.achievements.contains('streak_30')) {
      await _checkAchievements();
    }
  }

  // Check budget master achievement
  Future<bool> _checkBudgetMaster() async {
    // Check if user stayed within budget for 3 consecutive months
    // This would require historical data
    return false; // Implement with actual data
  }

  // Check OCR master achievement
  Future<bool> _checkOCRMaster() async {
    // Check if user has scanned 10 receipts
    // This would require tracking OCR usage
    return false; // Implement with actual data
  }

  // Check voice master achievement
  Future<bool> _checkVoiceMaster() async {
    // Check if user has used voice input 20 times
    return false; // Implement with actual data
  }

  // Check category master achievement
  Future<bool> _checkCategoryMaster() async {
    final transactions = _ref.read(transactionProvider);
    final categories = transactions.map((t) => t.category).toSet();
    return categories.length >= 8;
  }

  // Check early bird achievement (transaction before 9 AM)
  Future<bool> _checkEarlyBird() async {
    final transactions = _ref.read(transactionProvider);
    return transactions.any((t) => t.date.hour < 9);
  }

  // Check night owl achievement (transaction after 11 PM)
  Future<bool> _checkNightOwl() async {
    final transactions = _ref.read(transactionProvider);
    return transactions.any((t) => t.date.hour >= 23);
  }

  // Check perfect month achievement (no overspending for a month)
  Future<bool> _checkPerfectMonth() async {
    final budgets = _ref.read(budgetProvider);
    return budgets.every((b) => !b.isExceeded);
  }

  // Update and check badges
  Future<void> _checkAndUpdateBadges() async {
    final newlyUnlocked = <Badge>[];
    
    for (var badge in _allBadges) {
      if (!state.unlockedBadges.contains(badge) && state.user.level >= badge.minLevel) {
        newlyUnlocked.add(badge);
        await _notificationService.showLocalNotification(
          '🎖️ New Badge!',
          'Kamu mendapatkan badge "${badge.name}"!',
          'badge',
        );
      }
    }
    
    if (newlyUnlocked.isNotEmpty) {
      state = state.copyWith(
        unlockedBadges: [...state.unlockedBadges, ...newlyUnlocked],
      );
    }
  }

  // Update challenge progress
  Future<void> _updateChallengeProgress(String action) async {
    final updatedChallenges = state.activeChallenges.map((challenge) {
      if (challenge.requiredAction == action && !challenge.isCompleted) {
        final newProgress = challenge.currentProgress + 1;
        if (newProgress >= challenge.requiredAmount) {
          // Challenge completed
          _onChallengeCompleted(challenge);
          return challenge.copyWith(
            currentProgress: challenge.requiredAmount,
            isCompleted: true,
          );
        }
        return challenge.copyWith(currentProgress: newProgress);
      }
      return challenge;
    }).toList();
    
    state = state.copyWith(activeChallenges: updatedChallenges);
  }

  // Handle challenge completion
  Future<void> _onChallengeCompleted(Challenge challenge) async {
    await addXP('complete_challenge', customAmount: challenge.xpReward);
    await _notificationService.showLocalNotification(
      '🎯 Challenge Completed!',
      'Kamu menyelesaikan challenge "${challenge.title}"! +${challenge.xpReward} XP',
      'challenge',
    );
  }

  // Claim reward
  Future<bool> claimReward(Reward reward) async {
    if (state.user.xp >= reward.xpCost && !reward.isClaimed) {
      final newXP = state.user.xp - reward.xpCost;
      final updatedUser = state.user.copyWith(xp: newXP);
      
      final updatedRewards = state.availableRewards.map((r) {
        if (r.id == reward.id) {
          return r.copyWith(isClaimed: true);
        }
        return r;
      }).toList();
      
      state = state.copyWith(
        user: updatedUser,
        availableRewards: updatedRewards,
      );
      
      await _notificationService.showLocalNotification(
        '🎁 Reward Claimed!',
        'Selamat! Kamu mendapatkan ${reward.title}',
        'reward',
      );
      
      return true;
    }
    return false;
  }

  // Get daily reward
  Future<void> claimDailyReward() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (state.user.lastDailyClaim != today) {
      await addXP('daily_login');
      
      final updatedUser = state.user.copyWith(
        lastDailyClaim: today,
      );
      state = state.copyWith(user: updatedUser);
      
      await _notificationService.showLocalNotification(
        '🎁 Daily Reward!',
        'Kamu mendapatkan +5 XP untuk login hari ini!',
        'daily_reward',
      );
    }
  }

  // Get weekly XP total
  int getWeeklyXP() {
    final weekKey = _getCurrentWeekKey();
    return state.weeklyXP[weekKey] ?? 0;
  }

  // Get XP needed for next level
  int getXPForNextLevel() {
    final currentLevel = state.user.level;
    return _getNextLevelXP(currentLevel) - state.user.xp;
  }

  // Get progress percentage to next level
  double getProgressToNextLevel() {
    final currentLevel = state.user.level;
    final currentLevelXP = _getLevelStartXP(currentLevel);
    final nextLevelXP = _getNextLevelXP(currentLevel);
    final xpInCurrentLevel = state.user.xp - currentLevelXP;
    final xpNeededForNext = nextLevelXP - currentLevelXP;
    
    if (xpNeededForNext <= 0) return 1.0;
    return xpInCurrentLevel / xpNeededForNext;
  }

  // Helper methods
  int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2100) return 6;
    if (xp < 2800) return 7;
    if (xp < 3600) return 8;
    if (xp < 4500) return 9;
    if (xp < 5500) return 10;
    return 10 + ((xp - 5500) ~/ 1000);
  }

  int _getNextLevelXP(int currentLevel) {
    // Progressive XP requirements
    if (currentLevel == 1) return 100;
    if (currentLevel == 2) return 300;
    if (currentLevel == 3) return 600;
    if (currentLevel == 4) return 1000;
    if (currentLevel == 5) return 1500;
    if (currentLevel == 6) return 2100;
    if (currentLevel == 7) return 2800;
    if (currentLevel == 8) return 3600;
    if (currentLevel == 9) return 4500;
    return 5500 + ((currentLevel - 10) * 1000);
  }

  int _getLevelStartXP(int level) {
    if (level == 1) return 0;
    return _getNextLevelXP(level - 1);
  }

  String _getBadgeForLevel(int level) {
    switch (level) {
      case 1: return '🌱 Pemula';
      case 2: return '💰 Penabung Pemula';
      case 3: return '📊 Analis Keuangan';
      case 4: return '🎯 Master Budget';
      case 5: return '👑 Financial Guru';
      case 6: return '💎 Wealth Builder';
      case 7: return '⭐ Elite Saver';
      case 8: return '🏆 Legendary';
      case 9: return '👔 Financial Freedom';
      default: return '🚀 Infinite Wealth';
    }
  }

  int _calculateStreak(DateTime? lastDate) {
    if (lastDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(lastDate).inDays;
    
    if (difference == 0) return state.currentStreak;
    if (difference == 1) return state.currentStreak + 1;
    return 0;
  }

  String _getCurrentWeekKey() {
    final now = DateTime.now();
    final year = now.year;
    final week = ((now.difference(DateTime(year, 1, 1)).inDays) / 7).floor();
    return '$year-W$week';
  }

  Future<void> _saveUserProgress() async {
    // Firestore integration can be added here to persist user progress.
  }

  // Reset weekly challenges
  void resetWeeklyChallenges() {
    state = state.copyWith(
      activeChallenges: _getInitialChallenges(),
    );
  }
}

// Achievement Model
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int xpReward;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Badge Model
class Badge {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int minLevel;

  Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.minLevel,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Badge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Challenge Model
class Challenge {
  final String id;
  final String title;
  final String description;
  final String requiredAction;
  final int requiredAmount;
  final int currentProgress;
  final int xpReward;
  final bool isCompleted;
  final DateTime expiryDate;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredAction,
    required this.requiredAmount,
    this.currentProgress = 0,
    this.xpReward = 100,
    this.isCompleted = false,
    required this.expiryDate,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? requiredAction,
    int? requiredAmount,
    int? currentProgress,
    int? xpReward,
    bool? isCompleted,
    DateTime? expiryDate,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredAction: requiredAction ?? this.requiredAction,
      requiredAmount: requiredAmount ?? this.requiredAmount,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

// Reward Model
class Reward {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpCost;
  final bool isClaimed;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpCost,
    this.isClaimed = false,
  });

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? xpCost,
    bool? isClaimed,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpCost: xpCost ?? this.xpCost,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

// Initial data
List<Achievement> _allAchievements = [
  Achievement(
    id: 'first_transaction',
    name: 'First Step',
    description: 'Melakukan transaksi pertama',
    icon: Icons.rocket_launch,
    xpReward: 50,
  ),
  Achievement(
    id: 'save_1m',
    name: 'Millionaire Beginner',
    description: 'Mengumpulkan tabungan 1 juta',
    icon: Icons.attach_money,
    xpReward: 200,
  ),
  Achievement(
    id: 'save_5m',
    name: 'Multi-Millionaire',
    description: 'Mengumpulkan tabungan 5 juta',
    icon: Icons.monetization_on,
    xpReward: 500,
  ),
  Achievement(
    id: 'save_10m',
    name: 'Ten Million Club',
    description: 'Mengumpulkan tabungan 10 juta',
    icon: Icons.account_balance,
    xpReward: 1000,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Consistent Saver',
    description: 'Aktif selama 7 hari berturut-turut',
    icon: Icons.local_fire_department,
    xpReward: 100,
  ),
  Achievement(
    id: 'streak_30',
    name: 'Discipline Master',
    description: 'Aktif selama 30 hari berturut-turut',
    icon: Icons.emoji_events,
    xpReward: 500,
  ),
  Achievement(
    id: 'budget_master',
    name: 'Budget Master',
    description: 'Disiplin budget 3 bulan berturut-turut',
    icon: Icons.auto_graph,
    xpReward: 500,
  ),
  Achievement(
    id: 'ocr_expert',
    name: 'Tech Savvy',
    description: 'Scan 10 struk belanja',
    icon: Icons.document_scanner,
    xpReward: 150,
  ),
  Achievement(
    id: 'voice_master',
    name: 'Voice Commander',
    description: 'Gunakan input suara 20 kali',
    icon: Icons.mic,
    xpReward: 150,
  ),
  Achievement(
    id: 'transaction_100',
    name: 'Experienced User',
    description: 'Mencapai 100 transaksi',
    icon: Icons.receipt_long,
    xpReward: 300,
  ),
  Achievement(
    id: 'level_5',
    name: 'Rising Star',
    description: 'Mencapai Level 5',
    icon: Icons.grade,
    xpReward: 200,
  ),
  Achievement(
    id: 'level_10',
    name: 'Legendary Saver',
    description: 'Mencapai Level 10',
    icon: Icons.workspace_premium,
    xpReward: 1000,
  ),
  Achievement(
    id: 'category_master',
    name: 'Category Master',
    description: 'Menggunakan 8 kategori berbeda',
    icon: Icons.category,
    xpReward: 100,
  ),
  Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Transaksi sebelum jam 9 pagi',
    icon: Icons.wb_sunny,
    xpReward: 50,
  ),
  Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Transaksi setelah jam 11 malam',
    icon: Icons.nights_stay,
    xpReward: 50,
  ),
  Achievement(
    id: 'perfect_month',
    name: 'Perfect Month',
    description: 'Tidak melebihi budget sebulan penuh',
    icon: Icons.calendar_month,
    xpReward: 300,
  ),
];

List<Badge> _allBadges = [
  Badge(
    id: 'beginner',
    name: 'Pemula',
    icon: Icons.eco,
    color: Colors.green,
    minLevel: 1,
  ),
  Badge(
    id: 'saver',
    name: 'Penabung',
    icon: Icons.savings,
    color: Colors.blue,
    minLevel: 2,
  ),
  Badge(
    id: 'analyst',
    name: 'Analis',
    icon: Icons.analytics,
    color: Colors.purple,
    minLevel: 3,
  ),
  Badge(
    id: 'budget_master_badge',
    name: 'Master Budget',
    icon: Icons.auto_graph,
    color: Colors.teal,
    minLevel: 4,
  ),
  Badge(
    id: 'guru',
    name: 'Financial Guru',
    icon: Icons.psychology,
    color: Colors.deepPurple,
    minLevel: 5,
  ),
  Badge(
    id: 'elite',
    name: 'Elite Saver',
    icon: Icons.star,
    color: Colors.amber,
    minLevel: 6,
  ),
  Badge(
    id: 'legend',
    name: 'Legenda',
    icon: Icons.military_tech,
    color: Colors.red,
    minLevel: 7,
  ),
  Badge(
    id: 'wealth_builder',
    name: 'Wealth Builder',
    icon: Icons.trending_up,
    color: Colors.green,
    minLevel: 8,
  ),
  Badge(
    id: 'freedom',
    name: 'Financial Freedom',
    icon: Icons.celebration,
    color: Colors.purple,
    minLevel: 9,
  ),
  Badge(
    id: 'infinite',
    name: 'Infinite Wealth',
    icon: Icons.rocket,
    color: Colors.orange,
    minLevel: 10,
  ),
];

List<Challenge> _getInitialChallenges() {
  final now = DateTime.now();
  final weekLater = now.add(Duration(days: 7));
  
  return [
    Challenge(
      id: 'daily_transaction',
      title: 'Daily Saver',
      description: 'Tambahkan 5 transaksi hari ini',
      requiredAction: 'add_transaction',
      requiredAmount: 5,
      xpReward: 50,
      expiryDate: now.add(Duration(days: 1)),
    ),
    Challenge(
      id: 'weekly_budget',
      title: 'Budget Guardian',
      description: 'Jangan melebihi budget selama seminggu',
      requiredAction: 'stay_in_budget',
      requiredAmount: 7,
      xpReward: 200,
      expiryDate: weekLater,
    ),
    Challenge(
      id: 'scan_receipts',
      title: 'Receipt Scanner',
      description: 'Scan 3 struk belanja',
      requiredAction: 'scan_receipt',
      requiredAmount: 3,
      xpReward: 75,
      expiryDate: weekLater,
    ),
  ];
}

List<Reward> _getInitialRewards() {
  return [
    Reward(
      id: 'voucher_1',
      title: 'Voucher Belanja',
      description: 'Diskon 10% untuk pembelanjaan',
      icon: Icons.discount,
      xpCost: 500,
    ),
    Reward(
      id: 'exclusive_badge',
      title: 'Badge Eksklusif',
      description: 'Badge "Financial Master" eksklusif',
      icon: Icons.emoji_events,
      xpCost: 1000,
    ),
    Reward(
      id: 'premium_analytics',
      title: 'Premium Analytics',
      description: 'Akses fitur analitik lanjutan',
      icon: Icons.analytics,
      xpCost: 2000,
    ),
    Reward(
      id: 'custom_theme',
      title: 'Custom Theme',
      description: 'Buka tema eksklusif',
      icon: Icons.palette,
      xpCost: 1500,
    ),
    Reward(
      id: 'export_report',
      title: 'Export Report',
      description: 'Export laporan ke PDF/Excel',
      icon: Icons.description,
      xpCost: 800,
    ),
  ];
}