import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/widgets/manus_text_field.dart';

class HistorySearchBar extends StatelessWidget {
  const HistorySearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    super.key,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ManusTextField(
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: iconColor.withValues(alpha: 0.4),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 40,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SvgPicture.asset(
                AppAssets.searchSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  iconColor.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Transform.rotate(
                      angle: math.pi / 4,
                      child: SvgPicture.asset(
                        AppAssets.plusSvg,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          iconColor.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
