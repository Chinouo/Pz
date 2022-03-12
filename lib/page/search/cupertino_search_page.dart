import 'dart:math';
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/constant/search_config.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:all_in_one/page/search/search_filter.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

const double kShrinkSearchBarHeight = 100.0;

const double kStrengthSearchBarHeight = 300.0;

///
class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
  }) : super(key: key);

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

  late ApiClient apiClient;

  Future<Response>? trendTagsFuture;

  bool isSubmit = false;

  Future<Response?>? searchResultFuture;

  final autofillWords = <Tag>[];

  final trendTags = <TrendTag>[];

  TextEditingController textEditingController = TextEditingController();

  FocusNode focusNode = FocusNode();

  // TODO: Get Config from HiveBox
  late SearchConfig searchConfig;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    trendTagsFuture = apiClient.getIllustTrendTags();
    searchConfig = SearchConfig.defaultConfig();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final appBarConstraints = constraints.loosen();
      return CustomMultiChildLayout(
        delegate: SearchPageLayoutDelegate(
          appBarConStraint: appBarConstraints,
          stackConstraint: constraints,
        ),
        children: <Widget>[
          _buildTrendTagsView(),
          _buildOnFocusView(),
          _buildSearchBar(),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
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
        searchResultFuture = apiClient.getSearchIllust(words, searchConfig);
      },
    );

    final filter = MaterialButton(onPressed: () {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Filter(config: SearchConfig.defaultConfig());
          });
    });

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
                //To do: May need handle cancel future.
              },
              child: const Text("Cancle"),
            ),
          ],
        ));

    final size = MediaQuery.of(context).size;

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

    return LayoutId(
      id: ComponentId.searchAppBar,
      child: result,
    );
  }

  // 当文本框获得焦点时 根据不同行为构建相应的 widget
  Widget _buildOnFocusView() {
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
          child: ColoredBox(
            color: Colors.white,
            child: child,
          ),
        );
      },
      child: cur,
    );

    return LayoutId(
      id: ComponentId.searchResultView,
      child: aniBox,
    );
  }

  // 自动补全词语 组件
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
                  return const Center(
                      child: CupertinoActivityIndicator(
                    animating: true,
                  ));
                case ConnectionState.active:
                  debugPrint('-------ConnectionState.active---------');
                  break;
                case ConnectionState.done:
                  debugPrint('-------ConnectionState.done---${snapshot.hasData}------');
                  if (snapshot.hasData) {
                    final data = snapshot.data?.data["tags"] ?? [];

                    if (data.isEmpty) return const SizedBox.shrink();
                    autofillWords.clear();
                    for (var item in data) {
                      autofillWords.add(Tag.fromJson(item));
                    }

                    return ColoredBox(
                      key: UniqueKey(),
                      color: Colors.white,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildSliverFillAppBarBox(),
                          SliverList(
                              delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index % 2 == 0) {
                                return Container(
                                  height: 30,
                                  color: Colors.primaries[index % 18],
                                  child: Text("${autofillWords[index].name}"),
                                );
                              } else {
                                return const Divider(
                                  height: 3,
                                  color: Colors.grey,
                                );
                              }
                            },
                            childCount: autofillWords.length,
                          ))
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

  // 搜索热度词 组件
  Widget _buildTrendTagsView() {
    return LayoutId(
      id: ComponentId.tagGridView,
      child: FutureBuilder<Response>(
        future: trendTagsFuture,
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
              debugPrint('-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                List list = snapshot.data?.data["trend_tags"] ?? [];
                if (list.isEmpty) return const SliverToBoxAdapter();

                trendTags.clear();
                for (var item in list) {
                  trendTags.add(TrendTag.fromJson(item));
                }

                final trendsTagsSliver = SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        color: Colors.primaries[index % 18],
                        child: Text("${trendTags[index].tag}"),
                      );
                    },
                    childCount: trendTags.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                );
                return CustomScrollView(
                  slivers: <Widget>[_buildSliverFillAppBarBox(), trendsTagsSliver],
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

  // 搜索历史组件
  Widget _buildHistory() {
    return const SearchHistoryView();
  }

  // 构建瀑布流组件
  Widget _buildWaterFallView() {
    return FutureBuilder<Response?>(
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
              debugPrint('-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                // 当有搜索结果的时候 把数据处理
                // 并给 WaterFallFlowSearchIllustResult 保存管理
                List list = snapshot.data?.data["illusts"] ?? [];
                if (list.isEmpty) return const SliverToBoxAdapter();

                List<Illust> initialData = <Illust>[];
                for (var item in list) {
                  initialData.add(Illust.fromJson(item));
                }

                String? nextUrl = snapshot.data?.data["next_url"];
                return WaterFallFlowSearchIllustResult(
                  initialData: initialData,
                  nextUrl: nextUrl,
                );
              }
              break;
          }

          return const Center(
            child: Text("An exception occure!"),
          );
        });
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

/// 瀑布流的搜索结果组件
/// 使用自己写的 LoadingMore 组件
class WaterFallFlowSearchIllustResult extends StatefulWidget {
  const WaterFallFlowSearchIllustResult({
    Key? key,
    this.nextUrl,
    required this.initialData,
  }) : super(key: key);
  // 检索后 服务端第一次返回的数据
  final List<Illust> initialData;

  final String? nextUrl;

  @override
  State<WaterFallFlowSearchIllustResult> createState() =>
      _WaterFallFlowSearchIllustResultState();
}

class _WaterFallFlowSearchIllustResultState
    extends State<WaterFallFlowSearchIllustResult> {
  @override
  void initState() {
    super.initState();
    result = widget.initialData;
    resultLength = widget.initialData.length;
    targetBuildIndex = min(targetBuildIndex + steps, resultLength);
    nextUrl = widget.nextUrl;
  }

  late final List<Illust> result;

  int resultLength = 0;

  // 分页长度
  final int steps = 24;

  // 当前加载到第几个元素
  int currentBuildIndex = 0;
  // 目标加载到第几个元素
  int targetBuildIndex = 0;

  String? nextUrl;

  @override
  Widget build(BuildContext context) {
    final waterfallSliver = SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate(
        ((context, index) {
          currentBuildIndex = index;
          debugPrint(index.toString());
          return IllustCard(illust: result[index]);
        }),
        childCount: targetBuildIndex,
      ),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        //_buildSliverFillAppBarBox(),
        waterfallSliver,
        LoadingMoreSliver()
      ],
    );
  }

  // 懒加载处理 当拉到底时 没有更多元素 调用网络请求
  // 如果还有未加载完的 触发 setState 更新状态
  Future<void> _handleLazyLoad() async {
    if (resultLength == currentBuildIndex + 1) {
      // 意味着我们已经把结果加载完了 需要向服务器发新的请求
      if (nextUrl != null) {
        try {
          var api = ApiClient();
          Response res = await api.getNext(nextUrl!);
          final List list = res.data["illusts"];
          for (var item in list) {
            result.add(Illust.fromJson(item));
          }
          // 储存下一个Url
          nextUrl = res.data["next_url"];
          // To avoid setState during build or layout.
          SchedulerBinding.instance!.addPostFrameCallback(((timeStamp) {
            setState(() {
              resultLength += list.length;
              targetBuildIndex = min(steps + currentBuildIndex, resultLength);
            });
          }));
        } catch (e, s) {
          LogUitls.e(e.toString(), stackTrace: s);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => const Text("No more content"),
        );
      }
    } else {
      // 进行下一页加载
      SchedulerBinding.instance!.addPostFrameCallback(((timeStamp) {
        setState(() {
          targetBuildIndex = min(steps + currentBuildIndex, resultLength);
        });
      }));
    }
  }
}

/// 搜索历史 组件
class SearchHistoryView extends StatefulWidget {
  const SearchHistoryView({Key? key}) : super(key: key);

  @override
  State<SearchHistoryView> createState() => _SearchHistoryViewState();
}

class _SearchHistoryViewState extends State<SearchHistoryView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
