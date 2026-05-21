// lib/features/gamification/gamification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/providers/transaction_provider.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  GamificationScreenState createState() => GamificationScreenState();
}

class GamificationScreenState extends ConsumerState<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedBadgeIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(gamificationProvider);
    final transactions = ref.watch(transactionProvider);

    // Calculate stats for achievements
    final totalTransactions = transactions.length;
    final streak = _calculateStreak(transactions);
    final achievements = _checkAchievements(user.user, transactions);
    final nextLevelXP = _getNextLevelXP(user.user.level);
    final currentLevelXP = _getLevelStartXP(user.user.level);
    final progressToNextLevel =
        ((user.user.xp - currentLevelXP) / (nextLevelXP - currentLevelXP)) * 100;

    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header with Level and XP
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple, Colors.purple, Colors.pink],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Level Badge with Animation
                          GestureDetector(
                            onTap: () {
                              _animationController.forward().then(
                                (_) => _animationController.reverse(),
                              );
                              _confettiController.play();
                            },
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${user.user.level}',
                                            style: TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            'LEVEL',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            user.user.badge,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${user.user.xp} XP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // XP Progress Bar
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress ke Level ${user.user.level + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${user.user.xp - currentLevelXP} / ${nextLevelXP - currentLevelXP} XP',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressToNextLevel / 100,
                        backgroundColor: Colors.grey[200],
                        color: Colors.deepPurple,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt,
                          value: totalTransactions.toString(),
                          label: 'Transaksi',
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          value: streak.toString(),
                          label: 'Hari Aktif',
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events,
                          value: achievements.length.toString(),
                          label: 'Pencapaian',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievements Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 Pencapaian',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _allAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _allAchievements[index];
                            final isUnlocked = achievements.contains(
                              achievement.id,
                            );
                            return _AchievementCard(
                              achievement: achievement,
                              isUnlocked: isUnlocked,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Badges Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎖️ Badge yang Tersedia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _allBadges.length,
                        itemBuilder: (context, index) {
                          final badge = _allBadges[index];
                          final isUnlocked = user.user.level >= badge.minLevel;
                          return _BadgeCard(
                            badge: badge,
                            isUnlocked: isUnlocked,
                            onTap: () =>
                                setState(() => _selectedBadgeIndex = index),
                            isSelected: _selectedBadgeIndex == index,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tips to Earn More XP
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Tips Mendapatkan XP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _TipRow(
                            icon: Icons.add,
                            text: 'Tambah transaksi: +10 XP',
                          ),
                          _TipRow(
                            icon: Icons.photo_camera,
                            text: 'Scan struk: +5 XP',
                          ),
                          _TipRow(icon: Icons.mic, text: 'Input suara: +5 XP'),
                          _TipRow(
                            icon: Icons.check_circle,
                            text: 'Capai target budget: +50 XP',
                          ),
                          _TipRow(
                            icon: Icons.auto_graph,
                            text: 'Konsisten 7 hari: +100 XP',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingRewardButton(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingRewardButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showRewardsDialog(),
      icon: Icon(Icons.card_giftcard),
      label: Text('Klaim Reward'),
      backgroundColor: Colors.deepPurple,
    );
  }

  void _showRewardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎁 Reward Kamu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/gift.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            SizedBox(height: 16),
            Text(
              'Kamu memiliki 3 reward yang bisa diklaim!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            _RewardItem(
              icon: Icons.discount,
              title: 'Voucher Belanja',
              description: 'Diskon 10% untuk pembelanjaan',
              xpCost: 500,
            ),
            Divider(),
            _RewardItem(
              icon: Icons.emoji_events,
              title: 'Badge Eksklusif',
              description: 'Badge "Financial Master"',
              xpCost: 1000,
            ),
            Divider(),
            _RewardItem(
              icon: Icons.analytics,
              title: 'Premium Analytics',
              description: 'Akses fitur analitik lanjutan',
              xpCost: 2000,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return 0;

    final dates = transactions.map((t) => t.date).toSet().toList();
    dates.sort();

    int streak = 1;
    DateTime? lastDate = dates.last;

    for (int i = dates.length - 2; i >= 0; i--) {
      if (lastDate!.difference(dates[i]).inDays == 1) {
        streak++;
        lastDate = dates[i];
      } else {
        break;
      }
    }

    return streak;
  }

  List<String> _checkAchievements(
    UserModel user,
    List<TransactionModel> transactions,
  ) {
    final unlocked = <String>[];

    if (transactions.isNotEmpty) {
      unlocked.add('first_transaction');
    }
    if (user.totalSavings >= 1000000) {
      unlocked.add('save_1m');
    }
    if (_calculateStreak(transactions) >= 7) {
      unlocked.add('streak_7');
    }

    return unlocked;
  }

  int _getLevelStartXP(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    return 1500 + (level - 6) * 500;
  }

  int _getNextLevelXP(int currentLevel) {
    if (currentLevel < 1) return 100;
    if (currentLevel == 1) return 100;
    if (currentLevel == 2) return 300;
    if (currentLevel == 3) return 600;
    if (currentLevel == 4) return 1000;
    if (currentLevel == 5) return 1500;
    return 1500 + (currentLevel - 4) * 500;
  }
}

class _Achievement {
  final String id;
  final String title;
  final String emoji;
  final String description;

  const _Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

class _Badge {
  final String emoji;
  final String name;
  final int minLevel;

  const _Badge({
    required this.emoji,
    required this.name,
    required this.minLevel,
  });
}

const _allAchievements = [
  _Achievement(
    id: 'first_transaction',
    title: 'Transaksi Pertama',
    emoji: '🎯',
    description: 'Catat transaksi pertama',
  ),
  _Achievement(
    id: 'save_1m',
    title: 'Jutawan',
    emoji: '💰',
    description: 'Total tabungan Rp 1 juta',
  ),
  _Achievement(
    id: 'streak_7',
    title: 'Konsisten',
    emoji: '🔥',
    description: 'Aktif 7 hari berturut-turut',
  ),
];

const _allBadges = [
  _Badge(emoji: '🌱', name: 'Pemula', minLevel: 1),
  _Badge(emoji: '💰', name: 'Penabung', minLevel: 2),
  _Badge(emoji: '📊', name: 'Analis', minLevel: 3),
  _Badge(emoji: '🎯', name: 'Master', minLevel: 4),
  _Badge(emoji: '👑', name: 'Financial Guru', minLevel: 5),
  _Badge(emoji: '🏆', name: 'Legenda', minLevel: 6),
];

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isUnlocked ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.badge,
    required this.isUnlocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? Colors.deepPurple.shade50
            : isUnlocked
            ? Colors.white
            : Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badge.emoji,
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black : Colors.grey,
                ),
              ),
              if (!isUnlocked)
                Text(
                  'Lv ${badge.minLevel}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int xpCost;

  const _RewardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.xpCost,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Chip(
        label: Text('$xpCost XP'),
        backgroundColor: Colors.deepPurple.shade50,
      ),
    );
  }
}
