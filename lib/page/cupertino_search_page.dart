import 'package:flutter/material.dart';

import '../widgets/sliver_persistent_animated_head.dart';

class CupertinoPageRouteTemplate extends StatefulWidget {
  const CupertinoPageRouteTemplate({Key? key}) : super(key: key);

  @override
  _CupertinoPageRouteTemplateState createState() =>
      _CupertinoPageRouteTemplateState();
}

class _CupertinoPageRouteTemplateState extends State<CupertinoPageRouteTemplate>
    with SingleTickerProviderStateMixin {
  double appBarHeight = 210;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _buildScrollView(),
        buildStickyTopSearchBar(),
        _buildResultLayer()
      ],
    );
  }

  bool isFocus = false;

  double shrinkHeight = 200;

  double expandHeight = 300;

  Widget _buildResultLayer() {
    return Positioned(
        top: MediaQuery.of(context).viewPadding.top + appBarHeight,
        child: SizedBox(
          width: 300,
          height: 300,
          child: AnimatedSwitcher(
            key: UniqueKey(),
            duration: const Duration(milliseconds: 200),
            child: isFocus ? _buildAutoFillWordsList() : null,
          ),
        ));
  }

  // 不用persistent 是因为对其内部 size变换动画 不熟悉
  Widget buildStickyTopSearchBar() {
    return Positioned(
        top: 0,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          color: Colors.red.withOpacity(0.1),
          height: appBarHeight + MediaQuery.of(context).viewPadding.top,
          width: MediaQuery.of(context).size.width,
          child: MaterialButton(
            onPressed: () {
              setState(() {
                if (appBarHeight == 210) {
                  appBarHeight = 150;
                } else {
                  appBarHeight = 210;
                }
                isFocus = !isFocus;
              });
            },
            child: Text("Click Me!"),
          ),
        ));
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedContainer(
            color: Colors.grey.withOpacity(0.5),
            duration: const Duration(seconds: 1),
            height: appBarHeight,
          ),
        ),
        // SliverPersistentHeader(
        //     floating: true,
        //     pinned: true,
        //     delegate: TitlePersistHeader(
        //         vsync: this,
        //         shrinkHeight: shrinkHeight,
        //         stretchhHeight: expandHeight,
        //         parentStateTicker: this,
        //         parentSetState: () {
        //           setState(() {
        //             expandHeight = 100;
        //             shrinkHeight = 100;
        //           });
        //         })),
        // SliverAnimatedPersistentHeaderWidget(
        //   child: AnimatedContainer(
        //     color: Colors.green,
        //     height: 100,
        //     duration: Duration(seconds: 1),
        //   ),
        // ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          ((context, index) {
            return Container(
              color: Colors.primaries[index % 18],
              height: 200,
            );
          }),
          childCount: 20,
        ))
      ],
    );
  }

  Widget _buildAutoFillWordsList() {
    return ListView.separated(
      itemCount: 20,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        return Container(
          color: Colors.primaries[index % 18],
          child: Center(child: Text("$index")),
        );
      },
    );
  }

  double _searchTextfieldAligment = 0.0;
  Widget _buildSearchText() {
    return AnimatedAlign(
        alignment: Alignment(0, _searchTextfieldAligment),
        duration: const Duration(milliseconds: 200));
  }

  double _searchListOpacity = 1.0;

  double _appBarExtent = 200.0;
  Widget _buildGridTag() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _searchListOpacity,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: _appBarExtent),
          )
        ],
      ),
    );
  }
}

class TitlePersistHeader extends SliverPersistentHeaderDelegate {
  TitlePersistHeader(
      {required this.shrinkHeight,
      required this.stretchhHeight,
      required this.parentSetState,
      required this.parentStateTicker,
      required this.vsync});

  @override
  TickerProvider vsync;

  double shrinkHeight;

  double stretchhHeight;

  VoidCallback parentSetState;

  TickerProvider parentStateTicker;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color.fromARGB(255, 74, 147, 207),
      child: Center(
          child: MaterialButton(
        onPressed: () {
          parentSetState();
        },
        child: Text("$shrinkOffset"),
      )),
    );
  }

  @override
  double get maxExtent => stretchhHeight;

  @override
  double get minExtent => shrinkHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
