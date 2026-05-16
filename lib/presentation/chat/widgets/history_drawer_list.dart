import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/drawer_notifier.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';

class HistoryDrawerList extends ConsumerStatefulWidget {
  const HistoryDrawerList({super.key});

  @override
  ConsumerState<HistoryDrawerList> createState() => _HistoryDrawerListState();
}

class _HistoryDrawerListState extends ConsumerState<HistoryDrawerList> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(historySearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AsyncValue<List<Conversation>> historyState =
        ref.watch(historyProvider);
    final String activeConversationId = ref.watch(activeConversationIdProvider);
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.plusSvg,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(onSurface, BlendMode.srcIn),
                    ),
                    onPressed: () async {
                      ref.read(drawerProvider.notifier).close();
                      await Future<void>.delayed(
                          const Duration(milliseconds: 150));
                      if (context.mounted) {
                        context.go('/chat');
                      }
                    },
                    tooltip: 'New Chat',
                  ),
                ],
              ),
            ),
            _HistorySearchBar(
              controller: _searchController,
              onChanged: (final String val) =>
                  ref.read(historySearchProvider.notifier).set(val),
              onClear: () {
                _searchController.clear();
                ref.read(historySearchProvider.notifier).clear();
              },
            ),
            Expanded(
              child: historyState.when(
                data: (final _) {
                  final Map<String, List<Conversation>> groups =
                      ref.watch(groupedHistoryProvider);

                  if (groups.isEmpty) {
                    return _EmptyState(
                      onSurface: onSurface,
                      isSearching: ref.watch(historySearchProvider).isNotEmpty,
                    );
                  }

                  final List<String> headers = groups.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: headers.length,
                    itemBuilder: (final BuildContext context, final int index) {
                      final String header = headers[index];
                      final List<Conversation> items = groups[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SectionHeader(title: header),
                          ...items.map(
                            (final Conversation conversation) =>
                                _HistoryItemWrapper(
                              conversation: conversation,
                              isActive: conversation.id == activeConversationId,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (final Object err, final _) =>
                    Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySearchBar extends StatelessWidget {
  const _HistorySearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(final BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: onSurface.withValues(alpha: 0.4),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 40,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SvgPicture.asset(
                AppAssets.searchSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  onSurface.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Transform.rotate(
                      angle: math.pi / 4,
                      child: SvgPicture.asset(
                        AppAssets.plusSvg,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          onSurface.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _HistoryItemWrapper extends ConsumerWidget {
  const _HistoryItemWrapper({
    required this.conversation,
    required this.isActive,
  });

  final Conversation conversation;
  final bool isActive;

  Future<void> _confirmDelete(
      final BuildContext context, final WidgetRef ref) async {
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double constrainedWidth = (screenWidth * 0.8) - 16.0;

    return CupertinoContextMenu(
      actions: <Widget>[
        CupertinoContextMenuAction(
          onPressed: () => Navigator.pop(context),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                AppAssets.pencilSvg,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              const Text('Rename'),
            ],
          ),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            ref.read(historyProvider.notifier).pinConversation(
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
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(conversation.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        CupertinoContextMenuAction(
          onPressed: () => Navigator.pop(context),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                AppAssets.archieveSvg,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              const Text('Archive'),
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
                    CupertinoColors.destructiveRed, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              const Text('Delete'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: SizedBox(
          width: constrainedWidth,
          child: Material(
            color: Colors.transparent,
            child: _ConversationTile(
              conversation: conversation,
              isActive: isActive,
              onTap: () {
                ref.read(drawerProvider.notifier).close();
                AppLogger.info('Loading conversation: ${conversation.id}');
                context.go('/chat/${conversation.id}');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSurface, this.isSearching = false});
  final Color onSurface;
  final bool isSearching;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AppAssets.chatBubbleSvg,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
              onSurface.withValues(alpha: 0.2),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No chats match your search' : 'No conversations yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSurface.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(final BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.isActive,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        trailing: conversation.isPinned
            ? SvgPicture.asset(
                AppAssets.pinSvg,
                width: 14,
                colorFilter:
                    ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
              )
            : null,
      ),
    );
  }
}
