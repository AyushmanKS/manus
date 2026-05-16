import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/core/theme/app_theme.dart';
import 'package:manus/core/theme/theme_notifier.dart';
import 'package:manus/core/utils/app_logger.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    AppLogger.warning('Failed to load .env file: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox<String>('chat_history');
  await Hive.openBox<String>('conversations');

  AppLogger.info('Application Started');

  runApp(const ProviderScope(child: ManusApp()));
}

class ManusApp extends ConsumerWidget {
  const ManusApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Manus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 200),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: AppRouter.router,
    );
  }
}
