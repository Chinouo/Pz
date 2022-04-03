// 评论区
import 'dart:math';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

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
    try {
      ApiClient().getIllustComments(widget.illustID).then((Response response) {
        assert(SchedulerBinding.instance != null);
        storeComments(response);
        final needBuildCnt = min(commentsCount, 4);
        for (int i = 0; i < needBuildCnt; ++i) {
          _key.currentState?.insertItem(i);
        }
      }); // beatriful curly ...
    } on DioError catch (e) {
      LogUitls.e("#_IllustCommentCardState(_fetchComment): ${e.message}");
    }
  }

  // TODO: May out of range.
  Widget _buildAnimatedCard(Animation<double> animation, int index) {
    assert(index < commentsCount);
    final name = Text(
      comments[index].user!.name!,
      overflow: TextOverflow.ellipsis,
    );

    final proImg = ClipOval(
      child: PixivImage(
        url: comments[index].user!.profileImageUrls!.medium!,
        height: 47,
        width: 47,
      ),
    );

    final result = DecoratedBox(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: CupertinoColors.inactiveGray))),
      child: Padding(
        padding: Constant.kViewPaddingHoriziontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  proImg,
                  name,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(comments[index].comment!),
            ),
          ],
        ),
      ),
    );

    return SizeTransition(
      sizeFactor: animation,
      child: result,
    );
  }
}
