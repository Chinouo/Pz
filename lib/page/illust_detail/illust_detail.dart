import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/models/comment/comment.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/illust/tag.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

const _kViewInset = EdgeInsets.symmetric(horizontal: 28);

class IllustDetail extends StatefulWidget {
  const IllustDetail({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  State<IllustDetail> createState() => _IllustDetailState();
}

class _IllustDetailState extends State<IllustDetail> {
  late final Illust illust;

  @override
  void initState() {
    super.initState();
    illust = widget.illust;
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                IllustHolder(
                  illust: illust,
                ),
                ArtistSliver(
                  artistName: illust.user!.name!,
                  avatarUrl: illust.user!.profileImageUrls!.medium!,
                ),
                IllustInfo(
                    viewes: illust.totalView!,
                    likes: illust.totalBookmarks!,
                    createDate: illust.createDate.toString()),
                TagsFlow(tags: illust.tags!),
                CommentSnapShot(
                  comments: [],
                ),
              ],
            ),
          )
        ];
      },
      body: RelatedIllustView(
        illustID: illust.id!,
      ),
    );
  }
}

// 插画详情
// 自上而下 图片 -> 日期和浏览数和喜欢数 -> tags ->  作者详情 -> 评论区 -> 相关插画

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
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IllustCard(illust: widget.illust),
      Positioned(
        top: 100,
        left: 10,
        child: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    ]);
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
class ArtistSliver extends StatefulWidget {
  const ArtistSliver({
    Key? key,
    required this.avatarUrl,
    required this.artistName,
  }) : super(key: key);

  final String avatarUrl;

  final String artistName;

  @override
  State<ArtistSliver> createState() => _ArtistSliverState();
}

class _ArtistSliverState extends State<ArtistSliver> {
  @override
  Widget build(BuildContext context) {
    final avatar = PixivImage(
      shape: BoxShape.circle,
      url: widget.avatarUrl,
      height: 47,
      width: 47,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28),
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
        Spacer(),
        CupertinoButton(child: Text("Follow"), onPressed: () {}),
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
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return ListTile(
        title: Text(commentStore[index].comment!),
      );
    }, childCount: commentStore.length < 4 ? commentStore.length : 3));
  }
}

// 相关类型的插画
class RelatedIllustView extends StatefulWidget {
  const RelatedIllustView({
    Key? key,
    required this.illustID,
  }) : super(key: key);

  final int illustID;

  @override
  State<RelatedIllustView> createState() => _RelatedIllustViewState();
}

class _RelatedIllustViewState extends State<RelatedIllustView> {
  final relatedWorksStore = <Illust>[];

  String? nextUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: ApiClient().getIllustRelated(widget.illustID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return buildWaterFallFlow(snapshot.data!);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildWaterFallFlow(Response response) {
    nextUrl = response.data["next_url"];

    for (var item in response.data["illusts"]) {
      relatedWorksStore.add(Illust.fromJson(item));
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return CustomScrollView(
          slivers: [
            SliverWaterfallFlow(
              delegate: SliverChildBuilderDelegate((context, index) {
                return IllustCard(illust: relatedWorksStore[index]);
              }, childCount: relatedWorksStore.length),
              gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
            ),
            LoadingMoreSliver(
              onRefresh: () async {
                try {
                  if (nextUrl == null) return;
                  Response response = await ApiClient().getNext(nextUrl!);
                  if (mounted) {
                    SchedulerBinding.instance?.addPostFrameCallback(
                      (timeStamp) {
                        setState(
                          () {
                            nextUrl = response.data["next_url"];
                            for (var item in response.data["illusts"]) {
                              relatedWorksStore.add(Illust.fromJson(item));
                            }
                          },
                        );
                      },
                    );
                  }
                } on DioError catch (e) {
                  LogUitls.e(e.message);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant RelatedIllustView oldWidget) {
    super.didUpdateWidget(oldWidget);
    relatedWorksStore.clear();
  }
}
