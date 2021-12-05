import 'dart:html';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TokenInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == HttpStatus.badRequest) {
      // lock interceptor
      if (err.message.contains("OAUTH")) {
        handleAccessTokenExpired();
      }
    }

    return handler.next(err);
  }

  // 处理access_token过期
  void handleAccessTokenExpired() {}
}
