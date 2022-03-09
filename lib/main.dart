import 'dart:async';

import 'package:all_in_one/screen_fit/custom_binding.dart';
import 'package:all_in_one/screen_fit/screen_fit_util.dart';
import 'package:all_in_one/util/log_utils.dart';

import 'widgets/scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:all_in_one/constant/hive_boxes.dart';

void main() {
  runZonedGuarded<void>(() async {
    //初始化常量
    ScreenFitUtil().initConfig(baseWidth: 375);
    ScreenFitWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await HiveBoxes.openBoxes();

    runScreenFitApp(const MyApp());
  },
      (Object e, StackTrace s) => LogUitls.e(
            'Caught unhandled exception: $e',
            stackTrace: s,
          ));
}
