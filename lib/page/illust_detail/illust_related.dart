// 相关类型的插画
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// RenderObj is SliverWaterFallFlow
class RelatedIllustsView extends StatefulWidget {
  const RelatedIllustsView({
    Key? key,
    required this.illustID,
  }) : super(key: key);

  final int illustID;

  @override
  State<RelatedIllustsView> createState() => RelatedIllustsViewState();
}

class RelatedIllustsViewState extends State<RelatedIllustsView>
    with IllustResponseHelper {
  @override
  void initState() {
    super.initState();
    _initialResponse = ApiClient().getIllustRelated(widget.illustID);
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

    return SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return IllustCard(illust: illusts[index]);
        },
        childCount: illustsCount,
      ),
      gridDelegate:
          const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    );
  }

  Future<void> handleLoadingMoreIllusts() async {
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
