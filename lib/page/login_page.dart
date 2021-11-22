import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/constant.dart';
import 'package:all_in_one/db/db_helper.dart';
import 'package:all_in_one/util/api_util.dart';
import 'package:all_in_one/util/crypto_plugin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: 100,
              child: MaterialButton(
                onPressed: () async {
                  String str =
                      await Navigator.push(context, routePageBuilder());
                  debugPrint(str);
                },
                color: Colors.blue,
                child: Text("Login"),
              )),
          Positioned(
              top: 500,
              child: MaterialButton(
                onPressed: () {
                  debugPrint(Constant.refreshToken.toString());
                },
                child: Text("DO "),
              ))
        ],
      ),
    );
  }

  PageRouteBuilder routePageBuilder() {
    return PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginWebView(),
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
}

class LoginWebView extends StatefulWidget {
  const LoginWebView({Key? key}) : super(key: key);

  @override
  _LoginWebViewState createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  late String codeChanllenge;
  late String codeVer;

  @override
  void initState() {
    super.initState();
    Constant.loginInfo.codeVer = CryptoPlugin.getCodeVer();
    codeVer = Constant.loginInfo.codeVer!;

    Constant.loginInfo.codeChallenge =
        CryptoPlugin.getCodeChallenge(Constant.loginInfo.codeVer!);
    codeChanllenge = Constant.loginInfo.codeChallenge!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            Navigator.pop(context, "meg from pop Navigator!");
          },
        ),
        title: Text("Login WebView"),
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(useHybridComposition: true)),
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
          // 得携带登录时的Code，去请求token
          if (uri.scheme == "pixiv") {
            OAuthClient oac = OAuthClient();
            String code = uri.queryParameters["code"]!;
            Response response = await oac.code2Token(code, codeVer);

            String? s1 = response.data["refresh_token"];
            String? s2 = response.data["access_token"];
            if (s1 != null && s2 != null) {
              await Constant.storedToken(refreshToken: s1, accessToken: s2);
              Navigator.pop(context, "login success");
            }

            //debugPrint(response.data);
          }
        }
      },
    );
  }
}
