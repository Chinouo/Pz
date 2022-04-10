import 'package:all_in_one/models/account/account.dart';
import 'package:all_in_one/models/account/profile_image_urls.dart';
import 'package:all_in_one/models/account/user.dart';
import 'package:hive/hive.dart';
import 'store_boxes.dart';

// Perform like DAO Object. But actually, db never be changed in future.
// So, whatever.
class HiveBoxes {
  HiveBoxes._();

  static late Box<Account> accountBox;

  static Account? get userAccount => accountBox.get("myAccount");

  /// here are init function.
  static Future<void> openBoxes() async {
    Hive
      // Used for store login json.
      ..registerAdapter(AccountAdapter())
      ..registerAdapter(UserAdapter())
      ..registerAdapter(ProfileImageUrlsAdapter())
      // Used for user search preference.
      ..registerAdapter(SearchConfigAdapter());

    await Future.wait(<Future<void>>[
      () async {
        accountBox = await Hive.openBox("userAccount");
      }()
    ]);
  }
}
