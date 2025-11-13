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
  //final uid = FirebaseAuth.instance.currentUser!.uid;
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

    //submitting the expense
    try {
      final supabase = Supabase.instance.client;
      final user = Supabase.instance.client.auth.currentUser;

      //if no logged in user
      if (user == null) {
        return;
      }

      //upload to Supabase
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
                onPressed: () {
                  Navigator.pop(context);
                },
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

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      decoration: const InputDecoration(
        prefixText: 'KES ',
        labelText: 'Amount',
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      maxLength: 50,
      decoration: const InputDecoration(labelText: 'Expense Title'),
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
      behavior: HitTestBehavior.opaque, // so taps on empty space register
      onTap: () {
        FocusScope.of(context).unfocus(); // removes focus from any TextField
      },
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return SizedBox(
            //height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 32, 18, keyboardSpace + 13),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWide)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              labelText: 'Expense Title',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAmountField()),
                      ],
                    )
                  else
                    const SizedBox(height: 10),
                  _buildTitleField(),
                  //row 2
                  if (isWide)
                    Row(
                      children: [
                        _buildCategoryDropdown(),
                        const Spacer(),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                expenseDate == null
                                    ? 'No date selected'
                                    : formatter.format(expenseDate!),
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 10,
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
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: _buildAmountField()),
                        const SizedBox(width: 20),

                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                expenseDate == null
                                    ? 'No date selected'
                                    : formatter.format(expenseDate!),
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 10,
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

                  //row 3 (buttons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCategoryDropdown(),
                      TextButton(
                        onPressed: isAdding
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
