import 'dart:async';
import 'dart:io';

import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/db/db_helper.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:all_in_one/util/api_util.dart';
import 'package:all_in_one/util/crypto_plugin.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'constant/constant.dart';
import 'widgets/scaffold.dart';

void main() {
  runZonedGuarded<void>(() async {
    //初始化常量

    //
    WidgetsFlutterBinding.ensureInitialized();

    await DBHelper.initDBHelper();
    await Constant.initStoredToken();

    runApp(const MyApp());
  },
      (Object e, StackTrace s) => LogUitls.e(
            'Caught unhandled exception: $e',
            stackTrace: s,
          ));
}


/*
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    Dio api = OAuthClient().httpClient
      ..options.baseUrl = "https://app-api.pixiv.net";

    Response response = await api.get("/web/v1/login");

    debugPrint(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WebViewExample()));
              },
              child: Text("跳转"),
            ),
            MaterialButton(
              onPressed: () async {
                OAuthClient oac = OAuthClient();
                Response response = await oac.postRefreshAuthToken(
                    refreshToken:
                        "0GIHqn1q0BhFgShVmuPEgTWAwAIwZt2k_dIUcwQX6tg");
                debugPrint(response.data);
              },
              child: Text("刷新Token"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  late String codeChanllenge;
  late String codeVer;
  @override
  void initState() {
    super.initState();
    codeVer = CryptoPlugin.getCodeVer();
    codeChanllenge = CryptoPlugin.getCodeChallenge(codeVer);
  }

//"https://app-api.pixiv.net/web/v1/login?code_challenge=${CryptoPlugin.getCodeChallenge()}&code_challenge_method=S256&client=pixiv-android",
//"PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)"

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(
            "https://app-api.pixiv.net/web/v1/login?code_challenge=$codeChanllenge&code_challenge_method=S256&client=pixiv-android",
          ),
          headers: {
            "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)"
          }),
      onLoadStart: (controller, uri) async {
        debugPrint(uri.toString());
        debugPrint(uri?.host);
        debugPrint(uri?.scheme);
        debugPrint(uri?.queryParameters.toString());
        debugPrint(uri?.queryParameters['code']);
        debugPrint("=======================================");

        if (uri != null) {
          if (uri.scheme == "pixiv") {
            OAuthClient oac = OAuthClient();
            String code = uri.queryParameters["code"]!;
            Response response = await oac.code2Token(code, codeVer);
            debugPrint(response.data);
          }
        }
      },
    );
  }
}

*/