import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_navigation_observer.dart';
import 'package:manus/presentation/auth/auth_screen.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/auth/policy_screen.dart';
import 'package:manus/presentation/chat/chat_screen.dart';
import 'package:manus/presentation/home/home_screen.dart';
import 'package:manus/presentation/profile/profile_screen.dart';
import 'package:manus/presentation/splash/splash_screen.dart';

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(final Ref ref) {
    _subscription = ref.listen(authProvider, (
      final bool? prev,
      final bool next,
    ) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<bool> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final Provider<RouterRefreshListenable> routerRefreshProvider =
    Provider<RouterRefreshListenable>((final Ref ref) {
      final RouterRefreshListenable listenable = RouterRefreshListenable(ref);
      ref.onDispose(listenable.dispose);
      return listenable;
    });

final Provider<GoRouter> routerProvider = Provider<GoRouter>((final Ref ref) {
  final RouterRefreshListenable refreshListenable = ref.watch(
    routerRefreshProvider,
  );

  return GoRouter(
    initialLocation: AppRouter.splash,
    debugLogDiagnostics: true,
    observers: <NavigatorObserver>[AppNavigationObserver()],
    refreshListenable: refreshListenable,
    redirect: (final BuildContext context, final GoRouterState state) {
      final bool isLoggedIn = ref.read(authProvider);
      final String location = state.uri.path;

      if (location == AppRouter.splash) return null;

      if (isLoggedIn && location == AppRouter.auth) {
        return AppRouter.chat;
      }

      if (!isLoggedIn &&
          location != AppRouter.auth &&
          location != AppRouter.policy) {
        return AppRouter.auth;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRouter.splash,
        name: 'splash',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            AppRouter.buildPage(context, state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRouter.auth,
        name: 'auth',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            AppRouter.buildPage(context, state, const AuthScreen()),
      ),
      GoRoute(
        path: AppRouter.home,
        name: 'home',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            AppRouter.buildPage(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: AppRouter.policy,
        name: 'policy',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final Map<String, String> extra =
              (state.extra as Map<String, String>?) ?? <String, String>{};
          final String url = extra['url'] ?? 'https://manus.im/terms';
          final String title = extra['title'] ?? 'Terms';
          return AppRouter.buildPage(
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
          return AppRouter.buildPage(
            context,
            state,
            ChatScreen(conversationId: conversationId),
            fromDrawer: fromDrawer,
          );
        },
      ),
      GoRoute(
        path: AppRouter.chat,
        name: 'chat',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final bool fromDrawer =
              state.extra is Map<dynamic, dynamic> &&
              (state.extra as Map<dynamic, dynamic>)['fromDrawer'] == true;
          return AppRouter.buildPage(
            context,
            state,
            const ChatScreen(),
            fromDrawer: fromDrawer,
          );
        },
      ),
      GoRoute(
        path: AppRouter.profile,
        name: 'profile',
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            AppRouter.buildPage(context, state, const ProfileScreen()),
      ),
    ],
  );
});

class AppRouter {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String policy = '/policy';
  static const String chat = '/chat';
  static const String profile = '/profile';

  static Page<dynamic> buildPage(
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
}