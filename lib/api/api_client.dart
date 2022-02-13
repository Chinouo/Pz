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

  // 默认获取当日
  Future<Response> getIllustRanking(
      {String? mode = "day", String? date}) async {
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

  // Pixvision 的 内容 catogory 写死为 all 得了
  Future<Response> getSpotlightArticles() {
    return httpClient.get(
      "/v1/spotlight/articles?filter=for_android",
      queryParameters: {"category": "all"},
    );
  }

  // 获得推荐的插画
  Future<Response> getRecommend() async {
    return httpClient.get(
        "/v1/illust/recommended?filter=for_ios&include_ranking_label=true");
  }

  // 搜索用户 ？
  Future<Response> getSearchUser(String word) async {
    return httpClient.get("/v1/search/user?filter=for_android",
        queryParameters: {"word": word});
  }

  // 推荐用户
  Future<Response> getUserRecommended() async {
    return httpClient.get(
      "/v1/user/recommended?filter=for_android",
    );
  }

  // 搜索下面的推荐标签 就 Gird 那些
  Future<Response> getIllustTrendTags({bool force = false}) async {
    return httpClient.get(
      "/v1/trending-tags/illust?filter=for_android",
    );
  }

  // 搜索插画  见result_illust_list.dart
  Future<Response> getSearchIllust(String word,
      {String? sort,
      String? search_target,
      DateTime? start_date,
      DateTime? end_date,
      int? bookmark_num}) async {
    String? queryStartDate;
    String? queryEndDate;
    if (start_date != null) {
      queryStartDate = Util.formaDate(start_date);
    }
    if (end_date != null) {
      queryEndDate = Util.formaDate(end_date);
    }
    return httpClient.get(
        "/v1/search/illust?filter=for_android&merge_plain_keyword_results=true",
        queryParameters: {
          "sort": sort,
          "search_target": search_target,
          "start_date": queryStartDate,
          "end_date": queryEndDate,
          "bookmark_num": bookmark_num,
          "word": word
        });
  }

  // 自动补全词语？
  Future<Response> getSearchAutoCompleteKeywords(String word) async {
    final response = await httpClient.get(
      "/v2/search/autocomplete?merge_plain_keyword_results=true",
      queryParameters: {"word": word},
    );
    return response;
  }

  // 获得 next_url 的数据
  Future<Response> getNext(String nextUrl) async {
    var a = httpClient.options.baseUrl;
    String finalUrl = nextUrl.replaceAll(
        "app-api.pixiv.net", a.replaceAll(a, a.replaceFirst("https://", "")));

    debugPrint("real next url : $finalUrl");
    return httpClient.get(finalUrl);
  }
}
