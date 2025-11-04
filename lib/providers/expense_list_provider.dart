import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ExpenseListNotifier extends StateNotifier<List<Expense>> {
  ExpenseListNotifier() : super([]);

  int totalAmount = 0;

  //adding to expense List
  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void deleteExpense(Expense expense) {
    state = state.where((e) {
      return e != expense;
    }).toList();
  }

  void insertExpense(Expense expense, int index) {
    //create a copy
    final newList = List<Expense>.from(state);
    newList.insert(index, expense);
    state = newList;
  }

  int get totalExpenseAmount {
    int total = 0;
    for (final exp in state) {
      total += exp.amount;
    }
    return total;
  }
}

final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, List<Expense>>((ref) {
      return ExpenseListNotifier();
    });

final totalExpenseProvider = Provider<int>((ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses.fold(0, (sum, e) => sum + e.amount);
});
