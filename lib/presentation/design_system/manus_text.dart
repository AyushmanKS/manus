import 'package:flutter/material.dart';

enum ManusTextStyle { h1, h2, body, caption }

class ManusText extends StatelessWidget {
  final String text;
  final ManusTextStyle style;
  final Color? color;
  final TextAlign? textAlign;

  const ManusText(
    this.text, {
    super.key,
    this.style = ManusTextStyle.body,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(final BuildContext context) {
    final TextStyle textStyle = _getStyle(context);
    return Text(
      text,
      style: textStyle.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  TextStyle _getStyle(final BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    switch (style) {
      case ManusTextStyle.h1:
        return theme.headlineLarge!;
      case ManusTextStyle.h2:
        return theme.headlineMedium!;
      case ManusTextStyle.body:
        return theme.bodyLarge!;
      case ManusTextStyle.caption:
        return theme.bodySmall!;
    }
  }
}