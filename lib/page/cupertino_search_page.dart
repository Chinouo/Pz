import 'dart:math';
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:all_in_one/page/search_page.dart';
import 'package:all_in_one/widgets/pixiv_image.dart';
import 'package:all_in_one/widgets/sliver/loading_more_sliver.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

const Duration kMoveDuration = Duration(milliseconds: 200);

/// Align to top when focus.
const Alignment kSearchTextFieldFocusAligment = Alignment(0.0, -0.7);

/// Align when unfocus.
const Alignment kSearchTextFieldUnFocusAligment = Alignment(0.0, 0.0);

const double kInvisiable = 0.0;

const double kVisiable = 1.0;

const _debugUIErrorWidget = Center(
  child: Text("Internal Error!"),
);

enum ComponentId {
  searchAppBar,
  tagGridView,
  searchResultView,
}

const List<int> stared = <int>[
  0,
  100,
  250,
  500,
  1000,
  5000,
  10000,
  20000,
  30000,
  50000,
];

const List<String> sort = <String>[
  "date_desc",
  "date_asc",
  "popular_desc",
];

const List<String> searchTarget_1 = [
  "partial_match_for_tags",
  "exact_match_for_tags",
  "title_and_caption",
];

class SearchPageLayoutDelegate extends MultiChildLayoutDelegate {
  SearchPageLayoutDelegate({
    required this.appBarConStraint,
    required this.stackConstraint,
  });

  final BoxConstraints appBarConStraint;

  final BoxConstraints stackConstraint;

  @override
  void performLayout(Size size) {
    if (hasChild(ComponentId.searchAppBar)) {
      layoutChild(ComponentId.searchAppBar, appBarConStraint);
      positionChild(ComponentId.searchAppBar, Offset.zero);
    }

    if (hasChild(ComponentId.tagGridView)) {
      layoutChild(ComponentId.tagGridView, stackConstraint);
      positionChild(ComponentId.tagGridView, Offset.zero);
    }

    if (hasChild(ComponentId.searchResultView)) {
      layoutChild(ComponentId.searchResultView, stackConstraint);
      positionChild(ComponentId.searchResultView, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(SearchPageLayoutDelegate oldDelegate) {
    return oldDelegate.appBarConStraint != appBarConStraint ||
        oldDelegate.stackConstraint != stackConstraint;
  }
}

//
class CupertinoPageRouteTemplate extends StatefulWidget {
  const CupertinoPageRouteTemplate({Key? key}) : super(key: key);

  @override
  _CupertinoPageRouteTemplateState createState() =>
      _CupertinoPageRouteTemplateState();
}

class _CupertinoPageRouteTemplateState extends State<CupertinoPageRouteTemplate>
    with SingleTickerProviderStateMixin {
  double appBarHeight = 210;

  @override
  Widget build(BuildContext context) {
    return SearchPage(
      f: f,
    );
    // return Stack(
    //   fit: StackFit.passthrough,
    //   children: [
    //     _buildScrollView(),
    //     buildStickyTopSearchBar(),
    //     _buildResultLayer()
    //   ],
    // );
  }

  bool isFocus = false;

  double shrinkHeight = 200;

  double expandHeight = 300;

  // 不用persistent 是因为对其内部 size变换动画 不熟悉
  Widget buildStickyTopSearchBar() {
    return Positioned(
        top: 0,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          color: Colors.red.withOpacity(0.1),
          height: appBarHeight + MediaQuery.of(context).viewPadding.top,
          width: MediaQuery.of(context).size.width,
          child: MaterialButton(
            onPressed: () {
              setState(() {
                if (appBarHeight == 210) {
                  appBarHeight = 150;
                } else {
                  appBarHeight = 210;
                }
                isFocus = !isFocus;
              });
            },
            child: Text("Click Me!"),
          ),
        ));
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedContainer(
            color: Colors.grey.withOpacity(0.5),
            duration: const Duration(seconds: 1),
            height: appBarHeight,
          ),
        ),
        // SliverPersistentHeader(
        //     floating: true,
        //     pinned: true,
        //     delegate: TitlePersistHeader(
        //         vsync: this,
        //         shrinkHeight: shrinkHeight,
        //         stretchhHeight: expandHeight,
        //         parentStateTicker: this,
        //         parentSetState: () {
        //           setState(() {
        //             expandHeight = 100;
        //             shrinkHeight = 100;
        //           });
        //         })),
        // SliverAnimatedPersistentHeaderWidget(
        //   child: AnimatedContainer(
        //     color: Colors.green,
        //     height: 100,
        //     duration: Duration(seconds: 1),
        //   ),
        // ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          ((context, index) {
            return Container(
              color: Colors.primaries[index % 18],
              height: 200,
            );
          }),
          childCount: 20,
        ))
      ],
    );
  }

  Future<List<int>> f = fakeFuture();

  double _searchTextfieldAligment = 0.0;
  Widget _buildSearchText() {
    return AnimatedAlign(
        alignment: Alignment(0, _searchTextfieldAligment),
        duration: const Duration(milliseconds: 200));
  }

  double _searchListOpacity = 1.0;

  double _appBarExtent = 200.0;
  Widget _buildGridTag() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _searchListOpacity,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: _appBarExtent),
          )
        ],
      ),
    );
  }
}

