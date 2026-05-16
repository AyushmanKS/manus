import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthNotifier extends Notifier<bool> {
  late final Box<bool> _authBox;

  @override
  bool build() {
    _authBox = Hive.box<bool>('auth');
    return _authBox.get('isLoggedIn', defaultValue: false) ?? false;
  }

  Future<void> login() async {
    await _authBox.put('isLoggedIn', true);
    state = true;
  }

  Future<void> logout() async {
    await _authBox.put('isLoggedIn', false);
    state = false;
  }

  void navigateToPolicy(
    final BuildContext context, {
    required final String url,
    required final String title,
  }) {
    context.push(
      '/policy',
      extra: <String, String>{'url': url, 'title': title},
    );
  }
}

final NotifierProvider<AuthNotifier, bool> authProvider =
    NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
