import 'package:expense_tracker/screens/chart_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "💰 Your wallet's story.",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontSize: 24),
                ),
                Text(
                  "-visualized.",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontSize: 16),
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
    );
  }
}
