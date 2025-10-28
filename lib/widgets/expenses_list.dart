import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/widgets/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesList extends ConsumerWidget {
  const ExpensesList({
    super.key,
    //required this.expenses,
    required this.onDeleteExpense,
  });

  //final List<Expense> expenses;
  final void Function(Expense expense) onDeleteExpense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expenseListProvider);

    return ListView.builder(
      itemCount: allExpenses.length,
      //styling the individual item
      itemBuilder: (ctx, idx) => Dismissible(
        background: Container(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75),
          margin: EdgeInsets.symmetric(
            horizontal: Theme.of(context).cardTheme.margin!.horizontal,
          ),
        ),
        //key: asks which item?
        //it uniquely identifies which item was dismissed
        key: ValueKey(allExpenses[idx]),
        //onDismissed wants a callback that will run after dsimissing the widget
        onDismissed: (direction) {
          //onDeleteExpense is the mthd, defined in expenses.dart
          //removes the item from the list.
          onDeleteExpense(allExpenses[idx]);
        },
        //widget shown for each dissmissible
        child: ExpenseItem(expense: allExpenses[idx]),
      ),
    );
  }
}
