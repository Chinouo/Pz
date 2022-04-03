/// 主页
/// 结构由上到下
/// illust排行 -> pixivsion -> recommended

import 'dart:math';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/component/transition_route/pin_route_wrap.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/generated/l10n.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:all_in_one/page/home/content_cards.dart';
import 'package:all_in_one/page/illust_detail/illust_detail.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

// 将来需要跨组建管理

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // 水平滑动的内容
    final horizontalContent = Column(
      children: const [
        RankingView(),
        PivisionView(),
      ],
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(S.of(context).today),
        ),
        SliverToBoxAdapter(
          child: horizontalContent,
        ),
        ...buildRecommendView(),
        LoadingMoreSliver(
          onRefresh: () async {
            if (mounted && recommendKey.currentState != null) {
              if (recommendKey.currentState!.mounted) {
                await recommendKey.currentState?.handleLoadingMoreIllusts();
              }
            }
          },
        )
      ],
    );
  }

  final recommendKey = GlobalKey<_RecommandViewState>();

  // 第一次使用 global key
  List<Widget> buildRecommendView() {
    final title = _Header(leadingText: S.of(context).recommend);
    return [
      SliverToBoxAdapter(
          child: Padding(
        padding: Constant.kViewPaddingHoriziontal,
        child: title,
      )),
      RecommandView(
        key: recommendKey,
      ),
    ];
  }
}

const _kHeaderLeadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
    required this.leadingText,
    this.trailingText,
  }) : super(key: key);

  final String leadingText;

  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    var children = [
      Text(leadingText, style: _kHeaderLeadingTextStyle),
      const Spacer(),
    ];
    if (trailingText != null) {
      children.add(Text(trailingText!));
    }

    return Column(
      children: [
        const Divider(
          color: Colors.grey,
          height: 0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: children,
          ),
        ),
      ],
    );
  }
}

/// 水平滑动的 插画视图
class RankingView extends StatefulWidget {
  const RankingView({Key? key}) : super(key: key);

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> with IllustResponseHelper {
  @override
  void initState() {
    super.initState();
    illustFuture = ApiClient().getIllustRanking();
  }

  late Future<Response> illustFuture;

  @override
  Widget build(BuildContext context) {
    final title = Padding(
      padding: Constant.kViewPaddingHoriziontal,
      child: _Header(leadingText: S.of(context).ranking),
    );
    final content = Container(
      padding: const EdgeInsets.only(top: 8),
      height: 220,
      child: FutureBuilder<Response>(
        future: illustFuture,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());

            case ConnectionState.done:
              if (!snapshot.hasData) {
                return const Center(child: Text("No Data"));
              }
              storeIllusts(snapshot.data!);
              return GridView.builder(
                padding: Constant.kViewPaddingHoriziontal,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                addAutomaticKeepAlives: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 180,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return RankIllustCard(illust: illusts[index]);
                },
                itemCount: min(illustsCount, 7),
              );
            default:
              return const SizedBox.shrink();
          }
        }),
      ),
    );

    return Column(
      children: [title, content],
    );
  }
}

class PivisionView extends StatefulWidget {
  const PivisionView({Key? key}) : super(key: key);

  @override
  State<PivisionView> createState() => _PivisionViewState();
}

class _PivisionViewState extends State<PivisionView>
    with SpotLightArticleResponseHeler {
  @override
  void initState() {
    super.initState();
    illustFuture = ApiClient().getSpotlightArticles();
  }

  late Future<Response> illustFuture;

  @override
  Widget build(BuildContext context) {
    final title = Padding(
      padding: Constant.kViewPaddingHoriziontal,
      child: _Header(leadingText: S.of(context).pixvision),
    );
    final content = Container(
      padding: const EdgeInsets.only(top: 18),
      height: 200,
      child: FutureBuilder<Response>(
        future: illustFuture,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              storeSpotLightArticles(snapshot.data!);
              return ListView.builder(
                padding: Constant.kViewPaddingHoriziontal,
                itemExtent: 300,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                addAutomaticKeepAlives: false,
                // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //   crossAxisCount: 1,
                //   mainAxisSpacing: 36,
                //   childAspectRatio: 0.7,
                // ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: PivisionCard(
                      spotlightArticle: spotlights[index],
                    ),
                  );
                },
                itemCount: spotlightsCount,
              );
            default:
              return const SizedBox.shrink();
          }
        }),
      ),
    );

    return Column(
      children: [title, content],
    );
  }
}

class RecommandView extends StatefulWidget {
  const RecommandView({Key? key}) : super(key: key);

