import 'dart:io';
import 'package:all_in_one/api/api_client.dart';
import 'package:all_in_one/api/oauth.dart';
import 'package:all_in_one/constant/hive_boxes.dart';
import 'package:all_in_one/models/models.dart';
import 'package:all_in_one/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const int _retryMaxCount = 7;

class TokenInterceptor extends Interceptor {
  // The year i typed this line.
  // Only used for initializing.
  static final _initializedDate = DateTime(2021, 3, 17, 21, 05);

  DateTime lastRefreshTokenTime = _initializedDate;

  int retryNum = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final userAccount = HiveBoxes.accountBox.get("myAccount")!;
    final result = "Bearer " + userAccount.accessToken!;
    options.headers["Authorization"] = result;

    LogUitls.d("on Request:${options.path}");
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 好不优雅
    retryNum = 0;
    return handler.next(response);
  }

  // Todo: handle token expired.
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == HttpStatus.badRequest) {
      // 处理token 过期
      if (err.response?.data["error"]["message"].contains("OAuth")) {
        // 见 Oauth_error.json 查看
        await _updateTokenIfNeed();

        try {
          RequestOptions reqOpt = err.requestOptions;
          Response response = await ApiClient().httpClient.request(
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
          LogUitls.e(e.message);
          return handler.reject(e);
        }
      }
    }

    // 处理 可能网不好吧
    if (err.message
            .contains("Connection closed before full header was received") &&
        _retryMaxCount < retryNum) {
      try {
        ++retryNum;
        RequestOptions reqOpt = err.requestOptions;
        Response response = await ApiClient().httpClient.request(
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
        LogUitls.e(e.message);
        return handler.reject(e);
      }
    }

    // 发太多请求被 ban 了
    if (err.response?.statusCode == HttpStatus.forbidden) {
      LogUitls.e(err.message);
    }

    return handler.reject(err);
  }

  // 当一个 onError 出现，可能会更新 token，在更新前可能也发出很多个请求
  // 确保只发送一个更新token 的请求
  Future<void> _updateTokenIfNeed() async {
    if (DateTime.now().difference(lastRefreshTokenTime).inSeconds > 3600) {
      lastRefreshTokenTime = DateTime.now();
      try {
        ApiClient().httpClient.lock();
        await handleAccessTokenExpired();
      } on DioError catch (e) {
        LogUitls.e(e.message);
        lastRefreshTokenTime = _initializedDate;
      } finally {
        ApiClient().httpClient.unlock();
      }
    }
  }

  // 处理access_token过期
  Future<void> handleAccessTokenExpired() async {
    LogUitls.d("On updating Token. ");
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
