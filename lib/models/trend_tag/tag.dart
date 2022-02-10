class Tag {
  final String? name;
  final String? translatedName;

  const Tag({this.name, this.translatedName});

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json['name'] as String?,
        translatedName: json['translated_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'translated_name': translatedName,
      };
}
