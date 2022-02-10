import 'package:all_in_one/models/trend_tag/trend_tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class TrendTagProvider extends ChangeNotifier {
  final List<TrendTag> _collection = <TrendTag>[];

  List<TrendTag> get collection => _collection;

  void fromResponseAdd(Response response) {
    final List<dynamic> list = response.data["trend_tags"];
    for (var item in list) {
      collection.add(TrendTag.fromJson(item));
    }
    notifyListeners();
  }
}
