import 'dart:convert';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
      final url = Uri.https(
        'expense-tracker-32102-default-rtdb.firebaseio.com',
        'expenses.json',
      );
      //
      //http post
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'amount': enteredAmount,
          'category': _selectedCategory.name,
          'date': expenseDate!.millisecondsSinceEpoch,
        }),
      );
      if (response.statusCode >= 400) {
        throw Exception('An error occured!');
      }
      ref
          .read(expenseListProvider.notifier)
          .addExpense(
            Expense(
              title: _titleController.text,
              amount: enteredAmount,
              date: expenseDate!,
              category: _selectedCategory,
            ),
          );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error adding expense:  $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
            title: Text('Error'),
            content: Text('An error ocurred!'),
          ),
        );
      }
    }
    //http url
  }

  Widget _buildDatePickerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          expenseDate == null
              ? 'No date selected'
              : formatter.format(expenseDate!),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 5),
        IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: _showDatePickerScreen,
        ),
      ],
    );
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

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, 32, 18, keyboardSpace + 13),
            child: Column(
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
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: 'KES ',
                            labelText: 'Amount',
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Expense Title',
                    ),
                  ),

                const SizedBox(height: 10),

                //row 2
                if (isWide)
                  Row(
                    children: [
                      _buildCategoryDropdown(),
                      const Spacer(),
                      Expanded(child: _buildDatePickerRow()),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: 'KES ',
                            labelText: 'Amount',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: _buildDatePickerRow()),
                    ],
                  ),

                const SizedBox(height: 10),

                //row 3 (buttons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCategoryDropdown(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitExpenseForm,
                      child: const Text('Add expense'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
