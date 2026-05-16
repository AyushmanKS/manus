import 'package:flutter/material.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoppedBadge extends StatelessWidget {
  const StoppedBadge({super.key});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Generation stopped',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
