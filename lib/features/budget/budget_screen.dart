// lib/features/budget/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/budget_provider.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/models/budget_model.dart';
import '../../core/models/transaction_model.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();
  
  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionProvider);
    
    final monthlyExpenses = _getMonthlyExpensesByCategory(transactions, _selectedMonth);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(),
            tooltip: 'Tambah Budget',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildSummaryCards(budgets, monthlyExpenses),
          const SizedBox(height: 16),
          Expanded(
            child: budgets.isEmpty
                ? const Center(
                    child: Text('Belum ada budget. Tap + untuk menambah budget'),
                  )
                : ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      final spent = monthlyExpenses[budget.category] ?? 0.0;
                      return _buildBudgetCard(budget, spent);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'id').format(_selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards(List<BudgetModel> budgets, Map<String, double> monthlyExpenses) {
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amount);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + (monthlyExpenses[b.category] ?? 0.0));
    final remaining = totalBudget - totalSpent;
    // FIX 1: Tambah .toDouble() agar num -> double
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).toDouble() : 0.0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: percentage > 80 
                  ? [Colors.orange, Colors.red]
                  : [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'Total Budget',
                    amount: totalBudget,
                    color: Colors.white,
                  ),
                  _SummaryItem(
                    label: 'Total Terpakai',
                    amount: totalSpent,
                    color: Colors.white70,
                  ),
                  _SummaryItem(
                    label: 'Sisa Budget',
                    amount: remaining,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalBudget > 0 ? totalSpent / totalBudget : 0.0,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(1)}% Terpakai',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBudgetCard(BudgetModel budget, double spent) {
    // FIX 2: Tambah .toDouble() agar num -> double
    final percentage = budget.amount > 0 ? (spent / budget.amount * 100).toDouble() : 0.0;
    final isOverBudget = spent > budget.amount;
    final budgetColor = _getBudgetColor(percentage);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          // FIX 3: Ganti .red/.green/.blue yang deprecated
          backgroundColor: Color.fromARGB(
            51,
            (budgetColor.r * 255.0).round().clamp(0, 255),
            (budgetColor.g * 255.0).round().clamp(0, 255),
            (budgetColor.b * 255.0).round().clamp(0, 255),
          ),
          child: Icon(
            _getCategoryIcon(budget.category),
            color: budgetColor,
          ),
        ),
        title: Text(
          budget.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: budget.amount > 0 ? spent / budget.amount : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : _getBudgetColor(percentage),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${NumberFormat('#,###').format(spent)} / Rp ${NumberFormat('#,###').format(budget.amount)}',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget ? Colors.red : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _showEditBudgetDialog(budget),
        ),
        onTap: () => _showBudgetDetail(budget, spent),
      ),
    );
  }
  
  Map<String, double> _getMonthlyExpensesByCategory(List<TransactionModel> transactions, DateTime month) {
    final Map<String, double> expenses = {};
    
    for (final transaction in transactions) {
      // FIX 4: Bandingkan dengan TransactionType enum, bukan String
      if (transaction.type == TransactionType.expense) {
        if (transaction.date.year == month.year && 
            transaction.date.month == month.month) {
          expenses[transaction.category] = (expenses[transaction.category] ?? 0) + transaction.amount;
        }
      }
    }
    
    return expenses;
  }
  
  Color _getBudgetColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_cart;
      case 'Hiburan':
        return Icons.movie;
      case 'Tagihan':
        return Icons.receipt;
      case 'Kesehatan':
        return Icons.health_and_safety;
      case 'Pendidikan':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
  
  void _showAddBudgetDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedCategory = _categories.first;
    String amountController = '';
    
    showDialog(
      context: context,
      // FIX 5: Pindahkan actions ke luar Form/content, langsung di AlertDialog
      builder: (context) => AlertDialog(
        title: const Text('Tambah Budget'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Jumlah Budget (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountController = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newBudget = BudgetModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  category: selectedCategory,
                  amount: double.parse(amountController),
                  month: DateTime.now(),
                );
                ref.read(budgetProvider.notifier).addBudget(newBudget);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget berhasil ditambahkan')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  void _showEditBudgetDialog(BudgetModel budget) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(text: budget.amount.toString());
    
    showDialog(
      context: context,
      // FIX 6: Pindahkan actions ke luar Form/content, langsung di AlertDialog
      builder: (context) => AlertDialog(
        title: Text('Edit Budget ${budget.category}'),
        content: Form(
          key: formKey,
          // FIX 7: Ganti 'value' yang deprecated ke 'initialValue', child jadi terakhir
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Jumlah Budget (Rp)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan jumlah budget';
              }
              if (double.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final updatedBudget = BudgetModel(
                  id: budget.id,
                  category: budget.category,
                  amount: double.parse(amountController.text),
                  month: budget.month,
                );
                ref.read(budgetProvider.notifier).updateBudget(updatedBudget);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget berhasil diupdate')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _showBudgetDetail(BudgetModel budget, double spent) {
    final remaining = budget.amount - spent;
    final percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Budget ${budget.category}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Budget', value: 'Rp ${NumberFormat('#,###').format(budget.amount)}'),
            const Divider(),
            _DetailRow(label: 'Terpakai', value: 'Rp ${NumberFormat('#,###').format(spent)}'),
            const Divider(),
            _DetailRow(
              label: 'Sisa', 
              value: 'Rp ${NumberFormat('#,###').format(remaining)}',
              color: remaining >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(),
            _DetailRow(
              label: 'Persentase', 
              value: '${percentage.toStringAsFixed(1)}%',
              color: _getBudgetColor(percentage),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  
  const _DetailRow({
    required this.label,
    required this.value,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}