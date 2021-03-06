import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/material.dart';

class IllustProvider extends ChangeNotifier {
  final List<Illust> _collection = <Illust>[];

  List<Illust> get collection => _collection;

  void addillustFromList(List<Illust> list) {
    collection.addAll(list);
    notifyListeners();
  }
}
