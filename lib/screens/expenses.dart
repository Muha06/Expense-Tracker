import 'dart:convert';
import 'dart:math';

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
  bool isLoading = false;
  final searchController = TextEditingController();

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

  void deleteExpense(Expense expense) async {
    final expenseIndex = ref.read(expenseListProvider).indexOf(expense);
    ref.read(expenseListProvider.notifier).deleteExpense(expense);

    //delete in db
    final url = Uri.https(
      'expenses-tracker-32102-default-rtdb.firebaseio.com',
      'expenses/${expense.id}.json',
    );

    final response = await http.delete(url);

    print(response.statusCode);
    print(expense.id);

    if (response.statusCode >= 400) {
      ref
          .read(expenseListProvider.notifier)
          .insertExpense(expense, expenseIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something Unexpected happened!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    //delete locally

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          //undo logic locally & in db
          onPressed: () async {
            ref
                .read(expenseListProvider.notifier)
                .insertExpense(expense, expenseIndex);
            //undo in the db
            try {
              await http.put(
                url,
                body: json.encode({
                  'title': expense.title,
                  'amount': expense.amount,
                  'date': expense.date.millisecondsSinceEpoch,
                  'category': expense.category.name,
                }),
              );
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to restore expense in DB'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void loadItems() async {
    final url = Uri.https(
      'expense-tracker-32102-default-rtdb.firebaseio.com',
      'expenses.json',
    );

    setState(() {
      isLoading = true;
    });

    final response = await http.get(url);
    final Map<String, dynamic>? expenseData = json.decode(response.body);

    if (expenseData != null) {
      for (final exp in expenseData.entries) {
        final int timeStamp = exp.value['date'];
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        final category = Category.values.firstWhere((c) {
          return c.name == exp.value['category'];
        });

        ref
            .read(expenseListProvider.notifier)
            .addExpense(
              Expense(
                id: exp.key,
                title: exp.value['title'],
                amount: exp.value['amount'],
                date: date,
                category: category,
              ),
            );
      }
    }

    // always stop loading, even if DB was empty
    setState(() {
      isLoading = false;
    });
  }

  //load the expenses list when app starts
  @override
  void initState() {
    loadItems();
    super.initState();
    //unfocus keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final allExpenses = ref.watch(expenseListProvider);

    Widget mainContent = allExpenses.isEmpty
        ? Center(
            child: Text(
              'No expenses added',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        : ExpensesList(onDeleteExpense: deleteExpense);

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
                  //total amount card

                  //search textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: Theme.of(context).textTheme.bodyLarge!,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          ref.read(searchProvider.notifier).state = value
                              .trim()
                              .toLowerCase();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : mainContent,
                  ),
                ],
              ),
      ),
    );
  }
}