const double kShrinkSearchBarHeight = 100.0;

const double kStrengthSearchBarHeight = 300.0;

///
class SearchPage extends StatefulWidget {
  final Future<List<int>> f;

  const SearchPage({Key? key, required this.f}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

const kHistoryId = "0";
const kAutoFillId = "1";
const kResultId = "2";

class _SearchPageState extends State<SearchPage> {
  double searchBarHeight = kStrengthSearchBarHeight;

  /// Used for textfield floating.
  final focus = ValueNotifier<bool>(false);

  /// Used for select page after focus and text input.
  /// This value is used to make key.
  /// 0 -> history 1 -> autifill 2 -> result
  final searchContentID = ValueNotifier<String>(kHistoryId);

  final autofillFuture = ValueNotifier<Future<Response>?>(null);

  /// Whether to demonstrate view under search textfiels.
  bool shouldDisplaySearchView = false;

  late ApiClient apiClient;

  late Future<Response> trendTagsFuture;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    trendTagsFuture = apiClient.getIllustTrendTags();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Call Outter build");

    return LayoutBuilder(builder: (context, constraints) {
      debugPrint(constraints.toString());
      final appBarWidth = MediaQuery.of(context).size.width;
      final appBarHeight =
          MediaQuery.of(context).viewPadding.top + searchBarHeight;
      final appBarConstraints = constraints.loosen();
      return CustomMultiChildLayout(
        delegate: SearchPageLayoutDelegate(
          appBarConStraint: appBarConstraints,
          stackConstraint: constraints,
        ),
        children: <Widget>[
          _buildTagGridView(),
          _buildSearchResult(),
          _buildSearchBar(context),
        ],
      );
    });
  }

  double resultOpacity = 0.0;

  TextEditingController textEditingController = TextEditingController();

  FocusNode focusNode = FocusNode();

  Alignment searchTextAligment = kSearchTextFieldUnFocusAligment;

  double segOpacity = kInvisiable;

  Future<List<int>> f = fakeFuture();

  Widget _buildSearchBar(BuildContext context) {
    final searchTextField = CupertinoSearchTextField(
      controller: textEditingController,
      focusNode: focusNode,
      onTap: () {
        // Todo: Shrink appbar and focus.
        focus.value = true;
      },
      onSuffixTap: () {
        textEditingController.clear();
        //focusNode.unfocus();
      },
      onChanged: (words) {
        // Todo: Fetch AutoFillWord and build relative text.
        searchContentID.value = kAutoFillId;
        autofillFuture.value = apiClient.getSearchAutoCompleteKeywords(words);
      },
      onSubmitted: (words) {
        // Todo: Fetch IllustResult and build WaterFallFlow list.
        searchContentID.value = kResultId;
        var apiClient = ApiClient();
        searchResultFuture = apiClient.getSearchIllust(words,
            sort: sort[0], search_target: searchTarget_1[0]);
      },
    );

    const filter = Icon(Icons.filter_3_outlined);

    final searchBar = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(child: searchTextField),
            filter,
            MaterialButton(
              onPressed: () {
                textEditingController.clear();
                focusNode.unfocus();
                focus.value = false;
                searchContentID.value = kHistoryId;
                //To do: May need handle future.
              },
              child: Text("Cancle"),
            ),
          ],
        ));

    final size = MediaQuery.of(context).size;

    // like SafeArea
    final viewPaddingTopBox = SizedBox(
      height: MediaQuery.of(context).viewPadding.top,
      width: size.width,
    );

    // 搜索栏 和 搜索目标 Widget
    Widget result = ValueListenableBuilder<bool>(
      valueListenable: focus,
      builder: (context, isFocus, child) {
        final realAppBarHeight =
            MediaQuery.of(context).viewPadding.top + kShrinkSearchBarHeight;

        final searchTarget = AnimatedOpacity(
            opacity: isFocus ? kVisiable : kInvisiable,
            duration: kMoveDuration,
            child: CupertinoSlidingSegmentedControl(
              children: const {
                "Illusts": Text("Illust"),
                "Users": Text("Users"),
              },
              onValueChanged: (str) {
                // Todo:
              },
            ));

        return Container(
          height: realAppBarHeight,
          color: Colors.grey.withOpacity(0.7),
          child: Stack(
            fit: StackFit.loose,
            children: [
              AnimatedPositioned(
                top: isFocus ? MediaQuery.of(context).viewPadding.top : 77,
                duration: kMoveDuration,
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(size),
                  child: Wrap(alignment: WrapAlignment.center, children: [
                    searchBar,
                    searchTarget,
                  ]),
                ),
              )
            ],
          ),
        );
      },
    );

    //
    final searchTarget = AnimatedOpacity(
        opacity: kVisiable,
        duration: kMoveDuration,
        child: CupertinoSlidingSegmentedControl(
          children: const {
            "Illusts": Text("Illust"),
            "Users": Text("Users"),
          },
          onValueChanged: (str) {
            // Todo:
          },
        ));

    final appBarWrap = Wrap(
      children: [
        viewPaddingTopBox,
        result,
      ],
    );

    return LayoutId(
      id: ComponentId.searchAppBar,
      child: result,
    );
  }

  final tagCollection = <Tag>[];

  Widget _buildAutoFillWordsList() {
    // 外层是关键词 里层是搜索结果
    return ValueListenableBuilder<Future<Response>?>(
      valueListenable: autofillFuture,
      builder: (context, future, child) {
        return FutureBuilder<Response>(
            future: future,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                //return _buildFutureError(snapshot.error);
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  debugPrint('-------ConnectionState.none---------');
                  break;
                case ConnectionState.waiting:
                  return Center(
                      child: CupertinoActivityIndicator(
                    animating: true,
                  ));
                case ConnectionState.active:
                  debugPrint('-------ConnectionState.active---------');
                  break;
                case ConnectionState.done:
                  debugPrint(
                      '-------ConnectionState.done---${snapshot.hasData}------');
                  if (snapshot.hasData) {
                    final data = snapshot.data?.data["tags"] ?? [];

                    if (data.isEmpty) return const SizedBox.shrink();
                    tagCollection.clear();
                    for (var item in data) {
                      tagCollection.add(Tag.fromJson(item));
                    }

                    return ColoredBox(
                      key: UniqueKey(),
                      color: Colors.red,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildSliverFillAppBarBox(),
                          SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                            if (index % 2 == 0) {
                              return Container(
                                height: 70,
                                color: Colors.primaries[index % 18],
                                child: Center(
                                    child:
                                        Text("${tagCollection[index].name}")),
                              );
                            } else {
                              return const Divider(
                                height: 3,
                                color: Colors.grey,
                              );
                            }
                          }, childCount: tagCollection.length))
                        ],
                      ),
                    );
                  }
                  break;
              }

              return const Center(
                child: Text("An exception occure!"),
              );
            }));
      },
    );
  }

  Widget _buildTagGridView() {
    return LayoutId(
      id: ComponentId.tagGridView,
      child: FutureBuilder<Response>(
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return _buildFutureError(snapshot.error);
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              debugPrint('-------ConnectionState.none---------');
              break;
            case ConnectionState.waiting:
              return _buildLoading();
            case ConnectionState.active:
              debugPrint('-------ConnectionState.active---------');
              break;
            case ConnectionState.done:
              debugPrint(
                  '-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                return CustomScrollView(
                  slivers: <Widget>[
                    _buildSliverFillAppBarBox(),
                    _buildTagsGridSliver(snapshot.data!)
                  ],
                );
              }
              break;
          }

          return const Center(
            child: Text("An exception occure!"),
          );
        }),
      ),
    );
  }

  final trendTag = <TrendTag>[];

  Future<Response?>? searchResultFuture;

  Widget _buildTagsGridSliver(Response<dynamic> response) {
    List list = response.data["trend_tags"] ?? [];
    if (list.isEmpty) return const SliverToBoxAdapter();

    trendTag.clear();
    for (var item in list) {
      trendTag.add(TrendTag.fromJson(item));
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: Colors.primaries[index % 18],
            child: Text("${trendTag[index].tag}"),
          );
        },
        childCount: trendTag.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(
        animating: true,
      ),
    );
  }

  Widget _buildFutureError(Object? error) {
    return Center(
      child: Text("A network error occuer! \n Error:$error"),
    );
  }

  // 一个sliver 填充 appbar 的高度
  Widget _buildSliverFillAppBarBox() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        height: kShrinkSearchBarHeight,
      ),
    );
  }

  bool isSubmit = false;

  Key k1 = UniqueKey();
  Key k2 = UniqueKey();

  Widget _buildHistory() {
    return Center(
      child: Text("History"),
    );
  }

  Widget _buildSearchResult() {
    Widget cur = ValueListenableBuilder<String>(
      valueListenable: searchContentID,
      builder: (context, value, child) {
        Widget? body = _debugUIErrorWidget;
        switch (value) {
          case kHistoryId:
            body = _buildHistory();
            break;
          case kAutoFillId:
            body = _buildAutoFillWordsList();
            break;
          case kResultId:
            body = _buildWaterFallView();
            break;
        }
        return AnimatedSwitcher(
          duration: kMoveDuration,
          child: body,
        );
      },
    );

    // out islistener builder used for change opacity after focus
    Widget aniBox = ValueListenableBuilder<bool>(
      valueListenable: focus,
      builder: (context, isFocus, child) {
        return AnimatedOpacity(
          duration: kMoveDuration,
          opacity: isFocus ? kVisiable : kInvisiable,
          child: child,
        );
      },
      child: cur,
    );

    return LayoutId(
      id: ComponentId.searchResultView,
      child: aniBox,
    );
  }

  final resultIllusts = <Illust>[];

  // 构建瀑布流， 构建成功返回 CustomScrollView
  Widget _buildWaterFallView() {
    final waterfallSliver = SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate(((context, index) {
        return PixivImage(
          url: resultIllusts[index].imageUrls!.squareMedium!,
          height: 200,
          fit: BoxFit.cover,
        );
      })),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );
    final res = FutureBuilder<Response?>(
        future: searchResultFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildFutureError(snapshot.error);
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              debugPrint('-------ConnectionState.none---------');
              break;
            case ConnectionState.waiting:
              return _buildLoading();
            case ConnectionState.active:
              debugPrint('-------ConnectionState.active---------');
              break;
            case ConnectionState.done:
              debugPrint(
                  '-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                List list = snapshot.data?.data["illusts"] ?? [];
                if (list.isEmpty) return const SliverToBoxAdapter();
                resultIllusts.clear();
                for (var item in list) {
                  resultIllusts.add(Illust.fromJson(item));
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    _buildSliverFillAppBarBox(),
                    waterfallSliver,
                  ],
                );
              }
              break;
          }

          return const Center(
            child: Text("An exception occure!"),
          );
        });

    return res;
  }
}

