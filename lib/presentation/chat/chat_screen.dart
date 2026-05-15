import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/chat_composer.dart';
import 'package:manus/presentation/chat/widgets/chat_history_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

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
      if (_initialFocusRequested) return;
      _initialFocusRequested = true;
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _composerFocusNode.requestFocus();
      });
    });
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
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _listKey.currentState?.onScrollMetricsChanged();
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _listKey.currentState?.onScrollMetricsChanged();
      });
    });
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

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: (final ScrollMetricsNotification n) {
          _listKey.currentState?.onScrollMetricsChanged();
          return false;
        },
        child: Container(
          decoration: bgDecoration,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: ChatHistoryList(key: _listKey),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
