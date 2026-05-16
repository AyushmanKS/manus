import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PhysicsBlobType { bigCircle, smallCircle, hollowCircle, triangle }

class PhysicsBlob {
  Offset position;
  Offset velocity;
  final double radius;
  final double? innerRadius;
  final PhysicsBlobType type;
  final Path? trianglePath;
  double rotation;
  final double rotationSpeed;

  PhysicsBlob({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.type,
    this.innerRadius,
    this.trianglePath,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
  });

  void update(final double dt, final Size bounds) {
    position += velocity * dt;
    rotation += rotationSpeed * dt;

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

  bool contains(final Offset globalPoint) {
    final Offset localPoint = globalPoint - position;
    final double distance = localPoint.distance;

    switch (type) {
      case PhysicsBlobType.bigCircle:
      case PhysicsBlobType.smallCircle:
        return distance < radius;
      case PhysicsBlobType.hollowCircle:
        return distance < radius && distance > (innerRadius ?? 0);
      case PhysicsBlobType.triangle:
        if (trianglePath == null) return false;
        final double cosR = math.cos(-rotation);
        final double sinR = math.sin(-rotation);
        final Offset rotatedPoint = Offset(
          localPoint.dx * cosR - localPoint.dy * sinR,
          localPoint.dx * sinR + localPoint.dy * cosR,
        );
        return trianglePath!.contains(rotatedPoint);
    }
  }

  static void resolveCollision(final PhysicsBlob a, final PhysicsBlob b) {
    final Offset delta = a.position - b.position;
    final double distance = delta.distance;
    final double minDistance = a.radius + b.radius;

    if (distance < minDistance && distance > 0) {
      final Offset normal = delta / distance;

      final double overlap = minDistance - distance;
      a.position += normal * (overlap / 2.0);
      b.position -= normal * (overlap / 2.0);

      final Offset relativeVelocity = a.velocity - b.velocity;
      final double velocityAlongNormal =
          relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

      if (velocityAlongNormal < 0) {
        final Offset impulse = normal * velocityAlongNormal;
        a.velocity -= impulse;
        b.velocity += impulse;
      }
    }
  }
}