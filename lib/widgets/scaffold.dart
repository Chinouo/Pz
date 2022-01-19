import 'dart:ui';

import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/page/login_info_page_demo.dart';
import 'package:all_in_one/page/login_page.dart';
import 'package:all_in_one/page/login_page_real.dart';
import 'package:all_in_one/page/login_template.dart';
import 'package:all_in_one/page/pageview_demo.dart';
import 'package:all_in_one/page/ranking_page.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/screen_fit/media_query_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'custom_appbar.dart';
import 'lazy_indexed_stack.dart';

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
              LoginPage(),
              LoginEntry()
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
                    debugPrint(MediaQuery.of(context).toString());
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
