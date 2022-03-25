import 'package:all_in_one/component/pixiv_image.dart';
import 'package:all_in_one/models/illust/illust.dart';
import 'package:flutter/material.dart';

class IllustDetail extends StatefulWidget {
  const IllustDetail({
    Key? key,
    required this.illust,
  }) : super(key: key);

  final Illust illust;

  @override
  State<IllustDetail> createState() => _IllustDetailState();
}

class _IllustDetailState extends State<IllustDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.illust.id}")),
      body: PixivImage(
        fit: BoxFit.cover,
        url: widget.illust.imageUrls!.medium!,
      ),
    );
  }
}
