import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class ExpItem extends StatelessWidget {
  const ExpItem({super.key, required this.expense});

  final Expense expense;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        alignment: Alignment.center,
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(96, 104, 58, 183),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        //listtile
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          //icon
          leading: Icon(
            categoryIcons[expense.category],
            color: Colors.white,
            size: 44,
          ),
          //title
          title: Text(
            expense.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          subtitle: Text(expense.formattedDate.toString()),

          trailing: Text.rich(
            TextSpan(
              text: 'KES ',
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: Colors.grey),
              children: [
                TextSpan(
                  text: expense.amount.toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
