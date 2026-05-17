import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/app_spacing.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/auth/widgets/auth_button_list.dart';
import 'package:manus/presentation/design_system/widgets/manus_animated_background.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: AppColors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: ManusAnimatedBackground(
        child: RepaintBoundary(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 58),
                        SvgPicture.asset(
                          AppAssets.logoSvg,
                          width: 80,
                          colorFilter: ColorFilter.mode(
                            onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          'Welcome to Manus',
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AuthButtonList(),
                      SizedBox(height: 24),
                      LegalFooter(),
                      SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalFooter extends ConsumerWidget {
  const LegalFooter({super.key});
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Color mutedColor = onSurface.withValues(alpha: 0.5);
    final TextStyle baseStyle =
        (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
          fontSize: 13,
          color: mutedColor,
          height: 1.4,
        );
    final TextStyle linkStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
    );
    return Semantics(
      label: 'Legal Information',
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: <InlineSpan>[
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => ref
                    .read(authProvider.notifier)
                    .navigateToPolicy(
                      context,
                      url: 'https://manus.im/terms',
                      title: 'Terms',
                    ),
            ),
            const TextSpan(text: ' and have read our '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => ref
                    .read(authProvider.notifier)
                    .navigateToPolicy(
                      context,
                      url: 'https://manus.im/privacy',
                      title: 'Privacy',
                    ),
            ),
            const TextSpan(text: '. \u00A9 2026 Meta'),
          ],
        ),
      ),
    );
  }
}
