// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/models/transaction_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final currentMonth = DateTime.now();
    
    final expenseByCategory = _calculateExpenseByCategory(transactions, currentMonth);
    final dailySpending = _calculateDailySpending(transactions, currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analitik Keuangan'),
        actions: [
          IconButton(
            icon: Icon(Icons.trending_up),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengeluaran per Kategori',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(expenseByCategory),
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...expenseByCategory.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: _getCategoryColor(entry.key),
                            ),
                            SizedBox(width: 8),
                            Text(entry.key),
                            Spacer(),
                            Text(NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(entry.value)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tren Pengeluaran Harian',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(DateFormat('dd').format(
                                    DateTime(currentMonth.year, currentMonth.month, value.toInt())
                                  ));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: dailySpending.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _PredictionCard(transactions),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateExpenseByCategory(List<TransactionModel> transactions, DateTime month) {
    Map<String, double> result = {};
    
    transactions.where((t) => 
      t.type == 'expense' &&
      t.date.month == month.month &&
      t.date.year == month.year
    ).forEach((t) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    });
    
    return result;
  }

  List<double> _calculateDailySpending(List<TransactionModel> transactions, DateTime month) {
    List<double> dailySpending = List.filled(DateTime(month.year, month.month + 1, 0).day, 0.0);
    
    transactions.where((t) => 
      t.type == 'expense' &&
      t.date.month == month.month &&
      t.date.year == month.year
    ).forEach((t) {
      dailySpending[t.date.day - 1] += t.amount;
    });
    
    return dailySpending;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);
    
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 80,
        color: _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan': return Colors.orange;
      case 'Transportasi': return Colors.blue;
      case 'Belanja': return Colors.purple;
      case 'Hiburan': return Colors.pink;
      case 'Tagihan': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _PredictionCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  
  const _PredictionCard(this.transactions);

  @override
  Widget build(BuildContext context) {
    final lastMonth = DateTime.now().subtract(Duration(days: 30));
    final lastMonthExpense = transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(lastMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final prediction = lastMonthExpense * 1.05; // 5% increase prediction
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text('Prediksi Bulan Depan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Text('Berdasarkan pola pengeluaran Anda:',
              style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                  .format(prediction),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            SizedBox(height: 8),
            Text('⚠️ Perkiraan kenaikan 5% dari bulan lalu',
              style: TextStyle(fontSize: 12, color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}