import 'package:all_in_one/models/illust/illust.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class RecommandProvider extends ChangeNotifier {
  final List<Illust> _collection = <Illust>[];

  String? nextUrl;

  List<Illust> get collection => _collection;

  void addillustFromList(List<Illust> list) {
    collection.addAll(list);
    notifyListeners();
  }

  void fromResponseAdd(Response response) {
    final List<dynamic> list = response.data["illusts"];
    nextUrl = response.data["next_url"];

    for (var item in list) {
      collection.add(Illust.fromJson(item));
    }
    notifyListeners();
  }

  void clearCollection() {
    collection.clear();
    notifyListeners();
  }
}
