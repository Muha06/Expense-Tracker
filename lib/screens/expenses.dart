import 'dart:convert';
import 'dart:math';

import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/search_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/widgets/amount_card.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/widgets/drawer.dart';
import 'package:expense_tracker/widgets/section_header.dart';
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
      'expense-tracker-32102-default-rtdb.firebaseio.com',
      'expenses/${expense.id}.json',
    );

    final response = await http.delete(url);

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
        content: Text("'${expense.title}' deleted"),
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
    final allExpenses = ref.watch(expenseListProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    final now = DateTime.now();
    final today = allExpenses.where((exp) {
      return exp.date.year == now.year &&
          exp.date.month == now.month &&
          exp.date.day == now.day;
    }).toList();

    final yesterday = allExpenses.where((exp) {
      final y = now.subtract(const Duration(days: 1));
      return exp.date.year == y.year &&
          exp.date.month == y.month &&
          exp.date.day == y.day;
    }).toList();
    final todayPreview = today.take(3).toList();
    final yesterdayPreview = yesterday.take(3).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
        onPressed: _showExpenseOverlay,
        child: const Icon(Icons.add),
      ),

      //drawer
      drawer: const MyDrawer(),

      //seting app bg color
      body: SafeArea(
        child: Container(
          decoration: isDarkMode
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [
                      Color.fromARGB(255, 74, 2, 105),
                      Color.fromARGB(136, 17, 1, 27),
                    ],
                  ),
                )
              : null,

          //column whole whole screen
          child: Column(
            children: [
              //first child => row for title drawer, and theme toggleswitch
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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

              //child 2 => search textfield
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
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

              //child 3 => amount card
              const MyAmountCard(),

              //child 4 => Listview (row(text + btn) , maincontent, sctheader, list2)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          children: [
                            //#1 padding(row(text + button) )
                            const SectionHeader(title: 'Today'),

                            //#2 => our expenses list (listview.builder)
                            ExpensesList(
                              expenses: todayPreview,
                              onDeleteExpense: deleteExpense,
                            ),
                            const SectionHeader(title: 'yesterday'),
                            ExpensesList(
                              expenses: yesterdayPreview,
                              onDeleteExpense: deleteExpense,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
