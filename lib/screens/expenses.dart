import 'dart:convert';

import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/search_provider.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/widgets/drawer.dart';
import 'package:expense_tracker/widgets/toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final searchController = TextEditingController();

    final allExpenses = ref.watch(expenseListProvider);

    final width = MediaQuery.of(context).size.width;

    Widget mainContent = Center(
      child: Text(
        'No expenses added',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );

    if (allExpenses.isNotEmpty) {
      mainContent = Expanded(
        child: ExpensesList(onDeleteExpense: deleteExpense),
      );
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showExpenseOverlay,
          child: const Icon(Icons.add),
        ),
        drawer: const MyDrawer(),
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
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //drawer icon
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: const Icon(Icons.menu_rounded, size: 32),
                          ),
                        ),

                        //title
                        Text(
                          'ExpenseTrak',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(fontSize: 24),
                        ),

                        //theme toggle switch
                        const ThemeToggleSwitch(),
                      ],
                    ),
                  ),

                  //search textfield
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: TextField(
                        controller: searchController,
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
                  Expanded(child: mainContent),
                ],
              ),
      ),
    );
  }
}
