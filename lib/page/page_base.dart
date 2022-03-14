// 在构建 scaffold 之前，进行必要的初始化 和状态准备

import 'dart:ui';

import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/generated/l10n.dart';
import 'package:all_in_one/page/home/home_page.dart';
import 'package:all_in_one/page/login/login_page_real.dart';
import 'package:all_in_one/page/search/search_page.dart';
import 'package:all_in_one/page/user/user_setting_page.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/provider/pivision_provider.dart';
import 'package:all_in_one/provider/recommand_illust_provider.dart';
import 'package:all_in_one/provider/search_provider/illusts_search_provider.dart';
import 'package:all_in_one/provider/search_provider/user_search_provider.dart';
import 'package:all_in_one/provider/trend_tag_provider.dart';
import 'package:all_in_one/screen_fit/media_query_wrap.dart';
import 'package:all_in_one/widgets/b2t_cupertino_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:all_in_one/component/lazy_indexed_stack.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //透明化状态栏
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }

    return MultiProvider(
      providers: _buildProviders(),
      child: MaterialApp(
        navigatorKey: Constant.navigatorKey,
        builder: (context, widget) {
          return MediaQueryWrapper(
            builder: (BuildContext context) {
              return Material(child: widget!);
            },
          );
        },
        title: 'Localizations Sample App',
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        initialRoute: Constant.isLogged ? '/home' : '/login',
        onGenerateInitialRoutes: (initialRoute) => _handleInitialRoute(initialRoute),
        onGenerateRoute: (settings) => _handleCustomRoute(settings),
      ),
    );
  }

  // 自己搞一套路由 ...
  List<Route<dynamic>> _handleInitialRoute(String initialRoute) {
    if (initialRoute == '/home') {
      return [MaterialPageRoute(builder: (context) => const CustomScaffold())];
    }
    if (initialRoute == '/login') {
      return [FoundationRoute(builder: (context) => LoginEntry())];
    }
    return [
      PageRouteBuilder(pageBuilder: (_, __, ___) {
        return Container(
          color: Colors.white,
          child: const Center(
            child: Text("Internal Error"),
          ),
        );
      })
    ];
  }

  Route<dynamic>? _handleCustomRoute(RouteSettings settings) {
    if (settings.name == "/loginEntry") {
      return FoundationRoute(
        builder: (context) {
          return LoginEntry();
        },
      );
    }

    if (settings.name == '/home') {
      return MaterialPageRoute(
        builder: (context) {
          return const CustomScaffold();
        },
      );
    }
    return null;
  }

  List<SingleChildWidget> _buildProviders() {
    return <SingleChildWidget>[
      ChangeNotifierProvider<IllustSearchResultProvider>(
          create: (_) => IllustSearchResultProvider()),
    ];
  }
}

enum ScaffoldComponentId {
  bottomBar,
  body,
}

/// 底部为高斯模糊的 导航栏
/// 不用stack  万一某天有特殊需求
class BlurBottomBarDelegate extends MultiChildLayoutDelegate {
  BlurBottomBarDelegate({
    required this.bottomBarConstraint,
  });

  final BoxConstraints bottomBarConstraint;

  @override
  void performLayout(Size size) {
    if (hasChild(ScaffoldComponentId.bottomBar)) {
      final barSize = layoutChild(ScaffoldComponentId.bottomBar, bottomBarConstraint);
      positionChild(
          ScaffoldComponentId.bottomBar, Offset(0, size.height - barSize.height));
    }

    if (hasChild(ScaffoldComponentId.body)) {
      layoutChild(ScaffoldComponentId.body, BoxConstraints.tight(size));
      positionChild(ScaffoldComponentId.body, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(BlurBottomBarDelegate oldDelegate) {
    return oldDelegate.bottomBarConstraint != bottomBarConstraint;
  }
}

const _kBottomBarHeight = 56.0;

class CustomScaffold extends StatefulWidget {
  const CustomScaffold({Key? key}) : super(key: key);

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).viewPadding.bottom;
    final width = MediaQuery.of(context).size.width;

    final tabBar = BlurTabBar(
      children: [
        Expanded(
          child: GestureDetector(
            child: const Icon(CupertinoIcons.home),
            onTap: () {
              setState(() => _currentIndex = 0);
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _currentIndex = 1);
            },
            child: Icon(CupertinoIcons.search),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _currentIndex = 2);
            },
            child: const Icon(CupertinoIcons.cloud_moon_bolt_fill),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _currentIndex = 3);
            },
            child: const Icon(CupertinoIcons.settings),
          ),
        )
      ],
    );

    return CustomMultiChildLayout(
      children: [
        LayoutId(
            id: ScaffoldComponentId.body,
            child: LazyIndexedStack(
              index: _currentIndex,
              children: const [
                HomePage(),
                Placeholder(),
                SearchPage(),
                SettingPage(),
              ],
            )),
        LayoutId(id: ScaffoldComponentId.bottomBar, child: tabBar)
      ],
      delegate: BlurBottomBarDelegate(
        bottomBarConstraint: BoxConstraints.tight(
          Size(width, safeAreaHeight + _kBottomBarHeight),
        ),
      ),
    );
  }
}

const _kBarColor = Color.fromARGB(160, 104, 102, 102);

/// 底部半透明 导航栏
class BlurTabBar extends StatelessWidget {
  const BlurTabBar({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: ColoredBox(
      color: _kBarColor,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    ));
  }
}
