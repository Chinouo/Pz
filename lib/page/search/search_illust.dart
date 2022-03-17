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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// 热门标签 对应 官方的网格 热门词语
class TrendTagsView extends StatefulWidget {
  const TrendTagsView({
    Key? key,
    required this.paddingTop,
    required this.textEditingController,
  }) : super(key: key);

  final double paddingTop;

  final TextEditingController textEditingController;

  @override
  State<TrendTagsView> createState() => _TrendTagsViewState();
}

class _TrendTagsViewState extends State<TrendTagsView> {
  final trendTagsStore = <TrendTag>[];

  // TODO: implement grid card, and onTap behavior.
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = widget.textEditingController;
  }

  Widget buildErrorWidget(AsyncSnapshot<Response<dynamic>> snapshot) {
    return Center(child: Text("${snapshot.error}"));
  }

  Widget buildWaitingWidget() {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildGridWidget(AsyncSnapshot<Response<dynamic>> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final response = snapshot.data!.data;
      for (var tag in response["trend_tags"]) {
        trendTagsStore.add(TrendTag.fromJson(tag));
      }
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: widget.paddingTop),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PixivImage(
                  url: trendTagsStore[index].illust!.imageUrls!.squareMedium!,
                ),
                childCount: trendTagsStore.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            ),
          )
        ],
      );
    }
    return const Center(child: Text("No data"));
  }

  Widget _buildInternalError() {
    return const Center(child: Text("Internal Error"));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: ApiClient().getIllustTrendTags(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return buildErrorWidget(snapshot);

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return buildWaitingWidget();

          case ConnectionState.done:
            return buildGridWidget(snapshot);
          default:
            return _buildInternalError();
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant TrendTagsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    trendTagsStore.clear();
    textEditingController = widget.textEditingController;
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
      LogUitls.e(e.response.toString(), stackTrace: e.stackTrace!);
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

    LogUitls.d("fetched search result :" + response.data.toString());
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
    return Center(
        child: Column(
      children: [
        Text("Illust Query History"),
        MaterialButton(
          onPressed: () {
            textEditingController.text = "Asoul";
          },
          child: Text("Change Search Word"),
        )
      ],
    ));
  }
}
