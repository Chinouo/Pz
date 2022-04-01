/// 搜索页
/// 模仿 apple music
/// 提供 illust 和 user  两个 tab
/// 搜索 illust 按照官方的来  显示tag
/// 搜索 user 下面时推荐画师及其作品
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/lazy_indexed_stack.dart';
import 'package:all_in_one/constant/search_config.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/page/search/search_filter.dart';
import 'package:all_in_one/page/search/search_illust.dart';
import 'package:all_in_one/page/search/search_user.dart';
import 'package:all_in_one/provider/search_provider/illusts_search_provider.dart';
import 'package:all_in_one/provider/trend_tag_provider.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// 这些是搜索时候的 query 参数
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

const List<String> searchTarget = [
  "partial_match_for_tags",
  "exact_match_for_tags",
  "title_and_caption",
];

const Map<String, int> index2View = {
  "illust": 0,
  "user": 1,
};

enum ComponentId {
  searchAppBar, // 顶部搜索
  searchRecommendView, // 热门推荐标签
  searchResultView, // 搜索结果
  searchHistoryView, // 历史记录
}

const _kAppBarHeight = 188.0;

class SearchPageLayoutDelegate extends MultiChildLayoutDelegate {
  SearchPageLayoutDelegate({this.viewPaddingTop = 0});

  final double viewPaddingTop;

  @override
  void performLayout(Size size) {
    final viewConstraints = BoxConstraints.tight(size);
    final appBarConstraints =
        BoxConstraints.tight(Size(size.width, viewPaddingTop + _kAppBarHeight));

    if (hasChild(ComponentId.searchAppBar)) {
      layoutChild(ComponentId.searchAppBar, appBarConstraints);
      positionChild(ComponentId.searchAppBar, Offset.zero);
    }

    if (hasChild(ComponentId.searchHistoryView)) {
      layoutChild(ComponentId.searchHistoryView, viewConstraints);
      positionChild(ComponentId.searchHistoryView, Offset.zero);
    }

    if (hasChild(ComponentId.searchResultView)) {
      layoutChild(ComponentId.searchResultView, viewConstraints);
      positionChild(ComponentId.searchResultView, Offset.zero);
    }

    if (hasChild(ComponentId.searchRecommendView)) {
      layoutChild(ComponentId.searchRecommendView, viewConstraints);
      positionChild(ComponentId.searchRecommendView, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(SearchPageLayoutDelegate oldDelegate) {
    return oldDelegate.viewPaddingTop != viewPaddingTop;
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// Illust or User
  /// 影响 底部推荐 历史记录 自动补全 搜索结果
  final selectedSearchTarget = ValueNotifier<int>(index2View["illust"]!);

  /// 影响搜索结果
  late SearchConfig filterData;

  late final TextEditingController _textEditingController;

  TextEditingController get textEditingController => _textEditingController;

  final _focusNode = FocusNode(descendantsAreFocusable: false);

  // Used to controll history/autofill view display or not.
  final showHAView = ValueNotifier<bool>(false);

  // Used to controll result view display or not.
  final showResView = ValueNotifier<bool>(false);

  // Used to controll recommend view display or not.
  final showRecomView = ValueNotifier<bool>(true);

  // Used to setState for child when filter config changed.
  final illustResultViewKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    filterData = SearchConfig.defaultConfig(); // ?? stored
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build SearchPage.");
    // 顶部搜索栏
    final searchTextBar = LayoutId(
      id: ComponentId.searchAppBar,
      child: buildSearchBar(),
    );

    // 热门搜索词容器
    final recommendView = LayoutId(
      id: ComponentId.searchRecommendView,
      child: buildRecommandView(),
    );

    // 搜索历史容器
    final queryHistoryBoxes = LayoutId(
      id: ComponentId.searchHistoryView,
      child: buildQueryHistoryBoxes(),
    );

    // 搜索结果容器
    final queryResultBox = LayoutId(
      id: ComponentId.searchResultView,
      child: buildQueryResultBox(),
    );

    final viewPaddingTop = MediaQuery.of(context).viewPadding.top;
    return CustomMultiChildLayout(
      delegate: SearchPageLayoutDelegate(
        viewPaddingTop: viewPaddingTop,
      ),
      children: [
        recommendView,
        queryHistoryBoxes, // IndexedStack  stateful
        queryResultBox, //
        searchTextBar, // Container
      ],
    );
  }

  Widget buildSearchBar() {
    // 真值表嗯造
    final searchTextField = SizedBox(
        width: 300,
        child: CupertinoSearchTextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          onTap: () {
            // Todo: Shrink appbar and focus.
            //focus.value = true;
            showRecomView.value = false;
            showResView.value = false;
            showHAView.value = true;
          },
          onSuffixTap: () {
            textEditingController.clear();
            //focusNode.unfocus();
          },
          onChanged: (words) {
            // Todo: Fetch AutoFillWord and build relative text.
          },
          onSubmitted: (words) {
            debugPrint(words.isEmpty.toString());
            // Todo: Fetch IllustResult and build WaterFallFlow list.
            if (words.isEmpty) {
              // is nothing
              showRecomView.value = true;
              showResView.value = false;
              showHAView.value = false;
              return;
            }
            LogUitls.d(textEditingController.text);
            showRecomView.value = false;
            showResView.value = true;
            showHAView.value = false;
          },
        ));

    final filter = MaterialButton(
      onPressed: () async {
        SearchConfig? config = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return Filter(config: filterData);
            });
        if (config != null) {
          filterData = config;
          // Magic
          illustResultViewKey.currentState?.setState(() {});
        }
      },
      child: Text("Filter"),
    );

    final cancel = MaterialButton(
      onPressed: () {
        textEditingController.clear();
        _focusNode.unfocus();
        showRecomView.value = true;
        showResView.value = false;
        showHAView.value = false;
      },
      child: Text("Cancel"),
    );

    return Center(
        child: Row(children: [
      Expanded(flex: 2, child: searchTextField),
      Expanded(child: filter),
      Expanded(child: cancel),
    ]));
  }

