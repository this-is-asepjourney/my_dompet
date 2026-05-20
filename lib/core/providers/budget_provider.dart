// lib/core/providers/budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget_model.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetNotifier() : super([]);

  void addBudget(BudgetModel budget) {
    state = [budget, ...state];
  }

  void updateBudget(BudgetModel updatedBudget) {
    state = state.map((budget) {
      if (budget.id == updatedBudget.id) {
        return updatedBudget;
      }
      return budget;
    }).toList();
  }

  void setBudgets(List<BudgetModel> budgets) {
    state = budgets;
  }
}
