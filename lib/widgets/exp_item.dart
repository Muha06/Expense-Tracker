import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpItem extends ConsumerWidget {
  const ExpItem({super.key, required this.expense});

  final Expense expense;
  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        alignment: Alignment.center,
        height: 85,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromARGB(96, 104, 58, 183)
              : const Color.fromARGB(209, 39, 0, 65),
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
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
          ),
          subtitle: Text(
            expense.formattedDate.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 12, color: Colors.grey),
          ),

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
                    color: isDarkMode ? Colors.white : Colors.white,
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
