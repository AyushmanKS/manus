import 'dart:math' as math;
import 'package:flutter/material.dart';

class PhysicsBlob {
  Offset position;
  Offset velocity;
  final double radius;
  double rotation;
  final double rotationSpeed;
  final String assetPath;
  final Color color;

  PhysicsBlob({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.assetPath,
    required this.color,
    this.rotation = 0.0,
    this.rotationSpeed = 0.5,
  });

  void update(final double dt, final Size bounds) {
    // Position integration
    position += velocity * dt;
    rotation += rotationSpeed * dt;

    // Wall collisions
    if (position.dx - radius < 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (position.dx + radius > bounds.width) {
      position = Offset(bounds.width - radius, position.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    if (position.dy - radius < 0) {
      position = Offset(position.dx, radius);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    } else if (position.dy + radius > bounds.height) {
      position = Offset(position.dx, bounds.height - radius);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    }
  }

  static void resolveCollision(final PhysicsBlob a, final PhysicsBlob b) {
    final Offset delta = a.position - b.position;
    final double distance = delta.distance;
    final double minDistance = a.radius + b.radius;

    if (distance < minDistance) {
      // 1. Resolve Overlap (Static resolution)
      final double overlap = minDistance - distance;
      final Offset normal = delta / distance;
      final Offset separation = normal * (overlap / 2.0);
      a.position += separation;
      b.position -= separation;

      // 2. Elastic Collision (Velocity resolution)
      // Normal component of velocity
      final double v1n = a.velocity.dx * normal.dx + a.velocity.dy * normal.dy;
      final double v2n = b.velocity.dx * normal.dx + b.velocity.dy * normal.dy;

      // Swap normal velocities (assuming equal mass for simplicity)
      final double v1nAfter = v2n;
      final double v2nAfter = v1n;

      // Update velocities
      a.velocity += normal * (v1nAfter - v1n);
      b.velocity += normal * (v2nAfter - v2n);
    }
  }
}
