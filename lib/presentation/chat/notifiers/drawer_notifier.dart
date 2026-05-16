import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the drawer state globally.
/// Value 0.0 is closed, 1.0 is fully open.
class DrawerNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void open() => state = 1.0;
  void close() => state = 0.0;

  void update(final double value) {
    state = value.clamp(0.0, 1.0);
  }
}

final NotifierProvider<DrawerNotifier, double> drawerProvider =
    NotifierProvider<DrawerNotifier, double>(DrawerNotifier.new);
