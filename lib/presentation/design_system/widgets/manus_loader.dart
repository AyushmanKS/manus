import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manus/core/theme/app_colors.dart';

class ManusLoader extends StatelessWidget {
  const ManusLoader({super.key});
  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Dot(index: 0, color: AppColors.loaderDotColor),
            SizedBox(width: 6.0),
            _Dot(index: 1, color: AppColors.loaderDotColor),
            SizedBox(width: 6.0),
            _Dot(index: 2, color: AppColors.loaderDotColor),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int index;
  final Color color;
  const _Dot({required this.index, required this.color});
  @override
  Widget build(final BuildContext context) {
    return Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(
          onPlay: (final AnimationController controller) =>
              controller.repeat(reverse: true),
        )
        .moveY(
          begin: -3.0,
          end: 3.0,
          duration: 600.ms,
          delay: (index * 200).ms,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.2,
          end: 1.0,
          duration: 600.ms,
          delay: (index * 200).ms,
          curve: Curves.easeInOut,
        );
  }
}

Future<void> showManusLoader(
  final BuildContext context, {
  final bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: true,
    barrierColor: Colors.transparent,
    builder: (final BuildContext context) => const Center(child: ManusLoader()),
  );
}
