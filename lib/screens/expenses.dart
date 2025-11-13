import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/search_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/screens/all_expenses_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/utils/slide_nav.dart';
import 'package:expense_tracker/widgets/amount_card.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/widgets/drawer.dart';
import 'package:expense_tracker/widgets/section_header.dart';
import 'package:expense_tracker/widgets/toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  bool isLoading = false;
  final searchController = TextEditingController();
  // ignore: unused_field
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

  Future<void> deleteExpense(Expense expense) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      // Delete the row
      final response = await supabase
          .from('expenses')
          .delete()
          .eq('id', expense.id)
          .select();

      //if response is empty
      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense not found or delete failed')),
        );
        return;
      }
      // Update local state
      ref.read(expenseListProvider.notifier).deleteExpense(expense);

      //undo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('expense deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              //add expense to db
              final response = await supabase
                  .from('expenses')
                  .insert({
                    'id': expense.id,
                    'user_id': user!.id,
                    'title': expense.title,
                    'category': expense.category,
                    'amount': expense.amount,
                    'date': expense.date.toIso8601String(),
                  })
                  .select()
                  .maybeSingle();

              //if inserted, insert to riverpod
              if (response != null) {
                ref.read(expenseListProvider.notifier).addExpense(expense);
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to delete expense')));
      ref.read(expenseListProvider.notifier).addExpense(expense);
    }

    //undo
  }

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
    //final allExpenses = ref.watch(expenseListProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

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
                      end: Alignment.bottomRight,
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
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
                        .from('expenses')
                        .stream(primaryKey: ['id'])
                        .eq(
                          'user_id',
                          Supabase.instance.client.auth.currentUser!.id,
                        )
                        .order('created_at', ascending: false),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!;
                      if (data.isEmpty) {
                        return const Center(child: Text('No expenses yet 💸'));
                      }

                      // map Supabase rows to Expense model
                      final allExpenses = data
                          .map(
                            (e) => Expense(
                              id: e['id'],
                              title: e['title'],
                              amount: e['amount'],
                              category: Category.values.firstWhere(
                                (c) => c.name == e['category'],
                                orElse: () => Category.food,
                              ),
                              date: DateTime.parse(e['date']),
                            ),
                          )
                          .toList();

                      // split into today/yesterday
                      final now = DateTime.now();
                      final today = allExpenses
                          .where(
                            (exp) =>
                                exp.date.year == now.year &&
                                exp.date.month == now.month &&
                                exp.date.day == now.day,
                          )
                          .toList();
                      final todayPreview = today.take(3).toList();

                      final yesterday = allExpenses.where((exp) {
                        final y = now.subtract(const Duration(days: 1));
                        return exp.date.year == y.year &&
                            exp.date.month == y.month &&
                            exp.date.day == y.day;
                      }).toList();
                      final yesterdayPreview = yesterday.take(3).toList();
                      return ListView(
                        children: [
                          SectionHeader(
                            title: 'Today',
                            onTap: () {
                              Navigator.of(context).push(
                                SlidePageRoute(
                                  page: AllExpensesScreen(
                                    expenses: today,
                                    onDeleteExpense: deleteExpense,
                                  ),
                                ),
                              );
                            },
                          ),

                          //today list
                          ExpensesList(
                            expenses: todayPreview,
                            onDeleteExpense: deleteExpense,
                          ),

                          SectionHeader(
                            title: 'Yesterday',
                            onTap: () {
                              Navigator.of(context).push(
                                SlidePageRoute(
                                  page: AllExpensesScreen(
                                    expenses: today,
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
                      );
                    },
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
