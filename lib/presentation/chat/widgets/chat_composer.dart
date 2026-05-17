import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/notifiers/chat_status_notifiers.dart';
import 'package:manus/presentation/chat/notifiers/editing_notifier.dart';
import 'package:manus/presentation/chat/providers/attachment_provider.dart';
import 'package:manus/presentation/widgets/manus_text_field.dart';

import 'composer/action_icon.dart';
import 'composer/attachment_preview_row.dart';
import 'composer/attachment_tray.dart';
import 'composer/model_picker_sheet.dart';
import 'composer/send_button.dart';

class ChatComposer extends ConsumerStatefulWidget {
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
  ConsumerState<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends ConsumerState<ChatComposer>
    with TickerProviderStateMixin {
  bool _showAttachmentTray = false;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  FocusNode get _focusNode => widget.focusNode;

  TextEditingController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 1.02),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.02, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) widget.onKeyboardOpen();
  }

  void _onTextChanged() => setState(() {});

  void _handleSend(final EditingMessage? editingMessage) {
    unawaited(HapticFeedback.lightImpact());
    FocusManager.instance.primaryFocus?.unfocus();
    final String text = _controller.text.trim();
    final bool hasAttachments = ref.read(attachmentProvider).isNotEmpty;
    if (text.isEmpty && !hasAttachments) return;

    if (editingMessage != null) {
      ref
          .read(chatProvider.notifier)
          .editAndResend(editingMessage.messageId, text);
      ref.read(editingMessageProvider.notifier).confirmEditing();
    } else {
      widget.onSend(text);
    }
    _controller.clear();
    // TODO: encode attachments into Gemini multimodal request
    ref.read(attachmentProvider.notifier).clear();
  }

  void _toggleAttachmentTray() {
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _showAttachmentTray = !_showAttachmentTray);
  }

  void _toggleModelPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (final BuildContext ctx) => ModelPickerSheet(
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    ).whenComplete(() => _focusNode.requestFocus());
  }

  @override
  Widget build(final BuildContext context) {
    ref.listen<int>(composerPulseProvider, (final int? previous, final int next) {
      _pulseController.forward(from: 0.0);
    });

    final EditingMessage? editingMessage = ref.watch(editingMessageProvider);

    ref.listen<EditingMessage?>(editingMessageProvider, (
      final EditingMessage? previous,
      final EditingMessage? next,
    ) {
      if (next != null && previous != next) {
        _controller.text = next.originalText;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        WidgetsBinding.instance.addPostFrameCallback(
          (final _) => _focusNode.requestFocus(),
        );
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEmpty = ref.watch(chatProvider).isEmpty;

    final Color bgColor = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color iconColor = isDark ? AppColors.iconDark : AppColors.black;
    final Color secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                _buildEditingIndicator(editingMessage, secondaryTextColor),
                _buildAttachmentTray(iconColor),
                const AttachmentPreviewRow(),
                _buildTextField(isEmpty),
                const SizedBox(height: 16.0),
                _buildActionsRow(
                  iconFilter,
                  borderColor,
                  hasText,
                  isDark,
                  activeSendCircle,
                  inactiveSendCircle,
                  editingMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingIndicator(
    final EditingMessage? editingMessage,
    final Color color,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: editingMessage != null
          ? AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 28,
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      AppAssets.pencilSvg,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Editing message',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: color),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Transform.rotate(
                        angle: math.pi / 4,
                        child: SvgPicture.asset(
                          AppAssets.plusSvg,
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _controller.clear();
                        ref
                            .read(editingMessageProvider.notifier)
                            .cancelEditing();
                      },
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildAttachmentTray(final Color iconColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder:
          (final Widget child, final Animation<double> animation) {
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
          },
      child: _showAttachmentTray
          ? Padding(
              key: const ValueKey<String>('tray'),
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AttachmentTray(
                iconColor: iconColor,
                onClose: () => setState(() => _showAttachmentTray = false),
              ),
            )
          : const SizedBox.shrink(key: ValueKey<String>('empty')),
    );
  }

  Widget _buildTextField(final bool isEmpty) {
    return ManusTextField(
      controller: _controller,
      focusNode: _focusNode,
      minLines: 1,
      maxLines: 6,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: isEmpty ? 'Assign a task or ask anything' : 'Message Manus',
        contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
        isDense: true,
      ),
    );
  }

  Widget _buildActionsRow(
    final ColorFilter iconFilter,
    final Color borderColor,
    final bool hasText,
    final bool isDark,
    final Color activeSendCircle,
    final Color inactiveSendCircle,
    final EditingMessage? editingMessage,
  ) {
    return Row(
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
          editingMessage,
        ),
      ],
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
          child: ActionIcon(
            asset: AppAssets.plusSvg,
            onTap: _toggleAttachmentTray,
            colorFilter: iconFilter,
            size: 24.0,
          ),
        ),
        const SizedBox(width: 20.0),
        ActionIcon(
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
    final EditingMessage? editingMessage,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildChatIcon(iconFilter, borderColor, hasText),
        ActionIcon(
          asset: AppAssets.micSvg,
          onTap: () {},
          colorFilter: iconFilter,
        ),
        const SizedBox(width: 20.0),
        _buildSendButton(
          hasText,
          isDark,
          activeSendCircle,
          inactiveSendCircle,
          editingMessage,
        ),
      ],
    );
  }

  Widget _buildChatIcon(
    final ColorFilter iconFilter,
    final Color borderColor,
    final bool hasText,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder:
          (final Widget child, final Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
      child: hasText
          ? const SizedBox.shrink(key: ValueKey<bool>(true))
          : Row(
              key: const ValueKey<bool>(false),
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ActionIcon(
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
    );
  }

  Widget _buildSendButton(
    final bool hasText,
    final bool isDark,
    final Color activeSendCircle,
    final Color inactiveSendCircle,
    final EditingMessage? editingMessage,
  ) {
    return Consumer(
      builder: (final BuildContext ctx, final WidgetRef ref, final Widget? _) {
        final bool isStreaming = ref.watch(chatIsStreamingProvider);
        final bool isSubmitting = ref.watch(chatIsSubmittingProvider);

        bool canTap;
        if (editingMessage != null) {
          canTap =
              _controller.text.trim().isNotEmpty &&
              _controller.text.trim() != editingMessage.originalText;
        } else {
          canTap =
              hasText ||
              isStreaming ||
              ref.watch(attachmentProvider).isNotEmpty;
        }

        void onTap() {
          if (isStreaming) {
            unawaited(HapticFeedback.mediumImpact());
            ref.read(chatProvider.notifier).stopStream();
          } else if (!isSubmitting) {
            _handleSend(editingMessage);
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            SendButton(
              hasText: hasText,
              isStreaming: isStreaming,
              isSubmitting: isSubmitting,
              onTap: canTap ? onTap : null,
              isDark: isDark,
              activeSendCircle: activeSendCircle,
              inactiveSendCircle: inactiveSendCircle,
            ),
            const SendButtonBadge(),
          ],
        );
      },
    );
  }
}
