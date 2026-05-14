import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue<void>.data(null);
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue<void>.loading();
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      state = const AsyncValue<void>.data(null);
    } catch (e, st) {
      state = AsyncValue<void>.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue<void>.loading();
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      state = const AsyncValue<void>.data(null);
    } catch (e, st) {
      state = AsyncValue<void>.error(e, st);
    }
  }

  Future<void> signInWithMicrosoft() async {
    state = const AsyncValue<void>.loading();
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      state = const AsyncValue<void>.data(null);
    } catch (e, st) {
      state = AsyncValue<void>.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue<void>.loading();
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      state = const AsyncValue<void>.data(null);
    } catch (e, st) {
      state = AsyncValue<void>.error(e, st);
    }
  }

  Future<void> signInWithEmail() async {
    state = const AsyncValue<void>.loading();
    await Future<void>.delayed(const Duration(seconds: 1));
    state = const AsyncValue<void>.data(null);
  }

  Future<void> loginWithEmail(final String email, final String password) async {
    state = const AsyncValue<void>.loading();
    await Future<void>.delayed(const Duration(seconds: 1));

    if (email == 'error@manus.ai') {
      state = AsyncValue<void>.error('Invalid credentials', StackTrace.current);
    } else {
      state = const AsyncValue<void>.data(null);
    }
  }

  void navigateToPolicy(
    final BuildContext context, {
    required final String url,
    required final String title,
  }) {
    context.push(
      '/policy',
      extra: <String, String>{
        'url': url,
        'title': title,
      },
    );
  }
}

final NotifierProvider<AuthNotifier, AsyncValue<void>> authProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
