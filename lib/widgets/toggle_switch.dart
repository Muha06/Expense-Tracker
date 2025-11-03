import 'package:expense_tracker/providers/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkmode = ref.watch(isDarkModeProvider);

    return ToggleSwitch(
      minWidth: 35.0,
      minHeight: 30.0,
      initialLabelIndex: isDarkmode ? 1 : 0,
      cornerRadius: 20.0,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.black,
      inactiveFgColor: Colors.white,
      totalSwitches: 2,
      icons: const [Icons.sunny, Icons.brightness_2_rounded],
      iconSize: 20.0,
      activeBgColors: [
        [Theme.of(context).colorScheme.primary, Colors.grey],
        [Theme.of(context).colorScheme.primary, Colors.grey],
      ],
      animate:
          true, // with just animate set to true, default curve = Curves.easeIn
      curve: Curves.bounceInOut,
      onToggle: (idx) {
        ref.read(isDarkModeProvider.notifier).state = idx == 1;
      },
    );
  }
}
