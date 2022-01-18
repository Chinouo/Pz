import 'dart:ui';

import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/widgets/title_roll.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

//自定义顶部AppBar
class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget Function(BuildContext context, double offset) _builder;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  Widget Function(BuildContext context, double offset) get builder => _builder;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.builder != builder;
  }

  PersistentHeaderBuilder(
      {required double minExtent,
      required double maxExtent,
      required Widget Function(BuildContext context, double offset) builder})
      : _maxExtent = maxExtent,
        _minExtent = minExtent,
        _builder = builder;
}

class SliverContent extends StatefulWidget {
  const SliverContent({Key? key}) : super(key: key);

  @override
  _SliverContentState createState() => _SliverContentState();
}

class _SliverContentState extends State<SliverContent>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;
  late AnimationController _animationController;
  late Animation<double> _opacity;

  late double barOpacity;

  @override
  void initState() {
    super.initState();
    barOpacity = 0.15;
    _controller = ScrollController();
    _animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    _opacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  String toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        _builderAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              MaterialButton(
                onPressed: () async {
                  var api = ApiClient();
                  debugPrint("fetch illust ranking ... ");
                  Response r = await api.getIllustRanking("day", null);

                  debugPrint(r.data["illusts"].runtimeType
                      .toString()); // List<dynamic>
                  Provider.of<IllustProvider>(context, listen: false)
                      .updateIllustRanking(r.data["illusts"]);

                  debugPrint(r.toString());
                },
                child: Text("illust"),
                color: Colors.blue,
              ),
              MaterialButton(
                onPressed: () async {
                  var api = ApiClient();
                  Response r = await api.getMangaRanking(
                      "day", toRequestDate(DateTime.now()));
                  debugPrint(r.toString());
                },
                child: Text("manga"),
                color: Colors.blue,
              ),
              MaterialButton(
                onPressed: () async {
                  var api = ApiClient();
                  Response r = await api.getNovelRanking("day", null);
                  String a = r.toString();
                  debugPrint(r.toString());
                },
                child: Text("novel"),
                color: Colors.blue,
              ),
              Consumer<IllustProvider>(builder: (_, illusts, __) {
                return Text(
                    "illistsCount: ${illusts.illustsCollection.length}");
              })
            ],
          ),
        ),
        _buildSecondaryBar(),
        _buildSecondaryBar(),
        _buildSecondaryBar(),
        _buildListView()
      ],
    );
  }

  Widget _buildSecondaryBar() {
    return SliverToBoxAdapter(
      child: DailyContainer(),
    );
  }

  Widget _builderAppBar() {
    final double padding = 24;
    return SliverPersistentHeader(
        pinned: true,
        delegate: PersistentHeaderBuilder(
            minExtent: 100,
            maxExtent: 100,
            builder: (_, offset) {
              if (offset < 50) {
                barOpacity = 0.15;
              } else {
                barOpacity = 0.0;
              }

              if (offset < 100) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }

              return ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AnimatedContainer(
                        color: Color(0xDBEA8D).withOpacity(barOpacity),
                        duration: Duration(seconds: 1),
                        child: FadeTransition(
                            opacity: _opacity,
                            child: Padding(
                              padding: EdgeInsets.only(top: padding),
                              child: Center(child: Text("$offset")),
                            )))),
              );
            }));
  }

  Widget _buildListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((_, index) {
        return Container(
          color: Colors.primaries[index % 18],
          height: 168,
          child: Center(
            child: Text("$index"),
          ),
        );
      }),
    );
  }
}
