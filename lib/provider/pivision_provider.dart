import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:flutter/widgets.dart';

class PixivsionProvider extends ChangeNotifier {
  final List<SpotlightArticle> _collection = <SpotlightArticle>[];

  List<SpotlightArticle> get collection => _collection;

  void addillustFromList(List<SpotlightArticle> list) {
    collection.addAll(list);
    notifyListeners();
  }
}
