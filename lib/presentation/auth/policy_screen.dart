import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyScreen extends StatefulWidget {
  final String url;
  final String title;

  const PolicyScreen({required this.url, required this.title, super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController();

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (final int progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          onPageStarted: (final String url) {
            AppLogger.info('WebView started loading: $url');
          },
          onPageFinished: (final String url) {
            AppLogger.info('WebView finished loading: $url');
            if (mounted) {
              setState(() => _loadingProgress = 100);
            }
          },
          onWebResourceError: (final WebResourceError error) {
            AppLogger.error('WebView error: ${error.description}');
          },
          onNavigationRequest: (final NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    try {
      final Uri uri = Uri.parse(widget.url);
      _controller.loadRequest(uri);
    } catch (e) {
      AppLogger.error('Invalid URL passed to PolicyScreen: ${widget.url}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leadingWidth: 48,
        leading: Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            onPressed: () => context.pop(),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_loadingProgress < 100)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress / 100.0,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),
        ],
      ),
    );
  }
}
