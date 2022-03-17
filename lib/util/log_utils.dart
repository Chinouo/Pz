import 'dart:developer' as _dev;

class LogUitls {
  const LogUitls._();

  static void e(String message, {StackTrace? stackTrace}) {
    _dev.log(message, time: DateTime.now(), stackTrace: StackTrace.current, level: 777);
  }

  static void d(String message) {
    _dev.log(message, time: DateTime.now(), level: 1);
  }

  static void w(String message) {
    _dev.log(message, time: DateTime.now(), level: 7);
  }

  static void i(String message) {
    _dev.log(message, level: 0);
  }
}
