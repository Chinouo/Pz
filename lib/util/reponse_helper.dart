import 'package:all_in_one/models/illust/illust.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

mixin IllustResponseHelper on State {
  final illusts = <Illust>[];

  String? nextUrl;

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    illusts.clear();
  }

  void storeIllusts(Response response) {
    nextUrl = response.data["next_url"];
    for (var item in response.data["illusts"]) {
      illusts.add(Illust.fromJson(item));
    }
  }
}
