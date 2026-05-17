import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manus/core/services/haptic_service.dart';

class HapticListener extends StatefulWidget {
  const HapticListener({required this.child, super.key});
  final Widget child;
  @override
  State<HapticListener> createState() => _HapticListenerState();
}

class _HapticListenerState extends State<HapticListener> {
  Timer? _timer;
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      HapticService.light();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Listener(
      onPointerDown: (final _) => _startTimer(),
      onPointerUp: (final _) => _stopTimer(),
      onPointerCancel: (final _) => _stopTimer(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
