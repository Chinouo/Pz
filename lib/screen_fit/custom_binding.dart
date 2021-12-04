import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui show PointerDataPacket, window;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// 下列import为自定义binding

import 'screen_fit_util.dart';

/// 参考 screen_autosize 的写法 [screen_autosize](https://github.com/CxmyDev/screen_autosize)
/// 自己修改[bindBase]不方便，需要拷贝和解耦一堆官方的Binding，比如改一下GestureBding，
/// RenderBinding的,所以只能牺牲一下[GestureBinding]的一些方法和成员。
/// 如果直接操刀Framework，动一下RenderBinding的[createViewConfiguration]
/// 以及GestureBding的[initInstances]中的注册处理回调即可。
///
/// 所以这里直接CV官方的，定制了[createViewConfiguration]
/// 和[onPointerDataPacket]回调，其余的一致。

class ScreenFitWidgetsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  @override
  ViewConfiguration createViewConfiguration() {
    return ViewConfiguration(
      size: ScreenFitUtil.instance.screenSize,
      devicePixelRatio: ScreenFitUtil.instance.devicePixelRatio!,
    );
  }

  @override
  void initInstances() {
    super.initInstances();
    window.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    // We convert pointer data to logical pixels so that e.g. the touch slop can be
    // defined in a device-independent manner.
    _pendingPointerEvents.addAll(PointerEventConverter.expand(
        packet.data, ScreenFitUtil.instance.devicePixelRatio!));
    if (!locked) _flushPointerEventQueue();
  }

  void _flushPointerEventQueue() {
    assert(!locked);

    while (_pendingPointerEvents.isNotEmpty) {
      handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) ScreenFitWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }
}

void runScreenFitApp(Widget app) {
  ScreenFitWidgetsFlutterBinding.ensureInitialized()
    // ignore: invalid_use_of_protected_member
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}
