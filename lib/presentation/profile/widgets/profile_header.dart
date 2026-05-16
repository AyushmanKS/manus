import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : AppColors.textPrimaryLight;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                AppAssets.arrowBackSvg,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          Text(
            'Manus',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.iconDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}