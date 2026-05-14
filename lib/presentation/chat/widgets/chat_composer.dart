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

    final bool hasText = _controller.text.isNotEmpty;
    final Color borderColor = isDark
        ? AppColors.iconBorderDark
        : AppColors.iconBorderLight;

    final Color activeSendCircle = isDark
        ? AppColors.sendCircleActiveDark
        : AppColors.sendCircleActiveLight;
    final Color activeSendIcon = isDark ? AppColors.black : AppColors.white;
    final Color sendIconColor = hasText
        ? activeSendIcon
        : AppColors.iconDisabled;
    final ColorFilter sendFilter = ColorFilter.mode(
      sendIconColor,
      BlendMode.srcIn,
    );

    final Color inactiveSendCircle = isDark
        ? AppColors.iconBorderDark
        : AppColors.iconBorderLight;

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
                contentPadding: EdgeInsets.symmetric(vertical: 6.0),
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
                      isBold: true,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!hasText) ...<Widget>[
                      _ActionIcon(
                        asset: AppAssets.chatSvg,
                        onTap: () {},
                        colorFilter: iconFilter,
                        padding: 9.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                    ],
                    _ActionIcon(
                      asset: AppAssets.micSvg,
                      onTap: () {},
                      colorFilter: iconFilter,
                    ),
                    const SizedBox(width: 20.0),
                    _ActionIcon(
                      asset: AppAssets.upArrowSvg,
                      onTap: hasText ? _handleSend : null,
                      colorFilter: sendFilter,
                      padding: 10.0,
                      iconSizeOverride: 18.0,
                      isBold: true,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasText ? activeSendCircle : inactiveSendCircle,
                      ),
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
  final BoxDecoration? decoration;
  final double padding;
  final bool isBold;
  final double? iconSizeOverride;

  const _ActionIcon({
    required this.asset,
    this.onTap,
    required this.colorFilter,
    this.decoration,
    this.padding = 0.0,
    this.isBold = false,
    this.iconSizeOverride,
  });

  @override
  Widget build(final BuildContext context) {
    final double size = iconSizeOverride ?? 18.0;
    final Widget icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: colorFilter,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: decoration,
        child: isBold
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0.9, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-0.9, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, 0.9),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -0.9),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0.65, 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-0.65, 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0.65, -0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-0.65, -0.65),
                    child: icon,
                  ),
                  icon,
                ],
              )
            : icon,
      ),
    );
  }
}
