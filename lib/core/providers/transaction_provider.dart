// lib/core/providers/transaction_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  Future<void> addTransaction(TransactionModel transaction) async {
    // Save to Firestore
    state = [transaction, ...state];
  }

  Future<void> deleteTransaction(String id) async {
    state = state.where((t) => t.id != id).toList();
  }

  List<TransactionModel> getTransactionsByMonth(DateTime date) {
    return state.where((t) => 
      t.date.month == date.month && 
      t.date.year == date.year
    ).toList();
  }

  double getTotalIncome(DateTime date) {
    return getTransactionsByMonth(date)
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(DateTime date) {
    return getTransactionsByMonth(date)
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }
}
