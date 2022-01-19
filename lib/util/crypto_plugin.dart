import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class CryptoPlugin {
  static String genCodeVer() {
    const String randomKeySet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final result = List.generate(128,
            (i) => randomKeySet[Random.secure().nextInt(randomKeySet.length)])
        .join();
    return result;
  }

  static String genCodeChallenge(String codeVer) {
    final String codeVerifier = codeVer;

    final codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier)).bytes)
        .replaceAll('=', '');
    return codeChallenge;
  }
}
