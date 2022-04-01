class ProfileImageUrls {
  String? px16x16;
  String? px50x50;
  String? px170x170;

  ProfileImageUrls({this.px16x16, this.px50x50, this.px170x170});

  factory ProfileImageUrls.fromJson(Map<String, Object?> json) {
    return ProfileImageUrls(
      px16x16: json['px_16x16'] as String?,
      px50x50: json['px_50x50'] as String?,
      px170x170: json['px_170x170'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'px_16x16': px16x16,
        'px_50x50': px50x50,
        'px_170x170': px170x170,
      };
}
