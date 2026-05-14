import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/core/theme/app_theme.dart';
import 'package:manus/core/utils/app_logger.dart';

void main() {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  AppLogger.info('Application Started');

  runApp(const ProviderScope(child: ManusApp()));
}

class ManusApp extends ConsumerWidget {
  const ManusApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return MaterialApp.router(
      title: 'Manus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      themeAnimationDuration: const Duration(milliseconds: 200),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: AppRouter.router,
    );
  }
}
