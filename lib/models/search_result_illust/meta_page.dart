import 'image_urls.dart';

class MetaPage {
  ImageUrls? imageUrls;

  MetaPage({this.imageUrls});

  factory MetaPage.fromJson(Map<String, dynamic> json) => MetaPage(
        imageUrls: json['image_urls'] == null
            ? null
            : ImageUrls.fromJson(json['image_urls'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'image_urls': imageUrls?.toJson(),
      };
}
