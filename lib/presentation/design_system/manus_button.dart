import 'package:flutter/material.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

enum ManusButtonVariant { primary, secondary, outline }

class ManusButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ManusButtonVariant variant;
  final bool isLoading;
  final Widget? icon;

  const ManusButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = ManusButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(colorScheme),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  ManusText(
                    text,
                    style: ManusTextStyle.body,
                    color: _getTextColor(colorScheme),
                  ),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(final ColorScheme colorScheme) {
    switch (variant) {
      case ManusButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      case ManusButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      case ManusButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
    }
  }

  Color _getTextColor(final ColorScheme colorScheme) {
    switch (variant) {
      case ManusButtonVariant.primary:
        return colorScheme.onPrimary;
      case ManusButtonVariant.secondary:
        return colorScheme.onSecondaryContainer;
      case ManusButtonVariant.outline:
        return colorScheme.primary;
    }
  }
}
