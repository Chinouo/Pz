// 显示 pximg 服务器上的图片
import 'package:flutter/widgets.dart';
import 'package:extended_image/extended_image.dart';

class PixivImage extends StatelessWidget {
  const PixivImage({
    Key? key,
    required this.url,
    this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.fitWidth,
    this.borderRadius,
  }) : super(key: key);

  final String url;
  final Widget? placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: width,
      height: height,
      headers: header,
      fit: fit,
      borderRadius: borderRadius,
      shape: BoxShape.rectangle,
    );
  }

  static Map<String, String> get header => {
        "referer": "https://app-api.pixiv.net/",
        "User-Agent": "PixivIOSApp/5.8.0",
        "Host": "i.pximg.net"
      };
}
