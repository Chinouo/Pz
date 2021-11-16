import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:all_in_one/theme/dark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'lazy_indexed_stack.dart';

import 'title_roll.dart';

import 'package:sqflite/sqflite.dart';

import 'package:all_in_one/page/data_template.dart';
import 'package:all_in_one/page/login_template.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    debugPrint(AppLocalizations.supportedLocales.toString());

    //透明化状态栏
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }

    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: () => MaterialApp(
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant'), //更改此项  来修改语言
        title: 'Localizations Sample App',
        theme: ThemeData(brightness: Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint(MediaQuery.of(context).toString());

    return Scaffold(
        backgroundColor: Color(0xF7F9ED).withOpacity(1.0),
        body: Stack(children: [
          LazyIndexedStack(
            index: _currentIndex,
            children: [
              LoginTemplate(),
              DbTemplate(),
            ],
          ),
          Positioned(bottom: 0, width: 375.w, child: _buildTabBar())
        ]));
  }

  Widget _buildTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          color: Color(0xDBEA8D).withOpacity(0.15),
          height: 56.h + 16.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  debugDumpRenderTree();

                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: Text("Home"),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: Text("Search"),
              )
            ],
          ),
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        _builderAppBar(),
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
    final double padding = 24.h;
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
    return SliverList(delegate: SliverChildBuilderDelegate((_, index) {
      return Container(
        color: Colors.primaries[index % 18],
        height: 168,
        child: Center(
          child: Text("$index"),
        ),
      );
    }));
  }
}

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
