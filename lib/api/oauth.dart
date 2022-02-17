// ignore_for_file: non_constant_identifier_names, duplicate_ignore, constant_identifier_names

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import "package:dio/dio.dart";
import 'package:all_in_one/util/api_util.dart';

// ignore: non_constant_identifier_names
// 除了验证 一般情况下不在内存中
// Todo: IOS Proxy?
class OAuthClient {
  OAuthClient() {
    String time = Util.getIsoDate();
    httpClient = Dio()
      ..options.baseUrl = "https://$BASE_OAUTH_URL_HOST"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": Util.getHash(time + hashSalt),
        "User-Agent": "PixivIOSApp/7.7.5 (iOS 13.2.0; iPhone XR)",
        HttpHeaders.acceptLanguageHeader: "zh-CN",
        "App-OS": "ios",
        "App-OS-Version": "13.2.0",
        "App-Version": "7.7.5",
        "Host": BASE_OAUTH_URL_HOST
      }
      ..options.contentType = Headers.formUrlEncodedContentType;
    (httpClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };

      return httpClient;
    };

    //if (kDebugMode)
    httpClient.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));

    void initA(time) async {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        var headers = httpClient.options.headers;
        headers['User-Agent'] =
            "PixivAndroidApp/5.0.166 (Android ${androidInfo.version.release}; ${androidInfo.model})";
        headers['App-OS-Version'] = "Android ${androidInfo.version.release}";
      }
    }

    initA(time);
  }

  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";

  final String BASE_OAUTH_URL_HOST = "oauth.secure.pixiv.net";

  final String CLIENT_ID = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  final String CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";
  final String REFRESH_CLIENT_ID = "KzEZED7aC0vird8jWyHM38mXjNTY";
  final String REFRESH_CLIENT_SECRET =
      "W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP";

  final String LOGIN_URL = "https://app-api.pixiv.net/web/v1/login";

  late Dio httpClient;

  // 初次登录 Webview 登陆后 带着code 和  code_verifier 去验证得到 token
  Future<Response> code2Token(String code, String code_verifier) {
    return httpClient.post("/auth/token",
        data: {
          "code": code,
          "redirect_uri":
              "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback",
          "grant_type": "authorization_code",
          "include_policy": true,
          "client_id": CLIENT_ID,
          "code_verifier": code_verifier,
          "client_secret": CLIENT_SECRET
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  /// 非初次登录，带着refreshToken去刷新token
  Future<Response> postRefreshAuthToken({required String refreshToken}) {
    return httpClient.post("/auth/token", data: {
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "include_policy": true
    });
  }
}
