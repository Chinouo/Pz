class ImageUrls {
  String? squareMedium;
  String? medium;
  String? large;
  String? original;
  ImageUrls({this.squareMedium, this.medium, this.large, this.original});

  factory ImageUrls.fromJson(Map<String, dynamic> json) => ImageUrls(
        squareMedium: json['square_medium'] as String?,
        medium: json['medium'] as String?,
        large: json['large'] as String?,
        original: json['original'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'square_medium': squareMedium,
        'medium': medium,
        'large': large,
        'original': original,
      };
}
