import 'package:flutter/material.dart';
import 'package:expense_tracker/expenses.dart';

//light mode color scheme
var kcolorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 64, 0, 106),
);

//dark mode color scheme
var kdarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 39, 0, 65),
);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        // ignore: deprecated_member_use
        colorScheme: kdarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kdarkColorScheme.onPrimary,
          foregroundColor: kdarkColorScheme.onPrimaryContainer,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        cardTheme: const CardThemeData().copyWith(
          color: kdarkColorScheme.primaryContainer,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData().copyWith(
          backgroundColor: kdarkColorScheme.onPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kdarkColorScheme.primaryContainer,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kdarkColorScheme.onPrimaryContainer,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
          titleSmall: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme().copyWith(
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      //light mode
      theme: ThemeData().copyWith(
        //every widget pulls its colors from this color scheme
        colorScheme: kcolorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kcolorScheme.primary,
          foregroundColor: kcolorScheme.onPrimary,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        cardTheme: const CardThemeData().copyWith(
          color: kcolorScheme.primaryContainer,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData().copyWith(
          backgroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kcolorScheme.onPrimaryContainer,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kcolorScheme.onPrimaryContainer,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kcolorScheme.onPrimaryContainer,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            color: kcolorScheme.onPrimaryContainer,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kcolorScheme.onPrimaryContainer,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme().copyWith(
          labelStyle: TextStyle(
            color: kcolorScheme.onPrimaryContainer,
            fontSize: 14,
          ),
        ),
      ),
      home: const Expenses(),
    ),
  );
}
