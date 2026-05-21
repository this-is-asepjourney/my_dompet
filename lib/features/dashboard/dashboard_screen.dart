// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/models/transaction_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final user = ref.watch(gamificationProvider);
    final currentMonth = DateTime.now();

    final totalIncome = ref
        .read(transactionProvider.notifier)
        .getTotalIncome(currentMonth);
    final totalExpense = ref
        .read(transactionProvider.notifier)
        .getTotalExpense(currentMonth);
    final balance = totalIncome - totalExpense;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Dompet Pandu'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.purple],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user.user.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Level ${user.user.level} • ${user.user.badge}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.user.xp} XP',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Saldo Saat Ini',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(balance),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _InfoChip(
                                    label: 'Pemasukan',
                                    amount: totalIncome,
                                    color: Colors.green,
                                  ),
                                  _InfoChip(
                                    label: 'Pengeluaran',
                                    amount: totalExpense,
                                    color: Colors.red,
                                  ),
                                ],
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
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return const _QuickActions();
              }
              if (index == 1) {
                return _RecentTransactions(transactions.take(5).toList());
              }
              return const SizedBox();
            }, childCount: 2),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.add_circle,
                label: 'Tambah\nTransaksi',
                color: Colors.green,
                onTap: () {
                  // Navigate to add transaction screen
                  Navigator.pushNamed(context, '/add-transaction');
                },
              ),
              _ActionButton(
                icon: Icons.trending_up,
                label: 'Laporan',
                color: Colors.blue,
                onTap: () {
                  // Navigate to report screen
                  Navigator.pushNamed(context, '/report');
                },
              ),
              _ActionButton(
                icon: Icons.emoji_events,
                label: 'Pencapaian',
                color: Colors.orange,
                onTap: () {
                  // Navigate to achievements screen
                  Navigator.pushNamed(context, '/achievements');
                },
              ),
              _ActionButton(
                icon: Icons.person,
                label: 'Profil',
                color: Colors.purple,
                onTap: () {
                  // Navigate to profile screen
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _RecentTransactions(this.transactions);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaksi Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Belum ada transaksi'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'income'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    child: Icon(
                      transaction.type == 'income'
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: transaction.type == 'income'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(transaction.date),
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == 'income'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  onTap: () {
                    // Navigate to transaction detail
                    Navigator.pushNamed(
                      context,
                      '/transaction-detail',
                      arguments: transaction,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
