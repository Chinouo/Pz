import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';

//单例模式
class DBHelper {
  late Database db;

  static final DBHelper _internal = DBHelper._create();

  DBHelper._create() {
    _initDB();
  }

  factory DBHelper.instance() {
    return _internal;
  }

  void _initDB() async {
    String path = await getDatabasesPath();
    String loc = join(path, "debug.db");
    db = await openDatabase(loc);
  }

  Future<Map<String, dynamic>> getStoredToken() async {
    List result = await db.query("TOKEN");
    assert(result[0] != null);
    return result[0];
  }
}
