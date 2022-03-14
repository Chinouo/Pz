// 推荐用户
import 'package:all_in_one/models/user/user.dart';
import 'package:flutter/material.dart';

/// 推荐用户 listview
class RecommendUserView extends StatefulWidget {
  const RecommendUserView({Key? key}) : super(key: key);

  @override
  State<RecommendUserView> createState() => _RecommendUserViewState();
}

class _RecommendUserViewState extends State<RecommendUserView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// 搜索用户结果视图  listview
class UserResultView extends StatefulWidget {
  const UserResultView({Key? key}) : super(key: key);

  @override
  State<UserResultView> createState() => _UserResultViewState();
}

class _UserResultViewState extends State<UserResultView> {
  final usersStore = <User>[];

  @override
  Widget build(BuildContext context) {
    return Container();
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
