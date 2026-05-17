import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/widgets/tappable_opacity.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    required this.leading,
    required this.title,
    required this.onTap,
    this.showArrow = true,
    super.key,
  });
  final Widget leading;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    return TappableOpacity(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 22,
              height: 22,
              child: Center(child: leading),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                    ),
              ),
            ),
            if (showArrow)
              SvgPicture.asset(
                AppAssets.rightArrowSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(mutedColor, BlendMode.srcIn),
              ),
          ],
        ),
      ),
    );
  }
}
