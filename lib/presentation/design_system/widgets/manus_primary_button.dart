import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/app_spacing.dart';
class ManusPrimaryButton extends StatefulWidget {
  final String label;
  final String? iconPath;
  final VoidCallback onTap;
  final bool isBrandIcon;
  final double? iconSize;
  const ManusPrimaryButton({
    required this.label,
    required this.onTap,
    this.iconPath,
    this.isBrandIcon = false,
    this.iconSize,
    super.key,
  });
  @override
  State<ManusPrimaryButton> createState() => _ManusPrimaryButtonState();
}
class _ManusPrimaryButtonState extends State<ManusPrimaryButton> {
  bool _isPressed = false;
  void _handleTapDown(final TapDownDetails details) {
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
  }
  void _handleTapUp(final TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }
  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: widget.label,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOutCubic,
          opacity: _isPressed ? 0.7 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? AppColors.socialButtonBgDark : AppColors.white,
              border: isDark
                  ? null
                  : Border.all(color: AppColors.greyE6, width: 0.5),
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.white,
                        AppColors.greyF9,
                        AppColors.greyF2,
                      ],
                      stops: <double>[0.0, 0.95, 1.0],
                    ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (widget.iconPath != null)
                  Positioned(
                    left: 0,
                    width: AppSpacing.socialIconContainerWidth,
                    child: Center(
                      child: SvgPicture.asset(
                        widget.iconPath!,
                        width: widget.iconSize ?? AppSpacing.socialIconSize,
                        height: widget.iconSize ?? AppSpacing.socialIconSize,
                        colorFilter: widget.isBrandIcon
                            ? null
                            : ColorFilter.mode(
                                isDark ? AppColors.white : AppColors.black,
                                BlendMode.srcIn,
                              ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.socialIconContainerWidth,
                  ),
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}