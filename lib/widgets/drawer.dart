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
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-50 * (1 - value), 0), // slide effect
            child: Opacity(
              opacity: value, // fade in
              child: child,
            ),
          );
        },
        child: ListView(
          children: [
            //drawer header
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "💰 Your wallet's story.",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 24,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "-visualized.",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            //content - listTiles
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ListTile(
                    splashColor: Theme.of(context).colorScheme.primary,
                    leading: const Icon(Icons.home_filled),
                    onTap: () => Navigator.of(context).pop(),
                    title: const Text('H O M E'),
                  ),
                ),
              ),
            ),

            //chart listTile
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListTile(
                    leading: const Icon(Icons.stacked_bar_chart_sharp),
                    title: const Text('C H A R T'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return const ChartPage();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
