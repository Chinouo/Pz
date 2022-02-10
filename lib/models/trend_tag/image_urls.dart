class ImageUrls {
  final String? squareMedium;
  final String? medium;
  final String? large;

  const ImageUrls({this.squareMedium, this.medium, this.large});

  factory ImageUrls.fromJson(Map<String, dynamic> json) => ImageUrls(
        squareMedium: json['square_medium'] as String?,
        medium: json['medium'] as String?,
        large: json['large'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'square_medium': squareMedium,
        'medium': medium,
        'large': large,
      };
}
