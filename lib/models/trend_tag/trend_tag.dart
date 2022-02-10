import 'illust.dart';

class TrendTag {
  final String? tag;
  final String? translatedName;
  final Illust? illust;

  const TrendTag({this.tag, this.translatedName, this.illust});

  factory TrendTag.fromJson(Map<String, dynamic> json) => TrendTag(
        tag: json['tag'] as String?,
        translatedName: json['translated_name'] as String?,
        illust: json['illust'] == null
            ? null
            : Illust.fromJson(json['illust'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'translated_name': translatedName,
        'illust': illust?.toJson(),
      };
}
