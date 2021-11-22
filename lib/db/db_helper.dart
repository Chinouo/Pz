import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';

//单例模式
class DBHelper {
  Database db;

  DBHelper._(this.db);

  static DBHelper? _instance;

  static Future<void> initDBHelper() async {
    if (_instance == null) {
      String path = await getDatabasesPath();
      String loc = join(path, "debug.db");
      Database db = await openDatabase(loc, version: 1, onCreate: (db, _) {
        db.execute("CREATE TABLE TOKEN(refreshToken TEXT, accessToken TEXT)");
        db.insert("TOKEN", {"refreshToken": null, "accessToken": null});
      });
      _instance = DBHelper._(db);
    }
    return;
  }

  factory DBHelper.instance() {
    return _instance!;
  }

  Future<Map<String, dynamic>> getStoredToken() async {
    List result = await db.query("TOKEN");

    return result[0];
  }

  //储存Token
  Future<void> storedToken(Map<String, String> values) async {
    await db.update("TOKEN", values);
  }
}
