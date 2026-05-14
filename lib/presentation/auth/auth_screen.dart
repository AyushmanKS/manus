import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/auth/widgets/error_shake.dart';
import 'package:manus/presentation/design_system/manus_button.dart';
import 'package:manus/presentation/design_system/manus_text.dart';
import 'package:manus/presentation/design_system/manus_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AsyncValue<void> authState = ref.watch(authProvider);

    ref.listen(authProvider, (final AsyncValue<void>? previous, final AsyncValue<void> next) {
      if (next is AsyncData && previous is AsyncLoading) {
        context.go(AppRouter.home);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),
              const ManusText('Welcome back', style: ManusTextStyle.h1),
              const SizedBox(height: 12),
              const ManusText(
                'Sign in to continue your journey.',
                style: ManusTextStyle.body,
                color: Colors.white70,
              ),
              const SizedBox(height: 48),
              ErrorShake(
                shouldShake: authState is AsyncError,
                child: ManusTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              ManusTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
              ),
              const SizedBox(height: 32),
              ManusButton(
                text: 'Sign In',
                isLoading: authState is AsyncLoading,
                onPressed: () {
                  ref.read(authProvider.notifier).loginWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
              ),
              const SizedBox(height: 24),
              const Center(
                child: ManusText('OR', style: ManusTextStyle.caption, color: Colors.white24),
              ),
              const SizedBox(height: 24),
              ManusButton(
                text: 'Continue with Google',
                variant: ManusButtonVariant.outline,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              ManusButton(
                text: 'Continue with Apple',
                variant: ManusButtonVariant.outline,
                icon: const Icon(Icons.apple, size: 24),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
