import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // USERS COLLECTION
  // ==========================================

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  // ==========================================
  // TRANSACTIONS COLLECTION
  // ==========================================

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.collection('transactions').doc(transaction.id).set(transaction.toJson());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.collection('transactions').doc(transaction.id).update(transaction.toJson());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection('transactions').doc(transactionId).delete();
  }

  Stream<List<TransactionModel>> getTransactionsByUser(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  // ==========================================
  // BUDGETS COLLECTION
  // ==========================================

  Future<void> setBudget(BudgetModel budget) async {
    await _db.collection('budgets').doc(budget.id).set(budget.toJson());
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await _db.collection('budgets').doc(budget.id).update(budget.toJson());
  }

  Future<void> deleteBudget(String budgetId) async {
    await _db.collection('budgets').doc(budgetId).delete();
  }

  Stream<List<BudgetModel>> getBudgetsByUser(String userId) {
    return _db
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromJson(doc.data()))
            .toList());
  }
}
