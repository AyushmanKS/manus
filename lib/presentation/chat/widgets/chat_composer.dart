import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key});

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _handleSend() {
    HapticFeedback.lightImpact();
    _controller.clear();
  }

  @override
  Widget build(final BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color iconColor = isDark ? AppColors.white : AppColors.black;
    final ColorFilter iconFilter = ColorFilter.mode(iconColor, BlendMode.srcIn);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Assign a task or ask anything',
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: SvgPicture.asset(
                      AppAssets.plusSvg,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: iconFilter,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: SvgPicture.asset(
                      AppAssets.plugSvg,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: iconFilter,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.chatSvg,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: iconFilter,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.micSvg,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: iconFilter,
                    ),
                  ),
                  GestureDetector(
                    onTap: _controller.text.isNotEmpty ? _handleSend : null,
                    behavior: HitTestBehavior.opaque,
                    child: Opacity(
                      opacity: _controller.text.isNotEmpty ? 1.0 : 0.3,
                      child: SvgPicture.asset(
                        AppAssets.upArrowSvg,
                        width: 18.0,
                        height: 18.0,
                        colorFilter: iconFilter,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
