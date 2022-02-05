/// 主页
/// 结构由上到下
/// illust排行 -> pixivsion -> recommended

import 'dart:ui';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/page/login_page_real.dart';
import 'package:all_in_one/page/ranking_page.dart';
import 'package:all_in_one/page/user_setting_page.dart';
import 'package:all_in_one/page/walk_through_page.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/screen_fit/media_query_wrap.dart';
import 'package:all_in_one/widgets/b2t_cupertino_route.dart';
import 'package:all_in_one/widgets/custom_appbar.dart';
import 'package:all_in_one/widgets/lazy_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:all_in_one/constant/hive_boxes.dart';

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
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => IllustProvider())],
      child: MaterialApp(
        builder: (context, widget) {
          return MediaQueryWrapper(
            builder: (BuildContext context) {
              return widget!;
            },
          );
        },
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant'), //更改此项  来修改语言
        title: 'Localizations Sample App',
        theme: ThemeData(brightness: Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MyHomePage(),
        onUnknownRoute: (settings) {
          return FoundationRoute(
            builder: (context) {
              return LoginEntry();
            },
          );
        },
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
  late int _currentIndex = 0;
  late Box<Account> accountBox;
  @override
  void initState() {
    super.initState();
    accountBox = HiveBoxes.accountBox;
    if (accountBox.get("refresh_token") == null) {
      // 没有token
      _currentIndex = 0; //登录页
    } else {
      _currentIndex = 1; //主页
    }
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint(MediaQuery.of(context).toString());

    return Scaffold(
        backgroundColor: Color(0xFFFFFF).withOpacity(1.0),
        body: Stack(children: [
          LazyIndexedStack(
            index: _currentIndex,
            children: [
              RankingPage(),
              SliverContent(),
              //LoginTemplate(),
              //ShowAccountPage(),
              //LoginPage(),
              Placeholder(),
              SettingPage(),
              // Placeholder()
            ],
          ),
          Positioned(bottom: 0, width: 375, child: _buildTabBar())
        ]));
  }

  Widget _buildTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          color: Color(0xF2F2F7).withOpacity(0.8),
          height: 56 + 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: Text("Label1"),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: Text("Label2"),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: Text("Label3"),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 3;
                    // debugPrint(MediaQuery.of(context).toString());
                  });
                },
                child: Text("Label4"),
              )
            ],
          ),
        ),
      ),
    );
  }
}


/// 分页 和 上拉刷新

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: PullToBottomRefresh(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

// class PullToBottomRefresh extends StatefulWidget {
//   const PullToBottomRefresh({Key? key}) : super(key: key);

//   @override
//   _PullToBottomRefreshState createState() => _PullToBottomRefreshState();
// }

// class _PullToBottomRefreshState extends State<PullToBottomRefresh> {
//   // 触发刷新的阈值
//   final double kMaxOverScrollValue = 50;

//   ValueNotifier<double> overScrollLogicPixel = ValueNotifier<double>(0.0);

//   ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

//   ScrollController ctrl = ScrollController(keepScrollOffset: false);

//   int itemCount = 20;

//   double recentOverScroll = 0.0;

//   Key centerKey = UniqueKey();

//   Future<void> _loadMore() async {
//     isLoading.value = true;
//     Future.delayed(Duration(seconds: 5), () {
//       setState(() {
//         itemCount += 20;
//         isLoading.value = false;
//       });
//       debugPrint("End Loading!");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener(
//         onNotification: (notification) {
//           debugPrint(notification.runtimeType.toString());

//           // 如果正在加载 无视一切
//           if (isLoading.value) {
//             return false;
//           }

//           // if (notification is ScrollMetricsNotification) {
//           //   debugPrint(notification.metrics.pixels.toString());
//           // }

//           // 滑动 假如滑动到底部了
//           if (notification is ScrollUpdateNotification) {
//             // debugPrint("after:" + notification.metrics.extentAfter.toString());
//             // 判断是否触底了
//             if (notification.metrics.extentAfter == 0) {
//               //debugPrint(recentOverScroll.toString());
//               if (notification.metrics.pixels -
//                       notification.metrics.maxScrollExtent >
//                   kMaxOverScrollValue) {
//                 if (!isLoading.value) {
//                   _loadMore();
//                   debugPrint("Start Loading!");
//                 }
//               }

//               // 到底了 开始计算 overscroll 的值
//               //notification.scrollDelta

//             }
//             return false;
//           }
//           // 松手了
//           if (notification is ScrollEndNotification) {}

//           //ebugPrint("${notification.scrollDelta}");
//           return false;
//         },
//         child: Stack(children: [
//           Positioned(
//               left: 180,
//               height: 30,
//               bottom: 10,
//               child: ValueListenableBuilder(
//                 valueListenable: isLoading,
//                 builder: (BuildContext context, bool value, Widget? child) {
//                   return CupertinoActivityIndicator(
//                     key: UniqueKey(),
//                     animating: value,
//                     radius: 20,
//                   );
//                 },
//               )),
//           CustomScrollView(
//               controller: ctrl,
//               physics: CutsomBouncingScrollPhysics(),
//               slivers: [
//                 SliverList(
//                   key: centerKey,
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       return Container(
//                         color: Colors.primaries[index % 18],
//                         child: SizedBox(
//                           height: 70,
//                           child: Center(
//                             child: Text("$index"),
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: itemCount,
//                   ),
//                 ),
//                 SliverFillRemaining(
//                   hasScrollBody: false,
//                   child: ValueListenableBuilder(
//                     valueListenable: isLoading,
//                     builder: (BuildContext context, bool value, Widget? child) {
//                       return SizedBox(
//                         height: value ? kMaxOverScrollValue : 0.0,
//                       );
//                     },
//                   ),
//                 )
//               ]),
//         ]));
//   }
// }

// mixin Fk on BouncingScrollPhysics {
//   @override
//   CutsomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return CutsomBouncingScrollPhysics(parent: buildParent(ancestor));
//   }

//   @override
//   double adjustPositionForNewDimensions({
//     required ScrollMetrics oldPosition,
//     required ScrollMetrics newPosition,
//     required bool isScrolling,
//     required double velocity,
//   }) {
//     return oldPosition.pixels;
//   }
// }

// class CutsomBouncingScrollPhysics extends BouncingScrollPhysics with Fk {
//   const CutsomBouncingScrollPhysics({ScrollPhysics? parent})
//       : super(parent: parent);
// }
