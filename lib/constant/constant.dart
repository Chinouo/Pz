import 'package:all_in_one/db/db_helper.dart';
import 'package:all_in_one/models/token_model.dart';

class Constant {
  Constant._();

  static final loginInfo = TokenModel();

  static String? get refreshToken => loginInfo.refreshToken;
  static String? get accessToken => loginInfo.accessToken;

  //初始化 从数据库拿数据
  static Future<void> initStoredToken() async {
    DBHelper? db = DBHelper.instance();
    if (db == null) {
      print(6);
    }
    Map<String, dynamic> tokens = await db.getStoredToken();
    loginInfo.refreshToken = tokens["refreshToken"];
    loginInfo.accessToken = tokens["accessToken"];
  }

  //存 Token 到Constant 和 数据库
  static Future<void> storedToken(
      {required String refreshToken, required String accessToken}) async {
    loginInfo.refreshToken = refreshToken;
    loginInfo.accessToken = accessToken;

    DBHelper db = DBHelper.instance();
    Map<String, String> map = Map<String, String>();
    map["refreshToken"] = refreshToken;
    map["accessToken"] = accessToken;
    await db.storedToken(map);
  }

/*
  void xx() {
    InAppWebView(
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
  */
}
