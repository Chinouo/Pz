import 'package:all_in_one/component/illust_card.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/models/comment/comment.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
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
            createDate: illust.createDate.toString())
        //CommentSnapShot(),
        //RelatedIllustView(),
      ],
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
    return SliverToBoxAdapter(
      child: IllustCard(illust: widget.illust),
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
    return SliverToBoxAdapter(
      child: Row(children: [
        Expanded(
            child: Text(
                "${widget.createDate} views:${widget.viewes} likes:${widget.likes}")),
        Expanded(child: Icon(Icons.ac_unit_outlined)),
      ]),
    );
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
      height: 20,
      width: 20,
    );

    return SliverToBoxAdapter(
      child: ListTile(
        leading: avatar,
        title: Text(widget.artistName),
      ),
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
    required this.relatedWorks,
    this.nextUrl,
  }) : super(key: key);

  final List<Illust> relatedWorks;

  final String? nextUrl;

  @override
  State<RelatedIllustView> createState() => _RelatedIllustViewState();
}

class _RelatedIllustViewState extends State<RelatedIllustView> {
  final relatedWorksStore = <Illust>[];

  String? nextUrl;

  @override
  void initState() {
    super.initState();
    relatedWorksStore.addAll(widget.relatedWorks);
    nextUrl = widget.nextUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
