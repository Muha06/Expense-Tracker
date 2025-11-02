import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/chart/chart_bar.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Chart extends ConsumerStatefulWidget {
  const Chart({super.key, required this.expenses});

  //chart class requres a list of expenses
  final List<Expense> expenses;

  @override
  ConsumerState<Chart> createState() => _ChartState();
}

class _ChartState extends ConsumerState<Chart> {
  List<Expense> allExpenses = [];
  void getAllExpenses() {
    final expenses = ref.watch(expenseListProvider);
    allExpenses = expenses;
  }

  //a method that returns a list of buckets per category using the named constr
  List<ExpenseBucket> get buckets {
    return [
      // 4 diff category bar
      ExpenseBucket.forCategory(allExpenses, Category.food),
      ExpenseBucket.forCategory(allExpenses, Category.leisure),
      ExpenseBucket.forCategory(allExpenses, Category.transport),
      ExpenseBucket.forCategory(allExpenses, Category.airtime),
    ];
  }

  //get maxtotalexpense recorded in all categories,
  int get maxTotalExpense {
    int maxTotalExpense = 0;

    for (final bucket in buckets) {
      if (bucket.totalAmount > maxTotalExpense) {
        maxTotalExpense = bucket.totalAmount;
      }
    }
    return maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    getAllExpenses();

    //checks if darkmode
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onPrimaryContainer,
            Theme.of(context).colorScheme.onPrimary,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      //container child
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //creates a chartBar widget for each bucket
                for (final bucket in buckets)
                  ChartBar(
                    //fill:
                    fill: bucket.totalAmount == 0
                        ? 0
                        : bucket.totalAmount / maxTotalExpense,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            //we map the buckets into icons widgets for each bar
            children: buckets
                .map(
                  (bucket) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        categoryIcons[bucket.category],
                        color: isDarkMode
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
