import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/design_system/painters/dotted_grid_painter.dart';

class ManusAnimatedBackground extends StatelessWidget {
  final Widget child;

  const ManusAnimatedBackground({
    required this.child,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color blobColor1 = isDark ? AppColors.blob1Dark : AppColors.blob1Light;
    final Color blobColor2 = isDark ? AppColors.blob2Dark : AppColors.blob2Light;
    final Color dotColor = isDark ? AppColors.dotGridDark : AppColors.dotGridLight;

    return Stack(
      children: <Widget>[
        // Layer 1: Base Background
        Positioned.fill(
          child: Container(color: Theme.of(context).scaffoldBackgroundColor),
        ),

        // Layer 2: Moving Blobs
        _MovingBlob(
          color: blobColor1,
          beginOffset: const Offset(-0.5, -0.5),
          endOffset: const Offset(0.5, 0.5),
          duration: 15.seconds,
        ),
        _MovingBlob(
          color: blobColor2,
          beginOffset: const Offset(0.8, -0.2),
          endOffset: const Offset(-0.3, 0.7),
          duration: 12.seconds,
        ),

        // Layer 3: Dotted Grid
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: DottedGridPainter(dotColor: dotColor),
            ),
          ),
        ),

        // Layer 4: Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _MovingBlob extends StatelessWidget {
  final Color color;
  final Offset beginOffset;
  final Offset endOffset;
  final Duration duration;

  const _MovingBlob({
    required this.color,
    required this.beginOffset,
    required this.endOffset,
    required this.duration,
  });

  @override
  Widget build(final BuildContext context) {
    return Positioned.fill(
      child: Container()
          .animate(onPlay: (final AnimationController controller) => controller.repeat(reverse: true))
          .custom(
            duration: duration,
            curve: Curves.easeInOutSine,
            builder: (final BuildContext context, final double value, final Widget child) {
              final Offset currentOffset = Offset.lerp(beginOffset, endOffset, value)!;
              return Align(
                alignment: Alignment(currentOffset.dx, currentOffset.dy),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        color.withAlpha(100),
                        color.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
