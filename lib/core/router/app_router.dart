import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_navigation_observer.dart';
import 'package:manus/presentation/auth/auth_screen.dart';
import 'package:manus/presentation/auth/policy_screen.dart';
import 'package:manus/presentation/chat/chat_screen.dart';
import 'package:manus/presentation/home/home_screen.dart';
import 'package:manus/presentation/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String policy = '/policy';
  static const String chat = '/chat';

  static Page<dynamic> _buildPage(
    final BuildContext context,
    final GoRouterState state,
    final Widget child, {
    final bool fromDrawer = false,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPage<void>(key: state.pageKey, child: child);
    }

    if (fromDrawer) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder:
            (
              final BuildContext context,
              final Animation<double> animation,
              final Animation<double> secondaryAnimation,
              final Widget child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
      );
    }

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder:
          (
            final BuildContext context,
            final Animation<double> animation,
            final Animation<double> secondaryAnimation,
            final Widget child,
          ) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    observers: <NavigatorObserver>[AppNavigationObserver()],
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            _buildPage(context, state, const SplashScreen()),
      ),
      GoRoute(
        path: auth,
        name: 'auth',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            _buildPage(context, state, const AuthScreen()),
      ),
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            _buildPage(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: policy,
        name: 'policy',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final Map<String, String> extra =
              (state.extra as Map<String, String>?) ?? <String, String>{};
          final String url = extra['url'] ?? 'https://manus.im/terms';
          final String title = extra['title'] ?? 'Terms';
          return _buildPage(
            context,
            state,
            PolicyScreen(url: url, title: title),
          );
        },
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat_detail',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final String? conversationId = state.pathParameters['conversationId'];
          final bool fromDrawer =
              state.extra is Map<dynamic, dynamic> &&
              (state.extra as Map<dynamic, dynamic>)['fromDrawer'] == true;
          return _buildPage(
            context,
            state,
            ChatScreen(conversationId: conversationId),
            fromDrawer: fromDrawer,
          );
        },
      ),
      GoRoute(
        path: chat,
        name: 'chat',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final bool fromDrawer =
              state.extra is Map<dynamic, dynamic> &&
              (state.extra as Map<dynamic, dynamic>)['fromDrawer'] == true;
          return _buildPage(
            context,
            state,
            const ChatScreen(),
            fromDrawer: fromDrawer,
          );
        },
      ),
    ],
  );
}
