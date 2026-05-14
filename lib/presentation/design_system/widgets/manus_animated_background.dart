import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/design_system/models/physics_blob.dart';

class ManusAnimatedBackground extends StatefulWidget {
  final Widget child;

  const ManusAnimatedBackground({required this.child, super.key});

  @override
  State<ManusAnimatedBackground> createState() =>
      _ManusAnimatedBackgroundState();
}

class _ManusAnimatedBackgroundState extends State<ManusAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<PhysicsBlob> _blobs = <PhysicsBlob>[];
  bool _initialized = false;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _initBlobs(final Size size) {
    if (_blobs.isNotEmpty) return;

    final math.Random random = math.Random();

    _blobs.add(
      PhysicsBlob(
        position: _randomPos(size, 100, random),
        velocity: _randomVel(random),
        radius: 100,
        type: PhysicsBlobType.bigCircle,
      ),
    );

    _blobs.add(
      PhysicsBlob(
        position: _randomPos(size, 60, random),
        velocity: _randomVel(random),
        radius: 60,
        type: PhysicsBlobType.smallCircle,
      ),
    );

    _blobs.add(
      PhysicsBlob(
        position: _randomPos(size, 90, random),
        velocity: _randomVel(random),
        radius: 90,
        innerRadius: 60,
        type: PhysicsBlobType.hollowCircle,
      ),
    );

    const double side = 150.0;
    const double height = side * 0.866;
    final Path triPath = Path()
      ..moveTo(0, -height * 0.66)
      ..lineTo(side / 2, height * 0.33)
      ..lineTo(-side / 2, height * 0.33)
      ..close();

    _blobs.add(
      PhysicsBlob(
        position: _randomPos(size, 75, random),
        velocity: _randomVel(random),
        radius: 75,
        type: PhysicsBlobType.triangle,
        trianglePath: triPath,
        rotationSpeed: 0.3,
      ),
    );

    _initialized = true;
  }

  Offset _randomPos(final Size size, final double r, final math.Random rand) {
    return Offset(
      r + rand.nextDouble() * (size.width - r * 2),
      r + rand.nextDouble() * (size.height - r * 2),
    );
  }

  Offset _randomVel(final math.Random rand) {
    return Offset(
      (rand.nextDouble() - 0.5) * 60,
      (rand.nextDouble() - 0.5) * 60,
    );
  }

  void _onTick(final Duration elapsed) {
    if (!mounted) return;

    final double dt =
        (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    if (dt <= 0 || dt > 0.1) return;

    final Size size = MediaQuery.sizeOf(context);
    if (!_initialized) _initBlobs(size);

    for (final PhysicsBlob blob in _blobs) {
      blob.update(dt, size);
    }

    for (int i = 0; i < _blobs.length; i++) {
      for (int j = i + 1; j < _blobs.length; j++) {
        PhysicsBlob.resolveCollision(_blobs[i], _blobs[j]);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final Color idleDotColor = isDark
        ? AppColors.dotIdleDark
        : AppColors.dotIdleLight;

    return RepaintBoundary(
      child: CustomPaint(
        painter: ManusBackgroundPainter(
          blobs: List<PhysicsBlob>.from(_blobs),
          bgColor: bgColor,
          idleDotColor: idleDotColor,
        ),
        child: widget.child,
      ),
    );
  }
}

class ManusBackgroundPainter extends CustomPainter {
  final List<PhysicsBlob> blobs;
  final Color bgColor;
  final Color idleDotColor;

  ManusBackgroundPainter({
    required this.blobs,
    required this.bgColor,
    required this.idleDotColor,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    const double spacing = 6.0;
    const double dotRadius = 0.4;

    final List<Offset> idleDots = <Offset>[];
    final List<Offset> bigDots = <Offset>[];
    final List<Offset> smallDots = <Offset>[];
    final List<Offset> hollowDots = <Offset>[];
    final List<Offset> triangleDots = <Offset>[];

    for (double x = 0.0; x < size.width; x += spacing) {
      for (double y = 0.0; y < size.height; y += spacing) {
        final Offset point = Offset(x, y);
        PhysicsBlobType? type;

        for (final PhysicsBlob blob in blobs) {
          if (blob.contains(point)) {
            type = blob.type;
            break;
          }
        }

        if (type == null) {
          idleDots.add(point);
        } else {
          switch (type) {
            case PhysicsBlobType.bigCircle:
              bigDots.add(point);
              break;
            case PhysicsBlobType.smallCircle:
              smallDots.add(point);
              break;
            case PhysicsBlobType.hollowCircle:
              hollowDots.add(point);
              break;
            case PhysicsBlobType.triangle:
              triangleDots.add(point);
              break;
          }
        }
      }
    }

    final Paint p = Paint()
      ..strokeWidth = dotRadius * 2
      ..strokeCap = StrokeCap.round;

    _drawPoints(canvas, idleDots, p..color = idleDotColor);
    _drawPoints(canvas, bigDots, p..color = AppColors.blobBigCircle);
    _drawPoints(canvas, smallDots, p..color = AppColors.blobSmallCircle);
    _drawPoints(canvas, hollowDots, p..color = AppColors.blobHollowCircle);
    _drawPoints(canvas, triangleDots, p..color = AppColors.blobTriangle);
  }

  void _drawPoints(
    final Canvas canvas,
    final List<Offset> points,
    final Paint paint,
  ) {
    if (points.isNotEmpty) {
      canvas.drawPoints(PointMode.points, points, paint);
    }
  }

  @override
  bool shouldRepaint(covariant final ManusBackgroundPainter oldDelegate) =>
      true;
}