// 搜索内容界面
class SearchContent extends StatefulWidget {
  const SearchContent({
    Key? key,
    this.body,
    this.opacity = 0.0,
  }) : super(key: key);

  final Widget? body;

  final double opacity;

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    opacity = widget.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(
        milliseconds: 200,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 200,
        ),
        child: widget.body,
      ),
    );
  }

  @override
  void didUpdateWidget(SearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    opacity = widget.opacity;
  }
}

var fakeFuture = () {
  return Future.delayed(Duration(seconds: 5), () {
    return List.generate(100, (index) => index * Random().nextInt(10));
  });
};

// 瀑布流的搜索结果
class WaterFallFlowSearchIllustResult extends StatefulWidget {
  const WaterFallFlowSearchIllustResult({Key? key, this.future})
      : super(key: key);

  final Future<Response>? future;

  @override
  State<WaterFallFlowSearchIllustResult> createState() =>
      _WaterFallFlowSearchIllustResultState();
}

class _WaterFallFlowSearchIllustResultState
    extends State<WaterFallFlowSearchIllustResult> {
  final result = <Illust>[];

  // 分页长度
  final int steps = 24;

  // 当前加载到第几个元素
  int currentBuildIndex = 0;
  // 目标加载到第几个元素
  int targetBuildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final waterfallSliver = SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate(((context, index) {
        currentBuildIndex = index;
        return PixivImage(
          url: result[index].imageUrls!.squareMedium!,
          height: 200,
          fit: BoxFit.cover,
        );
      })),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        //_buildSliverFillAppBarBox(),
        waterfallSliver,
        LoadingMoreSliver(
            delegate: LoadingMoreSliverWithRefreshHandleDelegete(
          maxLayoutExtent: 200,
          triggerDistance: 100,
          onRefresh: _handleLazyLoad,
        ))
      ],
    );
  }

  // 懒加载处理 当拉到底时 没有更多元素 调用网络请求
  // 如果还有未加载完的 触发 setState 更新状态
  Future<void> _handleLazyLoad() async {
    if (result.length == currentBuildIndex + 1) {
      // 意味着我们已经把结果加载完了 需要向服务器发新的请求
      setState(() {});
    } else {
      // 进行下一页加载

    }
  }
}
