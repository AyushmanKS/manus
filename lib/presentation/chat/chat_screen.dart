import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/widgets/chat_composer.dart';
import 'package:manus/presentation/chat/widgets/chat_empty_state.dart';
import 'package:manus/presentation/chat/widgets/chat_history_list.dart';

import 'package:manus/presentation/chat/notifiers/drawer_notifier.dart';
import 'package:manus/presentation/chat/widgets/history_drawer_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({this.conversationId, super.key});

  final String? conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _composerController;
  late final FocusNode _composerFocusNode;
  final GlobalKey<ChatHistoryListState> _listKey =
      GlobalKey<ChatHistoryListState>();
  bool _initialFocusRequested = false;
  double _previousViewInset = 0;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _composerFocusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);

    _composerFocusNode.addListener(() {
      if (_composerFocusNode.hasFocus) {
        _listKey.currentState?.doubleFrameScrollToBottom();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _loadConversationIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant final ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conversationId != oldWidget.conversationId) {
      _loadConversationIfNeeded();
    }
  }

  void _loadConversationIfNeeded() {
    final String? convId = widget.conversationId;
    if (convId != null) {
      ref.read<ChatNotifier>(chatProvider.notifier).loadConversation(convId);
    } else {
      final List<ChatMessage> currentMessages = ref.read<List<ChatMessage>>(
        chatProvider,
      );
      if (currentMessages.isNotEmpty) {
        ref.read<ChatNotifier>(chatProvider.notifier).startNewConversation();
      }
    }
    unawaited(ref.read<HistoryNotifier>(historyProvider.notifier).refresh());

    if (ref.read<double>(drawerProvider) == 0) {
      if (_initialFocusRequested) return;
      _initialFocusRequested = true;
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted && ref.read<double>(drawerProvider) == 0) {
          _composerFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didChangeMetrics() {
    final double viewInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    if (viewInset == _previousViewInset) return;
    _previousViewInset = viewInset;
    _listKey.currentState?.onScrollMetricsChanged();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSystemUi();
  }

  void _updateSystemUi() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _composerController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    ref.listen<double>(drawerProvider, (final double? prev, final double next) {
      if (next > 0 && (prev == null || prev == 0)) {
        FocusManager.instance.primaryFocus?.unfocus();
      } else if (prev != null && prev > 0 && next == 0) {
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (mounted &&
              !_composerFocusNode.hasFocus &&
              ref.read<double>(drawerProvider) == 0) {
            _composerFocusNode.requestFocus();
          }
        });
      }
    });

    final String activeConvId = ref.watch<String>(activeConversationIdProvider);
    ref.listen<AsyncValue<HistoryState>>(historyProvider, (
      final AsyncValue<HistoryState>? previous,
      final AsyncValue<HistoryState> next,
    ) {
      if (next is AsyncData<HistoryState>) {
        final List<Conversation> nextAll = <Conversation>[
          ...next.value.activeChats,
          ...next.value.archivedChats,
        ];
        final List<Conversation> prevAll = previous?.value != null
            ? <Conversation>[
                ...previous!.value!.activeChats,
                ...previous.value!.archivedChats,
              ]
            : <Conversation>[];

        final bool wasPresent = prevAll.any(
          (final Conversation c) => c.id == activeConvId,
        );
        final bool isPresent = nextAll.any(
          (final Conversation c) => c.id == activeConvId,
        );

        if (wasPresent && !isPresent) {
          ref.read<ChatNotifier>(chatProvider.notifier).startNewConversation();
        }
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark
        ? AppColors.chatBgDarkBottom
        : AppColors.chatBgLight;

    final BoxDecoration bgDecoration = isDark
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.chatBgDarkTop,
                AppColors.chatBgDarkBottom,
              ],
            ),
          )
        : const BoxDecoration(color: AppColors.chatBgLight);

    final double drawerValue = ref.watch<double>(drawerProvider);

    return Scaffold(
      key: ValueKey<String>(activeConvId),
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: drawerValue == 0,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        child: const HistoryDrawerList(),
      ),
      onDrawerChanged: (final bool isOpen) {
        if (isOpen) {
          ref.read<DrawerNotifier>(drawerProvider.notifier).open();
        } else {
          ref.read<DrawerNotifier>(drawerProvider.notifier).close();
        }
      },
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: bgDecoration,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: _ChatHeader(composerFocusNode: _composerFocusNode),
              ),
              Expanded(
                child: ref.watch<List<ChatMessage>>(chatProvider).isEmpty
                    ? ChatEmptyState(
                        key: ValueKey<String>(activeConvId),
                        composerController: _composerController,
                        composerFocusNode: _composerFocusNode,
                      )
                    : ChatHistoryList(key: _listKey),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: ChatComposer(
                    controller: _composerController,
                    focusNode: _composerFocusNode,
                    onKeyboardOpen: () =>
                        _listKey.currentState?.doubleFrameScrollToBottom(),
                    onSend: (final String text) {
                      _listKey.currentState?.forceScrollToBottom();
                      ref
                          .read<ChatNotifier>(chatProvider.notifier)
                          .sendMessage(text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({required this.composerFocusNode});

  final FocusNode composerFocusNode;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final String selectedModel = ref.watch<String>(selectedModelProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : AppColors.textPrimaryLight;
    final Color mutedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: SvgPicture.asset(
              AppAssets.menuSvg,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            constraints: const BoxConstraints.tightFor(width: 36, height: 44),
            padding: EdgeInsets.zero,
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            onSelected: (final String model) {
              ref
                  .read<SelectedModelNotifier>(selectedModelProvider.notifier)
                  .set(model);
              composerFocusNode.requestFocus();
            },
            itemBuilder: (final BuildContext context) {
              final List<(String, String)> models = <(String, String)>[
                ('Manus 1.6 Lite', 'Fast and efficient'),
                ('Manus 1.6', 'Balanced'),
                ('Manus 2.0 Pro', 'Most capable'),
              ];
              return models.map((final (String, String) model) {
                final bool isSelected = selectedModel == model.$1;
                return PopupMenuItem<String>(
                  value: model.$1,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(model.$1, style: const TextStyle(fontSize: 15)),
                          Text(
                            model.$2,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    selectedModel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    AppAssets.downArrowSvg,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(mutedColor, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRouter.profile),
            icon: SvgPicture.asset(
              AppAssets.profileSvg,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            constraints: const BoxConstraints.tightFor(width: 36, height: 44),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
