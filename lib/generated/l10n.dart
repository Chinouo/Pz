// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: 'Which Language use this arb file',
      args: [],
    );
  }

  /// `Target`
  String get searchTarget {
    return Intl.message(
      'Target',
      name: 'searchTarget',
      desc: '',
      args: [],
    );
  }

  /// `Partial Match`
  String get partial_match_for_tags {
    return Intl.message(
      'Partial Match',
      name: 'partial_match_for_tags',
      desc: '',
      args: [],
    );
  }

  /// `Exact Match`
  String get exact_match_for_tags {
    return Intl.message(
      'Exact Match',
      name: 'exact_match_for_tags',
      desc: '',
      args: [],
    );
  }

  /// `Title & Caption`
  String get title_and_caption {
    return Intl.message(
      'Title & Caption',
      name: 'title_and_caption',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get searchSort {
    return Intl.message(
      'Sort',
      name: 'searchSort',
      desc: '',
      args: [],
    );
  }

  /// `Date Desc`
  String get date_desc {
    return Intl.message(
      'Date Desc',
      name: 'date_desc',
      desc: '',
      args: [],
    );
  }

  /// `Date Asc`
  String get date_asc {
    return Intl.message(
      'Date Asc',
      name: 'date_asc',
      desc: '',
      args: [],
    );
  }

  /// `Popular Desc`
  String get popular_desc {
    return Intl.message(
      'Popular Desc',
      name: 'popular_desc',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
