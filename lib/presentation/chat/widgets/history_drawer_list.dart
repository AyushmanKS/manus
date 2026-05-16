import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart' as msg;
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/drawer/archived_header.dart';
import 'package:manus/presentation/chat/widgets/drawer/history_empty_state.dart';
import 'package:manus/presentation/chat/widgets/drawer/history_item_wrapper.dart';
import 'package:manus/presentation/chat/widgets/drawer/history_search_bar.dart';
import 'package:manus/presentation/chat/widgets/drawer/history_section_header.dart';
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
                          AppLogger.info(
                            'HistoryDrawerList: starting new conversation from drawer',
                          );
                          ref
                              .read(chatProvider.notifier)
                              .startNewConversation();
                          Navigator.pop(context);
                          context.go(
                            '/chat',
                            extra: <String, dynamic>{'fromDrawer': true},
                          );
                        },
                        tooltip: 'New Chat',
                      ),
                  ],
                ),
              ),
              HistorySearchBar(
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
                      return HistoryEmptyState(
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
                            ArchivedHeader(
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dividerColor = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;
    for (final MapEntry<String, List<Conversation>> entry in groups.entries) {
      children.add(HistorySectionHeader(title: entry.key));
      final List<Conversation> groupConversations = entry.value;
      for (int i = 0; i < groupConversations.length; i++) {
        final Conversation conversation = groupConversations[i];
        children.add(
          HistoryItemWrapper(
            conversation: conversation,
            isActive: conversation.id == activeConversationId,
          ),
        );
        if (i < groupConversations.length - 1) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Divider(height: 1, thickness: 0.5, color: dividerColor),
            ),
          );
        }
      }
    }
    return children;
  }
}