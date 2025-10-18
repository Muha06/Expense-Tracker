import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      // rectangular border
      shape: RoundedRectangleBorder(
        // xtics of he border itself
        side: const BorderSide(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            //row for category and date
            Row(
              children: [
                Expanded(
                  child: Text(
                    'KES ${expense.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 16),
                //row for icon and date
                SizedBox(
                  width: 110,
                  child: Row(
                    children: [
                      Icon(categoryIcons[expense.category]),
                      const SizedBox(width: 5),
                      Text(
                        expense.formattedDate.toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
