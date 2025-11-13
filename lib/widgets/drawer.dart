import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/screens/chart_page.dart';
import 'package:expense_tracker/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final AuthService authService = AuthService();

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
                    title: Text(
                      'H O M E',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.stacked_bar_chart_sharp),
                    title: Text(
                      'C H A R T',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChartPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.stacked_bar_chart_sharp),
                    title: Text(
                      'P R O F I L E',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(
                      'Sign out',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      authService.signOut();
                    },
                    subtitle: Text(
                      authService.getUserEmail().toString(),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
