import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class Util {
  Util._();

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

  static String formaDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }
}
