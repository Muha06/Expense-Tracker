import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:flutter/material.dart';

class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({
    super.key,
    required this.expenses,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onDeleteExpense;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ExpensesList(expenses: expenses, onDeleteExpense: onDeleteExpense),
    );
  }
}
