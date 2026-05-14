import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashNotifier extends Notifier<void> {
  @override
  void build() {}

  void navigateToOnboarding(final BuildContext context) {
    context.go('/onboarding');
  }
}

final NotifierProvider<SplashNotifier, void> splashProvider =
    NotifierProvider<SplashNotifier, void>(SplashNotifier.new);
