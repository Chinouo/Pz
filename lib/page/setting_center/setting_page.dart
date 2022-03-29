import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      UserAccountCard(),
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
  const UserAccountCard({Key? key}) : super(key: key);

  @override
  State<UserAccountCard> createState() => _UserAccountCardState();
}

class _UserAccountCardState extends State<UserAccountCard> {
  @override
  Widget build(BuildContext context) {
    return Container();
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
    return Container();
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
    return Container();
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
    return Container();
  }
}
