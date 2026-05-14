import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/theme/app_colors.dart';

class ManusSocialButton extends StatefulWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;
  final Color? iconColor;

  const ManusSocialButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  @override
  State<ManusSocialButton> createState() => _ManusSocialButtonState();
}

class _ManusSocialButtonState extends State<ManusSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Spring Physics Simulation (Damped Spring)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const SpringCurve(),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: widget.label,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: isDark
                  ? null
                  : Border.all(
                      color: const Color(0xFFE6E6E6),
                      width: 0.5,
                    ),
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFF9F9F9), // Lightest hint of depth
                        Color(0xFFF2F2F2), // Subtle shadow at bottom
                      ],
                      stops: [0.0, 0.95, 1.0],
                    ),
            ),
            child: Stack(
              children: [
                // Icon leading container
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 40,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.iconPath,
                      width: 16,
                      height: 16,
                      colorFilter: widget.iconColor != null
                          ? ColorFilter.mode(widget.iconColor!, BlendMode.srcIn)
                          : null,
                    ),
                  ),
                ),
                // Centered text with compensated padding
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 54),
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A custom curve to simulate a spring effect
class SpringCurve extends Curve {
  const SpringCurve();

  @override
  double transform(double t) {
    // Simple damped spring implementation
    return math.sin(t * math.pi * 1.5) * (1 - t) + t;
  }
}
