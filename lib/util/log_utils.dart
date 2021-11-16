import "package:logging/logging.dart";
import 'dart:developer' as _dev;

class LogUitls {
  const LogUitls._();

  /// 打印Error信息
  static void e(String e, {required StackTrace stackTrace}) {
    _dev.log(e, time: DateTime.now(), stackTrace: StackTrace.current);
  }
}
