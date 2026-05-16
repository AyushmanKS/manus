import 'package:flutter/material.dart';

class ManusTextField extends StatelessWidget {
  const ManusTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.decoration,
    this.onChanged,
    this.textAlignVertical,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: style,
      decoration: decoration,
      onChanged: onChanged,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
    );
  }
}
