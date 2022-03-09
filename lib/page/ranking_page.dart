/// 主页
/// 结构由上到下
/// illust排行 -> pixivsion -> recommended

import 'dart:ui';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/provider/pivision_provider.dart';
import 'package:all_in_one/provider/recommand_illust_provider.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/widgets/sliver_title.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

// 触发刷新的阈值
const double kMaxOverScrollValue = 50;

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

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

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
          if (titleFontSize.value != (overscrollStart.abs() / 10).clamp(0, 28) + 36)
            titleFontSize.value = (overscrollStart.abs() / 10).clamp(0, 28) + 36;
        }

        if (isLoading.value) {
          return false;
        }
        // 判断是否触底了
        if (notification.metrics.extentAfter == 0) {
          //debugPrint(recentOverScroll.toString());
          if (notification.metrics.pixels - notification.metrics.maxScrollExtent >
              kMaxOverScrollValue) {
            if (!isLoading.value) {
              _loadMoreRecommand();
              debugPrint("Start Loading!");
            }
          }

          // 到底了 开始计算 overscroll 的值
          //notification.scrollDelta

        }
        return false;
      },
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 55,
            child: ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (BuildContext context, bool value, Widget? child) {
                return CupertinoActivityIndicator(
                  key: UniqueKey(),
                  animating: value,
                  radius: 20,
                );
              },
            )),
        _buildScrollBody(context),
      ]),
    );
  }

  Widget _buildScrollBody(BuildContext context) {
    return CustomScrollView(
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
                    "Ranking",
                    style: TextStyle(fontSize: value),
                  ),
                );
              },
              valueListenable: titleFontSize,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildRanking(context),
        ),
        SliverToBoxAdapter(
          child: _buildPixivison(context),
        ),
        ..._buildRecommand(context), // Effective Dart
        SliverFillRemaining(
          hasScrollBody: false,
          child: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (BuildContext context, bool value, Widget? child) {
              return SizedBox(
                height: value ? kMaxOverScrollValue : 0.0,
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildRanking(BuildContext context) {
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
              children: const [
                Text(
                  "Ranking",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text("See all")
              ],
            ),
          ),
        ],
      ),
    );
    // 滑动的图片

    Widget content = Consumer<IllustProvider>(builder: (_, illustProvider, __) {
      final imgCollection = illustProvider.collection;
      if (imgCollection.isEmpty) {
        return const SizedBox.shrink();
      }

      return CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 31),
            sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    debugPrint("rank img idx: $index");
                    return PixivImage(
                      url: illustProvider.collection[index].imageUrls!.squareMedium!,
                      width: 180,
                      height: 180,
                    );
                  },
                  childCount: imgCollection.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 180, mainAxisSpacing: 17, maxCrossAxisExtent: 225)),
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

  Widget _buildPixivison(BuildContext context) {
    // 头部标题
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
              children: const [
                Text(
                  "Pixivsion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text("See all")
              ],
            ),
          ),
        ],
      ),
    );

    // 图片 以及 介绍
    Widget content = Consumer<PixivsionProvider>(
      builder: (_, pixivsionProvider, child) {
        final imgCollection = pixivsionProvider.collection;
        // 下面都调用 length 了, 这个 isEmpty 有点尴尬
        if (imgCollection.isEmpty) {
          return const SizedBox.shrink();
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
                        url: pixivsionProvider.collection[index].thumbnail!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      );
                    },
                    childCount: imgCollection.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 180,
                      mainAxisSpacing: 17,
                      maxCrossAxisExtent: 225)),
            ),
          ],
        );
      },
    );

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

  List<Widget> _buildRecommand(BuildContext context) {
    final Widget header = SliverToBoxAdapter(
      child: Padding(
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
                children: const [
                  Text(
                    "Recommand",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final Widget body =
        Consumer<RecommandProvider>(builder: (context, recommandProvider, child) {
      final imgCollection = recommandProvider.collection;
      if (imgCollection.isEmpty) {
        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
      }

      return SliverWaterfallFlow(
        delegate: SliverChildBuilderDelegate((context, index) {
          debugPrint("recommand: current build img idx : $index");
          double height = 270;
          if (index % 7 == 0) {
            height = 200;
          }
          return PixivImage(
            fit: BoxFit.cover,
            url: recommandProvider.collection[index].imageUrls!.squareMedium!,
            height: height,
          );
        }, childCount: imgCollection.length),
        gridDelegate:
            const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      );
    });

    return <Widget>[header, body];
  }

  Future<void> _loadMoreRecommand() async {
    var api = ApiClient();
    final String? nextUrl =
        Provider.of<RecommandProvider>(context, listen: false).nextUrl;
    if (nextUrl != null) {
      isLoading.value = true;
      Response r = await api.getNext(nextUrl);
      // debugPrint(r.toString());
      Provider.of<RecommandProvider>(context, listen: false).fromResponseAdd(r);
      isLoading.value = false;
    } else {
      debugPrint("Next url is null");
    }
  }
}

/// 在这里好像不需要  自己写 Demo 的时候问题不复现了 可能是 法法的 Sliver 比官方强吧
/// 重写 保证在刷新的时候  如果手指不放开 列表默认会跳到底部
// class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
//   const CustomBouncingScrollPhysics({ScrollPhysics? parent})
//       : super(parent: parent);

//   @override
//   CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return CustomBouncingScrollPhysics(parent: buildParent(ancestor));
//   }

//   @override
//   double adjustPositionForNewDimensions({
//     required ScrollMetrics oldPosition,
//     required ScrollMetrics newPosition,
//     required bool isScrolling,
//     required double velocity,
//   }) {
//     return oldPosition.pixels;
//   }
// }
