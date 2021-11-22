import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:all_in_one/db/db_helper.dart';

class DbTemplate extends StatefulWidget {
  const DbTemplate({Key? key}) : super(key: key);

  @override
  _DbTemplateState createState() => _DbTemplateState();
}

class _DbTemplateState extends State<DbTemplate> {
  late DBHelper dbHelper;
  String? Rtoken;
  String? Atoken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper.instance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Token Demo"),
      ),
      body: Column(
        children: [
          Text(Rtoken ?? "not set!"),
          Text(Atoken ?? "not set!"),
          MaterialButton(
            onPressed: () async {
              /*
              Map token = await dbHelper.getStoredToken();
              setState(() {
                Rtoken = token["refresh_tokesn"];
                Atoken = token["access_token"];
              });

              Future.error("My Error");
              */
            },
            child: Text("Update"),
          )
        ],
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ABC"),
      ),
      body: Container(
        child: Column(
          children: [
            Center(
              child: MaterialButton(
                onPressed: () async {
                  try {
                    var databasePath = await getDatabasesPath();
                    var path = join(databasePath, "debug.db");
                    db = await openDatabase(path);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: Text("Create and Connect to db"),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                var result = await db?.execute(
                    "CREATE TABLE TOKEN (refresh_token TEXT,access_token TEXT);");
              },
              child: Text("Create Table"),
            ),
            MaterialButton(
              onPressed: () async {
                Map<String, String> map = Map<String, String>();
                map["refresh_token"] = "r1";
                map["access_token"] = "a1";
                var result = await db?.insert("TOKEN", map);
              },
              child: Text("Insert data"),
            ),
            MaterialButton(
              onPressed: () async {
                var result = await db?.query("TOKEN");
                debugPrint(result.toString());
              },
              child: Text("Query"),
            ),
          ],
        ),
      ),
    );
  }
  */
}
