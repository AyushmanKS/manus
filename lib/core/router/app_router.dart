import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/presentation/home/home_screen.dart';
import 'package:manus/presentation/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: home,
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
    ],
  );
}
