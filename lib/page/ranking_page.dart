///  展示每日Ranking排行表的页面
/// 见Figma 初版设计图

import 'dart:ui';

import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/widgets/pixiv_image.dart';
import 'package:all_in_one/widgets/sliver_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';

// 根据OverScroll 进行字体缩放的字体Widget

class RankingPage extends StatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  // 触发背景模糊的滑动阈值
  final double backdropEnableOffset = 100.0;

  final ValueNotifier<double> titleFontSize = ValueNotifier<double>(36);

  @override
  void initState() {
    super.initState();
  }

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
          SliverPersistentHeader(
            pinned: true,
            delegate: PersistentHeaderBuilder(
              minExtent: 106,
              maxExtent: 106,
              builder: (context, offset) {
                // debugPrint(offset.toString());
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
                      opacity: offset > 80 ? statuBarOpacity.clamp(0, 1) : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Divider(
                        height: 1,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 29.0),
              child: ValueListenableBuilder(
                builder: (BuildContext context, double value, Widget? child) {
                  return SizedBox(
                    height: 64,
                    child: Text(
                      "Settng",
                      style: TextStyle(fontSize: value),
                    ),
                  );
                },
                valueListenable: titleFontSize,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: RankingContent(
              rankingName: "illust",
            ),
          ),
          const SliverToBoxAdapter(
            child: RankingContent(
              rankingName: "Manga",
            ),
          ),
          const SliverToBoxAdapter(
            child: RankingContent(
              rankingName: "Novel",
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 83),
          )
        ],
      ),
    );
  }
}

// 从分割线开始的详情页
class RankingContent extends StatelessWidget {
  const RankingContent({Key? key, required this.rankingName}) : super(key: key);

  // 排行榜的标题
  final String rankingName;

  @override
  Widget build(BuildContext context) {
    // 排行小部件的顶部结构
    final Widget header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29.0, vertical: 18.0),
      child: Column(
        children: [
          const Divider(
            color: Colors.grey,
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text(
                  rankingName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text("See all")
              ],
            ),
          ),
        ],
      ),
    );
    // 滑动的图片

    Widget content = Consumer<IllustProvider>(builder: (_, illustProvider, __) {
      if (illustProvider.illustsCollection.isEmpty) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 31),
              sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: Text("$index"),
                      );
                    },
                    childCount: 3,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 180,
                      mainAxisSpacing: 17,
                      maxCrossAxisExtent: 225)),
            ),
          ],
        );
      }

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 31),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    return PixivImage(
                      url: illustProvider
                          .illustsCollection[index].imageUrls!.squareMedium!,
                      width: 180,
                      height: 180,
                    );
                  },
                  childCount: illustProvider.illustsCollection.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 180,
                    mainAxisSpacing: 17,
                    maxCrossAxisExtent: 225)),
          ),
        ],
      );
    });

    return Column(
      children: [
        header,
        SizedBox(
          height: 225,
          child: content,
        ),
      ],
    );
  }
}
