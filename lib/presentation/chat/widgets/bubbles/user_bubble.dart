import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/services/haptic_service.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/editing_notifier.dart';
import 'package:manus/presentation/widgets/haptic_listener.dart';

class UserBubble extends ConsumerWidget {
  const UserBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget bubbleContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(4.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message.text, style: Theme.of(context).textTheme.bodyLarge),
          if (message.isEdited)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'edited',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: CupertinoContextMenu(
          actions: <Widget>[
            CupertinoContextMenuAction(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(editingMessageProvider.notifier)
                    .startEditing(message.id, message.text);
              },
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    AppAssets.pencilSvg,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.iconDark
                          : Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit'),
                ],
              ),
            ),
            CupertinoContextMenuAction(
              onPressed: () {
                Navigator.pop(context);
                unawaited(Clipboard.setData(ClipboardData(text: message.text)));
                unawaited(HapticService.light());
              },
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    AppAssets.copySvg,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.iconDark
                          : Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Copy'),
                ],
              ),
            ),
          ],
          child: HapticListener(child: bubbleContent),
        ),
      ),
    );
  }
}
