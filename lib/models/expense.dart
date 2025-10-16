import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

enum Category { food, transport, airtime, leisure }

const categoryIcons = {
  Category.food: Icons.food_bank_outlined,
  Category.transport: Icons.emoji_transportation_outlined,
  Category.airtime: Icons.call,
  Category.leisure: Icons.beach_access,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  //properties
  final String id;
  final String title;
  final int amount;
  final DateTime date;
  final Category category;

  //method to GET formatted date, returns the formatted date
  String get formattedDate => formatter.format(date);
}
