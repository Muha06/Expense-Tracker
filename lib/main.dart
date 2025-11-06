import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/screens/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Light mode color scheme
var kcolorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 39, 0, 65),
);

// Dark mode color scheme
var kdarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 39, 0, 65),
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();

    return AnimatedTheme(
      data: isDark ? darkTheme : lightTheme,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

        // 🌞 Light Theme
        theme: ThemeData(
          colorScheme: kcolorScheme,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .copyWith(
                titleLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kcolorScheme.onPrimaryContainer,
                ),
                titleMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: kcolorScheme.onPrimaryContainer,
                ),
                bodyLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: kcolorScheme.onPrimaryContainer,
                ),
                bodyMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: kcolorScheme.onPrimaryContainer,
                ),
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: kcolorScheme.primary,
            foregroundColor: kcolorScheme.onPrimary,
            titleTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: kcolorScheme.onPrimary,
            ),
          ),
          cardTheme: CardThemeData(
            color: kcolorScheme.primaryContainer,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kcolorScheme.onPrimaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: GoogleFonts.poppins(
              color: kcolorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
          ),
        ),

        // 🌚 Dark Theme
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: kdarkColorScheme,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .copyWith(
                titleLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                titleMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
                bodyLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
                bodyMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: kdarkColorScheme.onPrimary,
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            color: kdarkColorScheme.primaryContainer,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kdarkColorScheme.primaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
        ),
        home: const AuthPage(),
      ),
    );
  }
}
