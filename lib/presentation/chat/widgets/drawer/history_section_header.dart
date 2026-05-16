import 'package:flutter/material.dart';

class HistorySectionHeader extends StatelessWidget {
  const HistorySectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(final BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
