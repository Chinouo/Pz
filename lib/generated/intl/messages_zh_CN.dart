// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "date_asc": MessageLookupByLibrary.simpleMessage("日期升序"),
        "date_desc": MessageLookupByLibrary.simpleMessage("日期降序"),
        "exact_match_for_tags": MessageLookupByLibrary.simpleMessage("精确匹配"),
        "language": MessageLookupByLibrary.simpleMessage("简体中文"),
        "partial_match_for_tags": MessageLookupByLibrary.simpleMessage("部分匹配"),
        "popular_desc": MessageLookupByLibrary.simpleMessage("热度降序"),
        "searchSort": MessageLookupByLibrary.simpleMessage("排序方式"),
        "searchTarget": MessageLookupByLibrary.simpleMessage("标签匹配"),
        "title_and_caption": MessageLookupByLibrary.simpleMessage("摘要匹配")
      };
}
