import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void info(final String message) {
    _logger.i(message);
  }

  static void warning(final String message) {
    _logger.w(message);
  }

  static void error(final String message, [final Object? error, final StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void route(final String message) {
    _logger.d('🛣️ ROUTE: $message');
  }

  static void debug(final String message) {
    _logger.d(message);
  }
}
