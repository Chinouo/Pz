import 'dart:io';
import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/models.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:all_in_one/util/api_util.dart';

// 总是在使用 应该常驻内存
class ApiClient {
  ApiClient._internal() {
    initClient();
  }

  factory ApiClient() => _instance;

  static ApiClient get _instance {
    _apiClient ??= ApiClient._internal();
    return _apiClient!;
  }

  static ApiClient? _apiClient;

  late Dio httpClient;
  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  final String BASE_API_URL_HOST = 'app-api.pixiv.net';
  final String BASE_IMAGE_HOST = "i.pximg.net";
  final String Accept_Language = "zh-CN";

  void initClient() {
    final String time = Util.getIsoDate();

    httpClient = Dio()
      ..options.baseUrl = "https://210.140.131.199"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": Util.getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 10.0; Pixel C)",
        HttpHeaders.acceptLanguageHeader: Accept_Language,
        "App-OS": "Android",
        "App-OS-Version": "Android 10.0",
        "App-Version": "5.0.166",
        "Host": BASE_API_URL_HOST
      }
      ..interceptors.add(InterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
        String result = "Bearer " + userAccount.accessToken!;
        options.headers["Authorization"] = result;
        return handler.next(options);
      }, onError: (DioError err, handler) async {
        Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
        // TO DO: Lock
        // 返回400 一般是accessToken过期了
        if (err.response?.statusCode == 400) {
          Response response = await OAuthClient()
              .postRefreshAuthToken(refreshToken: userAccount.refreshToken!);
          String? s1 = response.data["refresh_token"];
          String? s2 = response.data["access_token"];
          if (s1 != null && s2 != null) {
            userAccount.refreshToken = s1;
            userAccount.accessToken = s2;
            HiveBoxes.accountBox.put("myAccount", userAccount);
            debugPrint("Store two new Token");
          }
        }
        debugPrint(err.toString());
      }));

    (httpClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
  }

  //
  Future<Response> getIllustRanking(String mode, String? date,
      {bool force = false}) async {
    return httpClient
        .get("/v1/illust/ranking?filter=for_android", queryParameters: {
      "mode": mode,
      "date": date,
    });
  }

  Future<Response> getNovelRanking(String mode, String? date) async {
    return httpClient.get("/v1/novel/ranking?filter=for_android",
        queryParameters: {"mode": mode, "date": date});
  }

  Future<Response> getMangaRanking(String mode, String? date) async {
    return httpClient.get("/v1/manga/ranking?filter=for_android",
        queryParameters: {"mode": mode, "date": date});
  }
}
