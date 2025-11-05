import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/screens/chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color.fromARGB(71, 72, 2, 89)
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "💰 Your wallet's story",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 20,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "   -visualized.",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //below draweHeader
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white,
              ),
              child: Column(
                spacing: 8,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_filled),
                    title: const Text('H O M E'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.stacked_bar_chart_sharp),
                    title: const Text('C H A R T'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChartPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
