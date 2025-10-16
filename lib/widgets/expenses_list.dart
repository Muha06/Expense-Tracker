import 'package:expense_tracker/widgets/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onDeleteExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, idx) => Dismissible(
        //key: asks which item?
        //it uniquely identifies which item was dismissed 
        key: ValueKey(expenses[idx]),
        //onDismissed wants a callback that will run after dsimissing the widget
        onDismissed: (direction) {
          //onDeleteExpense is the mthd, defined in expenses.dart
          //removes the item from the list.
          onDeleteExpense(expenses[idx]);
        },
        //widget shown for each dissmissible
        child: ExpenseItem(expense: expenses[idx]),
      ),
    );
  }
}
