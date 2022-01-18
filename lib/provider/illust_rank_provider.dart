import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/material.dart';

class IllustProvider extends ChangeNotifier {
  List<Illust> illustsCollection = <Illust>[];

  void updateIllustRanking(List illusts) {
    for (var illust in illusts) {
      illustsCollection.add(Illust.fromJson(illust));
    }
    notifyListeners();
  }
}
