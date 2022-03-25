import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum RefreshState {
  inactive,
  refreshing,
  done,
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
  _LoadingMoreBottomSliverElement(_LoadingMoreBottomSliver widget)
      : super(widget);

  @override
  _LoadingMoreBottomSliver get widget =>
      super.widget as _LoadingMoreBottomSliver;

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
    renderObject._element = null;
    super.unmount();
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
    if (newDelegate.runtimeType != oldDelegate.runtimeType ||
        newDelegate.shouldRebuild(oldDelegate)) {
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

  double get maxScrollExtent => _element!.widget.delegate.maxScrollExtent;

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
    double maxExtent =
        constraints.remainingPaintExtent - min(constraints.overlap, 0.0);

    if (extent <= 0) {
      // we offer overscrolled 0 to builder, but the constraint to passed to
      // child still the remainingPaintExtent. you can use this constraint
      //to custom what you want.
      overscrolled = 0;
      invokeLayoutCallback((constraints) {
        updateChild();
      });
      child?.layout(constraints.asBoxConstraints(maxExtent: maxExtent));
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
        scrollExtent: min(maxExtent, maxScrollExtent),
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

class LoadingMoreSliver extends StatefulWidget {
  const LoadingMoreSliver({
    Key? key,
    this.maxScrollExtent = _kDefaultMaxScrollExtend,
    this.triggerDistance = _kDefaultTriggerDistance,
    this.ignoreRefreshDistance = _kDefaultIgnoreDistance,
    this.onRefresh,
  }) : super(key: key);

  final double triggerDistance;

  final double maxScrollExtent;

  final double ignoreRefreshDistance;

  final RefreshCallback? onRefresh;

  @override
  State<LoadingMoreSliver> createState() => _LoadingMoreSliverState();
}

class _LoadingMoreSliverState extends State<LoadingMoreSliver> {
  late LoadingMoreSliverDelegate delegate;

  final loadingStateNotifier =
      ValueNotifier<RefreshState>(RefreshState.inactive);

  @override
  void initState() {
    super.initState();
    delegate = _LoadingMoreSliverWithRefreshHandleDelegete(
      maxScrollExtent: widget.maxScrollExtent,
      triggerDistance: widget.triggerDistance,
      ignoreRefreshDistance: widget.ignoreRefreshDistance,
      loadingStateNotifier: loadingStateNotifier,
      onRefresh: widget.onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingMoreBottomSliver(
      delegate: delegate,
    );
  }

  @override
  void didUpdateWidget(covariant LoadingMoreSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Hot restart would be better
    // delegate = _LoadingMoreSliverWithRefreshHandleDelegete(
    //   maxScrollExtent: widget.maxScrollExtent,
    //   triggerDistance: widget.triggerDistance,
    //   ignoreRefreshDistance: widget.ignoreRefreshDistance,
    //   loadingStateNotifier: loadingStateNotifier,
    //   onRefresh: widget.onRefresh,
    // );
  }
}

typedef RefreshCallback = Future<void> Function();

const double _kDefaultMaxScrollExtend = 200.0;

const double _kDefaultTriggerDistance = 100.0;

const double _kDefaultIgnoreDistance = 75;

abstract class LoadingMoreSliverDelegate {
  Widget builder(BuildContext context, double overscrolled);

  bool shouldRebuild(LoadingMoreSliverDelegate oldDelegate);

  double get maxScrollExtent;

  double get triggerDistance;
}

/// Custom Delegate, which have a state machine to handle loading more.
class _LoadingMoreSliverWithRefreshHandleDelegete
    extends LoadingMoreSliverDelegate {
  _LoadingMoreSliverWithRefreshHandleDelegete({
    required this.maxScrollExtent,
    required this.triggerDistance,
    required this.ignoreRefreshDistance,
    required this.loadingStateNotifier,
    this.onRefresh,
  });

  ValueNotifier<RefreshState> loadingStateNotifier;

  bool isTriggered = false;

  bool canTiggerNext = false;

  @override
  final double triggerDistance;

  @override
  final double maxScrollExtent;

  final double ignoreRefreshDistance;

  RefreshCallback? onRefresh;

  @override
  bool shouldRebuild(LoadingMoreSliverDelegate oldDelegate) => false;
  // oldDelegate.maxScrollExtent != maxScrollExtent ||
  // oldDelegate.triggerDistance != triggerDistance ||
  // oldDelegate.ignoreRefreshDistance != ignoreRefreshDistance ||
  // oldDelegate.loadingStateNotifier != loadingStateNotifier ||
  // onRefresh != onRefresh;

  @override
  Widget builder(BuildContext context, double overscrolled) {
    handleNextState(loadingStateNotifier, overscrolled);
    return ValueListenableBuilder<RefreshState>(
        valueListenable: loadingStateNotifier,
        builder: (context, state, child) {
          return handleStateBuild(state, overscrolled);
        });
  }

  void handleNextState(
      ValueNotifier<RefreshState> currentState, double overscrolled) {
    switch (currentState.value) {
      case RefreshState.inactive:
        if (overscrolled < triggerDistance) {
          currentState.value = RefreshState.inactive;
          break;
        }

        isTriggered = true;
        currentState.value = RefreshState.refreshing;
        onRefresh!().whenComplete(
          () {
            isTriggered = false;
            currentState.value = RefreshState.done;
          },
        );
        break;
      case RefreshState.refreshing:
        if (isTriggered) {
          currentState.value = RefreshState.refreshing;
          break;
        }
        currentState.value = RefreshState.done;
        break;
      case RefreshState.done:
        if (overscrolled < ignoreRefreshDistance) {
          // when done, wating overscroll to 0 or user make it to 0,
          // the state could be inactive, otherwise, keep
          currentState.value = RefreshState.inactive;
          break;
        }
        currentState.value = RefreshState.done;
    }
  }

  Widget handleStateBuild(RefreshState currentState, double overscrolled) {
    switch (currentState) {
      case RefreshState.inactive:
        return SizedBox(
          child: Center(
            child: Text("$overscrolled"),
          ),
        );
      case RefreshState.refreshing:
        return const Center(
          child: CupertinoActivityIndicator(
            animating: true,
            radius: 20,
          ),
        );
      case RefreshState.done:
        return const Center(
          child: Icon(Icons.done_all_outlined),
        );
    }
  }
}
