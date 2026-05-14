import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_navigation_observer.dart';
import 'package:manus/presentation/auth/auth_screen.dart';
import 'package:manus/presentation/auth/policy_screen.dart';
import 'package:manus/presentation/home/home_screen.dart';
import 'package:manus/presentation/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String policy = '/policy';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    observers: <NavigatorObserver>[
      AppNavigationObserver(),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (final BuildContext context, final GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (final BuildContext context, final GoRouterState state) => const AuthScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (final BuildContext context, final GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: policy,
        name: 'policy',
        pageBuilder: (final BuildContext context, final GoRouterState state) {
          final Map<String, String> extra = state.extra as Map<String, String>;
          final String url = extra['url'] ?? 'https://manus.im/terms';
          final String title = extra['title'] ?? 'Terms';

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PolicyScreen(url: url, title: title),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (
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
        },
      ),
    ],
  );
}