  @override
  State<RecommandView> createState() => _RecommandViewState();
}

class _RecommandViewState extends State<RecommandView> with IllustResponseHelper {
  @override
  void initState() {
    super.initState();
    _initialResponse = ApiClient().getRecommend();
  }

  late final Future<Response> _initialResponse;

  bool _isFirstBuild = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: _initialResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return buildWaterFallFlow(snapshot.data!);

          default:
            return const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }

  Widget buildWaterFallFlow(Response response) {
    if (_isFirstBuild) {
      storeIllusts(response);
      _isFirstBuild = false;
    }

    return SliverPadding(
      padding: Constant.kViewPaddingHoriziontal,
      sliver: SliverWaterfallFlow(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ContainerWrap(
              closeBuilder: (context) {
                return IllustCard(
                  illust: illusts[index],
                );
              },
              openBuilder: (context) {
                return IllustDetail(illust: illusts[index]);
              },
            );
          },
          childCount: illustsCount,
        ),
        gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 17),
      ),
    );
  }

  // 用于 parent 的 onRefresh 的调用
  // only when future done will trigger loading more.
  Future<void> handleLoadingMoreIllusts() async {
    if (_isFirstBuild) return;

    try {
      if (nextUrl == null) return;
      Response response = await ApiClient().getNext(nextUrl!);
      setState(() {
        storeIllusts(response);
      });
    } on DioError catch (e) {
      LogUitls.e(e.response!.data.toString());
    }
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late int _currentIndex = 0;
//   late Box<Account> accountBox;
//   @override
//   void initState() {
//     super.initState();
//     _fetchAllResource();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //debugPrint(MediaQuery.of(context).toString());

//     return Stack(children: [
//       LazyIndexedStack(
//         index: _currentIndex,
//         children: [
//           RankingPage(),
//           SearchPage(),
//           //SliverContent(),
//           //LoginTemplate(),
//           //ShowAccountPage(),
//           //LoginPage(),
//           SearchPageOld(),
//           SettingPage(),
//           // Placeholder()
//         ],
//       ),
//       Positioned(bottom: 0, width: 375, child: _buildTabBar())
//     ]);
//   }

//   Widget _buildTabBar() {
//     return ClipRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
//         child: AnimatedContainer(
//           duration: Duration(seconds: 1),
//           color: Color(0xF2F2F7).withOpacity(0.8),
//           height: 56 + 16,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               MaterialButton(
//                 onPressed: () {
//                   setState(() {
//                     _currentIndex = 0;
//                   });
//                 },
//                 child: Text("Label1"),
//               ),
//               MaterialButton(
//                 onPressed: () {
//                   setState(() {
//                     _currentIndex = 1;
//                   });
//                 },
//                 child: Text("Label2"),
//               ),
//               MaterialButton(
//                 onPressed: () {
//                   setState(() {
//                     _currentIndex = 2;
//                   });
//                 },
//                 child: Text("Label3"),
//               ),
//               MaterialButton(
//                 onPressed: () {
//                   setState(() {
//                     _currentIndex = 3;
//                     // debugPrint(MediaQuery.of(context).toString());
//                   });
//                 },
//                 child: Text("Label4"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// 加载各种资源 一般用于 登陆后 或者 刚启动 App
//   /// 获取 用户JSON数据  排行榜  Pixivison 推荐插画
//   Future<void> _fetchAllResource() async {
//     var api = ApiClient();

//     // model 是生成工具提供的 是不是应该考虑一个 泛型的 fromJson 转换 减少代码
//     api.getIllustRanking().then((Response response) {
//       List list = response.data["illusts"];
//       List<Illust> result = <Illust>[];
//       for (var item in list) {
//         result.add(Illust.fromJson(item));
//       }
//       Provider.of<IllustProvider>(context, listen: false).addillustFromList(result);
//       // 把数据返回给Provider
//     });
//     api.getRecommend().then((Response response) =>
//         Provider.of<RecommandProvider>(context, listen: false)
//             .fromResponseAdd(response));
//     api.getSpotlightArticles().then((Response response) {
//       List list = response.data["spotlight_articles"];
//       List<SpotlightArticle> result = <SpotlightArticle>[];
//       for (var item in list) {
//         result.add(SpotlightArticle.fromJson(item));
//       }
//       Provider.of<PixivsionProvider>(context, listen: false).addillustFromList(result);
//     });

//     api.getIllustTrendTags().then((Response response) =>
//         Provider.of<TrendTagProvider>(context, listen: false)
//             .fromResponseAdd(response));
//   }
// }