  Widget buildQueryHistoryBoxes() {
    final visibleWrap = ValueListenableBuilder<bool>(
      valueListenable: showHAView,
      builder: (context, visible, child) {
        return Visibility(
          maintainState: true,
          child: child!,
          visible: visible,
        );
      },
      child: Container(
        color: Colors.white,
        child: ValueListenableBuilder<int>(
          valueListenable: selectedSearchTarget,
          builder: (context, index, child) {
            return LazyIndexedStack(
              index: index,
              children: [
                IllustQueryHistory(
                  textEditingController: textEditingController,
                ),
                UserQueryHistory(
                  textEditingController: textEditingController,
                ),
              ],
            );
          },
        ),
      ),
    );

    return visibleWrap;
  }

  Widget buildQueryResultBox() {
    final topPadding = _kAppBarHeight + MediaQuery.of(context).viewPadding.top;
    final visiableWrap = ValueListenableBuilder<bool>(
      valueListenable: showResView,
      builder: (context, visible, child) {
        return Visibility(
          maintainState: false,
          visible: visible,
          child: child!,
        );
      },
      child: Container(
        color: Colors.white,
        child: ValueListenableBuilder<int>(
          valueListenable: selectedSearchTarget,
          builder: (context, index, child) {
            switch (index) {
              case 0:
                return SearchResultView(
                  key: illustResultViewKey,
                  paddingTop: topPadding,
                  words: textEditingController.text,
                  searchConfig: filterData,
                );
              case 1:
                return UserResultView();
              default:
                return const Center(child: Text("Internal Error!"));
            }
          },
        ),
      ),
    );

    return visiableWrap;
  }

  Widget buildRecommandView() {
    final paddingTop = _kAppBarHeight + MediaQuery.of(context).viewPadding.top;

    final visiableWrap = ValueListenableBuilder<bool>(
      valueListenable: showRecomView,
      builder: (context, visible, child) {
        return Visibility(
          maintainState: true,
          visible: visible,
          child: child!,
        );
      },
      child: Container(
        color: Colors.white,
        child: ValueListenableBuilder<int>(
          valueListenable: selectedSearchTarget,
          builder: (context, index, child) {
            return LazyIndexedStack(index: index, children: [
              TrendTagsView(
                paddingTop: paddingTop,
                textEditingController: textEditingController,
              ),
              RecommendUserView(),
            ]);
            switch (index) {
              case 0:
                return TrendTagsView(
                  paddingTop: paddingTop,
                  textEditingController: textEditingController,
                );
              case 1:
                return RecommendUserView();
              default:
                return const Center(child: Text("Internal Error!"));
            }
          },
        ),
      ),
    );

    return visiableWrap;
  }
}

///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///

