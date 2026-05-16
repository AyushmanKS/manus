import 'package:flutter/material.dart';

class DottedGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  const DottedGridPainter({required this.dotColor, this.spacing = 24.0});

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const double dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant final DottedGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor || oldDelegate.spacing != spacing;
  }
}