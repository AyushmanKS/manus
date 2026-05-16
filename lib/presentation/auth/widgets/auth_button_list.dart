import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/design_system/widgets/manus_primary_button.dart';
import 'package:manus/presentation/design_system/widgets/manus_loader.dart';
class AuthButtonList extends ConsumerStatefulWidget {
  const AuthButtonList({super.key});
  @override
  ConsumerState<AuthButtonList> createState() => _AuthButtonListState();
}
class _AuthButtonListState extends ConsumerState<AuthButtonList> {
  bool _isLoading = false;
  Future<void> handleAuthAction(final BuildContext context) async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    unawaited(showManusLoader(context));
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!context.mounted) {
      return;
    }
    setState(() => _isLoading = false);
    context.pop();
    await ref.read(authProvider.notifier).login();
    if (context.mounted) {
      context.go('/chat');
    }
  }
  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dividerColor = theme.dividerColor;
    final TextStyle? mutedTextStyle = theme.textTheme.labelMedium;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ManusPrimaryButton(
          label: 'Continue with Facebook',
          iconPath: AppAssets.facebookSvg,
          isBrandIcon: true,
          onTap: () => handleAuthAction(context),
        ),
        const SizedBox(height: 6.0),
        ManusPrimaryButton(
          label: 'Continue with Google',
          iconPath: AppAssets.googleSvg,
          iconSize: 16.0,
          isBrandIcon: true,
          onTap: () => handleAuthAction(context),
        ),
        const SizedBox(height: 6.0),
        ManusPrimaryButton(
          label: 'Continue with Microsoft',
          iconPath: AppAssets.microsoftSvg,
          isBrandIcon: true,
          onTap: () => handleAuthAction(context),
        ),
        const SizedBox(height: 6.0),
        ManusPrimaryButton(
          label: 'Continue with Apple',
          iconPath: AppAssets.appleSvg,
          isBrandIcon: false,
          onTap: () => handleAuthAction(context),
        ),
        const SizedBox(height: 22.0),
        Row(
          children: <Widget>[
            Expanded(child: Divider(color: dividerColor, thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('OR', style: mutedTextStyle),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1.5)),
          ],
        ),
        const SizedBox(height: 22.0),
        ManusPrimaryButton(
          label: 'Continue with Email',
          iconPath: AppAssets.emailSvg,
          isBrandIcon: false,
          onTap: () => handleAuthAction(context),
        ),
      ],
    );
  }
}