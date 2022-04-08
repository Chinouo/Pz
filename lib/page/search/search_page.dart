/// 搜索页
/// 模仿 apple music
/// 提供 illust 和 user  两个 tab
/// 搜索 illust 按照官方的来  显示tag
/// 搜索 user 下面时推荐画师及其作品
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/lazy_indexed_stack.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/constant/search_config.dart';
import 'package:all_in_one/generated/l10n.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/page/search/search_filter.dart';
import 'package:all_in_one/page/search/search_illust.dart';
import 'package:all_in_one/page/search/search_user.dart';
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
  "Illust": 0,
  "User": 1,
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
    return false;
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
  final selectedSearchTarget = ValueNotifier<int>(index2View["Illust"]!);

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

  // Query Illust or User.
  final queryResultSelector = ValueNotifier<String>("Illust");

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
        SearchConfig? config = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return Filter(config: filterData);
          },
        ));

        if (config != null) {
          filterData = config;
          // Magic
          // TODO: setChild State After update.
          setState(() {});
        }
      },
      child: Text("Filter"),
    );

    final quertTargetSelector = CupertinoSegmentedControl<String>(
      //groupValue: "Illust",
      children: {
        "Illust": Text(S.of(context).illust),
        "User": Text(S.of(context).user),
      },
      onValueChanged: (value) {
        selectedSearchTarget.value = index2View[value]!;
        debugPrint(value.toString());
      },
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

    return ColoredBox(
      color: CupertinoColors.systemGrey4.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Expanded(flex: 2, child: searchTextField),
            Expanded(child: filter),
            Expanded(child: cancel),
          ]),
          quertTargetSelector
        ],
      ),
    );
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
                return UserResultView(
                  word: textEditingController.text,
                );
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
            return LazyIndexedStack(
              index: index,
              children: [
                TrendTagsView(
                  paddingTop: paddingTop,
                  textEditingController: textEditingController,
                ),
                RecommendUserView(),
              ],
            );
          },
        ),
      ),
    );

    return visiableWrap;
  }
}
