import 'dart:async';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/constant/search_config.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:all_in_one/provider/search_provider/illusts_search_provider.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// 热门标签 对应 官方的网格 热门词语
class TrendTagsView extends StatefulWidget {
  const TrendTagsView({Key? key}) : super(key: key);

  @override
  State<TrendTagsView> createState() => _TrendTagsViewState();
}

class _TrendTagsViewState extends State<TrendTagsView> {
  final trendTagsStore = <TrendTag>[];

  @override
  Widget build(BuildContext context) {
    if (trendTagsStore.isEmpty) return const Center(child: Text("TrendTags is Empty"));
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => PixivImage(
              url: trendTagsStore[index].illust!.imageUrls!.squareMedium!,
            ),
            childCount: trendTagsStore.length,
          ),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        )
      ],
    );
  }
}

/// 搜索插画的结果页  瀑布流
class IllustResultView extends StatefulWidget {
  const IllustResultView({
    Key? key,
    required this.paddingTop,
    required this.words,
    required this.searchConfig,
  }) : super(key: key);

  final String words;

  final SearchConfig searchConfig;

  /// 预留在顶部的高度
  final double paddingTop;

  @override
  State<IllustResultView> createState() => _IllustResultViewState();
}

class _IllustResultViewState extends State<IllustResultView> {
  List<Illust> _illustStore = <Illust>[];

  @override
  void initState() {
    super.initState();
    _fetchIllustResult();
  }

  @override
  Widget build(BuildContext context) {
    if (_illustStore.isEmpty) return const Center(child: Text("Nodate"));
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: widget.paddingTop),
          sliver: SliverWaterfallFlow(
            gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 20),
            delegate: SliverChildBuilderDelegate((context, index) {
              return IllustCard(illust: _illustStore[index]);
            }, childCount: _illustStore.length),
          ),
        ),
        LoadingMoreSliver(onRefresh: handleLoadingMore)
      ],
    );
  }

  @override
  void didUpdateWidget(covariant IllustResultView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final store = Provider.of<IllustSearchResultProvider>(context, listen: false);
    if (oldWidget.words != widget.words ||
        oldWidget.searchConfig != widget.searchConfig) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        store.clearStore();
        _fetchIllustResult();
      });
    }
    _illustStore = store.illustStore;
  }

  Future<void> _fetchIllustResult() async {
    try {
      final response =
          await ApiClient().getSearchIllust(widget.words, widget.searchConfig);
      _processIllustResponse(response);
    } on DioError catch (e) {
      LogUitls.e(e.message, stackTrace: e.stackTrace!);
    }
  }

  void _processIllustResponse(Response response) {
    final store = Provider.of<IllustSearchResultProvider>(context, listen: false);
    store.nextUrl = response.data["next_url"];
    final responseIllusts = <Illust>[];
    for (var item in response.data["illusts"]) {
      responseIllusts.add(Illust.fromJson(item));
    }
    store.addStore(responseIllusts);
  }

  Future<void> handleLoadingMore() async {
    try {
      final store = Provider.of<IllustSearchResultProvider>(context, listen: false);

      if (store.nextUrl == null) return;
      final response = await ApiClient().getNext(store.nextUrl!);
      _processIllustResponse(response);
    } on DioError catch (e) {
      LogUitls.e(e.message, stackTrace: e.stackTrace!);
    }
  }
}

/// 搜索插画的历史记录
class IllustQueryHistory extends StatefulWidget {
  const IllustQueryHistory({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);
  final TextEditingController textEditingController;
  @override
  State<IllustQueryHistory> createState() => _IllustQueryHistoryState();
}

class _IllustQueryHistoryState extends State<IllustQueryHistory> {
  late TextEditingController _textEditingController;

  TextEditingController get textEditingController => _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.textEditingController;
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Illust Query History"));
  }
}
