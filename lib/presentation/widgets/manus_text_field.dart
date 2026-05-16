import 'package:flutter/material.dart';

class ManusTextField extends StatelessWidget {
  const ManusTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textAlignVertical,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlignVertical? textAlignVertical;
  final int? minLines;
  final int? maxLines;
  final bool autofocus;

  @override
  Widget build(final BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      style: style,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textAlignVertical: textAlignVertical,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: autofocus,
    );
  }
}
