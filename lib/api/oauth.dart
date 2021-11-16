// ignore_for_file: non_constant_identifier_names, duplicate_ignore, constant_identifier_names

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import "package:dio/dio.dart";
import 'package:all_in_one/util/api_util.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

// ignore: non_constant_identifier_names
class OAuthClient {
  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";

  static const BASE_OAUTH_URL_HOST = "oauth.secure.pixiv.net";

  final String CLIENT_ID = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  final String CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";
  final String REFRESH_CLIENT_ID = "KzEZED7aC0vird8jWyHM38mXjNTY";
  final String REFRESH_CLIENT_SECRET =
      "W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP";

  final String LOGIN_URL = "https://app-api.pixiv.net/web/v1/login";

  late Dio httpClient;

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

  Future<Response> postRefreshAuthToken({required String refreshToken}) {
    return httpClient.post("/auth/token", data: {
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "include_policy": true
    });
  }

  OAuthClient() {
    String time = Util.getIsoDate();
    httpClient = Dio()
      ..options.baseUrl = "https://$BASE_OAUTH_URL_HOST"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": Util.getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
        HttpHeaders.acceptLanguageHeader: "zh-CN",
        "App-OS": "Android",
        "App-OS-Version": "Android 6.0",
        "App-Version": "5.0.166",
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
}
