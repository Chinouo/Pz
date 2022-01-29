/*
  用户设置列表
*/

import 'package:flutter/material.dart';
import 'package:all_in_one/widgets/sliver_title.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // 触发背景模糊的滑动阈值
  final double backdropEnableOffset = 100.0;

  final ValueNotifier<double> titleFontSize = ValueNotifier<double>(36);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          final double overscrollStart = notification.metrics.pixels;
          if (overscrollStart.isNegative && notification.depth == 0) {
            // 暂时不知道如何拿到Scrollable 里面的AnimaitionController 只能这样拙劣的模拟
            if (titleFontSize.value !=
                (overscrollStart.abs() / 10).clamp(0, 28) + 36)
              titleFontSize.value =
                  (overscrollStart.abs() / 10).clamp(0, 28) + 36;
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 或许SliverOpacity 和 SliverVisibility 可以试试
            SliverPersistentHeader(
                pinned: true,
                delegate: PersistentHeaderBuilder(
                  minExtent: 106,
                  maxExtent: 106,
                  builder: (context, offset) {
                    var statuBarOpacity = (80 - offset).abs() / 20;
                    var statuBarColorFactor = (offset - 80) / 20;

                    return Column(
                      children: [
                        BlurStatuBar(
                          statuBarColor: Color.lerp(
                              Colors.white,
                              const Color(0x00f9f9f9).withOpacity(0.94),
                              statuBarColorFactor)!,
                          titleOpacity: offset > 50.0 ? 1.0 : 0.0,
                        ),
                        AnimatedOpacity(
                          opacity:
                              offset > 80 ? statuBarOpacity.clamp(0, 1) : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Divider(
                            height: 1,
                          ),
                        )
                      ],
                    );
                  },
                )),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 29.0),
                child: ValueListenableBuilder(
                  builder: (BuildContext context, double value, Widget? child) {
                    return SizedBox(
                      height: 64,
                      child: Text(
                        "Setting",
                        style: TextStyle(fontSize: value),
                      ),
                    );
                  },
                  valueListenable: titleFontSize,
                ),
              ),
            ),
            // ios风格的 Widget
            SliverToBoxAdapter(
              child: _buildGrid(context),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 583),
            )
          ],
        ));
  }

  Widget _buildGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          margin: EdgeInsets.only(top: 20),
          width: 313,
          height: 155,
          child: Center(child: Text("用户信息")),
        ),
        Wrap(
          spacing: 20,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              margin: EdgeInsets.only(top: 20),
              width: 147,
              height: 147,
              child: Center(child: Text("其他设置")),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              margin: EdgeInsets.only(top: 20),
              width: 147,
              height: 147,
              child: Center(child: Text("夜间模式")),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(22))),
          margin: EdgeInsets.only(top: 20),
          width: 313,
          height: 155,
          child: Center(child: Text("浏览历史")),
        )
      ],
    );
  }
}
