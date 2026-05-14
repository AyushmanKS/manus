import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/design_system/widgets/manus_primary_button.dart';

class AuthButtonList extends ConsumerWidget {
  const AuthButtonList({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final AuthNotifier notifier = ref.read(authProvider.notifier);
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
          onTap: notifier.signInWithFacebook,
        ),
        const SizedBox(height: 6),
        ManusPrimaryButton(
          label: 'Continue with Google',
          iconPath: AppAssets.googleSvg,
          iconSize: 16.0,
          isBrandIcon: true,
          onTap: notifier.signInWithGoogle,
        ),
        const SizedBox(height: 6),
        ManusPrimaryButton(
          label: 'Continue with Microsoft',
          iconPath: AppAssets.microsoftSvg,
          isBrandIcon: true,
          onTap: notifier.signInWithMicrosoft,
        ),
        const SizedBox(height: 6),
        ManusPrimaryButton(
          label: 'Continue with Apple',
          iconPath: AppAssets.appleSvg,
          isBrandIcon: false,
          onTap: notifier.signInWithApple,
        ),
        const SizedBox(height: 22),
        Row(
          children: <Widget>[
            Expanded(child: Divider(color: dividerColor, thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: mutedTextStyle,
              ),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1.5)),
          ],
        ),
        const SizedBox(height: 22),
        ManusPrimaryButton(
          label: 'Continue with Email',
          iconPath: AppAssets.emailSvg,
          isBrandIcon: false,
          onTap: notifier.signInWithEmail,
        ),
      ],
    );
  }
}
