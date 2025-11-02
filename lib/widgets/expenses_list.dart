import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
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
    final isDarkMode = ref.watch(isDarkModeProvider);

    return ListView.builder(
      itemCount: allExpenses.length,
      //styling the individual item
      itemBuilder: (ctx, idx) => Dismissible(
        background: Container(
          width: 80,
          color: isDarkMode
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.error.withValues(alpha: 0.75),
          // margin: EdgeInsets.symmetric(
          //   horizontal: Theme.of(context).cardTheme.margin!.horizontal,
          // ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
        key: ValueKey(allExpenses[idx]),
        onDismissed: (direction) {
          onDeleteExpense(allExpenses[idx]);
        },
        //widget shown for each dissmissible
        child: ExpenseItem(expense: allExpenses[idx]),
      ),
    );
  }
}
