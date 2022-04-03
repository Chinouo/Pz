import 'dart:math';
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/models/comment/comment.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/page/illust_detail/illust_comment.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'illust_related.dart';

class IllustDetail extends StatefulWidget {
  const IllustDetail({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  State<IllustDetail> createState() => _IllustDetailState();
}

class _IllustDetailState extends State<IllustDetail>
    with IllustResponseHelper, CommentResponseHelper {
  late final Illust illust;

  @override
  void initState() {
    super.initState();
    illust = widget.illust;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColoredBox(
          color: CupertinoColors.lightBackgroundGray,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    IllustHolder(illust: illust),
                    ArtistSnapShot(
                      avatarUrl: illust.user!.profileImageUrls!.medium!,
                      artistName: illust.user!.name!,
                    ),
                  ],
                ),
              ),
              IllustCommentCard(illustID: illust.id!),
              const SliverToBoxAdapter(
                child: Center(
                    child: Text(
                  "More like this",
                  textScaleFactor: 2,
                )),
              ),
              RelatedIllustsView(
                key: relatedViewKey,
                illustID: illust.id!,
              ),
              LoadingMoreSliver(
                onRefresh: () async {
                  if (mounted &&
                      relatedViewKey.currentState != null &&
                      relatedViewKey.currentState!.mounted) {
                    await relatedViewKey.currentState?.handleLoadingMoreIllusts();
                  }
                },
              )
            ],
          ),
        ),
        Positioned(
          top: 70,
          left: 28,
          child: GestureDetector(
            child: ColoredBox(
                color: Colors.blueAccent.withOpacity(0.8),
                child: const Icon(Icons.arrow_back)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  final relatedViewKey = GlobalKey<RelatedIllustsViewState>();
}

// 插画详情
// 自上而下 图片 -> 日期和浏览数和喜欢数 -> tags ->  作者详情 -> 评论区 -> 相关插画

/// 数量取决于 json 的 page_count
/// 不要加载原图 不然等太久
class IllustHolder extends StatefulWidget {
  const IllustHolder({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;
  @override
  State<IllustHolder> createState() => _IllustHolderState();
}

class _IllustHolderState extends State<IllustHolder> {
  List<Map<String, String>>? pagesStore;

  @override
  Widget build(BuildContext context) {
    if (widget.illust.pageCount! > 1) {
      return _buildMultiIllustsView(widget.illust);
    } else {
      return _buildSingleIllustView(widget.illust);
    }
  }

  Widget _buildSingleIllustView(Illust illust) {
    final height = illust.height!.toDouble();
    final width = illust.width!.toDouble();

    bool isLongImg = height / width > 1 ? true : false;

    return AspectRatio(
      aspectRatio: width / height,
      child: PixivImage(
        url: illust.imageUrls!.large!,
        width: width,
        height: height,
        fit: isLongImg ? BoxFit.fitHeight : BoxFit.fitWidth,
      ),
    );
  }

  Widget _buildMultiIllustsView(Illust illust) {
    final height = illust.height!.toDouble();
    final width = illust.width!.toDouble();

    pagesStore = List<Map<String, String>>.from(illust.metaPages!);

    bool isLongImg = height / width > 1 ? true : false;

    return SizedBox(
      height: 500,
      child: AspectRatio(
          aspectRatio: width / height,
          child: PageView.builder(itemBuilder: (context, index) {
            return PixivImage(url: pagesStore![index]["large"]!);
          })),
    );
  }
}

// 插画详情信息 tags like view data ...
class IllustInfo extends StatefulWidget {
  const IllustInfo({
    Key? key,
    required this.viewes,
    required this.likes,
    required this.createDate,
  }) : super(key: key);

  final int viewes;

  final int likes;

  final String createDate;

  @override
  State<IllustInfo> createState() => _IllustInfoState();
}

class _IllustInfoState extends State<IllustInfo> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(
              "${widget.createDate} views:${widget.viewes} likes:${widget.likes}")),
      Expanded(child: Icon(Icons.ac_unit_outlined)),
    ]);
  }
}

// 作者快照
class ArtistSnapShot extends StatefulWidget {
  const ArtistSnapShot({
    Key? key,
    required this.avatarUrl,
    required this.artistName,
  }) : super(key: key);

  final String avatarUrl;

  final String artistName;

  @override
  State<ArtistSnapShot> createState() => _ArtistSnapShotState();
}

class _ArtistSnapShotState extends State<ArtistSnapShot> {
  @override
  Widget build(BuildContext context) {
    final avatar = PixivImage(
      shape: BoxShape.circle,
      url: widget.avatarUrl,
      height: 47,
      width: 47,
    );

    return Container(
      padding: Constant.kViewPaddingHoriziontal,
      height: 100,
      color: Colors.blueGrey[100],
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipOval(
          child: avatar,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(widget.artistName),
        ),
        SizedBox(
            width: 70,
            child: CupertinoButton(
              child: const Icon(CupertinoIcons.add_circled_solid),
              onPressed: () {},
            )),
      ]),
    );
  }
}

class TagsFlow extends StatelessWidget {
  const TagsFlow({Key? key, required this.tags}) : super(key: key);

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      children: [
        for (var item in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueGrey[100],
            ),
            child: Text(
              item.name!,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
      ],
    );
  }
}

// 评论区快照
class CommentSnapShot extends StatefulWidget {
  const CommentSnapShot({
    Key? key,
    required this.comments,
  }) : super(key: key);

  final List<Comment> comments;

  @override
  State<CommentSnapShot> createState() => _CommentSnapShotState();
}

class _CommentSnapShotState extends State<CommentSnapShot> {
  final commentStore = <Comment>[];

  @override
  void initState() {
    super.initState();
    commentStore.addAll(widget.comments);
  }

  @override
  Widget build(BuildContext context) {
    final size = min(commentStore.length, 3);
    List<Widget> items = [];
    for (int i = 0; i < size; ++i) {
      items.add(ListTile(
        title: Text(commentStore[0].comment!),
      ));
    }

    return Column(
      children: items,
    );
  }
}
