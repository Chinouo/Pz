import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/widgets.dart';

class RecommandProvider extends ChangeNotifier {
  final List<Illust> _collection = <Illust>[];

  List<Illust> get collection => _collection;

  void addillustFromList(List<Illust> list) {
    collection.addAll(list);
    notifyListeners();
  }

  void clearCollection() {
    collection.clear();
    notifyListeners();
  }
}
