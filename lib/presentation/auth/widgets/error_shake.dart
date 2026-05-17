import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ErrorShake extends StatelessWidget {
  final Widget child;
  final bool shouldShake;

  const ErrorShake({required this.child, required this.shouldShake, super.key});

  @override
  Widget build(final BuildContext context) {
    if (!shouldShake) return child;

    return child.animate().shakeX(
      duration: 500.ms,
      hz: 10,
      curve: Curves.easeInOut,
    );
  }
}