class SearchPageOld extends StatefulWidget {
  const SearchPageOld({Key? key}) : super(key: key);

  @override
  _SearchPageOldState createState() => _SearchPageOldState();
}

class _SearchPageOldState extends State<SearchPageOld> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CupertinoSearchPage(),
    );
  }
}

class TagGrid extends StatefulWidget {
  const TagGrid({Key? key}) : super(key: key);

  @override
  _TagGridState createState() => _TagGridState();
}

// 写道搜索页 想了一想 为了启动后发送一堆请求后马上用  似乎没有必要跨组件状态管理
class _TagGridState extends State<TagGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrendTagProvider>(
      builder: (context, trendProvider, child) {
        final tagCollection = trendProvider.collection;
        if (tagCollection.isEmpty) return const SizedBox.shrink();

        return CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                return PixivImage(
                    url: tagCollection[index].illust!.imageUrls!.squareMedium!);
              }, childCount: tagCollection.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
            )
          ],
        );
      },
    );
  }
}

// 写到这才发现原来官方实现了这么多 Cupertino 的组件 不过都半斤八两 有些效果还是差别蛮大的 自己再写
class CupertinoSearchPage extends StatefulWidget {
  const CupertinoSearchPage({Key? key}) : super(key: key);

  @override
  _CupertinoSearchPageState createState() => _CupertinoSearchPageState();
}

class _CupertinoSearchPageState extends State<CupertinoSearchPage> {
  String? selectTag;

  List<Illust> _searchResult = <Illust>[];

  @override
  void initState() {
    super.initState();
    selectTag = "illust";
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Call build in Out! ");
    // 这里 了解了下 NestedScrollView 的原理

    return NestedScrollView(
        headerSliverBuilder: (_, __) => [
              CupertinoSliverNavigationBar(
                largeTitle: Text("Search"),
                stretch: true,
              ),
              SliverToBoxAdapter(
                child: Hero(
                    tag: "Q",
                    placeholderBuilder: (context, heroSize, child) {
                      return Container(
                        height: heroSize.height,
                        width: heroSize.width,
                        color: Colors.blue,
                        child: child,
                      );
                    },
                    child: CupertinoTextField(
                      decoration: BoxDecoration(
                          color: CupertinoColors.tertiarySystemFill),
                      readOnly: true,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SearchResult()));
                      },
                    )),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: StatefulBuilder(
              //       builder: (BuildContext context,
              //           void Function(void Function()) setState) {
              //         debugPrint("Call build inside! ");
              //         return CupertinoSlidingSegmentedControl(
              //           groupValue: selectTag,
              //           onValueChanged: (String? value) {
              //             setState(() {
              //               selectTag = value;
              //             });
              //           },
              //           children: {
              //             "illust": Center(
              //               child: Text("illust"),
              //             ),
              //             "user": Center(
              //               child: Text("User"),
              //             )
              //           },
              //         );
              //       },
              //     ),
              //   ),
              // ),
            ],
        body: PageView(
          onPageChanged: (value) {
            if (value == 0) {
              selectTag = "illust";
            }
            if (value == 1) {
              selectTag = "User";
            }
          },
          children: [
            TagGrid(),
            Center(
              child: Column(
                children: [
                  MaterialButton(
                    onPressed: () async {
                      var api = ApiClient();
                      Response r = await api.getSearchAutoCompleteKeywords("原");
                      // Response r = await api.getSearchIllust("原神",
                      //     search_target: searchTarget[0], sort: sort[0]);
                      // for (var item in r.data["illusts"]) {
                      //   _searchResult.add(Illust.fromJson(item));
                      // }
                      // setState(() {});
                      debugPrint(r.toString());
                    },
                    child: Text("get genshin"),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return SearchFilter();
                          });
                    },
                    child: Text("get data"),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      var api = ApiClient();
                      Response r = await api.getUserRecommended();
                      debugPrint(r.toString());
                    },
                    child: Text("get User rec"),
                  )
                ],
              ),
            ),
            GridView.builder(
                itemCount: _searchResult.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  if (_searchResult.isNotEmpty)
                    return PixivImage(
                      url: _searchResult[index].imageUrls!.squareMedium!,
                      width: 180,
                      height: 180,
                    );
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.primaries[index % 18],
                  );
                })
          ],
        ));
  }
}

