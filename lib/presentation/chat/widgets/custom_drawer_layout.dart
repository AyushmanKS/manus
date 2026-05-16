import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/presentation/chat/notifiers/drawer_notifier.dart';

class CustomDrawerLayout extends ConsumerStatefulWidget {
  const CustomDrawerLayout({
    required this.child,
    required this.drawer,
    super.key,
  });

  final Widget child;
  final Widget drawer;

  @override
  ConsumerState<CustomDrawerLayout> createState() => _CustomDrawerLayoutState();
}

class _CustomDrawerLayoutState extends ConsumerState<CustomDrawerLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _drawerWidthFactor = 0.82;

  double _dragStartX = 0;
  bool _canDrag = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addListener(() {
      ref.read(drawerProvider.notifier).update(_controller.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(final DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;

    // Exclusion zone (0-40px) to allow system back gesture.
    // If the drawer is already open, dragging should always be allowed to close it.
    _canDrag = _dragStartX >= 40.0 || _controller.value > 0;

    if (_canDrag) {
      // Smoothly dismiss keyboard as drawer starts to open
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _onHorizontalDragUpdate(
    final DragUpdateDetails details,
    final double width,
  ) {
    if (!_canDrag) return;
    _controller.value += details.primaryDelta! / (width * _drawerWidthFactor);
  }

  void _onHorizontalDragEnd(final DragEndDetails details, final double width) {
    if (!_canDrag) return;

    final double velocity =
        details.primaryVelocity! / (width * _drawerWidthFactor);

    // mass: 1.0, stiffness: 250.0, damping: 25.0 to match iOS native sheets
    const SpringDescription spring = SpringDescription(
      mass: 1.0,
      stiffness: 250.0,
      damping: 25.0,
    );

    double target;
    if (velocity.abs() > 0.5) {
      target = velocity > 0 ? 1.0 : 0.0;
    } else {
      target = _controller.value > 0.5 ? 1.0 : 0.0;
    }

    final SpringSimulation simulation = SpringSimulation(
      spring,
      _controller.value,
      target,
      velocity,
    );

    _controller.animateWith(simulation);
  }

  @override
  Widget build(final BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double drawerWidth = width * _drawerWidthFactor;

    ref.listen<double>(drawerProvider, (final double? prev, final double next) {
      if (next != _controller.value && !_controller.isAnimating) {
        if (next == 0.0) {
          // Explicitly animate to 0.0 to ensure it closes fully
          _controller.animateTo(
            0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        } else {
          if (next > _controller.value) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          _controller.animateTo(
            next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });

    return Stack(
      children: <Widget>[
        widget.child,

        AnimatedBuilder(
          animation: _controller,
          builder: (final BuildContext context, final Widget? child) {
            if (_controller.value <= 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => ref.read(drawerProvider.notifier).close(),
              child: Container(
                color: Colors.black.withValues(alpha: _controller.value * 0.4),
              ),
            );
          },
        ),

        AnimatedBuilder(
          animation: _controller,
          builder: (final BuildContext context, final Widget? child) {
            return Transform.translate(
              offset: Offset(
                -drawerWidth + (_controller.value * drawerWidth),
                0,
              ),
              child: SizedBox(width: drawerWidth, child: widget.drawer),
            );
          },
        ),

        Positioned.fill(
          child: GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (final DragUpdateDetails d) =>
                _onHorizontalDragUpdate(d, width),
            onHorizontalDragEnd: (final DragEndDetails d) =>
                _onHorizontalDragEnd(d, width),
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}
