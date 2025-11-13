import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final formatter = DateFormat.yMd();

class NewExpense extends ConsumerStatefulWidget {
  const NewExpense({super.key});

  @override
  ConsumerState<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends ConsumerState<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? expenseDate;
  Category _selectedCategory = Category.food;
  var isAdding = false;

  void _showDatePickerScreen() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    );
    setState(() {
      expenseDate = pickedDate;
    });
  }

  void _submitExpenseForm() async {
    final enteredAmount = int.tryParse(_amountController.text);
    final invalidAmount = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        invalidAmount ||
        expenseDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Invalid Input',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'Please confirm if you filled in correctly',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final response = await supabase
          .from('expenses')
          .insert({
            'user_id': user.id,
            'title': _titleController.text,
            'amount': enteredAmount,
            'category': _selectedCategory.name,
            'date': expenseDate!.toIso8601String(),
          })
          .select()
          .maybeSingle();

      ref
          .read(expenseListProvider.notifier)
          .addExpense(
            Expense(
              id: response!['id'] as String,
              title: _titleController.text,
              amount: enteredAmount,
              date: expenseDate!,
              category: _selectedCategory,
            ),
          );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Error adding an expense'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton(
      value: _selectedCategory,
      items: Category.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final isDarkMode = ref.watch(isDarkModeProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, 32, 18, keyboardSpace + 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    hintText: 'Expense Title',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //amount date row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefixText: 'KES ',
                          labelText: 'Amount',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          expenseDate == null
                              ? Text(
                                  'No date selected',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 10,
                                      ),
                                )
                              : Text(
                                  formatter.format(expenseDate!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                      ),
                                ),
                          const SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              size: 24,
                            ),
                            onPressed: _showDatePickerScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCategoryDropdown(),
                    TextButton(
                      onPressed: isAdding ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDarkMode
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                      onPressed: _submitExpenseForm,
                      child: isAdding
                          ? const SizedBox(
                              height: 16,
                              width: 8,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Add expense',
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.white),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
