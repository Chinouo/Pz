import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/widgets.dart';

class IllustSearchResultProvider extends ChangeNotifier {
  final _illustsStore = <Illust>[];

  List<Illust> get illustStore => _illustsStore;

  String? nextUrl;

  void clearStore() {
    illustStore.clear();
    notifyListeners();
  }

  void addStore(List<Illust> list) {
    illustStore.addAll(list);
    notifyListeners();
  }

  // 仅供submit 点击后调用
  void updateResultView() {
    notifyListeners();
  }
}
