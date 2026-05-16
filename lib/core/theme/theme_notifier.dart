import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(final ThemeMode mode) {
    state = mode;
  }
}

final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);