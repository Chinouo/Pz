import 'dart:convert';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class Util {
  static String getIsoDate() {
    DateTime dateTime = DateTime.now();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'");
    return dateFormat.format(dateTime);
  }

  static String getHash(String string) {
    var content = const Utf8Encoder().convert(string);
    var digest = md5.convert(content);
    return digest.toString();
  }
}
