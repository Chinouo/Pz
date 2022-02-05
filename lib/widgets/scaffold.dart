import 'dart:ui';

import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/page/home_page.dart';

import 'package:all_in_one/page/login_page.dart';
import 'package:all_in_one/page/login_page_real.dart';
import 'package:all_in_one/page/login_template.dart';
import 'package:all_in_one/page/pageview_demo.dart';
import 'package:all_in_one/page/ranking_page.dart';
import 'package:all_in_one/page/user_setting_page.dart';
import 'package:all_in_one/provider/illust_rank_provider.dart';
import 'package:all_in_one/screen_fit/media_query_wrap.dart';
import 'package:all_in_one/widgets/b2t_cupertino_route.dart';
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

        onGenerateRoute: (settings) => _handleCustomRoute(settings),
      ),
    );
  }

  Route<dynamic>? _handleCustomRoute(RouteSettings settings) {
    if (settings.name == "/loginEntry") {
      return FoundationRoute(
        builder: (context) {
          return LoginEntry();
        },
      );
    }
  }
}
