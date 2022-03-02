import 'dart:math';

import 'package:all_in_one/page/search_page.dart';
import 'package:all_in_one/widgets/custom_appbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../widgets/sliver_persistent_animated_head.dart';

const Duration kMoveDuration = Duration(milliseconds: 200);

/// Align to top when focus.
const Alignment kSearchTextFieldFocusAligment = Alignment(0.0, -0.7);

/// Align when unfocus.
const Alignment kSearchTextFieldUnFocusAligment = Alignment(0.0, 0.0);

const double kInvisiable = 0.0;

const double kVisiable = 1.0;

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
    return SearchPage(
      f: f,
    );
    // return Stack(
    //   fit: StackFit.passthrough,
    //   children: [
    //     _buildScrollView(),
    //     buildStickyTopSearchBar(),
    //     _buildResultLayer()
    //   ],
    // );
  }

  bool isFocus = false;

  double shrinkHeight = 200;

  double expandHeight = 300;

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

  Future<List<int>> f = fakeFuture();

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

enum ComponentId {
  searchAppBar,
  tagGridView,
  searchResultView,
  fillViewPaddingTop
}

class SearchPageLayoutDelegate extends MultiChildLayoutDelegate {
  SearchPageLayoutDelegate({
    required this.appBarConStraint,
    required this.stackConstraint,
  });

  final BoxConstraints appBarConStraint;

  final BoxConstraints stackConstraint;

  @override
  void performLayout(Size size) {
    Size size = Size.zero;
    if (hasChild(ComponentId.fillViewPaddingTop)) {
      size = layoutChild(ComponentId.fillViewPaddingTop, appBarConStraint);
      positionChild(ComponentId.fillViewPaddingTop, Offset.zero);
    }

    if (hasChild(ComponentId.searchAppBar)) {
      layoutChild(ComponentId.searchAppBar, appBarConStraint);
      positionChild(ComponentId.searchAppBar, Offset(0, size.height));
    }

    if (hasChild(ComponentId.tagGridView)) {
      layoutChild(ComponentId.tagGridView, stackConstraint);
      positionChild(ComponentId.tagGridView, Offset.zero);
    }

    if (hasChild(ComponentId.searchResultView)) {
      layoutChild(ComponentId.searchResultView, stackConstraint);
      positionChild(ComponentId.searchResultView, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(SearchPageLayoutDelegate oldDelegate) {
    return oldDelegate.appBarConStraint != appBarConStraint ||
        oldDelegate.stackConstraint != stackConstraint;
  }
}

const double kShrinkSearchBarHeight = 200.0;

const double kStrengthSearchBarHeight = 300.0;

class SearchPage extends StatefulWidget {
  final Future<List<int>> f;

  const SearchPage({Key? key, required this.f}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  double searchBarHeight = kStrengthSearchBarHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      debugPrint(constraints.toString());
      final appBarWidth = MediaQuery.of(context).size.width;
      final appBarHeight =
          MediaQuery.of(context).viewPadding.top + searchBarHeight;
      final appBarConstraints = constraints.loosen();
      return CustomMultiChildLayout(
        delegate: SearchPageLayoutDelegate(
          appBarConStraint: appBarConstraints,
          stackConstraint: constraints,
        ),
        children: <Widget>[
          _buildTagGridView(),
          _buildSearchResult(),
          _buildSearchBar(context),
          _buildFillViewPaddingBox(context),
        ],
      );
    });
  }

  double resultOpacity = 0.0;

  TextEditingController textEditingController = TextEditingController();

  FocusNode focusNode = FocusNode();

  Alignment searchTextAligment = kSearchTextFieldUnFocusAligment;

  double segOpacity = kInvisiable;

  Future<List<int>> f = fakeFuture();

  Widget _buildSearchBar(BuildContext context) {
    final searchTextField = CupertinoSearchTextField(
      controller: textEditingController,
      focusNode: focusNode,
      onTap: () {
        // Todo: Shrink appbar and focus.
        setState(() {
          searchBarHeight = kShrinkSearchBarHeight;
          searchTextAligment = kSearchTextFieldFocusAligment;
          segOpacity = kVisiable;
        });
      },
      onSuffixTap: () {
        textEditingController.clear();
        //focusNode.unfocus();
      },
      onChanged: (words) {
        // Todo: Fetch AutoFillWord and build relative text.
        setState(() {
          f = widget.f;
          isSubmit = false;
          resultOpacity = 1.0;
        });
      },
      onSubmitted: (words) {
        // Todo: Fetch IllustResult and build WaterFallFlow list.
        setState(() {
          // isSubmit = !isSubmit;
          isSubmit = true;
          if (resultOpacity == 0.0) {
            resultOpacity = 1.0;
          }
        });
      },
    );

    const filter = Icon(Icons.filter_3_outlined);

    final searchBar = AnimatedAlign(
      alignment: Alignment(0.0, -0.7),
      duration: kMoveDuration,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(child: searchTextField),
              filter,
              MaterialButton(
                onPressed: () {
                  textEditingController.clear();
                  focusNode.unfocus();
                  setState(() {
                    searchBarHeight = kStrengthSearchBarHeight;
                    searchTextAligment = kSearchTextFieldUnFocusAligment;
                    segOpacity = kInvisiable;
                    isSubmit = false;

                    resultOpacity = 0.0;
                  });
                },
                child: Text("Cancle"),
              ),
            ],
          )),
    );

    final searchTarget = AnimatedOpacity(
        opacity: segOpacity,
        duration: kMoveDuration,
        child: CupertinoSlidingSegmentedControl(
          children: {
            "Illusts": Text("Illust"),
            "Users": Text("Users"),
          },
          onValueChanged: (str) {
            // Todo:
          },
        ));

    final appBarHeight =
        MediaQuery.of(context).viewPadding.top + searchBarHeight;
    return LayoutId(
        id: ComponentId.searchAppBar,
        child: AnimatedContainer(
          height: appBarHeight,
          color: Colors.grey.withOpacity(0.7),
          duration: const Duration(milliseconds: 200),
          child: AnimatedAlign(
            alignment: searchTextAligment,
            duration: kMoveDuration,
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: <Widget>[
                searchBar,
                searchTarget,
              ],
            ),
          ),
        ));
  }

  Widget _buildAutoFillWordsList(Key key) {
    return FutureBuilder<List<int>>(
        future: f,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            //return _buildFutureError(snapshot.error);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              debugPrint('-------ConnectionState.none---------');
              break;
            case ConnectionState.waiting:
              return Center(
                  child: CupertinoActivityIndicator(
                animating: true,
              ));
            case ConnectionState.active:
              debugPrint('-------ConnectionState.active---------');
              break;
            case ConnectionState.done:
              debugPrint(
                  '-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                return ListView.separated(
                  key: key,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    return Container(
                      color: Colors.primaries[index % 18],
                      child: Center(child: Text("${snapshot.data!.length}")),
                    );
                  },
                );
                ;
              }
              break;
          }

          return const Center(
            child: Text("An exception occure!"),
          );
        }));
  }

  Widget _buildTagGridView() {
    return LayoutId(
      id: ComponentId.tagGridView,
      child: FutureBuilder<Response>(
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return _buildFutureError(snapshot.error);
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              debugPrint('-------ConnectionState.none---------');
              break;
            case ConnectionState.waiting:
              return _buildLoading();
            case ConnectionState.active:
              debugPrint('-------ConnectionState.active---------');
              break;
            case ConnectionState.done:
              debugPrint(
                  '-------ConnectionState.done---${snapshot.hasData}------');
              if (snapshot.hasData) {
                return CustomScrollView(
                  slivers: <Widget>[
                    _buildSliverFillAppBarBox(),
                    _buildTagsGridSliver(snapshot.data!)
                  ],
                );
              }
              break;
          }

          return const Center(
            child: Text("An exception occure!"),
          );
        }),
      ),
    );
  }

  Widget _buildTagsGridSliver(Response<dynamic> response) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: Colors.primaries[index % 18],
          );
        },
        childCount: 30,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(
        animating: true,
      ),
    );
  }

  Widget _buildFutureError(Object? error) {
    return Center(
      child: Text("A network error occuer! \n Error:$error"),
    );
  }

  // 一个sliver 填充 appbar 的高度
  Widget _buildSliverFillAppBarBox() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        height: searchBarHeight,
      ),
    );
  }

  bool isSubmit = false;

  Key k1 = UniqueKey();
  Key k2 = UniqueKey();

  Widget _buildSearchResult() {
    return LayoutId(
        id: ComponentId.searchResultView,
        child: SearchContent(
            opacity: resultOpacity,
            body: isSubmit
                ? _buildWaterFallView(k2)
                : _buildAutoFillWordsList(k1)));
  }

  Widget _buildWaterFallView(Key key) {
    final waterfallSliver = SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate(((context, index) {
        return Container(
          color: Colors.primaries[index % 18],
          height: (index * 100) % 300,
          child: Center(
            child: Text("$index"),
          ),
        );
      })),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );

    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        waterfallSliver,
      ],
    );
  }

  Widget _buildFillViewPaddingBox(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding.top;
    final appBarWidth = MediaQuery.of(context).size.width;
    return LayoutId(
        id: ComponentId.fillViewPaddingTop,
        child: SizedBox(
          height: viewPadding,
          width: appBarWidth,
          child: const ColoredBox(color: Colors.grey),
        ));
  }
}

