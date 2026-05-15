import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    required this.onSend,
    required this.controller,
    required this.focusNode,
    required this.onKeyboardOpen,
    super.key,
  });

  final void Function(String text) onSend;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onKeyboardOpen;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  bool _showAttachmentTray = false;

  FocusNode get _focusNode => widget.focusNode;

  TextEditingController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) widget.onKeyboardOpen();
  }

  void _onTextChanged() => setState(() {});

  void _handleSend() {
    HapticFeedback.lightImpact();
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  void _toggleAttachmentTray() {
    HapticFeedback.mediumImpact();
    setState(() => _showAttachmentTray = !_showAttachmentTray);
  }

  void _toggleModelPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (final BuildContext ctx) => _ModelPickerSheet(
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    ).whenComplete(() => _focusNode.requestFocus());
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
    final Color inactiveSendCircle = isDark
        ? AppColors.iconBorderDark
        : AppColors.iconBorderLight;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: _slideTransition,
                child: _showAttachmentTray
                    ? Padding(
                        key: const ValueKey<String>('tray'),
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _AttachmentTray(iconColor: iconColor),
                      )
                    : const SizedBox.shrink(key: ValueKey<String>('empty')),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 6,
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _buildLeftActions(iconFilter),
                  _buildRightActions(
                    iconFilter,
                    borderColor,
                    hasText,
                    isDark,
                    activeSendCircle,
                    inactiveSendCircle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftActions(final ColorFilter iconFilter) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedRotation(
          turns: _showAttachmentTray ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: _ActionIcon(
            asset: AppAssets.plusSvg,
            onTap: _toggleAttachmentTray,
            colorFilter: iconFilter,
            size: 24.0,
          ),
        ),
        const SizedBox(width: 20.0),
        _ActionIcon(
          asset: AppAssets.plugSvg,
          onTap: _toggleModelPicker,
          colorFilter: iconFilter,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildRightActions(
    final ColorFilter iconFilter,
    final Color borderColor,
    final bool hasText,
    final bool isDark,
    final Color activeSendCircle,
    final Color inactiveSendCircle,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: _fadeHorizontalTransition,
          child: hasText
              ? const SizedBox.shrink(key: ValueKey<bool>(true))
              : Row(
                  key: const ValueKey<bool>(false),
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                ),
        ),
        _ActionIcon(
          asset: AppAssets.micSvg,
          onTap: () {},
          colorFilter: iconFilter,
        ),
        const SizedBox(width: 20.0),
        Consumer(
          builder:
              (final BuildContext ctx, final WidgetRef ref, final Widget? _) {
                final bool isStreaming = ref.watch(chatIsStreamingProvider);
                final bool isSubmitting = ref.watch(chatIsSubmittingProvider);
                final bool canTap = hasText || isStreaming;

                void onTap() {
                  if (isStreaming) {
                    HapticFeedback.mediumImpact();
                    ref.read(chatProvider.notifier).stopStream();
                  } else if (!isSubmitting) {
                    _handleSend();
                  }
                }

                return _SendButton(
                  hasText: hasText,
                  isStreaming: isStreaming,
                  isSubmitting: isSubmitting,
                  onTap: canTap ? onTap : null,
                  isDark: isDark,
                  activeSendCircle: activeSendCircle,
                  inactiveSendCircle: inactiveSendCircle,
                );
              },
        ),
      ],
    );
  }

  static Widget _slideTransition(
    final Widget child,
    final Animation<double> animation,
  ) {
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(animation);
    return ClipRect(
      child: SlideTransition(
        position: slide,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: child,
        ),
      ),
    );
  }

  static Widget _fadeHorizontalTransition(
    final Widget child,
    final Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.horizontal,
        child: child,
      ),
    );
  }
}

enum _SendState { idle, submitting, streaming }

class _SendButton extends StatelessWidget {
  final bool hasText;
  final bool isStreaming;
  final bool isSubmitting;
  final VoidCallback? onTap;
  final bool isDark;
  final Color activeSendCircle;
  final Color inactiveSendCircle;

  const _SendButton({
    required this.hasText,
    required this.isStreaming,
    required this.isSubmitting,
    required this.onTap,
    required this.isDark,
    required this.activeSendCircle,
    required this.inactiveSendCircle,
  });

  _SendState get _state {
    if (isSubmitting) return _SendState.submitting;
    if (isStreaming) return _SendState.streaming;
    return _SendState.idle;
  }

  @override
  Widget build(final BuildContext context) {
    final bool isActive = hasText || isStreaming || isSubmitting;
    final Color circleColor = isActive ? activeSendCircle : inactiveSendCircle;
    final Color iconColor = isActive
        ? (isDark ? AppColors.black : AppColors.white)
        : AppColors.iconDisabled;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: _morphTransition,
          child: _buildIcon(iconColor),
        ),
      ),
    );
  }

  Widget _buildIcon(final Color iconColor) {
    switch (_state) {
      case _SendState.submitting:
        return SizedBox(
          key: const ValueKey<String>('submitting'),
          width: 18.0,
          height: 18.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        );
      case _SendState.streaming:
        return Center(
          key: const ValueKey<String>('streaming'),
          child: Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        );
      case _SendState.idle:
        return Padding(
          key: const ValueKey<String>('idle'),
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            AppAssets.upArrowSvg,
            width: 18.0,
            height: 18.0,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        );
    }
  }

  static Widget _morphTransition(
    final Widget child,
    final Animation<double> animation,
  ) {
    final Animation<double> scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}

class _AttachmentTray extends StatelessWidget {
  final Color iconColor;

  const _AttachmentTray({required this.iconColor});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _TrayItem(
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          iconColor: iconColor,
        ),
        _TrayItem(
          icon: Icons.photo_outlined,
          label: 'Photo',
          iconColor: iconColor,
        ),
        _TrayItem(
          icon: Icons.insert_drive_file_outlined,
          label: 'File',
          iconColor: iconColor,
        ),
        _TrayItem(
          icon: Icons.crop_free_outlined,
          label: 'Capture',
          iconColor: iconColor,
        ),
      ],
    );
  }
}

class _TrayItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _TrayItem({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.composerIconBgDark
        : AppColors.composerIconBgLight;
    final Color labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 52.0,
            height: 52.0,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Icon(icon, color: iconColor, size: 24.0),
          ),
          const SizedBox(height: 6.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelPickerSheet extends StatelessWidget {
  final bool isDark;

  const _ModelPickerSheet({required this.isDark});

  @override
  Widget build(final BuildContext context) {
    final Color bg = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 36.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: divider,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Select Model',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16.0),
          ...<String>[
            'Manus Default',
            'GPT-4o',
            'Claude 3.5',
            'Gemini 1.5 Pro',
          ].map<Widget>(
            (final String model) => Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          model,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: divider, height: 1.0, thickness: 1.0),
              ],
            ),
          ),
        ],
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
  final double size;

  const _ActionIcon({
    required this.asset,
    this.onTap,
    required this.colorFilter,
    this.decoration,
    this.padding = 0.0,
    this.isBold = false,
    this.size = 18.0,
  });

  @override
  Widget build(final BuildContext context) {
    const double strength = 0.3;
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
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(padding),
        decoration: decoration,
        child: isBold
            ? Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(strength, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, strength),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -strength),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(strength * 0.65, strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength * 0.65, strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(strength * 0.65, -strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength * 0.65, -strength * 0.65),
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
