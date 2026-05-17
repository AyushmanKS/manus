import 'package:flutter/material.dart';

class TappableOpacity extends StatefulWidget {
  const TappableOpacity({
    required this.child,
    required this.onTap,
    this.pressedOpacity = 0.4,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;
  final HitTestBehavior behavior;

  @override
  State<TappableOpacity> createState() => _TappableOpacityState();
}

class _TappableOpacityState extends State<TappableOpacity> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: isEnabled ? () => _setPressed(false) : null,
      behavior: widget.behavior,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? widget.pressedOpacity : 1.0,
        child: widget.child,
      ),
    );
  }
}
