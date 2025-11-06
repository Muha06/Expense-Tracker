import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

enum Category { food, transport, airtime, leisure, other }

const categoryIcons = {
  Category.food: Icons.food_bank_outlined,
  Category.transport: Icons.emoji_transportation_outlined,
  Category.airtime: Icons.call,
  Category.leisure: Icons.beach_access,
  Category.other: Icons.circle_rounded,
};

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  //properties
  final String id;
  final String title;
  final int amount;
  final DateTime date;
  final Category category;

  //method to GET formatted date, returns the formatted date
  String get formattedDate => formatter.format(date);
}

class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});
  //properties
  final Category category;
  final List<Expense> expenses;

  //Filtering expenses of one category
  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
    : expenses = allExpenses
          .where((expense) => expense.category == category)
          .toList();

  //getter method that returns total sum of expense amount
  int get totalAmount {
    int sum = 0;
    //find total sum of amounts
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
