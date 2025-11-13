import 'dart:convert';
import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/search_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/screens/all_expenses_screen.dart';
import 'package:expense_tracker/screens/auth/expense_service.dart';
import 'package:expense_tracker/widgets/amount_card.dart';
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
  late Future<List<Map<String, dynamic>>> _loadItems;

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

    final url = Uri.https(
      'expense-tracker-b5a45-default-rtdb.firebaseio.com',
      'expenses.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ref
          .read(expenseListProvider.notifier)
          .insertExpense(expense, expenseIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'${expense.title}' deleted"),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              ref
                  .read(expenseListProvider.notifier)
                  .insertExpense(expense, expenseIndex);

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
  }

  // Future<List<Map<String, dynamic>>> loadItems() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     if (data == null) {
  //       ref.read(expenseListProvider.notifier).setExpenses([]);
  //       setState(() => isLoading = false);
  //       return;
  //     }

  //     final List<Expense> loadedExpenses = [];
  //     for (final item in data.entries) {
  //       final int timestamp = item.value['date'];
  //       final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //       final category = Category.values.firstWhere(
  //         (cat) => cat.name == item.value['category'],
  //       );
  //       loadedExpenses.add(
  //         Expense(
  //           id: item.key,
  //           title: item.value['title'],
  //           amount: item.value['amount'],
  //           date: date,
  //           category: category,
  //         ),
  //       );
  //     }

  //     ref.read(expenseListProvider.notifier).setExpenses(loadedExpenses);
  //   } catch (e) {
  //     print('Error loading expenses: $e');
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadItems = ExpenseService().getExpenses();
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
      drawer: const MyDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(Icons.menu_rounded, size: 32),
                        ),
                      ),
                      Text(
                        'ExpenseTrak',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(fontSize: 24),
                      ),
                      const ThemeToggleSwitch(),
                    ],
                  ),
                ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(searchProvider.notifier).state = value
                            .trim()
                            .toLowerCase();
                      },
                    ),
                  ),
                ),
                const MyAmountCard(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            children: [
                              SectionHeader(
                                title: 'Today',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => AllExpensesScreen(
                                        expenses: today,
                                        onDeleteExpense: deleteExpense,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              ExpensesList(
                                expenses: todayPreview,
                                onDeleteExpense: deleteExpense,
                              ),

                              SectionHeader(
                                title: 'Yesterday',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => AllExpensesScreen(
                                        expenses: yesterday,
                                        onDeleteExpense: deleteExpense,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
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
      ),
    );
  }
}
