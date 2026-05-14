import 'package:flutter/material.dart';
import 'package:manus/core/utils/app_logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.route('PUSH: ${route.settings.name ?? route.toString()}');
  }

  @override
  void didPop(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.route('POP: ${route.settings.name ?? route.toString()}');
  }

  @override
  void didReplace({final Route<dynamic>? newRoute, final Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      AppLogger.route('REPLACE: ${newRoute.settings.name ?? newRoute.toString()}');
    }
  }

  @override
  void didRemove(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AppLogger.route('REMOVE: ${route.settings.name ?? route.toString()}');
  }
}
