class MetaSinglePage {
  String? originalImageUrl;

  MetaSinglePage({this.originalImageUrl});

  factory MetaSinglePage.fromJson(Map<String, dynamic> json) {
    return MetaSinglePage(
      originalImageUrl: json['original_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'original_image_url': originalImageUrl,
      };
}
