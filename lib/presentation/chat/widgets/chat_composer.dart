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
      child: Padding(
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
                    _ActionIcon(
                      asset: AppAssets.plusSvg,
                      onTap: () {},
                      colorFilter: iconFilter,
                    ),
                    const SizedBox(width: 20.0),
                    _ActionIcon(
                      asset: AppAssets.plugSvg,
                      onTap: () {},
                      colorFilter: iconFilter,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _ActionIcon(
                      asset: AppAssets.chatSvg,
                      onTap: () {},
                      colorFilter: iconFilter,
                    ),
                    const SizedBox(width: 20.0),
                    _ActionIcon(
                      asset: AppAssets.micSvg,
                      onTap: () {},
                      colorFilter: iconFilter,
                    ),
                    const SizedBox(width: 20.0),
                    _ActionIcon(
                      asset: AppAssets.upArrowSvg,
                      onTap: _controller.text.isNotEmpty ? _handleSend : null,
                      colorFilter: iconFilter,
                      opacity: _controller.text.isNotEmpty ? 1.0 : 0.3,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;
  final ColorFilter colorFilter;
  final double opacity;

  const _ActionIcon({
    required this.asset,
    this.onTap,
    required this.colorFilter,
    this.opacity = 1.0,
  });

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          asset,
          width: 18.0,
          height: 18.0,
          colorFilter: colorFilter,
        ),
      ),
    );
  }
}
