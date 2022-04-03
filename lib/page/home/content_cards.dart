import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:all_in_one/models/spotlight_article.dart';
import 'package:flutter/cupertino.dart';

class RankIllustCard extends StatelessWidget {
  const RankIllustCard({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PixivImage(
          url: illust.imageUrls!.squareMedium!,
          fit: BoxFit.cover,
          height: 180,
        ),
        Text(
          illust.title!,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}

class PivisionCard extends StatelessWidget {
  const PivisionCard({
    Key? key,
    required this.spotlightArticle,
  }) : super(key: key);

  final SpotlightArticle spotlightArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: PixivImage(
            url: spotlightArticle.thumbnail!,
            fit: BoxFit.fitWidth,
            height: 220,
          ),
        ),
        Text(
          spotlightArticle.title!,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class RecommandIllustCard extends StatelessWidget {
  const RecommandIllustCard({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  Widget build(BuildContext context) {
    final width = illust.width!.toDouble();
    final height = illust.height!.toDouble();
    bool isLongImg = height / width > 1 ? true : false;
    return Column(
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
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Text(
                illust.title!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            const Expanded(
              flex: 1,
              child: Icon(CupertinoIcons.plus_app_fill),
            )
          ],
        )
      ],
    );
  }
}
