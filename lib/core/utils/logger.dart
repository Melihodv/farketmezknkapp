import 'dart:developer' as developer;

class AppLogger {
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('❌ $message', error: error, stackTrace: stackTrace, name: 'FarketmezKnk');
  }

  static void info(String message) {
    developer.log('ℹ️ $message', name: 'FarketmezKnk');
  }

  static void warning(String message) {
    developer.log('⚠️ $message', name: 'FarketmezKnk');
  }
}
