import 'package:hive/hive.dart';

import 'package:all_in_one/models/models.dart';

class HiveBoxes {
  HiveBoxes._();

  static late Box<Account> accountBox;

  static Account? get account => accountBox.get("myAccount");

  static Future<void> openBoxes() async {
    Hive.registerAdapter(AccountAdapter());

    await Future.wait(<Future<void>>[
      () async {
        accountBox = await Hive.openBox("userAccount");
      }()
    ]);
  }
}

class HiveAdapterTypeId {
  const HiveAdapterTypeId._();

  static const int userAccount = 0;
}
