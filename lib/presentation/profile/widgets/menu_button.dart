import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';

class MenuButton extends StatefulWidget {
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
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    return GestureDetector(
      onTapDown: (final _) => setState(() => _isPressed = true),
      onTapUp: (final _) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
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
                child: Center(child: widget.leading),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.title, style: const TextStyle(fontSize: 15)),
              ),
              if (widget.showArrow)
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
    );
  }
}
