import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 对官方的[SliverFillViewport]进行了一些定制，配合[CustomPageView]实现了左对齐的需求。
/// This Widget Modified from [SliverFillViewport], which designed to used for [CustomPageView],
/// giving it a ability to align left.
class CustomSliverFillViewport extends StatelessWidget {
  /// Creates a sliver whose box children that each fill the viewport.
  const CustomSliverFillViewport(
      {Key? key,
      required this.delegate,
      this.viewportFraction = 1.0,
      this.paddingFraction = 1.0})
      : assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        super(key: key);

  /// Determind the size of child.
  /// 用于计算子元素大小的比例，具体为：[itemExtend] = [viewExtend] * [viewportFraction].
  final double viewportFraction;

  /// Inset pixel to both leading and trailing of [CustomPageView]'s list.
  /// 用于填充大小的比例，具体为：[paddingExtend] * 2 = [viewExtend] * [paddingFraction].
  final double paddingFraction;

  final SliverChildDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return _SliverFractionalPadding(
      viewportFraction: paddingFraction,
      sliver: _CustomSliverFillViewportRenderObjectWidget(
        viewportFraction: viewportFraction,
        delegate: delegate,
      ),
    );
  }
}

class _CustomSliverFillViewportRenderObjectWidget
    extends SliverMultiBoxAdaptorWidget {
  const _CustomSliverFillViewportRenderObjectWidget({
    Key? key,
    required SliverChildDelegate delegate,
    this.viewportFraction = 1.0,
  })  : assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        super(key: key, delegate: delegate);

  final double viewportFraction;

  @override
  RenderSliverFillViewport createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverFillViewport(
        childManager: element, viewportFraction: viewportFraction);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverFillViewport renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _SliverFractionalPadding extends SingleChildRenderObjectWidget {
  const _SliverFractionalPadding({
    this.viewportFraction = 0,
    Widget? sliver,
  })  : assert(viewportFraction != null),
        assert(viewportFraction >= 0),
        assert(viewportFraction <= 0.5),
        super(child: sliver);

  final double viewportFraction;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSliverFractionalPadding(viewportFraction: viewportFraction);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverFractionalPadding renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _RenderSliverFractionalPadding extends RenderSliverEdgeInsetsPadding {
  _RenderSliverFractionalPadding({
    double viewportFraction = 0,
  })  : assert(viewportFraction != null),
        assert(viewportFraction <= 0.5),
        assert(viewportFraction >= 0),
        _viewportFraction = viewportFraction;

  SliverConstraints? _lastResolvedConstraints;

  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double newValue) {
    assert(newValue != null);
    if (_viewportFraction == newValue) return;
    _viewportFraction = newValue;
    _markNeedsResolution();
  }

  @override
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  EdgeInsets? _resolvedPadding;

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void _resolve() {
    if (_resolvedPadding != null && _lastResolvedConstraints == constraints)
      return;

    assert(constraints.axis != null);
    final double paddingValue =
        constraints.viewportMainAxisExtent * viewportFraction;
    _lastResolvedConstraints = constraints;
    switch (constraints.axis) {
      case Axis.horizontal:
        _resolvedPadding = EdgeInsets.symmetric(horizontal: paddingValue);
        break;
      case Axis.vertical:
        _resolvedPadding = EdgeInsets.symmetric(vertical: paddingValue);
        break;
    }

    return;
  }

  @override
  void performLayout() {
    _resolve();
    super.performLayout();
  }
}