// 搜索内容界面
class SearchContent extends StatefulWidget {
  const SearchContent({
    Key? key,
    this.body,
    this.opacity = 0.0,
  }) : super(key: key);

  final Widget? body;

  final double opacity;

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    opacity = widget.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(
        milliseconds: 200,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 200,
        ),
        child: widget.body,
      ),
    );
  }

  @override
  void didUpdateWidget(SearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    opacity = widget.opacity;
  }
}

// class TitlePersistHeader extends SliverPersistentHeaderDelegate {
//   TitlePersistHeader(
//       {required this.shrinkHeight,
//       required this.stretchhHeight,
//       required this.parentSetState,
//       required this.parentStateTicker,
//       required this.vsync});

//   @override
//   TickerProvider vsync;

//   double shrinkHeight;

//   double stretchhHeight;

//   VoidCallback parentSetState;

//   TickerProvider parentStateTicker;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: const Color.fromARGB(255, 74, 147, 207),
//       child: Center(
//           child: MaterialButton(
//         onPressed: () {
//           parentSetState();
//         },
//         child: Text("$shrinkOffset"),
//       )),
//     );
//   }

//   @override
//   double get maxExtent => stretchhHeight;

//   @override
//   double get minExtent => shrinkHeight;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
// }

var fakeFuture = () {
  return Future.delayed(Duration(seconds: 5), () {
    return List.generate(100, (index) => index * Random().nextInt(10));
  });
};
