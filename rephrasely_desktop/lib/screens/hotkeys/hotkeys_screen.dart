import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HotkeysScreen extends StatelessWidget {
  const HotkeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text('Hotkeys', style: theme.textTheme.h1),
          const SizedBox(height: 8),
          Text(
            'Keyboard shortcuts configuration will appear here',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
