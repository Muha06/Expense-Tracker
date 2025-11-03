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

    return Scaffold(body: Chart(expenses: allExpenses));
  }
}
