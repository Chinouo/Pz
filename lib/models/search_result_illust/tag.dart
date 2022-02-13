class Tag {
  String? name;
  dynamic translatedName;

  Tag({this.name, this.translatedName});

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json['name'] as String?,
        translatedName: json['translated_name'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'translated_name': translatedName,
      };
}
