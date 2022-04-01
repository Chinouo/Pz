import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/account/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      UserAccountCard(
        account: User(name: "Test"),
      ),
      Row(
        children: [
          Expanded(flex: 1, child: AppSettingCard()),
          Expanded(flex: 1, child: Toggle()),
        ],
      ),
      HistoryCard(),
    ];

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          largeTitle: Text("User"),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return cards[index];
          }, childCount: cards.length),
        )
      ],
    );
  }
}

// Rect
class UserAccountCard extends StatefulWidget {
  const UserAccountCard({
    Key? key,
    required this.account,
  }) : super(key: key);

  final User account;

  @override
  State<UserAccountCard> createState() => _UserAccountCardState();
}

class _UserAccountCardState extends State<UserAccountCard> {
  @override
  Widget build(BuildContext context) {
    HiveBoxes.accountBox.get("myAccount");

    return Container(
      color: Colors.amber,
      height: 200,
      child: Row(
        children: [
          ClipOval(
            child: Container(
              height: 80,
              width: 80,
              color: Colors.black26,
            ),
          ),
          Text(widget.account.name!),
        ],
      ),
    );
  }
}

// square
class AppSettingCard extends StatefulWidget {
  const AppSettingCard({Key? key}) : super(key: key);

  @override
  State<AppSettingCard> createState() => _AppSettingCardState();
}

class _AppSettingCardState extends State<AppSettingCard> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      fallbackHeight: 200,
    );
  }
}

// square
class Toggle extends StatefulWidget {
  const Toggle({Key? key}) : super(key: key);

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      fallbackHeight: 200,
    );
  }
}

// rect
class HistoryCard extends StatefulWidget {
  const HistoryCard({Key? key}) : super(key: key);

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 200,
      child: Center(
        child: Text("History"),
      ),
    );
  }
}
