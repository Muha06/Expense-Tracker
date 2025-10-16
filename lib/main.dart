import 'package:flutter/material.dart';
import 'package:expense_tracker/expenses.dart';

var kcolorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 64, 0, 106),
);
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        //every widget pulls its colors from this color scheme
        colorScheme: kcolorScheme,
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kcolorScheme.primary,
          foregroundColor: kcolorScheme.onPrimary,
        ),
        cardTheme: CardThemeData().copyWith(
          color: kcolorScheme.primaryContainer,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kcolorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kcolorScheme.onPrimaryContainer,
          ),
        ),
      ),
      home: Expenses(),
    ),
  );
}
