import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/theme_notifier.dart';

class ThemeSelectorItem extends ConsumerStatefulWidget {
  const ThemeSelectorItem({
    required this.iconColor,
    required this.themeInfo,
    super.key,
  });
  final Color iconColor;
  final (String, String) themeInfo;
  @override
  ConsumerState<ThemeSelectorItem> createState() => _ThemeSelectorItemState();
}

class _ThemeSelectorItemState extends ConsumerState<ThemeSelectorItem> {
  bool _isPressed = false;
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeMode currentMode = ref.watch(themeProvider);
    final Color mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    return PopupMenuButton<ThemeMode>(
      offset: const Offset(1000, 48),
      elevation: 0.5,
      tooltip: '',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSelected: (final ThemeMode mode) {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        unawaited(HapticFeedback.mediumImpact());
      },
      itemBuilder: (final BuildContext context) => <PopupMenuEntry<ThemeMode>>[
        _buildPopupItem(
          context,
          ThemeMode.system,
          'Follow system',
          AppAssets.contrastSvg,
          currentMode == ThemeMode.system,
        ),
        _buildDivider(isDark),
        _buildPopupItem(
          context,
          ThemeMode.light,
          'Light mode',
          AppAssets.lightModeSvg,
          currentMode == ThemeMode.light,
        ),
        _buildDivider(isDark),
        _buildPopupItem(
          context,
          ThemeMode.dark,
          'Dark mode',
          AppAssets.darkModeSvg,
          currentMode == ThemeMode.dark,
        ),
      ],
      child: Listener(
        onPointerDown: (final _) => setState(() => _isPressed = true),
        onPointerUp: (final _) => setState(() => _isPressed = false),
        onPointerCancel: (final _) => setState(() => _isPressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _isPressed ? 0.4 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.themeInfo.$2,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        widget.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.themeInfo.$1,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                        ),
                  ),
                ),
                SvgPicture.asset(
                  AppAssets.rightArrowSvg,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(mutedColor, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<ThemeMode> _buildDivider(final bool isDark) {
    return const PopupMenuDivider(height: 1);
  }

  PopupMenuItem<ThemeMode> _buildPopupItem(
    final BuildContext context,
    final ThemeMode mode,
    final String label,
    final String iconPath,
    final bool isSelected,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color itemIconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;
    return PopupMenuItem<ThemeMode>(
      value: mode,
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 20,
            child: isSelected
                ? SvgPicture.asset(
                    AppAssets.checkSvg,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.iconDark
                          : Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(
            iconPath,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(itemIconColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
