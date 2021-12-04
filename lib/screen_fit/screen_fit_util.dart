/// 参考 今日头条 屏幕适配方案
/// 参考 screen_autosize 的写法 [screen_autosize](https://github.com/CxmyDev/screen_autosize)
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

class ScreenFitUtil {
  ScreenFitUtil._internal();
  factory ScreenFitUtil() => instance;
  static ScreenFitUtil? _instance;
  double baseScreenWidth = 375;

  static ScreenFitUtil get instance {
    _instance ??= ScreenFitUtil._internal();
    _instance!._tryInit();
    return _instance!;
  }

  /// 传入设计稿的宽度
  void initConfig({required double baseWidth}) {
    baseScreenWidth = baseWidth;
    _tryInit();
  }

  void _tryInit() {
    if (devicePixelRatio != null) {
      return;
    }
    var window = WidgetsBinding.instance?.window ?? ui.window;
    devicePixelRatio = window.physicalSize.width / baseScreenWidth;
    mediaWidth = baseScreenWidth;
    mediaHeight = window.physicalSize.height / devicePixelRatio!;
    statusBarHeight = window.padding.top / devicePixelRatio!;
    bottomBarHeight = window.padding.bottom / devicePixelRatio!;
  }

  EdgeInsets get padding =>
      EdgeInsets.only(top: statusBarHeight, bottom: bottomBarHeight);

  Size get screenSize => Size(mediaWidth, mediaHeight);

  double? devicePixelRatio;

  late double mediaWidth;

  late double mediaHeight;

  late double bottomBarHeight;

  late double statusBarHeight;
}
