import 'dart:io';
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TokenInterceptor extends QueuedInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final userAccount = HiveBoxes.accountBox.get("myAccount")!;
    final result = "Bearer " + userAccount.accessToken!;
    options.headers["Authorization"] = result;
    return handler.next(options);
  }

  // Todo: handle token expired.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');

    return handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == HttpStatus.badRequest) {
      debugPrint(err.response?.data["error"]["message"].contains("OAuth").toString());
      if (err.response?.data["error"]["message"].contains("OAuth")) {
        // 见 Oauth_error.json 查看

        try {
          var apiClient = ApiClient();
          apiClient.httpClient.lock();

          await handleAccessTokenExpired();

          apiClient.httpClient.unlock();
          RequestOptions reqOpt = err.requestOptions;

          Response response = await apiClient.httpClient.request(
            reqOpt.path,
            data: reqOpt.data,
            queryParameters: reqOpt.queryParameters,
            options: Options(
              method: reqOpt.method,
              headers: reqOpt.headers,
              contentType: reqOpt.contentType,
            ),
          );
          return handler.resolve(response);
        } on DioError catch (e) {
          LogUitls.e(e.message, stackTrace: e.stackTrace);
          return handler.reject(err);
        }
      }
    }

    return handler.reject(err);
  }

  // 处理access_token过期
  Future<void> handleAccessTokenExpired() async {
    Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
    final refreshToken = userAccount.refreshToken;
    assert(refreshToken != null);
    Response response =
        await OAuthClient().postRefreshAuthToken(refreshToken: refreshToken!);
    Account freshUserData = Account.fromJson(response.data);
    HiveBoxes.accountBox.put("myAccount", freshUserData);

    LogUitls.d("A fresh Token is stored. ");
  }
}




// InterceptorsWrapper(onRequest:
//           (RequestOptions options, RequestInterceptorHandler handler) async {
//         Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
//         String result = "Bearer " + userAccount.accessToken!;
//         options.headers["Authorization"] = result;
//         return handler.next(options);
//       }, onError: (DioError err, handler) async {
//         Account userAccount = HiveBoxes.accountBox.get("myAccount")!;
//         // TO DO: Lock
//         // 返回400 一般是accessToken过期了
//         if (err.response?.statusCode == 400) {
//           Response response = await OAuthClient()
//               .postRefreshAuthToken(refreshToken: userAccount.refreshToken!);
//           String? s1 = response.data["refresh_token"];
//           String? s2 = response.data["access_token"];
//           if (s1 != null && s2 != null) {
//             userAccount.refreshToken = s1;
//             userAccount.accessToken = s2;
//             HiveBoxes.accountBox.put("myAccount", userAccount);
//             debugPrint("Store two new Token");
//           }
//         }
//         debugPrint(err.toString());
//       })
