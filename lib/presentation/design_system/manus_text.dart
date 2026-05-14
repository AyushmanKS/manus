import 'package:flutter/material.dart';

enum ManusTextStyle {
  h1,
  h2,
  body,
  caption,
}

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
  Widget build(BuildContext context) {
    final TextStyle textStyle = _getStyle(context);
    return Text(
      text,
      style: textStyle.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  TextStyle _getStyle(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    switch (style) {
      case ManusTextStyle.h1:
        return theme.headlineLarge ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case ManusTextStyle.h2:
        return theme.headlineMedium ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case ManusTextStyle.body:
        return theme.bodyLarge ?? const TextStyle(fontSize: 16);
      case ManusTextStyle.caption:
        return theme.bodySmall ?? const TextStyle(fontSize: 12);
    }
  }
}
