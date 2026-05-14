import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/core/theme/app_theme.dart';
import 'package:manus/core/utils/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Application Started');
  
  runApp(
    const ProviderScope(
      child: ManusApp(),
    ),
  );
}

class ManusApp extends ConsumerWidget {
  const ManusApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return MaterialApp.router(
      title: 'Manus AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
