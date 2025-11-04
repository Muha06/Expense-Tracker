import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartPage extends ConsumerStatefulWidget {
  const ChartPage({super.key});

  @override
  ConsumerState<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends ConsumerState<ChartPage> {
  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expenseListProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Expenses stats'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          
        ),
        body: Chart(expenses: allExpenses),
      ),
    );
  }
}
