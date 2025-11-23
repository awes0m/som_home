import 'package:logger/logger.dart';

class Log {
  // Create a static instance with a PrettyPrinter
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to display
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
    ),
  );

  static void d(String message) {
    _logger.d(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void w(String message) {
    _logger.w(message);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}