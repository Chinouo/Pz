// 推荐用户
import 'dart:io';
import 'dart:math';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/component/sliver/loading_more.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/models/illust/user.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:all_in_one/util/reponse_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 推荐用户 listview
class RecommendUserView extends StatefulWidget {
  const RecommendUserView({Key? key}) : super(key: key);

  @override
  State<RecommendUserView> createState() => _RecommendUserViewState();
}

class _RecommendUserViewState extends State<RecommendUserView>
    with UserPreviewsResponseHelper {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
        future: ApiClient().getUserRecommended(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              return _buildUserPreviewsList(snapshot.data!);
            default:
              return const Center(child: Text("Internal Error"));
          }
        });
  }

  Widget _buildUserPreviewsList(Response response) {
    storeUserPreviews(response);

    return StatefulBuilder(
      builder: (context, setState) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPreviewCard(index),
              childCount: previewCount,
            )),
            LoadingMoreSliver(
              onRefresh: () async {
                if (nextUrl == null) return;
                Response response = await ApiClient().getNext(nextUrl!);
                setState(() {
                  storeUserPreviews(response);
                });
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildPreviewCard(int index) {
    final config = userPreviews[index];

    final userTile = Row(
      children: [
        PixivImage(
          url: config.user!.profileImageUrls!.medium!,
          height: 50,
          width: 50,
        ),
        Text(userPreviews[index].user!.name!),
        CupertinoButton(child: Text("Follow"), onPressed: () {}),
      ],
    );

    // TODO: Fix 0 -> 2 img expanded size bug.
    final illustPreview = Row(
      children: [
        for (int i = 0; i < min(3, config.illusts!.length); ++i)
          Expanded(
              child: PixivImage(
            height: 100,
            width: 100,
            url: config.illusts![i].imageUrls!.squareMedium!,
          ))
      ],
    );

    final card = Container(
      margin: Constant.kViewPaddingHoriziontal.add(EdgeInsets.symmetric(vertical: 18)),
      height: 230,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        children: [
          illustPreview,
          userTile,
        ],
      ),
    );

    return card;
  }
}

/// 搜索用户结果视图  listview
class UserResultView extends StatefulWidget {
  const UserResultView({
    Key? key,
    required this.word,
  }) : super(key: key);

  final String word;

  @override
  State<UserResultView> createState() => _UserResultViewState();
}

class _UserResultViewState extends State<UserResultView>
    with UserPreviewsResponseHelper {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: ApiClient().getSearchUser(widget.word),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error"));
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            return _buildUserLists(snapshot.data!);
          default:
            return const Center(child: Text("Internal Error"));
        }
      },
    );
  }

  Widget _buildUserLists(Response response) {
    storeUserPreviews(response);

    return StatefulBuilder(builder: ((context, setState) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPreviewCard(index),
            childCount: previewCount,
          )),
          LoadingMoreSliver(
            onRefresh: () async {
              try {
                if (nextUrl == null) return;
                Response response = await ApiClient().getNext(nextUrl!);
                setState(() {
                  setState(() {
                    storeUserPreviews(response);
                  });
                });
              } on DioError catch (e) {
                LogUitls.e(e.message);
              }
            },
          )
        ],
      );
    }));
  }

  // Copy from top.
  Widget _buildPreviewCard(int index) {
    final config = userPreviews[index];

    final userTile = Row(
      children: [
        PixivImage(
          url: config.user!.profileImageUrls!.medium!,
          height: 50,
          width: 50,
        ),
        Text(userPreviews[index].user!.name!),
        CupertinoButton(child: Text("Follow"), onPressed: () {}),
      ],
    );

    // TODO: Fix 0 -> 2 img expanded size bug.
    final illustPreview = Row(
      children: [
        for (int i = 0; i < min(3, config.illusts!.length); ++i)
          Expanded(
              child: PixivImage(
            height: 100,
            width: 100,
            url: config.illusts![i].imageUrls!.squareMedium!,
          ))
      ],
    );

    final card = Container(
      margin: Constant.kViewPaddingHoriziontal.add(EdgeInsets.symmetric(vertical: 18)),
      height: 230,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        children: [
          illustPreview,
          userTile,
        ],
      ),
    );

    return card;
  }
}

/// 搜索历史记录 用户
class UserQueryHistory extends StatefulWidget {
  const UserQueryHistory({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);

  final TextEditingController textEditingController;

  @override
  State<UserQueryHistory> createState() => _UserQueryHistoryState();
}

class _UserQueryHistoryState extends State<UserQueryHistory> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("User Query History"));
  }
}
