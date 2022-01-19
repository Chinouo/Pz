import 'dart:typed_data';

import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/util/crypto_plugin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/*
  当前存在的问题，pixiv的scheme 加载太快 WebView报错 但是 Navigator带没有Pop
*/

class LoginEntry extends StatefulWidget {
  LoginEntry({Key? key}) : super(key: key);

  @override
  _LoginEntryState createState() => _LoginEntryState();
}

class _LoginEntryState extends State<LoginEntry> {
  double? _value;
  bool sw = false;

  late String codeChanllenge;
  late String codeVer;

  @override
  void initState() {
    super.initState();
    // codeVer = CryptoPlugin.genCodeVer();
    // codeChanllenge = CryptoPlugin.genCodeChallenge(codeVer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Entry"),
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () async {
                // 点击登录后 生成验证信息
                codeVer = CryptoPlugin.genCodeVer();
                codeChanllenge = CryptoPlugin.genCodeChallenge(codeVer);

                String? code =
                    await Navigator.push(context, routePageBuilder());
                if (code != null) {
                  await _fetchUserJson(code);
                  setState(() {
                    _value = 0.5;
                  });
                }
              },
              color: Colors.blue,
              child: Text("Login"),
            ),
            MaterialButton(
              onPressed: () async {
                setState(() {
                  sw = !sw;
                  sw ? _value = null : _value = 1.0;
                });
              },
              color: Colors.blue,
              child: Text("Test"),
            ),
            CircularProgressIndicator(
              value: _value,
              color: Colors.blue,
              strokeWidth: 2,
            )
          ],
        ),
      ),
    );
  }

  PageRouteBuilder<String> routePageBuilder() {
    return PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginWebView(
              codeChanllenge: codeChanllenge,
            ),
        transitionsBuilder: (_, animation, __, child) {
          var tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
          var ani =
              tween.chain(CurveTween(curve: Curves.ease)).animate(animation);
          return SlideTransition(
            position: ani,
            child: child,
          );
        });
  }

  // 获取用户信息
  Future<void> _fetchUserJson(String code) async {
    OAuthClient oathClient = OAuthClient();
    Response response = await oathClient.code2Token(code, codeVer);
    HiveBoxes.accountBox.put("myAccount", Account.fromJson(response.data));
  }
}

class LoginWebView extends StatelessWidget {
  const LoginWebView({Key? key, required this.codeChanllenge})
      : super(key: key);

  final String codeChanllenge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            Navigator.pop(context, null);
          },
        ),
        title: const Text("Login WebView"),
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform:
                InAppWebViewOptions(resourceCustomSchemes: ["pixiv"]),
            android: AndroidInAppWebViewOptions(useHybridComposition: true)),
        initialUrlRequest: URLRequest(
            url: Uri.parse(
              "https://app-api.pixiv.net/web/v1/login?code_challenge=$codeChanllenge&code_challenge_method=S256&client=pixiv-android",
            ),
            headers: {
              "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)"
            }),
        onLoadResourceCustomScheme: (controller, url) async {
          if (url.scheme == "pixiv") {
            var response = CustomSchemeResponse(
                data: Uint8List.fromList([]).buffer.asUint8List(),
                contentType: "text/html",
                contentEncoding: "utf-8");
            return response;
          }
          return null;
        },
        onLoadStart: (controller, uri) {
          if (uri != null) {
            if (uri.scheme == "pixiv") {
              // 获得uri里面的code 此时页面已经被拦截并加载成[CustomSchemeResponse]
              Navigator.pop(context, uri.queryParameters["code"]);
            }
          }
        },
      ),
    );
  }
}
