import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class LoadingMoreSliverDelegate {
  Widget builder(BuildContext context, double overscroll);

  bool shouldRebuild(LoadingMoreSliverDelegate oldDelegate);

  double get maxLayoutExtent;

  double get triggerDistance;
}

typedef RefreshCallback = Future<void> Function();

const double _kDefaultMaxLayoutExtend = 200.0;

const double _kDefaultTriggerDistance = 100.0;

class LoadingMoreSliverWithRefreshHandleDelegete extends LoadingMoreSliverDelegate {
  LoadingMoreSliverWithRefreshHandleDelegete({
    this.onRefresh,
    double maxLayoutExtent = 0,
    double triggerDistance = 0,
  })  : _maxLayoutExtent = _kDefaultMaxLayoutExtend,
        _triggerDistance = _kDefaultTriggerDistance;

  bool isTriggered = false;

  final double _maxLayoutExtent;

  final double _triggerDistance;

  RefreshCallback? onRefresh;

  @override
  bool shouldRebuild(LoadingMoreSliverDelegate oldDelegate) => true;

  @override
  double get maxLayoutExtent => _maxLayoutExtent;

  @override
  double get triggerDistance => _triggerDistance;

  @override
  Widget builder(BuildContext context, double overscroll) {
    return LayoutBuilder(builder: (context, constraints) {
      return _internalBuilder(context, overscroll);
    });
  }

  // TODO: 防抖
  Widget _internalBuilder(BuildContext context, double overscrolled) {
    if (isTriggered) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 36,
          animating: true,
        ),
      );
    }

    if (overscrolled > triggerDistance) {
      if (onRefresh != null) {
        isTriggered = true;
        onRefresh!().whenComplete(
          () => isTriggered = false,
        );
      }

      // build triggered value.
      return Container(
        color: Colors.amber,
        child: Center(child: Text("已触发")),
      );
    } else {
      final percentage = overscrolled.clamp(0, triggerDistance) / triggerDistance;
      // build widget which not triggered.
      return Center(
        child: CupertinoActivityIndicator.partiallyRevealed(
          progress: percentage,
          radius: 36 * percentage + 1,
        ),
      );
    }
  }
}

class LoadingMoreSliver extends StatelessWidget {
  const LoadingMoreSliver({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final LoadingMoreSliverWithRefreshHandleDelegete delegate;

  @override
  Widget build(BuildContext context) {
    return _LoadingMoreBottomSliver(
      delegate: delegate,
    );
  }
}

// We need a builder to offer a overscroll pixel.
// We need a delegate.
class _LoadingMoreBottomSliver extends RenderObjectWidget {
  const _LoadingMoreBottomSliver({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final LoadingMoreSliverDelegate delegate;

  @override
  _RenderLoadingMoreSliver createRenderObject(BuildContext context) {
    return _RenderLoadingMoreSliver();
  }

  @override
  _LoadingMoreBottomSliverElement createElement() =>
      _LoadingMoreBottomSliverElement(this);
}

class _LoadingMoreBottomSliverElement extends RenderObjectElement {
  _LoadingMoreBottomSliverElement(_LoadingMoreBottomSliver widget) : super(widget);

  @override
  _LoadingMoreBottomSliver get widget => super.widget as _LoadingMoreBottomSliver;

  @override
  _RenderLoadingMoreSliver get renderObject =>
      super.renderObject as _RenderLoadingMoreSliver;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject._element = this;
  }

  @override
  void unmount() {
    super.unmount();
    renderObject._element = null;
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.triggerRebuild();
  }

  @override
  void update(_LoadingMoreBottomSliver newWidget) {
    final _LoadingMoreBottomSliver oldWidget = widget;
    super.update(newWidget);
    final LoadingMoreSliverDelegate newDelegate = newWidget.delegate;
    final LoadingMoreSliverDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      renderObject.triggerRebuild();
    }
  }

  Element? child;

  void _build(double shrinkOffset) {
    owner!.buildScope(this, () {
      child = updateChild(
        child,
        widget.delegate.builder(this, shrinkOffset),
        null,
      );
    });
  }

  @override
  void forgetChild(Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, Object? slot) {
    renderObject.child = null;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) visitor(child!);
  }
}

/// This render sliver mantain a shrink offset during [performLayout].
class _RenderLoadingMoreSliver extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox>, RenderSliverHelpers {
  _RenderLoadingMoreSliver();

  _LoadingMoreBottomSliverElement? _element;

  double overscrolled = 0;

  double get maxLayoutExtent => _element!.widget.delegate.maxLayoutExtent;

  @override
  void performLayout() {
    SliverConstraints constraints = this.constraints;
    // We never call build unless user overscrolled.
    if (constraints.remainingPaintExtent < 1) {
      geometry = SliverGeometry.zero;
      return;
    }

    // calculate remain space on viewport.
    // if slivers before this one not fill the viewportExtent, this value could
    // be < 0, which means this sliver is always visiable now, in this case, we
    // never performm any load more behavior.
    double extent =
        constraints.precedingScrollExtent - constraints.viewportMainAxisExtent;

    // the total overscrolled area in viewport.
    double maxExtent = constraints.remainingPaintExtent - min(constraints.overlap, 0.0);

    if (extent <= 0) {
      // we offer overscrolled 0 to builder, but the constraint to passed to
      // child still the remainingPaintExtent. you can use this constraint
      //to custom what you want.
      overscrolled = 0;
      invokeLayoutCallback((constraints) {
        updateChild();
      });
      child?.layout(constraints.asBoxConstraints(maxExtent: maxExtent));
      debugPrint("On visiable but not perform any load behavior! ");
      geometry = SliverGeometry(
        scrollExtent: 0,
        paintExtent: maxExtent,
        maxPaintExtent: maxExtent,
      );
      return;
    }

    // here, remainingPaintExtent is overscrolled.
    overscrolled = maxExtent;
    invokeLayoutCallback((constraints) {
      updateChild();
    });
    child?.layout(constraints.asBoxConstraints(maxExtent: maxExtent),
        parentUsesSize: true);

    geometry = SliverGeometry(
        scrollExtent: min(maxExtent, maxLayoutExtent),
        paintExtent: maxExtent,
        maxPaintExtent: maxExtent);
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    return;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.size.height > 0) {
      context.paintChild(child!, offset);
    }
  }

  void updateChild() {
    _element!._build(overscrolled);
  }

  void triggerRebuild() {
    markNeedsLayout();
  }
}
