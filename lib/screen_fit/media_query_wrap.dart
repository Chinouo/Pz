import 'package:all_in_one/screen_fit/screen_fit_util.dart';
import 'package:flutter/widgets.dart';

/// 你已经把系统的大小夺舍了，所以需要对MediaQuery进行修改，
/// 保证设计稿的属性能够正确应用到MediaQuery
/// 当然，你用[window]的属性依然可以访问到正确的设备属性，而非设计稿的内容。
class MediaQueryWrapper extends StatelessWidget {
  const MediaQueryWrapper({Key? key, required this.builder}) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
          size: ScreenFitUtil.instance.screenSize,
          padding: ScreenFitUtil.instance.padding,
          devicePixelRatio: ScreenFitUtil.instance.devicePixelRatio,
        ),
        child: builder(context));
  }
}
