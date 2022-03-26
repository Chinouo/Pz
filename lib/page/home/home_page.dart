/// 主页
/// 结构由上到下
/// illust排行 -> pixivsion -> recommended

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/component/transition_route/pin_route_wrap.dart';
import 'package:all_in_one/generated/l10n.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:all_in_one/page/illust_detail/illust_detail.dart';
import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(S.of(context).today),
        ),
        const SliverToBoxAdapter(
          child: RankingView(),
        ),
        const SliverToBoxAdapter(
          child: PivisionView(),
        ),
        ...buildRecommendView(),
        LoadingMoreSliver(
          onRefresh: () async {
            await recommendKey.currentState?.fetchNext();
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
      SliverToBoxAdapter(child: title),
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

const _kHomePageViewPadding = EdgeInsets.symmetric(horizontal: 29.0, vertical: 18.0);

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

    return Padding(
      padding: _kHomePageViewPadding,
      child: Column(
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
      ),
    );
  }
}

/// 水平滑动的 插画视图
class RankingView extends StatefulWidget {
  const RankingView({Key? key}) : super(key: key);

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  @override
  void initState() {
    super.initState();
    illustFuture = ApiClient().getIllustRanking();
  }

  final illustStore = <Illust>[];

  late Future<Response> illustFuture;

  @override
  Widget build(BuildContext context) {
    final title = _Header(leadingText: S.of(context).ranking);
    final content = SizedBox(
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
              return const CircularProgressIndicator();

            case ConnectionState.done:
              if (!snapshot.hasData) {
                return const Center(child: Text("No Data"));
              }
              storeIllustDataFrom(snapshot.data!);
              return GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                addAutomaticKeepAlives: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 36,
                ),
                itemBuilder: (context, index) {
                  debugPrint("index:$index  ${illustStore[index].id!}");

                  return ContainerWrap(
                    closeBuilder: (context) {
                      return PixivImage(
                        url: illustStore[index].imageUrls!.medium!,
                        height: 160,
                        width: 160,
                      );
                    },
                    openBuilder: (context) {
                      return IllustDetail(illust: illustStore[index]);
                    },
                  );
                  return OpenContainer(
                    openBuilder: (context, action) {
                      return IllustDetail(illust: illustStore[index]);
                    },
                    closedBuilder: (context, f) {
                      return PixivImage(
                        url: illustStore[index].imageUrls!.medium!,
                        height: 360,
                        width: 360,
                      );
                    },
                  );
                },
                itemCount: illustStore.length,
              );
            default:
              return const SizedBox(
                height: 360,
              );
          }
        }),
      ),
    );

    return Column(
      children: [title, content],
    );
  }

  void storeIllustDataFrom(Response response) {
    for (var illust in response.data["illusts"]) {
      illustStore.add(Illust.fromJson(illust));
    }
  }
}

class PivisionView extends StatefulWidget {
  const PivisionView({Key? key}) : super(key: key);

  @override
  State<PivisionView> createState() => _PivisionViewState();
}

class _PivisionViewState extends State<PivisionView> {
  @override
  void initState() {
    super.initState();
    illustFuture = ApiClient().getSpotlightArticles();
  }

  final illustStore = <SpotlightArticle>[];

  late Future<Response> illustFuture;

  @override
  Widget build(BuildContext context) {
    final title = _Header(leadingText: S.of(context).pixvision);
    final content = SizedBox(
      height: 360,
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
                return const CircularProgressIndicator();

              case ConnectionState.done:
                if (!snapshot.hasData) {
                  return const Center(child: Text("No Data"));
                }
                storeIllustDataFrom(snapshot.data!);
                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  addAutomaticKeepAlives: false,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 36,
                  ),
                  itemBuilder: (context, index) {
                    return PixivImage(
                      url: illustStore[index].thumbnail!,
                      height: 360,
                      width: 360,
                    );
                  },
                  itemCount: illustStore.length,
                );
              default:
                return const SizedBox(
                  height: 360,
                );
            }
          })),
    );

    return Column(
      children: [title, content],
    );
  }

  void storeIllustDataFrom(Response response) {
    for (var illust in response.data["spotlight_articles"]) {
      illustStore.add(SpotlightArticle.fromJson(illust));
    }
  }
}

class RecommandView extends StatefulWidget {
  const RecommandView({Key? key}) : super(key: key);

  @override
  State<RecommandView> createState() => _RecommandViewState();
}

class _RecommandViewState extends State<RecommandView> {
  @override
  void initState() {
    super.initState();
    illustFuture = ApiClient().getRecommend()
      ..then((response) {
        storeIllustDataFrom(response);
      })
      ..whenComplete(
        () {
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        },
      );
  }

  final illustStore = <Illust>[];

  String? nextUrl;

  late Future<Response> illustFuture;

  @override
  Widget build(BuildContext context) {
    if (illustStore.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 360,
          width: 360,
        ),
      );
    }
    return SliverWaterfallFlow(
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ContainerWrap(
            closeBuilder: (context) {
              return IllustCard(
                illust: illustStore[index],
              );
            },
            openBuilder: (context) {
              return IllustDetail(illust: illustStore[index]);
            },
          );
        },
        childCount: illustStore.length,
      ),
    );
  }

  void storeIllustDataFrom(Response response) {
    nextUrl = response.data["next_url"];
    for (var illust in response.data["illusts"]) {
      illustStore.add(Illust.fromJson(illust));
    }
  }

  // 用于 parent 的 onRefresh 的调用
  Future<void> fetchNext() async {
    if (nextUrl != null) {
      Response response = await ApiClient().getNext(nextUrl!);
      storeIllustDataFrom(response);
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    } else {
      debugPrint("No more date because next Url is NULL");
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
