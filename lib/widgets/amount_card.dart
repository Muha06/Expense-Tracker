import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/screens/chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAmountCard extends ConsumerWidget {
  const MyAmountCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final totalAmount = ref.watch(totalExpenseProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black54 : Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total spent ',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
              ),
            ),
          ),

          //amount row
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 0, left: 32),
            child: Row(
              spacing: 8,
              children: [
                Text(
                  'KES ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
                ),

                //amount
                Text(
                  totalAmount.toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChartPage()),
                  );
                },
                label: Text(
                  'View Chart',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down_outlined, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
