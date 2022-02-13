class ProfileImageUrls {
  String? medium;

  ProfileImageUrls({this.medium});

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) {
    return ProfileImageUrls(
      medium: json['medium'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'medium': medium,
      };
}
