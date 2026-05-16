import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
class ArchivedHeader extends StatelessWidget {
  const ArchivedHeader({required this.isOpen, required this.onTap, super.key});
  final bool isOpen;
  final VoidCallback onTap;
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              AppAssets.archieveSvg,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                iconColor.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Archived',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: iconColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                AppAssets.downArrowSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  iconColor.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}