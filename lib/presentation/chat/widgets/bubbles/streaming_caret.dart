import 'package:flutter/material.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreamingCaret extends StatelessWidget {
  const StreamingCaret({super.key});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color caretColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 2.0,
          height: 14.0,
          margin: const EdgeInsets.only(top: 2.0, left: 2.0),
          decoration: BoxDecoration(
            color: caretColor,
            borderRadius: BorderRadius.circular(1.0),
          ),
        )
        .animate(
          onPlay: (final AnimationController c) => c.repeat(reverse: true),
        )
        .fadeIn(duration: 530.ms);
  }
}
