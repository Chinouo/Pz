import 'dart:io';
import 'package:all_in_one/constant/search_config.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:all_in_one/util/api_util.dart';

import 'refresh_token_interceptor.dart';

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
      ..interceptors.add(
        TokenInterceptor(),
        //   InterceptorsWrapper(onRequest:
        //     (RequestOptions options, RequestInterceptorHandler handler) async {
        //   Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
        //   String result = "Bearer " + userAccount.accessToken!;
        //   options.headers["Authorization"] = result;
        //   return handler.next(options);
        // }, onError: (DioError err, handler) async {
        //   Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
        //   // TO DO: Lock
        //   // 返回400 一般是accessToken过期了
        //   if (err.response?.statusCode == 400) {
        //     Response response = await OAuthClient()
        //         .postRefreshAuthToken(refreshToken: userAccount.refreshToken!);
        //     String? s1 = response.data["refresh_token"];
        //     String? s2 = response.data["access_token"];
        //     if (s1 != null && s2 != null) {
        //       userAccount.refreshToken = s1;
        //       userAccount.accessToken = s2;
        //       HiveBoxes.accountBox.put("myAccount", userAccount);
        //       debugPrint("Store two new Token");
        //     }
        //   }
        //   debugPrint(err.toString());
        // })
      );

    (httpClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
  }

  // 默认获取当日
  Future<Response> getIllustRanking({String? mode = "day", String? date}) async {
    return httpClient.get("/v1/illust/ranking?filter=for_android", queryParameters: {
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
    return httpClient
        .get("/v1/illust/recommended?filter=for_ios&include_ranking_label=true");
  }

  // 搜索用户 返回lists
  Future<Response> getSearchUser(String word) async {
    return httpClient
        .get("/v1/search/user?filter=for_android", queryParameters: {"word": word});
  }

  //
  Future<Response> getSearchUserById(int id) async {
    return httpClient
        .get("/v1/user/detail?filter=for_android", queryParameters: {"user_id": id});
  }

  // 推荐用户
  Future<Response> getUserRecommended() async {
    return httpClient.get(
      "/v1/user/recommended?filter=for_android",
    );
  }

  // Future<Response> getUserFollowing(int user_id, String restrict) {
  //   return httpClient.get(
  //     "/v1/user/following?filter=for_android",
  //     queryParameters: {"restrict": restrict, "user_id": user_id},
  //   );
  // }

  // Future<IllustBookmarkTagsResponse> getUserBookmarkTagsIllust(int user_id,
  //     {String restrict = 'public'}) async {
  //   final result = await httpClient.get(
  //     "/v1/user/bookmark-tags/illust",
  //     queryParameters: notNullMap({"user_id": user_id, "restrict": restrict}),
  //   );
  //   return IllustBookmarkTagsResponse.fromJson(result.data);
  // }

  // 搜索下面的推荐标签 就 Gird 那些
  Future<Response> getIllustTrendTags({bool force = false}) async {
    return httpClient.get(
      "/v1/trending-tags/illust?filter=for_android",
    );
  }

  // 搜索插画  见result_illust_list.dart
  Future<Response> getSearchIllust(String word, SearchConfig config) async {
    String queryStartDate = Util.formaDate(config.startDate);
    String queryEndDate = Util.formaDate(config.endDate);

    debugPrint(config.target);

    return httpClient.get(
        "/v1/search/illust?filter=for_android&merge_plain_keyword_results=true",
        queryParameters: {
          "sort": config.sort,
          "search_target": config.target,
          "start_date": queryStartDate,
          "end_date": queryEndDate,
          "bookmark_num": config.stared,
          "word": word,
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

  // 插画详情页
  Future<Response> getIllustDetail(int illust_id) {
    return httpClient.get("/v1/illust/detail?filter=for_android",
        queryParameters: {"illust_id": illust_id});
  }

  // 插画评论区
  // May can cached using maxStale ...
  Future<Response> getIllustComments(int illustId) async {
    return httpClient.get(
      "/v3/illust/comments",
      queryParameters: {
        "illust_id": illustId,
      },
    );
  }

  Future<Response> getIllustCommentsReplies(int commentId) async {
    return httpClient.get(
      "/v2/illust/comment/replies",
      queryParameters: {
        "comment_id": commentId,
      },
    );
  }

  // May can cached using maxStale ...
  Future<Response> getIllustRelated(int illustId, {bool force = false}) async {
    return httpClient.get(
      "/v2/illust/related?filter=for_android",
      queryParameters: {
        "illust_id": illustId,
      },
    );
  }
}
