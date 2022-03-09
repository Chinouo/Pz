import 'dart:io';
import 'dart:typed_data';

import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/page/search/search_page.dart';
import 'package:all_in_one/util/crypto_plugin.dart';
import 'package:all_in_one/widgets/b2t_cupertino_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import 'search/cupertino_search_page.dart';

class LoginEntry extends StatefulWidget {
  LoginEntry({Key? key}) : super(key: key);

  @override
  _LoginEntryState createState() => _LoginEntryState();
}

class _LoginEntryState extends State<LoginEntry> {
  late String codeChanllenge;
  late String codeVer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

                String? code = await Navigator.push(
                    context,
                    IOSPageRoute<String>(
                        builder: (_) => LoginWebView(
                              codeChanllenge: codeChanllenge,
                            )));

                if (code != null) {
                  await _fetchUserJson(code);
                  await Navigator.popAndPushNamed(context, "/home");
                }
              },
              color: Colors.blue,
              child: Text("Login"),
            ),
            MaterialButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return SearchPage();
                })));
              },
              child: Text("Test Entry"),
            )
          ],
        ),
      ),
    );
  }

  // 获取用户信息
  Future<void> _fetchUserJson(String code) async {
    try {
      OAuthClient oathClient = OAuthClient();
      Response response = await oathClient.code2Token(code, codeVer);
      HiveBoxes.accountBox.put("myAccount", Account.fromJson(response.data));
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}

class LoginWebView extends StatefulWidget {
  const LoginWebView({Key? key, required this.codeChanllenge})
      : super(key: key);

  final String codeChanllenge;

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  ValueNotifier<String> url = ValueNotifier<String>("Pixiv");

  @override
  void initState() {
    //  if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 80,
        leading: MaterialButton(
          child: const Text("Done"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        title: ValueListenableBuilder(
          valueListenable: url,
          builder: (BuildContext context, String value, Widget? child) {
            return Text(value);
          },
        ),
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform:
                InAppWebViewOptions(resourceCustomSchemes: ["pixiv"]),
            android: AndroidInAppWebViewOptions(useHybridComposition: true)),
        initialUrlRequest: URLRequest(
            url: Uri.parse(
              "https://app-api.pixiv.net/web/v1/login?code_challenge=${widget.codeChanllenge}&code_challenge_method=S256&client=pixiv-android",
            ),
            headers: {
              "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)"
            }),
        onLoadResourceCustomScheme: (controller, url) async {
          if (url.scheme == "pixiv") {
            // 在自定义 scheme 加载前拦截
            var response = CustomSchemeResponse(
                data: Uint8List.fromList([]).buffer.asUint8List(),
                contentType: "text/html",
                contentEncoding: "utf-8");
            if (Platform.isIOS) {
              Navigator.pop(context, url.queryParameters["code"]);
            }
            return response;
          }
          return null;
        },
        onLoadStart: (controller, uri) {
          if (uri != null) {
            url.value = uri.host;
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

// WebView(
//     javascriptMode: JavascriptMode.unrestricted,
//     onWebViewCreated: (controller) {
//       controller.loadUrl(
//           "https://app-api.pixiv.net/web/v1/login?code_challenge=${widget.codeChanllenge}&code_challenge_method=S256&client=pixiv-android",
//           headers: {
//             "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)"
//           });
//     },
//   )
