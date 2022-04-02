// 评论区
import 'dart:math';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class IllustCommentCard extends StatefulWidget {
  const IllustCommentCard({
    Key? key,
    required this.illustID,
  }) : super(key: key);

  final int illustID;

  @override
  State<IllustCommentCard> createState() => _IllustCommentCardState();
}

class _IllustCommentCardState extends State<IllustCommentCard>
    with CommentResponseHelper {
  late GlobalKey<SliverAnimatedListState> _key;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<SliverAnimatedListState>();
    _fetchComment();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _key,
      itemBuilder: (context, index, animation) {
        return _buildAnimatedCard(animation, index);
      },
    );
  }

  void _fetchComment() {
    ApiClient().getIllustComments(widget.illustID).then((Response response) {
      assert(SchedulerBinding.instance != null);
      storeComments(response);
      final needBuildCnt = min(commentsCount, 4);
      for (int i = 0; i < needBuildCnt; ++i) {
        _key.currentState?.insertItem(i);
      }
    }); // beatriful curly ...
  }

  Widget _buildAnimatedCard(Animation<double> animation, int index) {
    final name = Text(comments[index].user!.name!);
    final proImg = ClipOval(
      child: PixivImage(
        url: comments[index].user!.profileImageUrls!.medium!,
        height: 17,
        width: 17,
      ),
    );

    final result = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              name,
              proImg,
            ],
          ),
          Text(comments[index].comment!),
        ],
      ),
    );

    return SizeTransition(
      sizeFactor: animation,
      child: result,
    );
  }
}
