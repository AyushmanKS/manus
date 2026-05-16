import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/chat/widgets/chat_composer.dart';
import 'package:manus/presentation/chat/widgets/chat_history_list.dart';

import 'package:manus/presentation/chat/notifiers/drawer_notifier.dart';
import 'package:manus/presentation/chat/widgets/custom_drawer_layout.dart';
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
      ref.read(chatProvider.notifier).loadConversation(convId);
    } else {
      ref.read(chatProvider.notifier).startNewConversation();
    }
    unawaited(ref.read(historyProvider.notifier).refresh());

    // Only request focus if the drawer is closed
    if (ref.read(drawerProvider) == 0) {
      if (_initialFocusRequested) return;
      _initialFocusRequested = true;
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted && ref.read(drawerProvider) == 0) {
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
      if (next > 0) {
        if (_composerFocusNode.hasFocus) {
          _composerFocusNode.unfocus();
        }
      } else if (prev != null && prev > 0 && next == 0) {
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (mounted &&
              !_composerFocusNode.hasFocus &&
              ref.read(drawerProvider) == 0) {
            _composerFocusNode.requestFocus();
          }
        });
      }
    });

    final String activeConvId = ref.watch(activeConversationIdProvider);
    ref.listen<AsyncValue<List<Conversation>>>(historyProvider, (
      final AsyncValue<List<Conversation>>? previous,
      final AsyncValue<List<Conversation>> next,
    ) {
      if (next is AsyncData<List<Conversation>>) {
        final List<Conversation> nextList = next.value;
        final List<Conversation> prevList = previous?.value ?? <Conversation>[];

        final bool wasPresent = prevList.any(
          (final Conversation c) => c.id == activeConvId,
        );
        final bool isPresent = nextList.any(
          (final Conversation c) => c.id == activeConvId,
        );

        if (wasPresent && !isPresent) {
          ref.read(chatProvider.notifier).startNewConversation();
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

    return CustomDrawerLayout(
      drawer: const HistoryDrawerList(),
      child: Scaffold(
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: bgDecoration,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: _ChatTopBar(
                    onMenuTap: () => ref.read(drawerProvider.notifier).open(),
                    isDark: isDark,
                  ),
                ),
                Expanded(child: ChatHistoryList(key: _listKey)),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                    child: ChatComposer(
                      controller: _composerController,
                      focusNode: _composerFocusNode,
                      onKeyboardOpen: () =>
                          _listKey.currentState?.doubleFrameScrollToBottom(),
                      onSend: (final String text) {
                        ref.read(chatProvider.notifier).sendMessage(text);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({required this.onMenuTap, required this.isDark});

  final VoidCallback onMenuTap;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    final Color iconColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              AppAssets.menuSvg,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            onPressed: onMenuTap,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
