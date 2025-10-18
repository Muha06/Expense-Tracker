import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class NewExpense extends StatefulWidget {
  const NewExpense({
    super.key,
    required this.registeredExpenses,
    required this.onAddExpense,
  });
  final List<Expense> registeredExpenses;
  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? expenseDate;
  Category _selectedCategory = Category.food;

  void _showDatePickerscreen() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final DateTime? datePicked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    ); // await waits for the date picker to give value the stored into 'datePicked'
    //then the value used right after the next line
    setState(() {
      expenseDate = datePicked;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpenseForm() {
    final enteredAmount = int.tryParse(_amountController.text); //n
    final amountIsInvalid =
        enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        expenseDate == null) {
      //show error message
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Invalid Input',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              'Ebu angalia kama umeandika vizuri',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
      return;
    }
    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: expenseDate!,
        category: _selectedCategory,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 32, 18, 13),
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        children: [
          // Title text field
          TextField(
            controller: _titleController,
            maxLength: 50,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'Expense Title',
            ),
          ),

          const SizedBox(height: 10),

          // Amount + Date row
          Row(
            children: [
              // Amount text field
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _amountController,
                  decoration: const InputDecoration(
                    prefixText: 'KES ',
                    labelText: 'Amount',
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Date Row
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      onPressed: _showDatePickerscreen,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //dropdown
              DropdownButton(
                value: _selectedCategory,
                items: Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }).toList(),
                //this method executed when user selects a menu item
                //the selected item is assigned to 'value'
                onChanged: (selectedvalue) {
                  if (selectedvalue == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = selectedvalue;
                  });
                },
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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
    );
  }
}
