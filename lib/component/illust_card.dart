import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/page/illust_detail/illust_detail.dart';
import 'package:flutter/cupertino.dart';

/// Api thumbnail offer two aspect ratios.
/// 360 x 360 or 540 x 540 , ratio = 1.
/// 600 x 1200, ratio = 2.

/// If height is  bigger than width, use ratio
class IllustCard extends StatelessWidget {
  const IllustCard({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  Widget build(BuildContext context) {
    assert(illust.height != null && illust.width != null);

    final height = illust.height!.toDouble();
    final width = illust.width!.toDouble();

    bool isLongImg = height / width > 1 ? true : false;

    final title = Text("${illust.title}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: width / height,
          child: PixivImage(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            url: illust.imageUrls!.large!,
            width: width,
            height: height,
            fit: isLongImg ? BoxFit.fitHeight : BoxFit.fitWidth,
          ),
        ),
        title
      ],
    );
  }
}
