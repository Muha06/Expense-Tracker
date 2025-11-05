import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          //child1 - text
          Align(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontSize: 16),
            ),
          ),
          const Spacer(),
          //child2
          TextButton(onPressed: () {}, child: const Text('View all')),
        ],
      ),
    );
  }
}
