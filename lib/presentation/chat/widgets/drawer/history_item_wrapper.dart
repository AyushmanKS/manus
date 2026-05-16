import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/widgets/drawer/conversation_tile.dart';

class HistoryItemWrapper extends ConsumerWidget {
  const HistoryItemWrapper({
    required this.conversation,
    required this.isActive,
    super.key,
  });

  final Conversation conversation;
  final bool isActive;

  Future<void> _confirmDelete(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final bool? confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (final BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(historyProvider.notifier)
          .deleteConversation(conversation.id);
    }
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double constrainedWidth = (screenWidth * 0.8) - 16.0;

    return CupertinoContextMenu(
      actions: <Widget>[
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            ref.read(renamingChatIdProvider.notifier).set(conversation.id);
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
              const Text('Rename'),
            ],
          ),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(historyProvider.notifier)
                .pinConversation(
                  conversation.id,
                  pinned: !conversation.isPinned,
                );
          },
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                AppAssets.pinSvg,
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
              Text(conversation.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            if (conversation.isArchived) {
              ref.read(historyProvider.notifier).unarchiveChat(conversation.id);
            } else {
              ref.read(historyProvider.notifier).archiveChat(conversation.id);
            }
          },
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                AppAssets.archieveSvg,
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
              Text(conversation.isArchived ? 'Unarchive' : 'Archive'),
            ],
          ),
        ),
        CupertinoContextMenuAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            unawaited(_confirmDelete(context, ref));
          },
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                AppAssets.deleteSvg,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  CupertinoColors.destructiveRed,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Delete'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: SizedBox(
          width: constrainedWidth,
          child: Material(
            color: Colors.transparent,
            child: ConversationTile(
              conversation: conversation,
              isActive: isActive,
              onTap: () {
                Navigator.pop(context); // Close the drawer immediately
                AppLogger.info('Loading conversation: ${conversation.id}');
                context.go(
                  '/chat/${conversation.id}',
                  extra: <String, dynamic>{'fromDrawer': true},
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
