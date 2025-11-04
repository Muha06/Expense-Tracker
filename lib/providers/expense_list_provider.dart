import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/legacy.dart';

class ExpenseListNotifier extends StateNotifier<List<Expense>> {
  ExpenseListNotifier() : super([]);

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
}

final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, List<Expense>>((ref) {
      return ExpenseListNotifier();
    });
