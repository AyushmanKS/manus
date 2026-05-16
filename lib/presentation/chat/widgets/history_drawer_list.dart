import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart' as msg;
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/drawer_notifier.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/widgets/manus_text_field.dart';

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
    final AsyncValue<HistoryState> historyState = ref.watch(historyProvider);
    final String activeConversationId = ref.watch(activeConversationIdProvider);
    final List<msg.ChatMessage> messages = ref.watch<List<msg.ChatMessage>>(
      chatProvider,
    );
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    final bool isChatEmpty = messages.isEmpty;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (!isChatEmpty)
                      IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.plusSvg,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          ref.read(drawerProvider.notifier).close();
                          Future<void>.delayed(
                            const Duration(milliseconds: 300),
                            () {
                              if (context.mounted) {
                                context.go(
                                  '/chat',
                                  extra: <String, dynamic>{'fromDrawer': true},
                                );
                              }
                            },
                          );
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
                  data: (final HistoryState _) {
                    final Map<String, List<Conversation>> activeGroups = ref
                        .watch(groupedHistoryProvider);
                    final Map<String, List<Conversation>> archivedGroups = ref
                        .watch(groupedArchivedHistoryProvider);
                    final bool isArchivedVisible = ref.watch(
                      isArchivedViewVisibleProvider,
                    );

                    if (activeGroups.isEmpty && archivedGroups.isEmpty) {
                      return _EmptyState(
                        isSearching: ref
                            .watch(historySearchProvider)
                            .isNotEmpty,
                      );
                    }

                    return RefreshIndicator(
                      color: Theme.of(context).disabledColor,
                      strokeWidth: 1.5,
                      onRefresh: () =>
                          ref.read(historyProvider.notifier).refresh(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: <Widget>[
                          ..._buildGroupedList(
                            activeGroups,
                            activeConversationId,
                          ),
                          if (archivedGroups.isNotEmpty) ...<Widget>[
                            _ArchivedHeader(
                              isOpen: isArchivedVisible,
                              onTap: () => ref
                                  .read(isArchivedViewVisibleProvider.notifier)
                                  .toggle(),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: isArchivedVisible
                                  ? Column(
                                      children: _buildGroupedList(
                                        archivedGroups,
                                        activeConversationId,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (final Object err, final StackTrace _) =>
                      Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList(
    final Map<String, List<Conversation>> groups,
    final String activeConversationId,
  ) {
    final List<Widget> children = <Widget>[];
    for (final MapEntry<String, List<Conversation>> entry in groups.entries) {
      children.add(_SectionHeader(title: entry.key));
      children.addAll(
        entry.value.map(
          (final Conversation conversation) => _HistoryItemWrapper(
            conversation: conversation,
            isActive: conversation.id == activeConversationId,
          ),
        ),
      );
    }
    return children;
  }
}

class _ArchivedHeader extends StatelessWidget {
  const _ArchivedHeader({required this.isOpen, required this.onTap});

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              AppAssets.archieveSvg,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                iconColor.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Archived',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: iconColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                AppAssets.downArrowSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  iconColor.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ManusTextField(
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: iconColor.withValues(alpha: 0.4),
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
                  iconColor.withValues(alpha: 0.4),
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
                          iconColor.withValues(alpha: 0.4),
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
                Future<void>.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    AppLogger.info('Loading conversation: ${conversation.id}');
                    context.go(
                      '/chat/${conversation.id}',
                      extra: <String, dynamic>{'fromDrawer': true},
                    );
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.isSearching = false});

  final bool isSearching;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AppAssets.chatBubbleSvg,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
              iconColor.withValues(alpha: 0.2),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No chats match your search' : 'No conversations yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: iconColor.withValues(alpha: 0.4),
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

class _ConversationTile extends ConsumerStatefulWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.isActive,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final bool isActive;

  @override
  ConsumerState<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends ConsumerState<_ConversationTile> {
  late final TextEditingController _renameController;

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.conversation.title);
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String? renamingId = ref.watch(renamingChatIdProvider);
    final bool isCurrentlyRenaming = renamingId == widget.conversation.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.isActive
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: isCurrentlyRenaming ? null : widget.onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: isCurrentlyRenaming
            ? ManusTextField(
                controller: _renameController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                ),
                onSubmitted: (final String newName) async {
                  if (newName.isNotEmpty &&
                      newName != widget.conversation.title) {
                    await ref
                        .read(historyProvider.notifier)
                        .renameChat(widget.conversation.id, newName);
                  }
                  ref.read(renamingChatIdProvider.notifier).set(null);
                },
              )
            : Text(
                widget.conversation.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: widget.isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
        subtitle: Text(
          widget.conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: widget.conversation.isPinned
            ? SvgPicture.asset(
                AppAssets.pinSvg,
                width: 14,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              )
            : null,
      ),
    );
  }
}
