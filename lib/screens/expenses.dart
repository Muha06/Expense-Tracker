import 'dart:convert';

import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/search_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  void _showExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) {
        return const NewExpense();
      },
    );
  }

  void deleteExpense(Expense expense) {
    //INCASE OF UNDO:
    //find expense index
    final expenseIndex = ref.read(expenseListProvider).indexOf(expense);
    //delete expense
    ref.read(expenseListProvider.notifier).deleteExpense(expense);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref
                .read(expenseListProvider.notifier)
                .insertExpense(expense, expenseIndex);
          },
        ),
      ),
    );
  }

  void loadItems() async {
    //http url
    final url = Uri.https(
      'expense-tracker-32102-default-rtdb.firebaseio.com',
      'expenses.json',
    );
    final response = await http.get(url);
    final Map<String, dynamic> expenseData = json.decode(response.body);

    for (final exp in expenseData.entries) {
      //convert int time to type dateTime
      final int timeStamp = exp.value['date'];
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
      final category = Category.values.firstWhere((c) {
        return c.name == exp.value['category'];
      });
      //add the new expense to the state
      ref
          .read(expenseListProvider.notifier)
          .addExpense(
            Expense(
              title: exp.value['title'],
              amount: exp.value['amount'],
              date: date,
              category: category,
            ),
          );
    }
  }

  //load the expenses list when app starts
  @override
  void initState() {
    loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SearchController = TextEditingController();

    final isDarkmode = ref.watch(isDarkModeProvider);
    final allExpenses = ref.read(expenseListProvider);

    final width = MediaQuery.of(context).size.width;

    Widget mainContent = Center(
      child: Text(
        'No expenses added',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
    if (allExpenses.isEmpty) {
      mainContent;
    } else {
      mainContent = Expanded(
        child: ExpensesList(onDeleteExpense: deleteExpense),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ToggleSwitch(
              minWidth: 35.0,
              minHeight: 30.0,
              initialLabelIndex: isDarkmode ? 1 : 0,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.black,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              icons: const [Icons.sunny, Icons.brightness_2_rounded],
              iconSize: 20.0,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary, Colors.grey],
                [Theme.of(context).colorScheme.primary, Colors.grey],
              ],
              animate:
                  true, // with just animate set to true, default curve = Curves.easeIn
              curve: Curves.bounceInOut,
              onToggle: (idx) {
                ref.read(isDarkModeProvider.notifier).state = idx == 1;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showExpenseOverlay,
        child: const Icon(Icons.add),
      ),
      body: width > 600
          ? Row(
              children: [
                Expanded(flex: 1, child: Chart(expenses: allExpenses)),
                Expanded(flex: 2, child: mainContent),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: TextField(
                      controller: SearchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        ref.read(searchProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
                Chart(expenses: allExpenses),
                Expanded(child: mainContent),
              ],
            ),
    );
  }
}
