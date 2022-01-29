//自定义顶部AppBar
import 'dart:ui';

import 'package:flutter/widgets.dart';

class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget Function(BuildContext context, double offset) _builder;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  Widget Function(BuildContext context, double offset) get builder => _builder;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.builder != builder;
  }

  PersistentHeaderBuilder(
      {required double minExtent,
      required double maxExtent,
      required Widget Function(BuildContext context, double offset) builder})
      : _maxExtent = maxExtent,
        _minExtent = minExtent,
        _builder = builder;
}

class BlurStatuBar extends StatelessWidget {
  const BlurStatuBar({
    Key? key,
    required this.titleOpacity,
    required this.statuBarColor,
  }) : super(key: key);

  final Color statuBarColor;

  final double titleOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AnimatedContainer(
        height: 100,
        color: statuBarColor,
        duration: const Duration(microseconds: 100),
        child: AnimatedOpacity(
          opacity: titleOpacity,
          duration: const Duration(milliseconds: 200),
          child: const Center(
            child: Text(
              " Rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
