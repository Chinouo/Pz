import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// We want this sliver have a ability to sticky on top, and perform its
/// layout from child. We don't need parameter maxExtent etc.

// var t1 = RenderSliverPinnedPersistentHeader();
// var t2 = RenderSliverFloatingPersistentHeader();
// var t3 = RenderSliverToBoxAdapter();
// var t4 = SliverToBoxAdapter()

// 吸顶 但是 不置顶
class SliverAnimatedPersistentHeaderWidget
    extends SingleChildRenderObjectWidget {
  const SliverAnimatedPersistentHeaderWidget({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  SliverAnimatedPersistentHeaderElement createElement() =>
      SliverAnimatedPersistentHeaderElement(this);

  @override
  RenderPersistentAnimatedHeader createRenderObject(BuildContext context) =>
      RenderPersistentAnimatedHeader();
}

class RenderPersistentAnimatedHeader extends RenderSliverToBoxAdapter {
  RenderPersistentAnimatedHeader({RenderBox? child}) : super(child: child);

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }

    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        maxScrollObstructionExtent: cacheExtent,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow: true);
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    print(geometry!.visible);
    if (child != null && geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, childParentData.paintOffset);
    }
    return;
    // if (child != null && geometry!.visible) {
    //   assert(constraints.axisDirection != null);
    //   switch (applyGrowthDirectionToAxisDirection(
    //       constraints.axisDirection, constraints.growthDirection)) {
    //     case AxisDirection.up:
    //       offset += Offset(
    //           0.0,
    //           geometry!.paintExtent -
    //               childMainAxisPosition(child!) -
    //               childExtent);
    //       break;
    //     case AxisDirection.down:
    //       offset += Offset(0.0, childMainAxisPosition(child!));
    //       break;
    //     case AxisDirection.left:
    //       offset += Offset(
    //           geometry!.paintExtent -
    //               childMainAxisPosition(child!) -
    //               childExtent,
    //           0.0);
    //       break;
    //     case AxisDirection.right:
    //       offset += Offset(childMainAxisPosition(child!), 0.0);
    //       break;
    //   }
    //   context.paintChild(child!, offset);
    //}
  }
}

class SliverAnimatedPersistentHeaderElement
    extends SingleChildRenderObjectElement {
  SliverAnimatedPersistentHeaderElement(
      SliverAnimatedPersistentHeaderWidget widget)
      : super(widget);

  @override
  SliverAnimatedPersistentHeaderWidget get widget =>
      super.widget as SliverAnimatedPersistentHeaderWidget;

  @override
  RenderPersistentAnimatedHeader get renderObject =>
      super.renderObject as RenderPersistentAnimatedHeader;
}

// Solution 2
class RenderSliverAPH extends RenderSliverPersistentHeader {
  @override
  // TODO: implement maxExtent
  double get maxExtent => throw UnimplementedError();

  @override
  // TODO: implement minExtent
  double get minExtent => throw UnimplementedError();

  @override
  void performLayout() {
    // TODO: implement performLayout
  }
}
