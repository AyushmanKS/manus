import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

import 'package:manus/presentation/chat/widgets/chat_header.dart';

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
                child: ChatHeader(composerFocusNode: _composerFocusNode),
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