class SearchResult extends StatefulWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  late String result;

  var api = ApiClient();

  @override
  void initState() {
    super.initState();
    result = "Empty";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                centerTitle: true,
                leading: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                pinned: true,
                backgroundColor: Colors.white.withOpacity(0.7),
                title: Hero(
                    placeholderBuilder: (context, heroSize, child) {
                      return Container(
                        height: heroSize.height,
                        width: heroSize.width,
                        color: Colors.red,
                        child: child,
                      );
                    },
                    tag: "Q",
                    child: CupertinoSearchTextField(
                      autofocus: true,
                      decoration: BoxDecoration(
                          color: CupertinoColors.tertiarySystemFill),
                      onChanged: (value) {
                        api.getSearchAutoCompleteKeywords(value);
                        setState(() {
                          result = "正在输入";
                        });
                      },
                      onSubmitted: (value) async {
                        // 点击搜索
                        //api.getSearchIllust(value);
                        result = "in query ...";
                        setState(() {});
                      },
                    )),
                actions: [
                  GestureDetector(
                    onTap: () async {
                      await showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return SearchFilter();
                          });
                    },
                    child: Icon(
                      Icons.filter_1_outlined,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 10,
                  color: Colors.primaries[1],
                ),
              )
            ];
          },
          body: AnimatedSwitcher(
              duration: Duration(seconds: 2),
              child: Builder(
                key: UniqueKey(),
                builder: (context) {
                  if (result == "in query ...") {
                    return _buildResult();
                  } else if (result == "正在输入") {
                    return _buildAutoFillWord();
                  }
                  return _buildHistory();
                },
              ))
          // WaterfallFlow.builder(
          //   itemBuilder: (context, index) {
          //     return Container(
          //       color: Colors.primaries[index % 18],
          //       height: index % 2 == 0 ? 100 : 133,
          //     );
          //   },
          //   gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          //       crossAxisCount: 2),
          // ),
          ),
    );
  }

  Widget _buildAutoFillWord() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            child: Text("$index"),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: 10);
  }

  Widget _buildResult() {
    FutureBuilder(builder: ((context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Error"),
        );
      }

      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Center(
            child: CupertinoActivityIndicator(animating: true),
          );
        case ConnectionState.done:
          if (snapshot.hasData) return _buildResult();
          return Center(
            child: Text("No data"),
          );
        default:
          return Center(
            child: Text("nothing"),
          );
      }
    }));
    return WaterfallFlow.builder(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.primaries[index % 18],
            height: index % 2 == 0 ? 200 : 233,
          );
        });
  }

  Widget _buildHistory() {
    return Text("History");
  }
}

// 筛选组件
class SearchFilter extends StatefulWidget {
  const SearchFilter({Key? key}) : super(key: key);

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      // The Bottom margin is provided to align the popup above the system navigation bar.

      // Provide a background color for the popup.
      color: CupertinoColors.systemBackground.resolveFrom(context),
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
          bottom: false,
          top: false,
          child: SizedBox.expand(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildTagSelector(),
              _buildTagSelector(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date Start"),
                  CupertinoButton(
                      child: Text("yy-mm-dd"),
                      onPressed: () async {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return _buildDataPicker();
                            });
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date End"),
                  CupertinoButton(
                      child: Text("yy-mm-dd"),
                      onPressed: () async {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return _buildDataPicker();
                            });
                      }),
                ],
              )
            ]),
          )),
    );
  }

  // 检索选择和排序
  Widget _buildTagSelector() {
    return CupertinoSlidingSegmentedControl(
      groupValue: "a",
      onValueChanged: (value) {},
      children: {
        "a": Text("a"),
        "b": Text("b"),
        "c": Text("c"),
      },
    );
  }

  Widget _buildDataPicker() {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      // The Bottom margin is provided to align the popup above the system navigation bar.
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // Provide a background color for the popup.
      color: CupertinoColors.systemBackground.resolveFrom(context),
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
        top: false,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (DateTime value) {
            debugPrint("select: " + value.toLocal().toString());
          },
        ),
      ),
    );
  }

  final List<Tag> _autofillTag = <Tag>[];

  void _handleAutoFillWordFrom(Response response) {
    _autofillTag.clear();
    for (var item in response.data["tags"]) {
      _autofillTag.add(Tag.fromJson(item));
    }
  }

  final List<Illust> _illustResult = <Illust>[];

  void _handleIllustResultFrom(Response response) {
    _illustResult.clear();
    for (var item in response.data["illusts"]) {
      _illustResult.add(Illust.fromJson(item));
    }
  }
}
