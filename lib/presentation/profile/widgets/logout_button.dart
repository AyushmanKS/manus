import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/presentation/profile/widgets/logout_dialog.dart';
import 'package:manus/presentation/profile/widgets/menu_button.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({required this.iconColor, super.key});

  final Color iconColor;

  void _showLogoutDialog(final BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (final BuildContext context) => const LogoutDialog(),
    );
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return MenuButton(
      leading: SvgPicture.asset(
        AppAssets.logoutSvg,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
      title: 'Logout',
      showArrow: false,
      onTap: () => _showLogoutDialog(context),
    );
  }
}
